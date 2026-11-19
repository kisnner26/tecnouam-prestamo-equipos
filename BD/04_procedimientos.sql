-- =============================================================================
-- TecnoUAM - 04_procedimientos.sql : procedimientos almacenados
-- =============================================================================
-- Permiten operar la base directamente con SQL aplicando las mismas reglas de
-- negocio que PrestamoService y EquipoService, con los mismos mensajes de
-- error. La aplicacion no los usa: sirven para trabajo manual o demostraciones.
--
-- Cada procedimiento es atomico: si algo falla, deshace todo y devuelve el
-- error (SQLSTATE 45000 con el mensaje de la regla que no se cumplio).
--
-- Se necesita el cliente `mysql` (o Workbench) por el uso de DELIMITER.
-- =============================================================================

USE tecnouam;

DROP PROCEDURE IF EXISTS sp_registrar_prestamo;
DROP PROCEDURE IF EXISTS sp_devolver_prestamo;
DROP PROCEDURE IF EXISTS sp_eliminar_equipo;

DELIMITER $$

-- -----------------------------------------------------------------------------
-- Registra un prestamo y marca el equipo como PRESTADO.
-- Uso: CALL sp_registrar_prestamo(1, 'Juan Perez', '2026-11-18', '2026-11-25', @id);
--      SELECT @id;
-- -----------------------------------------------------------------------------
CREATE PROCEDURE sp_registrar_prestamo(
    IN  p_equipo_id         BIGINT,
    IN  p_solicitante       VARCHAR(255),
    IN  p_fecha_prestamo    DATE,
    IN  p_fecha_prevista    DATE,
    OUT p_prestamo_id       BIGINT
)
BEGIN
    DECLARE v_estado VARCHAR(20);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF p_equipo_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El equipo es obligatorio';
    END IF;
    IF p_solicitante IS NULL OR CHAR_LENGTH(TRIM(p_solicitante)) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre del solicitante es obligatorio';
    END IF;
    IF p_fecha_prestamo IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La fecha de prestamo es obligatoria';
    END IF;
    IF p_fecha_prevista IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La fecha prevista de devolucion es obligatoria';
    END IF;
    IF p_fecha_prevista < p_fecha_prestamo THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La fecha prevista de devolucion no puede ser anterior a la fecha del prestamo';
    END IF;

    START TRANSACTION;

    -- FOR UPDATE bloquea la fila del equipo hasta el COMMIT: dos llamadas
    -- simultaneas sobre el mismo equipo no pueden prestarlo dos veces.
    SELECT estado INTO v_estado
    FROM equipos
    WHERE id = p_equipo_id
    FOR UPDATE;

    IF v_estado IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Equipo no encontrado';
    END IF;
    IF v_estado = 'PRESTADO' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El equipo ya se encuentra PRESTADO';
    END IF;

    INSERT INTO prestamos (equipo_id, nombre_solicitante, fecha_prestamo,
                           fecha_devolucion_prevista, estado)
    VALUES (p_equipo_id, TRIM(p_solicitante), p_fecha_prestamo,
            p_fecha_prevista, 'ACTIVO');

    SET p_prestamo_id = LAST_INSERT_ID();

    UPDATE equipos SET estado = 'PRESTADO' WHERE id = p_equipo_id;

    COMMIT;
END$$

-- -----------------------------------------------------------------------------
-- Registra la devolucion de un prestamo y deja el equipo DISPONIBLE.
-- p_fecha es opcional: si es NULL se usa la fecha de hoy (igual que el API).
-- Uso: CALL sp_devolver_prestamo(5, NULL);
-- -----------------------------------------------------------------------------
CREATE PROCEDURE sp_devolver_prestamo(
    IN p_prestamo_id BIGINT,
    IN p_fecha       DATE
)
BEGIN
    DECLARE v_estado    VARCHAR(20);
    DECLARE v_equipo_id BIGINT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT estado, equipo_id INTO v_estado, v_equipo_id
    FROM prestamos
    WHERE id = p_prestamo_id
    FOR UPDATE;

    IF v_estado IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Prestamo no encontrado';
    END IF;
    IF v_estado = 'DEVUELTO' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El prestamo ya fue devuelto';
    END IF;

    UPDATE prestamos
    SET estado = 'DEVUELTO',
        fecha_devolucion_real = COALESCE(p_fecha, CURDATE())
    WHERE id = p_prestamo_id;

    UPDATE equipos SET estado = 'DISPONIBLE' WHERE id = v_equipo_id;

    COMMIT;
END$$

-- -----------------------------------------------------------------------------
-- Elimina un equipo y su historial de prestamos.
-- Se rechaza si el equipo tiene un prestamo ACTIVO.
-- Uso: CALL sp_eliminar_equipo(12);
-- -----------------------------------------------------------------------------
CREATE PROCEDURE sp_eliminar_equipo(
    IN p_equipo_id BIGINT
)
BEGIN
    DECLARE v_existe INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT COUNT(*) INTO v_existe
    FROM equipos
    WHERE id = p_equipo_id
    FOR UPDATE;

    IF v_existe = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Equipo no encontrado';
    END IF;

    IF EXISTS (SELECT 1 FROM prestamos
               WHERE equipo_id = p_equipo_id AND estado = 'ACTIVO') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No se puede eliminar un equipo con prestamos activos';
    END IF;

    DELETE FROM prestamos WHERE equipo_id = p_equipo_id;
    DELETE FROM equipos   WHERE id        = p_equipo_id;

    COMMIT;
END$$

DELIMITER ;
