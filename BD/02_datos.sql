-- =============================================================================
-- TecnoUAM - 02_datos.sql : datos de prueba
-- =============================================================================
-- Incluye las cuentas y los 3 equipos que siembra DataLoader al arrancar la
-- aplicacion (mismos valores), mas inventario y un historial de prestamos para
-- poder probar consultas, vistas y reportes.
--
-- El script se puede ejecutar varias veces: no duplica filas.
-- Las fechas son fijas; los prestamos "vencidos" se calculan contra CURDATE().
-- =============================================================================

USE tecnouam;

-- -----------------------------------------------------------------------------
-- Usuarios (hashes BCrypt reales, compatibles con Spring Security)
--   admin      / admin123       -> rol ADMIN
--   instructor / instructor123  -> rol USER
-- -----------------------------------------------------------------------------
INSERT INTO usuarios (username, password, rol) VALUES
    ('admin',      '$2a$10$XlYit8WZO8QlIGMfsovjnOTnVv7XrCB/fulBS7KeHF3GAdICHVTBS', 'ADMIN'),
    ('instructor', '$2a$10$wS9i.RXMd/QkwECxNx4h4O.g.5TEPFM53rD3DxYB3J01x2z21wbDy', 'USER')
AS nuevo
ON DUPLICATE KEY UPDATE username = nuevo.username;

-- -----------------------------------------------------------------------------
-- Equipos (TEC-001 a TEC-003 son los mismos que siembra DataLoader)
-- Todos entran como DISPONIBLE; el estado real se ajusta al final del script
-- segun los prestamos que queden activos.
-- -----------------------------------------------------------------------------
INSERT INTO equipos (codigo_patrimonial, nombre, tipo, estado) VALUES
    ('TEC-001', 'Laptop Dell Latitude 5420',          'LAPTOP',    'DISPONIBLE'),
    ('TEC-002', 'Proyector Epson PowerLite',          'PROYECTOR', 'DISPONIBLE'),
    ('TEC-003', 'Tableta Samsung Galaxy Tab A8',      'TABLETA',   'DISPONIBLE'),
    ('TEC-004', 'Laptop Lenovo ThinkPad E14',         'LAPTOP',    'DISPONIBLE'),
    ('TEC-005', 'Laptop HP ProBook 440 G9',           'LAPTOP',    'DISPONIBLE'),
    ('TEC-006', 'Proyector BenQ MW560',               'PROYECTOR', 'DISPONIBLE'),
    ('TEC-007', 'Tableta Apple iPad 10',              'TABLETA',   'DISPONIBLE'),
    ('TEC-008', 'Camara Canon EOS Rebel T7',          'CAMARA',    'DISPONIBLE'),
    ('TEC-009', 'Microfono inalambrico Shure BLX24',  'MICROFONO', 'DISPONIBLE'),
    ('TEC-010', 'Parlante portatil JBL Charge 5',     'PARLANTE',  'DISPONIBLE'),
    ('TEC-011', 'Monitor portatil ASUS ZenScreen 15', 'MONITOR',   'DISPONIBLE'),
    ('TEC-012', 'Kit Arduino Uno R3',                 'KIT',       'DISPONIBLE')
AS nuevo
ON DUPLICATE KEY UPDATE codigo_patrimonial = nuevo.codigo_patrimonial;

-- -----------------------------------------------------------------------------
-- Prestamos: historial (DEVUELTO) y prestamos en curso (ACTIVO)
-- Se referencia el equipo por su codigo patrimonial para no depender de los id.
-- El NOT EXISTS evita duplicar un prestamo si el script se corre otra vez.
-- -----------------------------------------------------------------------------
INSERT INTO prestamos (equipo_id, nombre_solicitante, fecha_prestamo,
                       fecha_devolucion_prevista, fecha_devolucion_real, estado)
SELECT e.id, v.solicitante, v.f_prestamo, v.f_prevista, v.f_real, v.estado
FROM (
    VALUES
        -- codigo,   solicitante,             prestamo,          prevista,          devolucion real,   estado
        ROW('TEC-001', 'Maria Fernanda Lopez', DATE '2026-08-18', DATE '2026-08-22', DATE '2026-08-21', 'DEVUELTO'),
        ROW('TEC-002', 'Carlos Mendoza',       DATE '2026-08-25', DATE '2026-08-25', DATE '2026-08-25', 'DEVUELTO'),
        ROW('TEC-004', 'Ana Gabriela Ruiz',    DATE '2026-09-01', DATE '2026-09-08', DATE '2026-09-10', 'DEVUELTO'),
        ROW('TEC-003', 'Jose Antonio Rivas',   DATE '2026-09-15', DATE '2026-09-19', DATE '2026-09-18', 'DEVUELTO'),
        ROW('TEC-008', 'Daniela Castillo',     DATE '2026-09-22', DATE '2026-09-26', DATE '2026-09-26', 'DEVUELTO'),
        ROW('TEC-001', 'Luis Alberto Garcia',  DATE '2026-10-05', DATE '2026-10-09', DATE '2026-10-12', 'DEVUELTO'),
        ROW('TEC-006', 'Sofia Martinez',       DATE '2026-10-20', DATE '2026-10-20', DATE '2026-10-20', 'DEVUELTO'),
        ROW('TEC-002', 'Andrea Solis',         DATE '2026-11-10', DATE '2026-11-14', DATE '2026-11-13', 'DEVUELTO'),
        ROW('TEC-004', 'Kevin Jose Morales',   DATE '2026-11-03', DATE '2026-11-10', NULL,              'ACTIVO'),
        ROW('TEC-005', 'Valeria Hernandez',    DATE '2026-11-12', DATE '2026-11-26', NULL,              'ACTIVO'),
        ROW('TEC-008', 'Ricardo Pineda',       DATE '2026-11-16', DATE '2026-11-20', NULL,              'ACTIVO'),
        ROW('TEC-010', 'Camila Torres',        DATE '2026-11-17', DATE '2026-11-19', NULL,              'ACTIVO')
) AS v (codigo, solicitante, f_prestamo, f_prevista, f_real, estado)
JOIN equipos e ON e.codigo_patrimonial = v.codigo
WHERE NOT EXISTS (
    SELECT 1
    FROM prestamos p
    WHERE p.equipo_id          = e.id
      AND p.fecha_prestamo     = v.f_prestamo
      AND p.nombre_solicitante = v.solicitante
)
ORDER BY v.f_prestamo;

-- -----------------------------------------------------------------------------
-- Sincroniza el estado de cada equipo con sus prestamos:
-- PRESTADO si tiene un prestamo ACTIVO, DISPONIBLE en caso contrario.
-- -----------------------------------------------------------------------------
UPDATE equipos e
SET e.estado = IF(
        EXISTS (SELECT 1 FROM prestamos p
                WHERE p.equipo_id = e.id AND p.estado = 'ACTIVO'),
        'PRESTADO', 'DISPONIBLE');
