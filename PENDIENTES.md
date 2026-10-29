# Pendientes y plan de contingencia

Estado al 2026-10-29: la rúbrica del examen está cubierta en el repositorio
(ver README, sección "Rúbrica" discutida en el chat). Esto es lo que queda
abierto y cómo continuarlo si esta sesión se corta por límite de uso.

## 1. Colaborador `alelegh` sin invitar

`gh api repos/kisnner26/tecnouam-prestamo-equipos/collaborators/alelegh -X PUT -f permission=push`
devolvió 404: ese usuario no existe en GitHub con ese handle exacto.

**Para continuar:** confirmar con esa persona su usuario real de GitHub y correr:

```bash
gh api repos/kisnner26/tecnouam-prestamo-equipos/collaborators/<handle-correcto> -X PUT -f permission=push
```

## 2. Aportes de `drakus7` y `Oalvarado031`

Ya están invitados como colaboradores (con permiso de escritura) pero todavía
no han hecho ningún commit ni PR. La rúbrica pondera "aportes identificables
de los cinco integrantes" — esto sigue siendo el mayor riesgo de la entrega.

**Para continuar:** cada uno debe clonar el repo, crear su propia rama, y abrir
un PR con algo real (aunque sea pequeño: un test, un ajuste de validación, una
mejora de UI). Una vez abran el PR, pedirle a Claude (o a quien esté
revisando) que lo revise antes de fusionar, igual que se hizo con el de
`eaguilar0705` (PR #2).

## 3. Si hace falta que otro agente (p. ej. Codex) retome esto

Contexto que necesita para no perder tiempo repitiendo trabajo:

- Repo: `kisnner26/tecnouam-prestamo-equipos` (rama principal `master`).
- Backend: Spring Boot 4 en `backend/`, perfil `dev` usa H2 en memoria (no
  necesita instalar nada), levantar con `./mvnw spring-boot:run` desde
  `backend/`. Cuentas semilla: `admin`/`admin123` (ADMIN),
  `instructor`/`instructor123` (USER).
- Frontend: React + Vite en `frontend/`, `npm install && npm run dev`
  (puerto 5173; el backend solo permite CORS desde `localhost:5173` y
  `localhost:3000` — ver `SecurityConfig.corsConfigurationSource`).
- Colección Postman en `postman/TecnoUAM.postman_collection.json`, ya corre
  limpio (16/16) con:
  ```bash
  npx newman run postman/TecnoUAM.postman_collection.json
  ```
  Si se vuelve a tocar la colección, cuidado con nombrar una variable `data`
  en los test scripts — colisiona con una variable reservada del motor de
  Newman y rompe todos los tests con `SyntaxError`. Usar otro nombre (en esta
  colección se usa `cuerpo`).
- Evidencias ya generadas en `postman/evidencias/` (JSON, texto plano y dos
  capturas del frontend real). Si se vuelve a correr la demo, está bien
  regenerarlas pisando los mismos archivos.
- Script SQL de referencia (no se ejecuta automáticamente, es solo para
  inspección/MySQL manual) en `backend/src/main/resources/db/`.

## 4. Fuera del alcance de cualquier agente

El Reto 5 (defensa técnica) depende de que los cinco integrantes entiendan el
sistema completo y puedan explicar en vivo cualquier parte — eso no se puede
resolver con código ni con comandos.
