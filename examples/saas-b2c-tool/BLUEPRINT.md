# BLUEPRINT — Focusly

> Esempio di BLUEPRINT.md per un SaaS B2C di produttività.

---

## Progetto

**Nome:** Focusly
**Tipo:** SaaS B2C
**Descrizione:** Tool di produttività personale con timer Pomodoro, task management e analytics delle sessioni di lavoro. Abbonamento mensile con piano free limitato.

**Utenti target:**
- Freelancer e professionisti che lavorano da remoto
- Studenti universitari

**Modello di business:** freemium — piano free (5 task/giorno) + Pro €8/mese (illimitato + analytics)

---

## Stack

**Frontend:** Next.js App Router
**Backend:** incluso nel frontend
**Database:** Supabase (realtime per il timer sincronizzato tra dispositivi)
**ORM/Query:** lascia decidere a omega
**Auth:** Supabase Auth (login Google + email magic link)
**Deploy:** Vercel
**Email:** Resend
**Pagamenti:** Stripe (abbonamento mensile + yearly con sconto)

---

## Design

**Tier:** 2 — Professionale
**Palette colori:**
- Primary: #7C3AED
- Background: #FAFAFA
- Accent: #F59E0B
**Font:** Inter
**Stile generale:** minimal, motivante, dark mode opzionale

---

## Database — Schema

**utenti** (gestito da Supabase Auth)
- piano: TEXT — "free" | "pro"
- piano_scadenza: TIMESTAMPTZ

**task**
- id: UUID PK
- utente_id: UUID FK
- titolo: TEXT
- completato: BOOLEAN
- data_creazione: TIMESTAMPTZ
- pomodori_stimati: INT

**sessioni_pomodoro**
- id: UUID PK
- utente_id: UUID FK
- task_id: UUID FK (nullable)
- durata_minuti: INT
- completata: BOOLEAN
- iniziata_il: TIMESTAMPTZ

---

## Moduli / Funzionalità

### MVP
- [ ] Timer Pomodoro (25/5 min) con notifica browser
- [ ] Task list giornaliera con drag & drop
- [ ] Contatore sessioni completate
- [ ] Autenticazione (Google + magic link)
- [ ] Piano free vs Pro con paywall
- [ ] Checkout Stripe + Customer Portal

### Post-MVP
- [ ] Analytics settimanali (grafico sessioni, top task)
- [ ] Sincronizzazione realtime multi-dispositivo
- [ ] Integrazione Notion / Todoist
- [ ] App mobile (Expo)

---

## Vincoli

- **GDPR:** dati utente solo in EU (Supabase EU region)
- **Performance:** timer deve essere preciso al secondo anche in background
- **Mobile:** responsive obbligatorio, PWA desiderabile
