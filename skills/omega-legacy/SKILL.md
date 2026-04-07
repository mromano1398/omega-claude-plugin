---
name: omega-legacy
description: Use when migrating a legacy application (PHP, jQuery, old Node.js, MySQL) to a modern stack, planning a Strangler Fig migration, handling MySQL to PostgreSQL conversion, bridging old auth systems, or managing coexistence of old and new systems during transition.
user-invocable: false
---

# omega-legacy — Migrazione Legacy · Strangler Fig · MySQL→PostgreSQL

**Lingua:** Sempre italiano.
**Principio:** Una migrazione legacy reale richiede mesi, non settimane. Non fare big bang — usa il pattern Strangler Fig per migrare feature per feature con zero downtime.

---

## STEP 0 — INVENTARIO LEGACY (prima di pianificare qualsiasi cosa)

Prima di scrivere una riga di codice nuovo, crea `omega/legacy-inventory.md`:

```markdown
# Inventario Legacy — [timestamp]

## Pagine/Route
- /gestionale/commesse.php → descrizione
- /gestionale/articoli.php → descrizione

## DB — Tabelle principali
| Tabella | Record stimati | Critica | Note |
|---|---|---|---|
| clienti | ~5k | sì | FK da ordini |
| ordini | ~80k | sì | stored proc di fatturazione |

## Stored Procedures / Trigger / View
- sp_calcola_fattura → logica fatturazione
- trigger_aggiorna_saldo → eseguito su INSERT in pagamenti
- view_riepilogo_ordini → usata da 3 pagine

## Cron Jobs
- billing_mensile.php → 1° del mese alle 02:00
- pulizia_sessioni.php → ogni notte
- report_settimanale.php → ogni lunedì

## File Upload
- /var/www/html/uploads/ → PDF fatture, immagini prodotti
- Stima: 12GB, ~8.000 file

## Autenticazione attuale
- Tipo: [sessioni PHP / JWT custom / basic auth]
- Sessioni in: [file /tmp / MySQL / Redis]
- Cookie: PHPSESSID, durata: [X ore]

## Integrazioni Esterne
- API pagamenti: [provider]
- Email: [mail() / PHPMailer / SMTP]
- [altri servizi]

## URL Importanti (da preservare con redirect)
- /gestionale/commessa?id=123 → dovrà diventare /commesse/123
```

---

## STRANGLER FIG — Pattern di migrazione graduale

Il principio: costruisci il nuovo sistema attorno al vecchio, migra una feature alla volta, poi "strangola" il vecchio.

```
Fase 1: Reverse proxy davanti a entrambi i sistemi
         Nginx/Caddy instrada per path:
         /nuovo-modulo → Next.js (nuovo)
         /* → PHP legacy (vecchio)

Fase 2: Migra feature per feature (inizia da quelle meno rischiose)
         Mantieni i dati in sync tra i due sistemi

Fase 3: Quando 100% migrato → spegni il legacy
```

### Configurazione Nginx (routing ibrido)

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

### Piano fasi migrazione

```
1. Feature a basso rischio (solo lettura, no scrittura critica)
   → Pagine di report, liste, dashboard
   → Nessun side effect, facile da rollback

2. Feature di creazione (inserimento nuovi record)
   → Nuovo sistema scrive solo nel nuovo DB
   → Sync verso legacy tramite event / API

3. Feature di modifica/cancellazione (stato esistente)
   → Qui si complicano i dual-write
   → Richiede periodo di sync rigoroso

4. Cutover finale
   → Sposta tutto il traffico al nuovo
   → Legacy diventa read-only per 30 giorni
   → Poi spento
```

---

## DUAL-WRITE — Coesistenza DB

Quando il nuovo sistema deve scrivere dati che il legacy deve leggere (e viceversa):

```typescript
// lib/dual-write.ts — esempio: nuova commessa visibile anche al legacy
export async function creaCommessaDualWrite(data: CommessaInput) {
  return await withTransaction(async (client) => {
    // 1. Scrivi nel nuovo DB (source of truth)
    const { rows } = await client.query(
      'INSERT INTO commesse (...) VALUES (...) RETURNING id',
      [...]
    )

    // 2. Sync al legacy (best-effort, con retry)
    // Opzione A: API REST del legacy
    await fetch('http://php_legacy/api/sync/commessa', {
      method: 'POST',
      body: JSON.stringify({ ...data, new_id: rows[0].id }),
      headers: { 'X-Sync-Token': process.env.LEGACY_SYNC_TOKEN! }
    }).catch(err => {
      // Log ma non bloccare — il legacy ritroverà i dati al prossimo sync
      console.error('Legacy sync failed:', err)
      await client.query('INSERT INTO sync_queue (tipo, data) VALUES ($1, $2)',
        ['commessa', JSON.stringify(rows[0])])
    })

    return rows[0]
  })
}
```

**Nota:** Il dual-write è complesso. Valuta se puoi evitarlo facendo il cutover veloce invece.

---

## MYSQL → POSTGRESQL — Guida migrazione

### Differenze critiche (possono corrompere dati silenziosamente)

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

### Tool consigliato: pgloader

```bash
# Migrazione automatica MySQL → PostgreSQL
docker run --rm dimitri/pgloader pgloader \
  mysql://user:pass@mysql_host/source_db \
  postgresql://user:pass@pg_host/target_db

# pgloader gestisce la conversione dei tipi automaticamente
# Verifica sempre il risultato — non è perfetto su stored procedures
```

### Verifica post-migrazione

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

### Stored Procedures → Application Layer

MySQL stored procedures non si convertono 1:1 in PostgreSQL. Strategia:
1. Inventariale tutte (vedere `SHOW PROCEDURE STATUS`)
2. Per ogni SP: capire cosa fa → riscrivere come Server Action o lib function
3. Testare equivalenza di output

---

## SESSION BRIDGING — PHP → NextAuth

Problema: utenti loggati nel legacy PHP devono rimanere loggati durante la migrazione.

### Opzione A — Shared token (consigliata)

```php
// PHP legacy: genera un token temporaneo per l'utente loggato
// Quando l'utente naviga verso una route migrata
$token = bin2hex(random_bytes(32));
$pdo->prepare("INSERT INTO bridge_tokens (token, user_id, expires_at)
               VALUES (?, ?, DATE_ADD(NOW(), INTERVAL 5 MINUTE))")
    ->execute([$token, $_SESSION['user_id']]);
header("Location: https://newapp.com/bridge?token=$token");
```

```typescript
// Next.js: route /api/auth/bridge
export async function GET(req: Request) {
  const token = new URL(req.url).searchParams.get('token')
  if (!token) return redirect('/login')

  // Verifica token nel DB condiviso
  const { rows } = await query(
    'DELETE FROM bridge_tokens WHERE token = $1 AND expires_at > NOW() RETURNING user_id',
    [token]
  )
  if (!rows[0]) return redirect('/login?error=session_expired')

  // Crea sessione NextAuth per l'utente
  // ...usa signIn() con adapter custom
}
```

### Opzione B — Cutover con logout forzato

Più semplice ma richiede di avvisare gli utenti in anticipo:
- Messaggio 7 giorni prima: "Il sistema verrà aggiornato il [data]. Dovrai fare un nuovo login."
- Al cutover: invalida tutte le sessioni PHP, il nuovo sistema fa login fresco.

---

## URL REDIRECT STRATEGY

```typescript
// next.config.js — redirect permanenti (301) da vecchi URL
const redirects = [
  { source: '/gestionale/commesse', destination: '/commesse', permanent: true },
  { source: '/gestionale/commessa', destination: '/commesse/:id', permanent: true },
  { source: '/gestionale/articoli.php', destination: '/articoli', permanent: true },
  // Pattern con query param
  { source: '/gestionale/:page', destination: '/:page', permanent: true },
]
module.exports = { async redirects() { return redirects } }
```

**Verifica redirect con:**
```bash
curl -I https://mioapp.com/gestionale/commesse
# HTTP/1.1 301 → Location: https://mioapp.com/commesse
```

---

## ROLLBACK PLAN

Per ogni fase della migrazione Strangler Fig, definire il rollback PRIMA di procedere:

```markdown
## Rollback — Fase [N]: Migrazione [modulo]

**Trigger rollback:** errori > 1% · downtime > 5 min · dati inconsistenti rilevati

**Procedura (max 15 minuti):**
1. Nginx: torna a instradare /[modulo] → PHP legacy
   `nginx -s reload` dopo modifica upstream
2. Verifica che il legacy funzioni (smoke test manuale)
3. Controlla dati scritti nel nuovo DB durante la fase → sync manuale se necessario
4. Avvisa gli utenti

**Chi decide il rollback:** [nome] o [nome in assenza]
**Come comunicare agli utenti:** [canale Slack / email / banner]
```

---

## CRON JOB MIGRATION

```typescript
// Da: cronjob PHP ogni notte
// A: GitHub Actions scheduled workflow OPPURE /api/cron + cron-job.org

// app/api/cron/billing/route.ts — chiamata da cron esterno con secret
export async function POST(req: Request) {
  const authHeader = req.headers.get('authorization')
  if (authHeader !== `Bearer ${process.env.CRON_SECRET}`) {
    return new Response('Unauthorized', { status: 401 })
  }
  // ... logica billing
}

// .github/workflows/cron.yml
// on:
//   schedule:
//     - cron: '0 2 1 * *'  # 1° del mese alle 02:00
```

---

## CHECKLIST MIGRAZIONE LEGACY

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
