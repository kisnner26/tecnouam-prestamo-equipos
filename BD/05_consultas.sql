-- =============================================================================
-- TecnoUAM - 05_consultas.sql : consultas de ejemplo
-- =============================================================================
-- Consultas utiles para revisar la base o para la defensa del proyecto.
-- Ninguna modifica datos salvo la seccion 5, que esta comentada a proposito.
-- =============================================================================

USE tecnouam;

-- 1. Lo mismo que devuelve GET /api/equipos -----------------------------------
SELECT id, codigo_patrimonial, nombre, tipo, estado
FROM equipos
ORDER BY id;

-- 2. Lo mismo que devuelve GET /api/prestamos (PrestamoResponse) ---------------
SELECT p.id,
       p.equipo_id,
       e.codigo_patrimonial AS equipo_codigo_patrimonial,
       e.nombre             AS equipo_nombre,
       p.nombre_solicitante,
       p.fecha_prestamo,
       p.fecha_devolucion_prevista,
       p.fecha_devolucion_real,
       p.estado
FROM prestamos p
JOIN equipos e ON e.id = p.equipo_id
ORDER BY p.id;

-- 3. Reportes con las vistas ---------------------------------------------------
SELECT * FROM v_prestamos_activos  ORDER BY fecha_devolucion_prevista;
SELECT * FROM v_prestamos_vencidos ORDER BY dias_retraso DESC;
SELECT * FROM v_inventario_por_tipo ORDER BY total DESC, tipo;
SELECT * FROM v_uso_equipos ORDER BY total_prestamos DESC, codigo_patrimonial;
SELECT * FROM v_inconsistencias_estado;   -- debe salir vacia

-- 4. Otras consultas -----------------------------------------------------------

-- Equipos disponibles para prestar, agrupados por tipo
SELECT tipo, GROUP_CONCAT(codigo_patrimonial ORDER BY codigo_patrimonial) AS equipos
FROM equipos
WHERE estado = 'DISPONIBLE'
GROUP BY tipo;

-- Historial de un equipo concreto
SELECT prestamo_id, nombre_solicitante, fecha_prestamo,
       fecha_devolucion_prevista, fecha_devolucion_real, situacion
FROM v_prestamos_detalle
WHERE codigo_patrimonial = 'TEC-001'
ORDER BY fecha_prestamo;

-- Solicitantes con mas prestamos y cuantas veces devolvieron tarde
SELECT nombre_solicitante,
       COUNT(*)                                   AS prestamos,
       SUM(situacion = 'DEVUELTO CON RETRASO')    AS devoluciones_tarde,
       SUM(situacion = 'VENCIDO')                 AS vencidos_ahora
FROM v_prestamos_detalle
GROUP BY nombre_solicitante
ORDER BY prestamos DESC, nombre_solicitante;

-- Prestamos por mes
SELECT DATE_FORMAT(fecha_prestamo, '%Y-%m') AS mes,
       COUNT(*)                             AS prestamos,
       ROUND(AVG(dias_en_prestamo), 1)      AS promedio_dias
FROM v_prestamos_detalle
GROUP BY mes
ORDER BY mes;

-- Porcentaje de devoluciones a tiempo
SELECT ROUND(100 * SUM(situacion = 'DEVUELTO A TIEMPO') / COUNT(*), 1)
           AS porcentaje_a_tiempo
FROM v_prestamos_detalle
WHERE estado = 'DEVUELTO';

-- Usuarios del sistema (nunca mostrar el hash)
SELECT id, username, rol FROM usuarios ORDER BY id;

-- 5. Operaciones con los procedimientos (descomentar para probar) -------------
-- CALL sp_registrar_prestamo(1, 'Juan Perez', CURDATE(), CURDATE() + INTERVAL 7 DAY, @nuevo_id);
-- SELECT @nuevo_id;
-- CALL sp_devolver_prestamo(@nuevo_id, NULL);
-- CALL sp_eliminar_equipo(12);
