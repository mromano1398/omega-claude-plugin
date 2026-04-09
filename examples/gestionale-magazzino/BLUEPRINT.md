# BLUEPRINT — GestMag

> Esempio di BLUEPRINT.md per un gestionale magazzino interno.

---

## Progetto

**Nome:** GestMag
**Tipo:** gestionale
**Descrizione:** Sistema interno per la gestione del magazzino aziendale. Permette di tracciare articoli, movimenti di carico/scarico, giacenze per sede e generare report PDF.

**Utenti target:**
- Operatori magazzino (inserimento movimenti)
- Responsabile logistica (report, approvazioni)
- Admin (configurazione, utenti)

**Modello di business:** uso interno aziendale

---

## Stack

**Frontend:** Next.js App Router
**Backend:** incluso nel frontend (Server Actions)
**Database:** PostgreSQL
**ORM/Query:** pg diretto (tabelle movimenti append-only, aggregazioni complesse)
**Auth:** Auth.js v5
**Deploy:** Vercel
**Email:** Resend (notifiche report pronti)
**Pagamenti:** nessuno

---

## Design

**Tier:** 1 — Funzionale
**Palette colori:**
- Primary: #2563EB
- Background: #F8FAFC
- Accent: #0EA5E9
**Font:** Inter
**Stile generale:** minimal, professionale, tabelle chiare

---

## Database — Schema

**articoli**
- id: SERIAL PK
- codice: TEXT UNIQUE — codice interno articolo
- descrizione: TEXT
- unita_misura: TEXT — es. "pz", "kg", "lt"
- categoria_id: INT FK → categorie

**movimenti**
- id: SERIAL PK
- articolo_id: INT FK → articoli
- sede_id: INT FK → sedi
- tipo: TEXT — "CARICO" | "SCARICO" | "RETTIFICA"
- quantita: DECIMAL(12,4)
- segno: INT — +1 o -1
- data_movimento: TIMESTAMPTZ
- operatore_id: INT FK → utenti
- note: TEXT

**giacenze_correnti** (summary table con trigger)
- articolo_id: INT FK
- sede_id: INT FK
- giacenza: DECIMAL(12,4)
- aggiornato_il: TIMESTAMPTZ
- PRIMARY KEY (articolo_id, sede_id)

**sedi**
- id: SERIAL PK
- nome: TEXT
- indirizzo: TEXT

---

## Moduli / Funzionalità

### MVP
- [ ] Dashboard giacenze per sede con filtri
- [ ] Inserimento movimento carico/scarico
- [ ] Ricerca articoli (fulltext)
- [ ] Report giacenze PDF
- [ ] Gestione utenti con ruoli (admin/operatore/readonly)
- [ ] Audit trail completo su ogni scrittura
- [ ] Login con email/password

### Post-MVP
- [ ] Import massivo da CSV
- [ ] Barcode scanner (webcam)
- [ ] Alert giacenza sotto soglia minima
- [ ] API REST per integrazione con ERP

---

## Vincoli

- **Performance:** giacenze mai calcolate live — usare summary table con trigger
- **GDPR:** solo uso interno, dati non sensibili
- **Accessibilità:** WCAG AA per operatori con difficoltà visive
- **Mobile:** responsive obbligatorio (tablet in magazzino)
