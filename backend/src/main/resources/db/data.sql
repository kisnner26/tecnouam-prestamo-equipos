-- Datos minimos para reproducir la demostracion (mismos valores que siembra
-- DataLoader al arrancar la app). Los hashes de contrasena son BCrypt reales
-- generados con el mismo PasswordEncoder que usa Spring Security.

USE tecnouam;

INSERT INTO usuarios (username, password, rol) VALUES
    ('admin', '$2a$10$XlYit8WZO8QlIGMfsovjnOTnVv7XrCB/fulBS7KeHF3GAdICHVTBS', 'ADMIN'),
    ('instructor', '$2a$10$wS9i.RXMd/QkwECxNx4h4O.g.5TEPFM53rD3DxYB3J01x2z21wbDy', 'USER')
ON DUPLICATE KEY UPDATE username = username;

INSERT INTO equipos (codigo_patrimonial, nombre, tipo, estado) VALUES
    ('TEC-001', 'Laptop Dell Latitude 5420', 'LAPTOP', 'DISPONIBLE'),
    ('TEC-002', 'Proyector Epson PowerLite', 'PROYECTOR', 'DISPONIBLE'),
    ('TEC-003', 'Tableta Samsung Galaxy Tab A8', 'TABLETA', 'DISPONIBLE')
ON DUPLICATE KEY UPDATE codigo_patrimonial = codigo_patrimonial;

-- Credenciales de las cuentas sembradas (en texto plano, solo para referencia
-- de quien ejecute este script; en la base de datos se guarda el hash BCrypt):
--   admin / admin123        (rol ADMIN)
--   instructor / instructor123  (rol USER)
