---
name: omega-legacy
description: Use when migrating a legacy application (PHP, jQuery, old Node.js, MySQL) to a modern stack, planning a Strangler Fig migration, handling MySQL to PostgreSQL conversion, bridging old auth systems, or managing coexistence of old and new systems during transition.
user-invocable: false
---

# omega-legacy — Migrazione Legacy · Strangler Fig · MySQL→PostgreSQL

**Lingua:** Sempre italiano.
**Principio:** Una migrazione legacy reale richiede mesi, non settimane. Non fare big bang — usa il pattern Strangler Fig per migrare feature per feature con zero downtime.

## QUANDO USARE

- Migrazione da PHP/jQuery/MySQL/old Node.js a stack moderno
- Pianificazione Strangler Fig (migrazione graduale)
- Conversione MySQL → PostgreSQL
- Bridging sessioni legacy → NextAuth
- Coesistenza old system + new system durante transizione

## FLUSSO DECISIONALE

```
1. PRIMA di tutto → Inventario legacy in omega/legacy-inventory.md
   (pagine, tabelle, SP, trigger, cron, file upload, URL, auth, integrazioni)

2. Scegli strategia:
   Pochi mesi + team piccolo → Strangler Fig graduale
   Deadline stretta + sistema semplice → Cutover rapido con logout forzato

3. Configura Nginx routing ibrido (vecchio + nuovo in parallelo)

4. Migra feature in ordine: lettura → creazione → modifica → cancellazione

5. Cutover finale → legacy read-only 30 giorni → poi spento
```

## REGOLE CHIAVE

1. **Inventario PRIMA del codice** — non scrivere una riga senza conoscere tutto il sistema
2. **Strangler Fig, non big bang** — migra una feature alla volta
3. **Backup DB prima di ogni fase** — pg_dump obbligatorio
4. **Verifica count record** — originale = nuovo per ogni tabella
5. **Rollback plan documentato per ogni fase** — chi decide, procedura, max 15 minuti
6. **Session bridging testato** — utenti non devono essere disconnessi durante migrazione
7. **Redirect 301 per tutti i vecchi URL** — SEO + UX
8. **Stored procedures → application layer** — non convertire 1:1 in PostgreSQL
9. **Dual-write è complesso** — considera cutover veloce come alternativa
10. **Legacy read-only 30 giorni** dopo il cutover prima di spegnerlo

## CHECKLIST SINTETICA

- [ ] Inventario completo: pagine, tabelle, SP, trigger, cron, file upload, URL
- [ ] Strangler Fig: proxy configurato, routing ibrido testato
- [ ] MySQL→PG: conversione tipi verificata, no dati corrotti silenziosamente
- [ ] Stored procedures: tutte mappate → application layer
- [ ] Cron job: tutti migrati con equivalente moderno
- [ ] File upload: migrati in storage nuovo, path aggiornati in DB
- [ ] Session bridging: testato che utenti loggati non vengono disconnessi
- [ ] URL redirect: 301 per tutti i vecchi URL, testati con curl
- [ ] Rollback plan documentato per ogni fase
- [ ] Verifica count record: originale = nuovo per ogni tabella
- [ ] Smoke test su 10 operazioni critiche post-migrazione

## REFERENCES

Per dettagli tecnici completi, leggi:
- [references/strangler-fig.md] — inventario legacy, piano fasi, dual-write, session bridging, URL redirect, rollback, cron migration
- [references/db-migration.md] — MySQL→PostgreSQL differenze critiche, pgloader, verifica post-migrazione, stored procedures

## PATOLOGIE COMUNI — Migrazione MySQL → PostgreSQL

Questi bug si manifestano silenziosamente durante la migrazione. Verificali sempre PRIMA del cutover.

### 1. Charset: latin1 → UTF8
```sql
-- MySQL: verifica encoding attuale
SELECT CCSA.character_set_name
FROM information_schema.TABLES T, information_schema.COLLATION_CHARACTER_SET_APPLICABILITY CCSA
WHERE T.table_schema = DATABASE() AND CCSA.collation_name = T.table_collation;

-- Se latin1: converte in PostgreSQL con iconv o durante il dump
mysqldump --default-character-set=utf8mb4 database > dump.sql
-- Poi: sed -i 's/SET NAMES utf8mb4/SET NAMES utf8/' dump.sql (per pg_restore)
```

### 2. Date invalide: `0000-00-00` MySQL
```sql
-- Trova le date invalide prima della migrazione
SELECT COUNT(*) FROM tabella WHERE data_campo = '0000-00-00';

-- Strategia: converti in NULL (più sicura) o in una data sentinella
UPDATE tabella SET data_campo = NULL WHERE data_campo = '0000-00-00';

-- In PostgreSQL, `0000-00-00` non esiste — il driver si rifiuta di inserirlo
-- Configura MySQL dump con: --compatible=postgresql oppure pre-processa il file SQL
```

### 3. TINYINT(1) come boolean
```sql
-- MySQL usa TINYINT(1) per i boolean — in PostgreSQL vanno convertiti
-- Durante la migrazione verifica ogni TINYINT(1):
SELECT column_name, data_type FROM information_schema.columns
WHERE table_schema = DATABASE() AND data_type = 'tinyint';

-- In PostgreSQL, crea come BOOLEAN con cast:
CREATE TABLE prodotti (
  attivo BOOLEAN DEFAULT TRUE  -- non TINYINT
);
-- Migrazione: INSERT ... SELECT CAST(attivo AS BOOLEAN) ...
```

### 4. AUTO_INCREMENT → IDENTITY
```sql
-- MySQL:
CREATE TABLE ordini (id INT AUTO_INCREMENT PRIMARY KEY);

-- PostgreSQL (moderno, preferibile a SERIAL):
CREATE TABLE ordini (id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY);

-- ⚠️ Dopo la migrazione dati, resetta la sequence al valore massimo:
SELECT setval('ordini_id_seq', (SELECT MAX(id) FROM ordini));
-- Altrimenti il prossimo INSERT fallisce per conflitto di chiave
```

### 5. ENUM MySQL → CHECK constraint PostgreSQL
```sql
-- MySQL:
CREATE TABLE utenti (ruolo ENUM('admin','user','guest'));

-- PostgreSQL (due opzioni):
-- Opzione A — Tipo custom (meglio per molte tabelle):
CREATE TYPE ruolo_type AS ENUM ('admin', 'user', 'guest');
CREATE TABLE utenti (ruolo ruolo_type);

-- Opzione B — CHECK constraint (più flessibile):
CREATE TABLE utenti (ruolo TEXT CHECK (ruolo IN ('admin', 'user', 'guest')));
```

### 6. Collation case-insensitive
```sql
-- MySQL con _ci collation: WHERE nome = 'mario' trova anche 'Mario'
-- PostgreSQL è case-sensitive per default — le query potrebbero rompere

-- Soluzione A — citext extension:
CREATE EXTENSION IF NOT EXISTS citext;
ALTER TABLE utenti ALTER COLUMN email TYPE citext;

-- Soluzione B — LOWER() nelle query:
SELECT * FROM utenti WHERE LOWER(email) = LOWER('Mario@example.com');
-- E aggiungi indice: CREATE INDEX ON utenti (LOWER(email));
```

### 7. Checklist pre-cutover migrazione MySQL → PostgreSQL
- [ ] Charset verificato e convertito (latin1 → utf8mb4 → UTF8)
- [ ] Date `0000-00-00` convertite in NULL
- [ ] TINYINT(1) convertiti in BOOLEAN
- [ ] AUTO_INCREMENT → IDENTITY + sequences resettate ai valori MAX
- [ ] ENUM convertiti (tipo custom o CHECK)
- [ ] Query con confronti string testate in entrambe le modalità (case sensitivity)
- [ ] Stored procedures riscritte in PL/pgSQL (sintassi diversa da MySQL)
- [ ] `LIMIT x,y` convertito in `LIMIT y OFFSET x`
- [ ] `IFNULL` → `COALESCE`, `IF()` → `CASE WHEN`
- [ ] Count originale tabelle = Count dopo migrazione (verifica integrità)
