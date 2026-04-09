# RLS — Row Level Security

Doc ufficiale: https://supabase.com/docs/guides/database/postgres/row-level-security

## Principio fondamentale

**RLS è la prima linea di difesa del DB.** Attiva su OGNI tabella che contiene dati utente.

```sql
-- Attiva RLS sulla tabella
ALTER TABLE ordini ENABLE ROW LEVEL SECURITY;

-- Senza policy: nessuno accede (default deny)
-- Con anon key e RLS attivo: solo le policy permettono accesso
```

## Policy pattern — CRUD completo per owner

```sql
-- Utente vede solo i propri record
CREATE POLICY "utenti vedono i propri ordini"
  ON ordini FOR SELECT
  USING (auth.uid() = utente_id);

-- Utente crea solo record propri
CREATE POLICY "utenti creano propri ordini"
  ON ordini FOR INSERT
  WITH CHECK (auth.uid() = utente_id);

-- Utente modifica solo i propri
CREATE POLICY "utenti modificano propri ordini"
  ON ordini FOR UPDATE
  USING (auth.uid() = utente_id)
  WITH CHECK (auth.uid() = utente_id);

-- Utente cancella solo i propri
CREATE POLICY "utenti cancellano propri ordini"
  ON ordini FOR DELETE
  USING (auth.uid() = utente_id);
```

## Policy per ruoli (RBAC)

```sql
-- Tabella con colonna ruolo in JWT
CREATE POLICY "admin vede tutto"
  ON ordini FOR SELECT
  USING (auth.jwt() ->> 'user_role' = 'admin');

-- Oppure con tabella profili separata
CREATE POLICY "admin vede tutto"
  ON ordini FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM profili
      WHERE profili.id = auth.uid()
      AND profili.ruolo = 'ADMIN'
    )
  );
```

## Policy per organizzazioni (multi-tenant in row-level)

```sql
-- Utente vede i dati della sua organizzazione
CREATE POLICY "member vede dati organizzazione"
  ON clienti FOR SELECT
  USING (
    organizzazione_id IN (
      SELECT organizzazione_id FROM membri
      WHERE utente_id = auth.uid()
    )
  );
```

## Verifica RLS dal codice

```typescript
// ✅ Corretto — usa anon key, RLS filtra automaticamente
const supabase = createClient()
const { data } = await supabase.from('ordini').select('*')
// Ritorna solo gli ordini dell'utente autenticato

// ✅ Admin bypass (server-side only, per operazioni privilegiate)
const { data: all } = await adminClient.from('ordini').select('*')
// Ritorna TUTTI gli ordini — usare con cautela
```

## Migrations — Workflow Supabase

```bash
# Installa CLI Supabase
npm install -g supabase

# Link al progetto
supabase link --project-ref [project-ref]

# Crea nuova migration
supabase migration new nome_migration
# → crea supabase/migrations/[timestamp]_nome_migration.sql

# Applica in sviluppo
supabase db push

# Genera tipi TypeScript dal DB
supabase gen types typescript --linked > src/types/database.ts

# Pull schema da produzione (per sincronizzare)
supabase db pull
```

### Struttura migration

```sql
-- supabase/migrations/20260407120000_crea_ordini.sql

-- Crea tabella
CREATE TABLE ordini (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  utente_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  importo NUMERIC(12, 2) NOT NULL,
  stato TEXT NOT NULL DEFAULT 'BOZZA',
  creato_il TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Attiva RLS subito
ALTER TABLE ordini ENABLE ROW LEVEL SECURITY;

-- Policy di base (espandi dopo)
CREATE POLICY "owner" ON ordini FOR ALL USING (auth.uid() = utente_id);

-- Indice
CREATE INDEX ON ordini (utente_id, creato_il DESC);
```

## Supabase Storage — Bucket e Policy

```sql
-- In SQL Editor di Supabase
INSERT INTO storage.buckets (id, name, public) VALUES ('documenti', 'documenti', false);
-- false = privato, richiede auth per accesso

-- Policy storage — solo owner può leggere/caricare
CREATE POLICY "utenti gestiscono i propri file"
  ON storage.objects FOR ALL
  USING (auth.uid()::text = (storage.foldername(name))[1])
  WITH CHECK (auth.uid()::text = (storage.foldername(name))[1]);
```

### Upload dal Server Action

```typescript
// app/actions/upload.ts
'use server'
import { createClient } from '@/lib/supabase/server'

export async function uploadFile(formData: FormData) {
  const supabase = createClient()
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) throw new Error('Non autenticato')

  const file = formData.get('file') as File
  const buffer = Buffer.from(await file.arrayBuffer())

  // Path: utente_id/uuid.ext — garantisce isolamento tra utenti
  const filePath = `${user.id}/${crypto.randomUUID()}.${file.name.split('.').pop()}`

  const { error } = await supabase.storage
    .from('documenti')
    .upload(filePath, buffer, { contentType: file.type })

  if (error) throw error
  return { path: filePath }
}
```

### Download con URL firmato (privato)

```typescript
// URL firmato — valido per 1 ora, solo per file privati
const { data } = await supabase.storage
  .from('documenti')
  .createSignedUrl(filePath, 3600)  // secondi

return data?.signedUrl  // URL temporaneo sicuro
```
