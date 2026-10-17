# FASE 1 — Verificación local

## Preparación

```powershell
Copy-Item .env.example .env
# Editar .env si cambias contraseñas
```

Arrancar **Docker Desktop** y luego:

```powershell
docker run --rm -v "${PWD}:/app" -w /app composer:2 composer install --no-interaction --prefer-dist
docker compose up --build
```

## Comprobaciones

| Prueba | Comando / URL | Resultado esperado |
|--------|---------------|-------------------|
| Web health | http://localhost:8080/ | JSON `service: web`, `database: connected` |
| API health | http://localhost:8080/api/ | JSON `service: api` |
| `.env` | `git status` | No debe aparecer `.env` ni `vendor/` |

## Reinicio de datos (fase 1)

- `docker compose down` — conserva volumen MariaDB.
- `docker compose down -v` — **borra** la base de datos del contenedor.
