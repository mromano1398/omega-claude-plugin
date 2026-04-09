---
name: omega-security
description: Use when running a security audit, implementing auth patterns, handling file uploads, configuring GDPR compliance, reviewing OWASP Top 10, or setting up secrets management. Triggered by menu [8] Sicurezza OWASP, [SEC], or when building apps with sensitive data.
user-invocable: false
---

# omega-security — OWASP · GDPR · Auth · Secrets

**Lingua:** Sempre italiano. Riferimenti ufficiali:
- OWASP Top 10:2025: https://owasp.org/Top10/2025
- OWASP Cheat Sheet: https://cheatsheetseries.owasp.org
- GDPR: https://gdpr.eu

## QUANDO USARE

- Audit di sicurezza del codice (prima del lancio o su richiesta)
- Implementazione auth con ruoli e permessi
- Gestione file upload sicuro
- Conformità GDPR
- Configurazione secrets e variabili d'ambiente

## FLUSSO AUDIT — 4 assi

```
1. OWASP Top 10:2025 → verifica ogni punto, documenta in omega/audit.md
2. Correttezza codice → any, cast pericolosi, N+1, race conditions
3. Design system → coerenza token colori/font/spacing
4. Database → FK mancanti, indici mancanti, aggregazioni pericolose
```

Risultati in `omega/audit.md` con severity: 🔴 Critico / 🟠 Alto / 🟡 Medio / 🔵 Basso

## REGOLE CHIAVE

1. **`withAuth()` su ogni Server Action** — mai saltare il check di sessione
2. **Ownership check obbligatorio** — utente A non può mai leggere record di utente B
3. **File upload FUORI da `public/`** — usa `private/uploads`, servi con route autenticata
4. **Magic bytes per tipo file** — non fidarsi del Content-Type HTTP
5. **PII mascherata nei log** — mai password, IBAN, CF, email in chiaro in registro_audit
6. **Secrets in env vars** — mai hardcodati, secret scanning nei commit
7. **TLS su connessione DB** — `?sslmode=require` obbligatorio in production
8. **`npm audit` zero critici** prima del deploy
9. **Security headers** configurati in next.config.js (HSTS, CSP, X-Frame-Options)
10. **Rate limiting** su auth + upload + API pubbliche

## CHECKLIST SINTETICA PRE-LANCIO

- [ ] OWASP Top 10: tutti i punti verificati (vedi references/owasp.md)
- [ ] `npm audit` zero vulnerabilità critiche/alte
- [ ] Nessun secret hardcoded (verificato con secretlint)
- [ ] File upload fuori da public/ con auth e ownership check
- [ ] Audit log con PII mascherata e retention policy
- [ ] withAuth() con ownership check su ogni operazione
- [ ] Security headers configurati (HSTS, CSP, X-Frame-Options, ecc.)
- [ ] Rate limiting su auth + upload + API pubbliche
- [ ] TLS su connessione DB (`?sslmode=require`)
- [ ] Backup cifrati
- [ ] GDPR: privacy policy, cookie banner, diritto cancellazione
- [ ] `security.txt` in public/ con contatto responsabile

## REFERENCES

Per dettagli tecnici completi, leggi:
- [references/owasp.md] — OWASP Top 10 dettagliato, file upload pattern, audit log, CSRF
- [references/auth-patterns.md] — withAuth(), ownership check, RBAC, security headers, secrets management
- [references/gdpr.md] — checklist GDPR completa per articolo (5, 13, 17, 30, 32, 33)
