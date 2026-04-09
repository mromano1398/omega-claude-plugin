# GDPR — Checklist Operativa Completa

Riferimento: https://gdpr.eu

## Art. 5 — Principi

- [ ] **Minimizzazione dati**: raccogli solo ciò che serve
- [ ] **Storage limitation**: definita retention policy per ogni tipo di dato
- [ ] **Integrità/Riservatezza**: cifratura at-rest per dati sanitari/finanziari

## Art. 13/14 — Trasparenza

- [ ] Privacy policy aggiornata e accessibile
- [ ] Cookie banner se analytics (consenso opt-in)

## Art. 17 — Diritto alla cancellazione

- [ ] Implementato `DELETE /api/account` con hard delete (non solo soft delete)
- [ ] I log audit vengono anonimizzati, non cancellati

## Art. 30 — Registro trattamenti

- [ ] Documento interno che elenca: dati trattati, base legale, retention, terze parti

## Art. 32 — Sicurezza del trattamento

- [ ] Cifratura at-rest per dati sanitari/finanziari (column encryption o TDE)
- [ ] TLS su tutte le connessioni DB (`sslmode=require` in DATABASE_URL)
- [ ] Backup cifrati

## Art. 33 — Notifica breach entro 72h

- [ ] Runbook documentato: chi notificare, come, entro quando
- [ ] Contatto DPO o responsabile privacy definito

## Vendor GDPR

- [ ] Sentry: configurare `beforeSend` per filtrare PII prima dell'invio
- [ ] Email provider: DPA firmato
- [ ] Log aggregation: in UE o con garanzie adeguate

## Conversione rischi tecnici → business (per PM)

| Problema tecnico trovato | Rischio business |
|---|---|
| Audit sicurezza non fatto | Vulnerabilità non corrette → possibile accesso non autorizzato ai dati |
| Dipendenze non aggiornate (npm audit) | Componenti con falle di sicurezza note → conformità GDPR a rischio |
| File sensibili in cloud storage pubblico | Documenti privati accessibili da chiunque con il link |
