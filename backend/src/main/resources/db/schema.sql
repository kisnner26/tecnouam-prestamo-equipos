-- Script de referencia para crear el esquema en MySQL manualmente.
-- La aplicacion genera estas mismas tablas de forma automatica (JPA/Hibernate,
-- ddl-auto=update) al arrancar; este script sirve para inspeccionar o recrear
-- la base de datos fuera de la app, tal como pide el enunciado del examen.

CREATE DATABASE IF NOT EXISTS tecnouam
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE tecnouam;

CREATE TABLE IF NOT EXISTS usuarios (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    rol VARCHAR(20) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS equipos (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    codigo_patrimonial VARCHAR(30) NOT NULL UNIQUE,
    nombre VARCHAR(255) NOT NULL,
    tipo VARCHAR(255) NOT NULL,
    estado VARCHAR(20) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS prestamos (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    equipo_id BIGINT NOT NULL,
    nombre_solicitante VARCHAR(255) NOT NULL,
    fecha_prestamo DATE NOT NULL,
    fecha_devolucion_prevista DATE NOT NULL,
    fecha_devolucion_real DATE NULL,
    estado VARCHAR(20) NOT NULL,
    CONSTRAINT fk_prestamo_equipo FOREIGN KEY (equipo_id) REFERENCES equipos(id)
) ENGINE=InnoDB;
