# TecnoUAM — Sistema de prestamo de equipos tecnologicos.

Proyecto para el examen practico integrador de Servicios Web (UAM, segundo corte).
Backend en Spring Boot + JPA + Spring Security/JWT y frontend en React + Axios.

## Estructura:

```
servicios-web-prestamos/
├── backend/     Spring Boot (API REST, JPA, seguridad JWT)
│   └── src/main/resources/db/   Script SQL de referencia (schema.sql, data.sql)
├── frontend/    React + Vite (consumo de la API)
├── docs/        Capturas de la interfaz (ver Reto 3)
└── postman/     Coleccion Postman y evidencias de ejecucion (Reto 4)
    └── evidencias/
```

## Requisitos

- Java 17+
- Maven (se incluye `mvnw`)
- Node 18+ y npm

## 1. Levantar el backend

Por defecto usa base de datos H2 en memoria (perfil `dev`), sin necesidad de instalar MySQL.

```bash
cd backend
./mvnw spring-boot:run
```

El API queda en `http://localhost:8080/api`. Al arrancar se crean automaticamente:

- Cuentas de prueba:
  - `admin` / `admin123` (rol ADMIN)
  - `instructor` / `instructor123` (rol USER)
- 3 equipos de ejemplo (`TEC-001`, `TEC-002`, `TEC-003`)

Consola H2 disponible en `http://localhost:8080/h2-console`
(JDBC URL `jdbc:h2:mem:tecnouam`, usuario `sa`, password vacio).

### Script SQL de referencia

`backend/src/main/resources/db/schema.sql` y `data.sql` reproducen manualmente
el mismo esquema y los mismos datos minimos que la app genera sola (via JPA +
`DataLoader`). Sirven para inspeccionar o recrear la base en MySQL sin levantar
la aplicacion:

```bash
mysql -u root -p < backend/src/main/resources/db/schema.sql
mysql -u root -p < backend/src/main/resources/db/data.sql
```

### Usar MySQL en lugar de H2

```bash
export APP_PROFILE=mysql
export DB_HOST=localhost
export DB_NAME=tecnouam
export DB_USER=root
export DB_PASSWORD=tu_password
cd backend
./mvnw spring-boot:run
```

### Variables de entorno relevantes (sin secretos en el repo)

| Variable | Descripcion | Default |
|---|---|---|
| `APP_PROFILE` | `dev` (H2) o `mysql` | `dev` |
| `JWT_SECRET` | Secreto HMAC para firmar los JWT | valor de desarrollo en `application.properties`, cambialo en produccion |
| `JWT_EXPIRATION_MS` | Expiracion del token en milisegundos | `3600000` (1 hora) |
| `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD` | Conexion MySQL (perfil `mysql`) | ver `application-mysql.properties` |

## 2. Levantar el frontend

```bash
cd frontend
npm install
npm run dev
```

Abrir `http://localhost:5173`. La URL del API se configura en `frontend/.env` (`VITE_API_URL`).

Inicia sesion con `instructor` / `instructor123` (o `admin` / `admin123`) y la tabla de
equipos se carga desde el endpoint protegido `GET /api/equipos` usando el JWT recibido
en el login. El boton "Actualizar" vuelve a consultar la API, util despues de crear o
prestar equipos desde Postman.

## 3. Endpoints principales

| Metodo y ruta | Rol requerido | Descripcion |
|---|---|---|
| `POST /api/auth/login` | publico | Login, devuelve JWT |
| `GET /api/equipos` | USER, ADMIN | Listar equipos |
| `GET /api/equipos/{id}` | USER, ADMIN | Consultar equipo |
| `POST /api/equipos` | ADMIN | Crear equipo (201) |
| `PUT /api/equipos/{id}` | ADMIN | Actualizar equipo |
| `DELETE /api/equipos/{id}` | ADMIN | Eliminar (409 si tiene prestamo activo) |
| `GET /api/prestamos` | USER, ADMIN | Listar prestamos |
| `POST /api/prestamos` | ADMIN | Registrar prestamo (409 si el equipo ya esta PRESTADO) |
| `PUT /api/prestamos/{id}/devolver` | ADMIN | Registrar devolucion |

Codigos usados: `200` consulta/actualizacion, `201` creacion, `204` eliminacion,
`400` datos invalidos, `401` sin token o credenciales invalidas, `403` sin permisos,
`404` recurso inexistente, `409` conflicto de reglas de negocio.

## 4. Pruebas con Postman

Importar `postman/TecnoUAM.postman_collection.json` en Postman. La coleccion ya trae,
en orden, las 16 solicitudes que cubren el Reto 4: login, CRUD de equipos, prestamo,
intento de doble prestamo (409), devolucion, eliminacion permitida/bloqueada y los
casos 401/403. Cada request incluye un test automatico que valida el codigo HTTP
esperado.

### Evidencia de ejecucion

La coleccion ya se corrio contra el backend real (con `newman`, el runner de
linea de comandos de Postman) y los resultados quedaron en `postman/evidencias/`:

- `resultado-ejecucion.json` — reporte completo (16/16 solicitudes, 16/16 tests, 0 fallos)
- `resultado-ejecucion.txt` — misma corrida en texto plano, igual de legible sin abrir Postman
- `capturas/01-login.jpg` y `capturas/02-catalogo.jpg` — capturas reales del frontend contra la API

Para volver a generar la evidencia (con el backend corriendo en `:8080`):

```bash
npx newman run postman/TecnoUAM.postman_collection.json \
  --reporters cli,json \
  --reporter-json-export postman/evidencias/resultado-ejecucion.json
```

## 5. Equipo

Repositorio compartido, con colaboradores (GitHub) invitados con permiso de
escritura para que cada integrante registre su propio trabajo con commits y
pull requests identificables:

| Integrante (usuario GitHub) | Aporte |
|---|---|
| `kisnner26` | Backend (API, JPA, JWT, reglas de negocio), estructura del proyecto |
| `eaguilar0705` | Rediseño de interfaz: login y catalogo de equipos (ver PR #2) |
| `drakus7` | — |
| `Oalvarado031` | — |
| `alelegh` | — *(invitacion pendiente: el usuario de GitHub no aparece con ese nombre exacto; confirmar el handle correcto)* |

## 6. Notas de arquitectura

- `Equipo` y `Prestamo` son entidades JPA independientes relacionadas por
  `Prestamo.equipo` (`@ManyToOne`).
- Las reglas de negocio (no prestar un equipo ya PRESTADO, no eliminar con prestamo
  activo, fecha de devolucion no anterior a la fecha de prestamo) viven en la capa de
  servicio (`EquipoService`, `PrestamoService`), no en los controladores.
- La seguridad usa JWT firmado (HMAC) sin sesiones de servidor (`SessionCreationPolicy.STATELESS`),
  con un filtro (`JwtAuthFilter`) que valida el token en cada peticion.
- `GlobalExceptionHandler` centraliza los codigos de error (400/401/403/404/409/500).
