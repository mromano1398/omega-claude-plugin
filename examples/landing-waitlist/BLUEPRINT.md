# BLUEPRINT — LaunchSoon

> Esempio di BLUEPRINT.md per una landing page con waitlist.

---

## Progetto

**Nome:** LaunchSoon
**Tipo:** landing
**Descrizione:** Landing page per raccogliere email di una waitlist prima del lancio di un prodotto SaaS. Include una sezione hero con video background, feature highlights, pricing teaser e form waitlist con conferma email.

**Utenti target:**
- Visitatori pubblici (no registrazione)

**Modello di business:** raccolta lead pre-lancio

---

## Stack

**Frontend:** Astro
**Backend:** nessuno (form via Resend API)
**Database:** nessuno (email salvate su Resend audiences)
**ORM/Query:** nessuno
**Auth:** nessuna
**Deploy:** Vercel
**Email:** Resend (conferma iscrizione waitlist)
**Pagamenti:** nessuno

---

## Design

**Tier:** 3 — Cinematic
**Palette colori:**
- Primary: #6366F1
- Background: #09090B
- Accent: #A78BFA
**Font:** Cal Sans (heading) + Inter (body)
**Stile generale:** dark, impatto visivo forte, hero con animazioni scroll

---

## Moduli / Funzionalità

### MVP
- [ ] Hero section con headline + subheadline + CTA
- [ ] Form iscrizione waitlist (email + nome)
- [ ] Email di conferma automatica con Resend
- [ ] Sezione features (3-4 feature highlights)
- [ ] Sezione pricing teaser ("in arrivo")
- [ ] Footer con link social
- [ ] Open Graph per social sharing

### Post-MVP
- [ ] Counter pubblico iscritti ("già 1.234 persone in lista")
- [ ] Referral program (ogni referral sale in lista)
- [ ] Pagina di ringraziamento personalizzata

---

## Vincoli

- **Performance:** Lighthouse Performance ≥ 95
- **SEO:** sitemap.xml, meta tags completi, Open Graph
- **Accessibilità:** WCAG AA
- **Multi-lingua:** solo italiano per ora
