# FASE 0 — Auditoría, arquitectura y planificación

Documento de cierre de la fase 0 para la prueba técnica **Gestión de reservas de alojamiento** (PHP nativo, MySQL/MariaDB, PDO, Twig, API REST).

**Fecha de cierre:** 2026-10-17  
**Repositorio:** https://github.com/DanielNavas34/prueba-tecnica-misterPlan (privado)

---

## 1. Resumen ejecutivo

El proyecto arranca **greenfield**: no había código previo ni dependencias heredadas. Se definió una arquitectura en capas (Controller → Service → Repository), API REST con validación estricta, vistas Twig, JavaScript vanilla, pruebas PHPUnit y despliegue en hosting PHP+MySQL con `public/` como document root. El desarrollo local usará **Docker**; PHP y Composer **no están en el PATH** del host Windows, por lo que la verificación de runtime se hará en contenedor.

La fase 0 **no incluye implementación de negocio**; deja listos criterios de aceptación por fase, riesgos mitigados y decisiones documentadas para ejecutar las fases 1–8.

---

## 2. Auditoría del workspace (estado al cierre)

| Elemento | Hallazgo |
|----------|----------|
| Código PHP / SQL | **Inexistente** — pendiente Fase 1+ |
| `composer.json` | **No creado** — Fase 1 |
| Base de datos | **No creada** — Fase 2 (`database/schema.sql`) |
| Git | **Inicializado** en `main` |
| Remoto | `origin` → GitHub `DanielNavas34/prueba-tecnica-misterPlan` |
| Versionado | `.gitignore`, `.env.example`, `var/log`, `var/cache` |
| Carpetas locales (sin trackear aún) | Esqueleto orientativo: `app/`, `config/`, `public/`, `docker/`, `templates/`, `database/` |
| Secretos | `.env` excluido de Git; plantilla en `.env.example` |

**Conclusión:** no hay deuda técnica ni conflictos con código legacy; la implementación puede seguir el plan sin adaptaciones por código existente.

---

## 3. Entorno y limitaciones

Comprobaciones realizadas en el entorno de desarrollo:

| Herramienta | Estado |
|-------------|--------|
| Git | Disponible (2.48.x) |
| Docker | Disponible (29.7.x) |
| PHP (host) | **No en PATH** |
| Composer (host) | **No en PATH** |
| MySQL/MariaDB (host) | **No en PATH** |
| GitHub CLI (`gh`) | **No en PATH** (remoto configurado con `git remote`) |

**Impacto:** Fase 1 deberá incluir `docker-compose.yml` para PHP, Composer y MariaDB. PHPUnit y smoke tests HTTP se ejecutarán dentro del contenedor hasta que el host tenga PHP/Composer instalados.

**OneDrive:** el proyecto vive bajo OneDrive; `vendor/` y logs en `var/` están ignorados por Git. Si la sincronización ralentiza Composer, valorar excluir `vendor/` de OneDrive o mover el clon fuera de la carpeta sincronizada.

---

## 4. Arquitectura propuesta

Namespace PSR-4 `App\` vía Composer. Separación de responsabilidades:

- **Http:** `Router`, `Request`, `Response`, guardia de escritura API
- **Controllers:** interpretan HTTP, delegan al servicio
- **Services:** reglas de negocio, transacciones, transiciones de estado
- **Repositories:** PDO y consultas preparadas
- **Validators:** validación independiente del controlador
- **Support:** `Database`, `ErrorHandler`

**Puntos de entrada**

- `public/index.php` — rutas HTML (Twig)
- `public/api/index.php` — API JSON (mismo bootstrap, distinto enrutado)

**Solo `public/` expuesto** al servidor web (Docker nginx y hosting de producción).

---

## 5. Decisiones técnicas (fase 0)

| Tema | Decisión |
|------|----------|
| Campo «importar» del enunciado | Campo **`importe`** DECIMAL(10,2); probable errata tipográfica |
| Filtro de fechas en listado API | **Solapamiento:** reserva visible si `fecha_entrada <= to` y `fecha_salida >= from` |
| Estados | `pendiente`, `confirmada`, `cancelada`; sin reactivar cancelada vía PATCH |
| Eventos | Tabla `reserva_evento`; create y cambio de estado **atómicos** con transacción |
| `.env` | `vlucas/phpdotenv` vía Composer (justificado frente a parser casero) |
| Escritura API | Clave `API_WRITE_KEY` en cabecera; sin clave en producción → POST/PATCH **503**; GET público en demo |
| Autenticación de usuarios | **No implementada** (fuera de enunciado); documentar riesgo y mitigación |
| Docker vs hosting | Docker **solo desarrollo**; producción en hosting PHP+MySQL con document root `public/` |
| `schema.sql` | Script **autónomo** importable a mano; Docker puede usarlo solo en **primer** arranque de volumen |
| Reinicio BD Docker | `docker compose down` conserva datos; `down -v` borra volumen (documentado, uso consciente) |
| Git | Commits coherentes + push progresivo; **sin mínimo artificial** de commits; evitar coautoría no deseada en historial (atribución Cursor desactivada / commits manuales) |

---

## 6. Plan de fases y criterios de aceptación

| Fase | Objetivo | Criterio verificable (resumen) |
|------|----------|--------------------------------|
| **1** | Bootstrap, Composer, PDO, Docker, entrypoint | `docker compose up`, GET `/`, PDO con `.env` |
| **2** | `database/schema.sql` + seed | Import en BD vacía sin errores FK |
| **3** | Repository, Service, Validator, transacciones | Tests: create+evento, rollback, transiciones, sin eventos duplicados |
| **4** | API REST + códigos HTTP + write guard | curl/Postman 4 endpoints; 401/503 escritura; 422/409 |
| **5** | Twig: base, listado, detalle, formulario, errores | SSR con seed; autoescape |
| **6** | JS: filtros, create, confirm/cancel | Fetch, sin innerHTML con datos usuario |
| **7** | PHPUnit, seguridad, responsive | `composer test` en contenedor |
| **8** | README, auditoría final, despliegue | Checklist §20; URL pública solo si verificada |

En cada cierre de fase se distinguirá explícitamente: **implementado** / **probado (con evidencia)** / **pendiente**.

---

## 7. Riesgos y mitigaciones

1. **Runtime solo en Docker** — Mitigación: compose documentado; README con comandos exactos.
2. **Exposición de archivos internos** — Mitigación: document root `public/`; no desplegar si el hosting no lo permite.
3. **API de escritura abierta** — Mitigación: `API_WRITE_KEY`; 503 sin clave en producción.
4. **Inyección SQL / XSS** — Mitigación planificada: PDO preparado, Twig autoescape, validación servidor.
5. **Historial Git poco creíble** — Mitigación: unidades pequeñas, push continuo, mensajes descriptivos.
6. **Pérdida accidental de datos BD** — Mitigación: no usar `DROP DATABASE` en schema; documentar `down` vs `down -v`.

---

## 8. Criterios de aceptación — FASE 0

| Requisito | Estado |
|-----------|--------|
| Inspección del proyecto | Cumplido |
| Inventario de archivos y dependencias | Cumplido |
| Comprobación de entorno (PHP/Composer/MySQL/Docker/Git) | Cumplido (limitaciones documentadas) |
| Decisión greenfield vs adaptación | Greenfield |
| Arquitectura propuesta | Cumplido (§4) |
| Plan por fases con criterios | Cumplido (§6) |
| Riesgos identificados | Cumplido (§7) |
| Limitaciones Twig/MySQL/PHPUnit/despliegue | Cumplido (§3, §5) |
| Git y remoto preparados para trabajo incremental | Cumplido (commit inicial publicado) |

**Pruebas ejecutadas en fase 0:** ninguna de aplicación (no hay código ejecutable). **Pruebas pendientes:** todas las de fases 1–8.

---

## 9. Siguiente paso

**FASE 1** — en unidades con commit y push:

1. `composer.json` + autoload PSR-4  
2. Bootstrap, `Database`, `ErrorHandler`, configuración  
3. Docker Compose + nginx  
4. `public/index.php` (health check)
