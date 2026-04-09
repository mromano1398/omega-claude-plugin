# DB Migration — MySQL → PostgreSQL

## Differenze critiche (possono corrompere dati silenziosamente)

| MySQL | PostgreSQL | Azione |
|---|---|---|
| `TINYINT(1)` = boolean | `BOOLEAN` | Converti: `CASE WHEN col=1 THEN TRUE ELSE FALSE END` |
| `DATETIME` senza timezone | `TIMESTAMP WITH TIME ZONE` | Decidi la timezone aziendale, converti |
| `GROUP BY` permissivo | `GROUP BY` strict | Aggiungi tutte le colonne non aggregate |
| `utf8mb4` | `UTF8` | Verifica encoding, specialmente emoji |
| `AUTO_INCREMENT` | `SERIAL` o `BIGSERIAL` | Aggiorna sequence al valore MAX+1 |
| `ENUM('a','b')` | `TEXT CHECK (col IN ('a','b'))` | Converti |
| `IFNULL(x, y)` | `COALESCE(x, y)` | Trova e sostituisci |
| `STR_TO_DATE(s, fmt)` | `TO_DATE(s, fmt)` | Formati diversi |
| `LIMIT x, y` | `LIMIT y OFFSET x` | Riordina parametri |
| `GROUP_CONCAT()` | `STRING_AGG()` | Sostituisci |

## Tool consigliato: pgloader

```bash
# Migrazione automatica MySQL → PostgreSQL
docker run --rm dimitri/pgloader pgloader \
  mysql://user:pass@mysql_host/source_db \
  postgresql://user:pass@pg_host/target_db

# pgloader gestisce la conversione dei tipi automaticamente
# Verifica sempre il risultato — non è perfetto su stored procedures
```

## Verifica post-migrazione

```sql
-- Conta record per ogni tabella (confronta con MySQL)
SELECT schemaname, tablename, n_live_tup
FROM pg_stat_user_tables
ORDER BY n_live_tup DESC;

-- Verifica FK consistency
SELECT conname, conrelid::regclass, confrelid::regclass
FROM pg_constraint WHERE contype = 'f';

-- Sample check: confronta 100 record random tra MySQL e PG
```

## Stored Procedures → Application Layer

MySQL stored procedures non si convertono 1:1 in PostgreSQL. Strategia:
1. Inventariale tutte (vedere `SHOW PROCEDURE STATUS`)
2. Per ogni SP: capire cosa fa → riscrivere come Server Action o lib function
3. Testare equivalenza di output

## Nginx Routing Ibrido (Strangler Fig)

```nginx
server {
    listen 443 ssl;
    server_name mioapp.com;

    # Nuove sezioni già migrate → Next.js
    location /commesse { proxy_pass http://nextjs:3000; }
    location /articoli  { proxy_pass http://nextjs:3000; }
    location /api/v2    { proxy_pass http://nextjs:3000; }

    # Tutto il resto → PHP legacy
    location / {
        proxy_pass http://php_legacy:80;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```
