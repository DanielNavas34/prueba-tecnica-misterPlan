# FASE 2 — Esquema y datos de demostración

## Importación manual (obligatoria en hosting / BD ya existente)

Desde la raíz del proyecto, con MariaDB/MySQL accesible:

```powershell
# Ejemplo con cliente local
mysql -h 127.0.0.1 -P 3307 -u reservas -p < database/schema.sql
```

Con Docker Compose en marcha:

```powershell
Get-Content -Raw database/schema.sql | docker compose exec -T db mariadb -uroot -pTU_ROOT_PASSWORD
```

(Ajusta `TU_ROOT_PASSWORD` al valor de `MYSQL_ROOT_PASSWORD` en tu `.env`.)

## Docker: init automático solo en volumen nuevo

Si el volumen `db_data` **ya existía** (Fase 1), MariaDB **no** vuelve a ejecutar scripts de init. Usa importación manual arriba.

Para recrear desde cero **borrando datos**:

```powershell
docker compose down -v
docker compose up -d
```

Con `docker-compose.yml` montando `database/schema.sql` en `/docker-entrypoint-initdb.d/`, el seed se carga en el primer arranque.

## Comprobaciones

```sql
USE reservas;
SELECT estado, COUNT(*) FROM reserva GROUP BY estado;
SELECT COUNT(*) FROM reserva_evento;
```

Esperado: **6** reservas (2 pendientes, 2 confirmadas, 2 canceladas) y **11** eventos.

## Reinicio sin borrado accidental

| Comando | Efecto |
|---------|--------|
| `docker compose down` | Para contenedores; **conserva** `db_data` |
| `docker compose down -v` | **Elimina** volumen y todos los datos MariaDB |
| Reimportar `schema.sql` | `DROP TABLE` dentro de `reservas`; no toca otras bases |
