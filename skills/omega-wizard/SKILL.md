---
name: omega-wizard
description: Use when starting a new project (empty folder), resuming an existing project for the first time with omega, or when a BLUEPRINT.md exists. Handles 3 paths: NUOVO (5-step wizard), ESISTENTE (code analysis + gap questions), RIPRENDI (state resume). Calls omega-tier-system for design choice and omega-doc-generator for document generation.
user-invocable: false
---

# omega-wizard v4.0 — Wizard Adattivo

**Lingua:** Sempre italiano.

---

## MODALITÀ C — BLUEPRINT (priorità massima)

Se esiste `BLUEPRINT.md` nella root: il wizard è saltato completamente.

1. Leggi `BLUEPRINT.md` per intero — fonte di verità assoluta
2. Estrai: obiettivo, utenti, stack, schema DB, moduli, UX patterns, design system, scope
3. Genera direttamente tutti i documenti omega **senza fare domande** su cose già definite:
   - `omega/STRATEGY.md` — da sezioni obiettivo/utenti/competitor/differenziazione (se assenti nel BLUEPRINT, deducile dall'obiettivo; non inventare competitor ma lascia il campo "[da definire]")
   - `omega/MVP.md` — da sezione obiettivo/scope
   - `omega/PRD.md` — da sezione moduli/spec
   - `omega/design-system.md` — copia esattamente il design system dal blueprint, non inventare
   - `omega/roadmap.md` — da sezione fasi/roadmap
4. Mostra anteprima → chiedi approvazione → poi inizia codice

**Regola:** Design system definito nel blueprint → copialo esattamente, zero domande di conferma sullo stile.
**Regola STRATEGY.md in MODALITÀ C:** Estrai tutto ciò che il blueprint specifica. Per le sezioni assenti (competitor, North Star), scrivi "[da definire — usa `[PS]` per completare la strategia]" invece di inventare.

---

## RILEVAMENTO PERCORSO

Prima di iniziare, determina silenziosamente il percorso:

| Condizione | Percorso |
|---|---|
| `omega/` esiste con state.md | RIPRENDI |
| Cartella vuota o quasi, nessun src/ | PROGETTO NUOVO |
| Codice esistente, nessuna `omega/` | PROGETTO ESISTENTE |
| `BLUEPRINT.md` presente | MODALITÀ C (sopra) |
| Utente menziona reskin/redesign | → chiama `/omega:omega-reskin` |
| Utente menziona autopilot | → chiama `/omega:omega-autopilot-engine` |

**Nota:** Questi percorsi corrispondono ai Percorsi A/B/C/D in `omega/SKILL.md`.
Condizione per RIPRENDI: `omega/state.md` deve esistere (anche se altri documenti omega/ sono assenti).

---

## PERCORSO: PROGETTO NUOVO

### Step 0 — Orientamento silenzioso

Leggi (senza commentare): `package.json`, struttura root, `README.md` se presente.
Determina: cartella vuota? framework già installato? Rileva se BEGINNER dal linguaggio dell'utente.

> Se utente è BEGINNER (linguaggio non tecnico, nessun termine tecnico): chiama `/omega:omega-beginner`.

### Step 1 — Descrizione progetto

```
Descrivimi cosa vuoi costruire in 2-3 frasi.
Cosa risolve, per chi, e perché.
```

Da questa risposta omega deduce internamente:
- **TIPO**: gestionale / SaaS / e-commerce / landing / showcase / mobile / CLI / API
- **BEGINNER**: linguaggio non tecnico → `/omega:omega-beginner`

### Step 1.5 — Business Canvas (OBBLIGATORIO)

Chiama `/omega:omega-product-strategy` passando:
- tipo rilevato dallo Step 1
- descrizione progetto dell'utente
- modalità (BEGINNER / DEV)

omega-product-strategy si occupa di:
- Domande business specifiche per tipo (obiettivi, target, modello revenue)
- Analisi competitor
- Suggerimento feature proattivo
- Definizione North Star Metric
- Generazione `omega/STRATEGY.md`

**Non fare qui le domande di business** (target, competitor, revenue model) — le gestisce omega-product-strategy.
Al suo completamento, ricevi: `north_star`, `features_mvp`, `differenziazione`, `competitor_gap`, `tipo_confermato`.

### Step 2 — Livello visivo

Chiama `/omega:omega-tier-system` per configurazione completa del tier scelto.

```
Che livello di impatto visivo vuoi?

[1] FUNZIONALE   — pulito e veloce, tabelle chiare, zero distrazioni
[2] PROFESSIONALE — curato e moderno, microinterazioni, mobile-friendly
[3] CINEMATIC    — cinematografico, animazioni scroll, dark theme, font display
[4] IMMERSIVO    — esperienze 3D interattive, Three.js, effetti particellari

[STITCH] Import design esterno (URL, screenshot, DESIGN.md)
```

> Se STITCH: chiama `/omega:omega-stitch`.

> omega-tier-system riceve il tier già scelto (1/2/3/4) e fornisce la configurazione
> dettagliata (palette suggerite, librerie, regole) per quel tier — non ripete la scelta.
> Le sue domande sono di personalizzazione (es. "colore brand?"), non di selezione tier.

### Step 3 — Domande tecniche (adattive)

**BEGINNER nel wizard:** max 1 domanda tecnica (il flusso completo è in omega-beginner). **DEV:** max 3 domande tecniche.
Le domande business (target, revenue, competitor) sono già state gestite da omega-product-strategy — non ripeterle.
Fai SOLO le domande tecniche non deducibili dal contesto.

Domande tecniche disponibili (scegli le più rilevanti):
- "Il tuo prodotto serve singoli utenti o organizzazioni con più membri?" — solo se non emerso da product-strategy
    → Organizzazione (workspace): valuta omega-multitenant anche per B2C
    → Più aziende clienti: omega-multitenant obbligatorio (B2B SaaS)
- "Vincoli tecnici?" → "Cosa devo integrare? Ci sono sistemi esistenti da collegare?"
- "DB esistente?" → se sì: "Che sistema? Quante tabelle? — lo analizzo in sola lettura"
- "Tecnologie che già conosci o vuoi usare?" — rileva preferenze stack

**TRIGGER AUTOMATICO — basati sull'output di omega-product-strategy (Step 1.5)**

Questi trigger si attivano DOPO product-strategy, non ripetono domande già fatte lì.

**TRIGGER SaaS multi-tenant:**
Se product-strategy ha identificato: tipo = SaaS B2B / più organizzazioni clienti / isolamento dati richiesto:
→ Avvisa: "Hai confermato un SaaS multi-tenant. Aggiungo omega-multitenant [MT] al piano —
   gestirà isolamento dati, provisioning e tenant detection dopo la generazione documenti."
→ Passa a stack-advisor: `multitenant: true` (include PostgreSQL RLS o schema-per-tenant nella raccomandazione)

**TRIGGER SaaS con abbonamento/pagamenti:**
Se product-strategy ha identificato: modello business = Abbonamento / Freemium / E-commerce:
→ Avvisa: "Il modello richiede pagamenti. Aggiungo Stripe allo stack —
   omega-payments [PAY] gestirà webhook, abbonamenti e Customer Portal."
→ Passa a stack-advisor: `payments: stripe` (incluso automaticamente)
→ Documenta in PRD: piano Free, piano Pro, feature gate, trial period

Se il tipo è già chiarissimo dalla descrizione → salta le domande ridondanti.

### Step 3.5 — Stack tecnologico

Chiama `/omega:omega-stack-advisor` passando:
- tipo progetto rilevato
- tier scelto
- vincoli e preferenze raccolte alle Step 3
- modalità utente (BEGINNER / DEV)

omega-stack-advisor produce la raccomandazione finale dello stack.

### Step 4 — Proposta unica

```
╔═══════════════════════════════════════════════════════════╗
║  PROGETTO: [nome dedotto]                                 ║
╠═══════════════════════════════════════════════════════════╣
║  Tipo:      [tipo rilevato]                               ║
║  Tier:      [N] — [nome tier]                             ║
╠═══════════════════════════════════════════════════════════╣
║  STRATEGIA (da omega-product-strategy):                   ║
║  Target:    [cliente/utente principale]                   ║
║  North Star:[metrica principale]                          ║
║  Vantaggio: [differenziazione vs competitor]              ║
║  MVP scope: [N feature selezionate]                       ║
╠═══════════════════════════════════════════════════════════╣
║  STACK (da omega-stack-advisor):                          ║
║  Frontend:  [tecnologia]                                  ║
║  Backend:   [tecnologia o "incluso in Frontend"]          ║
║  Database:  [tecnologia]                                  ║
║  ORM/Query: [tecnologia]                                  ║
║  Auth:      [tecnologia]                                  ║
║  Deploy:    [piattaforma]                                 ║
║  [se email/pagamenti] Email: [tecn.] · Pay: [tecn.]       ║
║  Costo stimato: [range €/mese]                            ║
╠═══════════════════════════════════════════════════════════╣
║  Design:  [palette] · Font: [font]                        ║
║  Sicurezza: [livello — sempre inclusa in Fase 1]          ║
╠═══════════════════════════════════════════════════════════╣
║  [OK]      Approva → genera documenti e inizia Fase 1     ║
║  [M]       Modifica → dimmi cosa cambiare                 ║
║  [STACK]   Cambia stack → /omega:omega-stack-advisor      ║
║  [AP FULL] Approva + autopilot end-to-end                 ║
╚═══════════════════════════════════════════════════════════╝
```

### Step 5 — Generazione documenti

Su approvazione:
1. `omega/STRATEGY.md` — già generato da omega-product-strategy (Step 1.5)
2. Chiama `/omega:omega-blueprints` (architettura per tipo progetto rilevato)
3. Chiama `/omega:omega-doc-generator` → COSTRUZIONE (include STRATEGY.md come input per PRD)

---

## PERCORSO: PROGETTO ESISTENTE (prima volta omega)

### Step 0 — Analisi silenziosa profonda

Leggi (senza commentare): `package.json`, struttura `src/`, schema DB (solo lettura), route presenti, componenti, stile CSS/Tailwind esistente, `README.md`.

**RILEVAMENTO PATTERN LEGACY (silenzioso):**
Cerca nei file letti questi indicatori:
- `mysql` / `mysql2` nelle dipendenze package.json
- File PHP nella root (`*.php`, `wp-config.php`, `index.php`)
- Sessioni PHP (`express-session` + pattern session_start, o cookie `PHPSESSID`)
- Next.js `pages/` router senza `app/` (versione < 13 o migrazione non completata)
- jQuery, Backbone.js, AngularJS (non Angular moderno) nelle dipendenze
- Schema SQL con `TINYINT(1)`, `AUTO_INCREMENT`, `ENGINE=InnoDB`

SE 2 o più indicatori trovati:
  → Prima di procedere allo Step 1, avvisa:
    "Rilevo pattern legacy nel progetto: [elenco indicatori trovati].
     Consiglio di attivare omega-legacy [LEG] per una migrazione sicura.
     Procedo con l'analisi standard oppure attivo subito omega-legacy?"
  → Se l'utente conferma legacy → chiama `/omega:omega-legacy`
  → Se l'utente vuole analisi standard → procedi ma annota i rischi nei documenti generati

### Step 1 — Presenta ciò che vede

```
Dal codice vedo:
→ Stack: [stack rilevato]
→ Tipo: [tipo dedotto]
→ Moduli: [lista moduli/route trovati]
→ DB: [struttura se trovata]
→ Design: [palette/stile rilevato] → Tier stimato: [N]

È corretto? Cosa manca o è sbagliato?
```

### Step 2 — Chiedi lacune (max 3 domande)

1. "Cos'è la priorità ora?" → [Nuove feature / Fix bug / Uniformare design / Pre-lancio]
2. "Vuoi formalizzare il design com'è o cambiarlo?"
   - Se cambiare → `/omega:omega-tier-system` → scegli tier → opzionale `/omega:omega-stitch`
   - Se formalizzare → deduce tier dal codice esistente
3. "C'è qualcosa di critico non visibile nel codice?" (integrazioni esterne, vincoli business)

**Domanda aggiuntiva (solo se nessun file di test trovato in Step 0):**
"Non vedo test nel progetto. Vuoi aggiungere una suite di test mentre sviluppiamo?"
→ Se Sì: dopo la generazione documenti, aggiungi nota: "Per i test usa `/omega:omega-testing [T]`
   — consiglio di iniziare con unit test sui moduli più critici già esistenti."
→ Se No / dopo: segnala comunque `/omega:omega-testing [T]` nella roadmap generata

### Step 3 — Proposta

Stesso formato del NUOVO Step 4, ma basato sull'analisi del codice reale.

### Step 4 — Generazione documenti

Chiama `/omega:omega-doc-generator` (modalità: "dal codice reale")
→ COSTRUZIONE oppure → `/omega:omega-reskin` se l'utente vuole cambiare design

---

## PERCORSO: RIPRENDI (omega/ esiste)

### Step 0 — Leggi stato

Leggi: `omega/state.md` + `omega/autopilot-state.md` (se presente) + ultime 30 righe `omega/log.md` + piano attivo se presente.

### Step 1 — Mostra stato corrente

```
╔═══════════════════════════════════════════════════════════╗
║  Progetto: [nome]     Fase: [N]     Score: [N]/100        ║
╠═══════════════════════════════════════════════════════════╣
║  Ultimo evento: [data] — [azione]                         ║
║  Piano attivo: [nome] — step [N/M]                        ║
╠═══════════════════════════════════════════════════════════╣
║  RF completate: [N]/[M]                                   ║
╚═══════════════════════════════════════════════════════════╝
```

### Step 2 — Azione

```
Se piano attivo:
  → "Continuo da dove ero rimasto?" [Sì] [No, mostrami il menu]

Altrimenti:
  → mostra menu principale omega
```

---

## TABELLA STACK DI RIFERIMENTO

> Questa tabella è un riferimento rapido. Per raccomandazioni dettagliate e catalogo completo → `/omega:omega-stack-advisor`.

| Tipo | Stack base | Note |
|---|---|---|
| SaaS / Gestionale (CRUD) | Next.js · PostgreSQL · Prisma · Auth.js · Resend | ORM per CRUD semplice |
| SaaS con Supabase | Next.js · Supabase · Resend | Solo se serve realtime/RLS |
| Gestionale/ERP (tabelle crescono) | Next.js · PostgreSQL · **pg diretto** · Auth.js | Controllo totale query |
| Landing / Blog | Astro · Tailwind · Resend | Zero JS inutile |
| E-commerce | Next.js · PostgreSQL · Stripe · Resend | Pagamenti + ricerca |
| API pura | Hono/Express · PostgreSQL · pg diretto · OpenAPI | No frontend |
| Mobile | Expo (React Native) · Supabase | Cross-platform |
| CLI / Script | Node.js · Commander · pg diretto | Chiama `/omega:omega-cli` |

**⚠️ Prisma + RLS:** Prisma bypassa RLS PostgreSQL per default (usa service role).
Per SaaS multi-tenant con Row Level Security:
- Usare `pg` diretto per le query tenant-sensitive (quelle con `tenant_id` nel WHERE)
- Oppure configurare Prisma con un connection pooler RLS-aware (Supavisor / pgBouncer con session mode)
- Prisma va bene per CRUD semplice non-tenant (settings, configurazioni globali)

**Quando usare `pg` diretto invece di Prisma:**
- Tabelle append-only che crescono senza limite (movimenti, log, audit)
- Aggregazioni complesse (GROUP BY, window functions)
- Performance critica su query calde
- Controllo totale su transazioni complesse

**Quando usare Supabase invece di PostgreSQL puro:**
- Realtime subscriptions necessarie
- Row Level Security (RLS) come requisito
- Team conosce già Supabase
- Autenticazione OAuth senza Auth.js

---

## REGOLE OPERATIVE

1. Il wizard NON gestisce RESKIN né AUTOPILOT — delega sempre
2. Le domande sono adattive: DEV max 4, BEGINNER max 2 nel wizard (omega-beginner ha invece un flusso autonomo a 3 domande)
3. La proposta Step 4 include SEMPRE: design (palette+font) + livello sicurezza
4. I template dei documenti sono in `omega-doc-generator/references/templates.md` — non qui
5. Il DB originale non viene mai modificato — solo lettura per analisi
6. Se BLUEPRINT.md presente → MODALITÀ C ha priorità assoluta su tutto
