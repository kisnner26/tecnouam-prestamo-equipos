-- =============================================================================
-- TecnoUAM - 03_vistas.sql : vistas para consultas y reportes
-- =============================================================================
-- Las vistas no modifican datos ni las usa la aplicacion; sirven para consultar
-- la informacion ya combinada (por ejemplo desde MySQL Workbench).
-- =============================================================================

USE tecnouam;

-- -----------------------------------------------------------------------------
-- Detalle de cada prestamo con los datos de su equipo y su situacion:
--   EN CURSO              prestamo activo dentro del plazo
--   VENCIDO               prestamo activo con la fecha prevista ya pasada
--   DEVUELTO A TIEMPO     se devolvio en o antes de la fecha prevista
--   DEVUELTO CON RETRASO  se devolvio despues de la fecha prevista
-- dias_retraso: dias pasados de la fecha prevista (0 si no hay retraso).
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_prestamos_detalle AS
SELECT
    p.id                         AS prestamo_id,
    e.id                         AS equipo_id,
    e.codigo_patrimonial,
    e.nombre                     AS equipo_nombre,
    e.tipo                       AS equipo_tipo,
    p.nombre_solicitante,
    p.fecha_prestamo,
    p.fecha_devolucion_prevista,
    p.fecha_devolucion_real,
    p.estado,
    CASE
        WHEN p.estado = 'ACTIVO' AND p.fecha_devolucion_prevista < CURDATE()
            THEN 'VENCIDO'
        WHEN p.estado = 'ACTIVO'
            THEN 'EN CURSO'
        WHEN p.fecha_devolucion_real > p.fecha_devolucion_prevista
            THEN 'DEVUELTO CON RETRASO'
        ELSE 'DEVUELTO A TIEMPO'
    END                          AS situacion,
    GREATEST(
        DATEDIFF(COALESCE(p.fecha_devolucion_real, CURDATE()),
                 p.fecha_devolucion_prevista),
        0)                       AS dias_retraso,
    DATEDIFF(COALESCE(p.fecha_devolucion_real, CURDATE()),
             p.fecha_prestamo)   AS dias_en_prestamo
FROM prestamos p
JOIN equipos e ON e.id = p.equipo_id;

-- -----------------------------------------------------------------------------
-- Prestamos que siguen activos (equipos fuera del inventario ahora mismo)
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_prestamos_activos AS
SELECT prestamo_id, equipo_id, codigo_patrimonial, equipo_nombre, equipo_tipo,
       nombre_solicitante, fecha_prestamo, fecha_devolucion_prevista,
       situacion, dias_retraso
FROM v_prestamos_detalle
WHERE estado = 'ACTIVO';

-- -----------------------------------------------------------------------------
-- Prestamos activos cuya fecha prevista de devolucion ya paso
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_prestamos_vencidos AS
SELECT prestamo_id, equipo_id, codigo_patrimonial, equipo_nombre,
       nombre_solicitante, fecha_prestamo, fecha_devolucion_prevista,
       dias_retraso
FROM v_prestamos_detalle
WHERE situacion = 'VENCIDO';

-- -----------------------------------------------------------------------------
-- Inventario resumido por tipo de equipo
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_inventario_por_tipo AS
SELECT
    tipo,
    COUNT(*)                     AS total,
    SUM(estado = 'DISPONIBLE')   AS disponibles,
    SUM(estado = 'PRESTADO')     AS prestados
FROM equipos
GROUP BY tipo;

-- -----------------------------------------------------------------------------
-- Uso historico de cada equipo (incluye equipos que nunca se han prestado)
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_uso_equipos AS
SELECT
    e.id                                  AS equipo_id,
    e.codigo_patrimonial,
    e.nombre,
    e.tipo,
    e.estado,
    COUNT(p.id)                           AS total_prestamos,
    COALESCE(SUM(p.estado = 'DEVUELTO' AND p.fecha_devolucion_real > p.fecha_devolucion_prevista), 0)
                                          AS devoluciones_con_retraso,
    MAX(p.fecha_prestamo)                 AS ultimo_prestamo
FROM equipos e
LEFT JOIN prestamos p ON p.equipo_id = e.id
GROUP BY e.id, e.codigo_patrimonial, e.nombre, e.tipo, e.estado;

-- -----------------------------------------------------------------------------
-- Control de integridad: equipos cuyo estado no coincide con sus prestamos.
-- Debe devolver 0 filas. Si aparece alguno, el estado del equipo quedo
-- desincronizado (por ejemplo por un UPDATE manual).
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_inconsistencias_estado AS
SELECT
    e.id                  AS equipo_id,
    e.codigo_patrimonial,
    e.estado              AS estado_registrado,
    IF(COUNT(p.id) > 0, 'PRESTADO', 'DISPONIBLE') AS estado_esperado
FROM equipos e
LEFT JOIN prestamos p ON p.equipo_id = e.id AND p.estado = 'ACTIVO'
GROUP BY e.id, e.codigo_patrimonial, e.estado
HAVING estado_registrado <> estado_esperado;
