-- =============================================================================
-- TecnoUAM - Sistema de prestamo de equipos tecnologicos
-- 01_esquema.sql : base de datos, tablas, restricciones e indices
-- Motor: MySQL 8.0.19 o superior (CHECK, VALUES ROW e INSERT ... AS alias)
-- =============================================================================
-- Las tablas y columnas son exactamente las que mapean las entidades JPA del
-- backend (Usuario, Equipo, Prestamo), con la estrategia de nombres por defecto
-- de Spring Boot (camelCase -> snake_case). Asi la aplicacion puede trabajar
-- sobre esta base con el perfil `mysql` sin cambiar nada del codigo.
--
-- Ademas de lo que genera Hibernate, este script agrega restricciones a nivel
-- de base de datos que replican las reglas de negocio de la capa de servicio:
--   * Los estados solo admiten los valores de los enums Java.
--   * La fecha prevista de devolucion no puede ser anterior a la del prestamo.
--   * Un prestamo DEVUELTO tiene fecha de devolucion real; uno ACTIVO no.
--   * Un equipo no puede tener dos prestamos ACTIVOS al mismo tiempo.
--   * No se puede borrar un equipo que tenga prestamos registrados (FK).
--
-- Ejecutar sobre una base vacia (ver README.md). Si la aplicacion ya creo las
-- tablas, borra primero la base para que se apliquen estas restricciones.
-- =============================================================================

CREATE DATABASE IF NOT EXISTS tecnouam
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE tecnouam;

-- -----------------------------------------------------------------------------
-- usuarios: cuentas que inician sesion en el API (entidad Usuario)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS usuarios (
    id        BIGINT       NOT NULL AUTO_INCREMENT,
    username  VARCHAR(255) NOT NULL,
    password  VARCHAR(255) NOT NULL COMMENT 'Hash BCrypt, nunca texto plano',
    rol       VARCHAR(20)  NOT NULL COMMENT 'Enum Rol: USER | ADMIN',

    CONSTRAINT pk_usuarios          PRIMARY KEY (id),
    CONSTRAINT uk_usuarios_username UNIQUE (username),
    CONSTRAINT ck_usuarios_rol      CHECK (rol IN ('USER', 'ADMIN')),
    CONSTRAINT ck_usuarios_username CHECK (CHAR_LENGTH(TRIM(username)) > 0)
) ENGINE = InnoDB
  COMMENT = 'Usuarios del sistema y su rol de acceso';

-- -----------------------------------------------------------------------------
-- equipos: inventario de equipos prestables (entidad Equipo)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS equipos (
    id                 BIGINT       NOT NULL AUTO_INCREMENT,
    codigo_patrimonial VARCHAR(30)  NOT NULL COMMENT 'Codigo de inventario, ej. TEC-001',
    nombre             VARCHAR(255) NOT NULL,
    tipo               VARCHAR(255) NOT NULL COMMENT 'LAPTOP, PROYECTOR, TABLETA, ...',
    estado             VARCHAR(20)  NOT NULL DEFAULT 'DISPONIBLE'
                                    COMMENT 'Enum EstadoEquipo: DISPONIBLE | PRESTADO',

    CONSTRAINT pk_equipos             PRIMARY KEY (id),
    CONSTRAINT uk_equipos_codigo      UNIQUE (codigo_patrimonial),
    CONSTRAINT ck_equipos_estado      CHECK (estado IN ('DISPONIBLE', 'PRESTADO')),
    CONSTRAINT ck_equipos_codigo      CHECK (CHAR_LENGTH(TRIM(codigo_patrimonial)) > 0),
    CONSTRAINT ck_equipos_nombre      CHECK (CHAR_LENGTH(TRIM(nombre)) > 0),
    CONSTRAINT ck_equipos_tipo        CHECK (CHAR_LENGTH(TRIM(tipo)) > 0),

    INDEX idx_equipos_estado (estado),
    INDEX idx_equipos_tipo   (tipo)
) ENGINE = InnoDB
  COMMENT = 'Inventario de equipos tecnologicos';

-- -----------------------------------------------------------------------------
-- prestamos: prestamos y devoluciones de equipos (entidad Prestamo)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS prestamos (
    id                        BIGINT       NOT NULL AUTO_INCREMENT,
    equipo_id                 BIGINT       NOT NULL,
    nombre_solicitante        VARCHAR(255) NOT NULL,
    fecha_prestamo            DATE         NOT NULL,
    fecha_devolucion_prevista DATE         NOT NULL,
    fecha_devolucion_real     DATE         NULL     COMMENT 'Se llena al registrar la devolucion',
    estado                    VARCHAR(20)  NOT NULL DEFAULT 'ACTIVO'
                                           COMMENT 'Enum EstadoPrestamo: ACTIVO | DEVUELTO',

    -- Columna calculada (no la usa JPA): vale equipo_id solo mientras el
    -- prestamo esta ACTIVO y NULL cuando se devuelve. Como el indice UNIQUE
    -- ignora los NULL, garantiza que cada equipo tenga como maximo un
    -- prestamo activo, aun si dos peticiones llegan al mismo tiempo.
    equipo_activo_id BIGINT AS (IF(estado = 'ACTIVO', equipo_id, NULL)) STORED
                     COMMENT 'Auxiliar: un solo prestamo ACTIVO por equipo',

    CONSTRAINT pk_prestamos PRIMARY KEY (id),
    CONSTRAINT fk_prestamo_equipo
        FOREIGN KEY (equipo_id) REFERENCES equipos (id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,
    CONSTRAINT uk_prestamos_equipo_activo UNIQUE (equipo_activo_id),
    CONSTRAINT ck_prestamos_estado
        CHECK (estado IN ('ACTIVO', 'DEVUELTO')),
    CONSTRAINT ck_prestamos_solicitante
        CHECK (CHAR_LENGTH(TRIM(nombre_solicitante)) > 0),
    CONSTRAINT ck_prestamos_fecha_prevista
        CHECK (fecha_devolucion_prevista >= fecha_prestamo),
    CONSTRAINT ck_prestamos_devolucion_coherente
        CHECK (   (estado = 'ACTIVO'   AND fecha_devolucion_real IS NULL)
               OR (estado = 'DEVUELTO' AND fecha_devolucion_real IS NOT NULL)),

    -- Consultas del backend: existsByEquipoAndEstado / findByEquipoAndEstado
    INDEX idx_prestamos_equipo_estado (equipo_id, estado),
    -- Reportes de prestamos activos / vencidos
    INDEX idx_prestamos_estado_prevista (estado, fecha_devolucion_prevista),
    INDEX idx_prestamos_fecha (fecha_prestamo)
) ENGINE = InnoDB
  COMMENT = 'Prestamos de equipos y su devolucion';
