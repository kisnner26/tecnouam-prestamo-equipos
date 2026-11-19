-- =============================================================================
-- TecnoUAM - instalar_todo.sql
-- Ejecuta todos los scripts en orden. Correr desde esta misma carpeta:
--     mysql -u root -p < instalar_todo.sql
-- (SOURCE busca los archivos en la carpeta desde donde se llama a mysql.)
-- =============================================================================

SOURCE 01_esquema.sql;
SOURCE 02_datos.sql;
SOURCE 03_vistas.sql;
SOURCE 04_procedimientos.sql;
