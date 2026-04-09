---
name: omega-supabase
description: Use when the project uses Supabase as database/auth/storage backend. Covers Row Level Security, Auth.js adapter, real-time subscriptions, Supabase Storage, Edge Functions, and migration workflow. Triggered when stack includes Supabase or user mentions RLS, Supabase Auth, or Supabase Storage.
user-invocable: false
---

# omega-supabase — RLS · Auth · Storage · Real-time · Migrations

**Lingua:** Sempre italiano. Riferimenti ufficiali:
- Docs: https://supabase.com/docs
- Auth.js adapter: https://authjs.dev/getting-started/adapters/supabase
- RLS guide: https://supabase.com/docs/guides/database/postgres/row-level-security

## QUANDO USARE

- Progetto usa Supabase come database/auth/storage
- Configurare RLS su tabelle con dati utente
- Setup auth (Supabase Auth nativo o Auth.js adapter)
- Gestione file con Supabase Storage
- Real-time subscriptions su tabelle
- Migration workflow con CLI Supabase

## FLUSSO DECISIONALE

```
Nuovo progetto Supabase:
1. Scegli auth: Supabase Auth nativo (più semplice) vs Auth.js adapter (più flessibile)
2. Per ogni tabella con dati utente → attiva RLS + scrivi policy PRIMA di andare in prod
3. Storage privato (public: false) per documenti sensibili
4. Real-time solo dove necessario (consuma risorse)
5. Migration in supabase/migrations/, versionate in git

Nuova tabella:
→ Crea migration → attiva RLS subito → aggiungi policy → indici → genera tipi TypeScript
```

## REGOLE CHIAVE

1. **RLS attiva su OGNI tabella con dati utente** — default deny è la regola di sicurezza
2. **`adminClient` solo server-side** — mai esposto al client, bypassa RLS
3. **`SUPABASE_SERVICE_ROLE_KEY` mai in variabili `NEXT_PUBLIC_`**
4. **Policy per SELECT + INSERT + UPDATE + DELETE** — non lasciare operazioni senza policy
5. **Storage bucket privati** (public: false) per documenti sensibili
6. **Path storage include `utente_id`** come primo segmento per isolamento
7. **Middleware protegge tutte le route private** — non solo la UI
8. **Tipi TypeScript generati dal DB** — `supabase gen types` dopo ogni migration
9. **Migration versionate** in `supabase/migrations/` e in git
10. **Real-time abilitato solo dove necessario** — consuma risorse

## CHECKLIST SINTETICA

- [ ] RLS attiva su tutte le tabelle con dati utente
- [ ] Policy definite per SELECT, INSERT, UPDATE, DELETE
- [ ] `adminClient` usato solo server-side, mai esposto al client
- [ ] `SUPABASE_SERVICE_ROLE_KEY` non in variabili pubbliche (`NEXT_PUBLIC_`)
- [ ] Bucket storage privati (public: false) per documenti sensibili
- [ ] Path storage include `utente_id` come primo segmento (isolamento)
- [ ] Middleware protegge tutte le route private
- [ ] Tipi TypeScript generati da schema (`supabase gen types`)
- [ ] Migration versionate in `supabase/migrations/`
- [ ] Real-time abilitato solo dove necessario (consuma risorse)

## REFERENCES

Per dettagli tecnici completi, leggi:
- [references/rls.md] — RLS policy patterns (owner, RBAC, multi-tenant), migrations, Supabase Storage
- [references/auth.md] — client setup SSR, Supabase Auth nativo, Auth.js adapter, middleware protezione route, Edge Functions
- [references/realtime.md] — subscription pattern con gestione INSERT/UPDATE/DELETE
