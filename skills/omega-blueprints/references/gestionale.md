# Blueprint: Gestionale / ERP

## Struttura Cartelle
```
src/
├── app/
│   ├── (auth)/
│   │   ├── login/page.tsx
│   │   └── layout.tsx
│   ├── (dashboard)/
│   │   ├── layout.tsx           # Sidebar + header
│   │   ├── page.tsx             # Dashboard overview
│   │   ├── [modulo]/
│   │   │   ├── page.tsx         # Lista principale
│   │   │   ├── [id]/page.tsx    # Dettaglio/edit
│   │   │   └── nuovo/page.tsx   # Creazione
│   │   └── impostazioni/
│   │       ├── page.tsx
│   │       └── utenti/page.tsx
│   └── api/
│       └── [modulo]/route.ts
├── modules/
│   └── [dominio]/
│       ├── types.ts             # TypeScript types/interfaces
│       ├── queries.ts           # Letture DB (SELECT)
│       └── actions.ts           # Writes DB (INSERT/UPDATE/DELETE)
├── components/
│   ├── ui/                      # shadcn components
│   ├── layout/
│   │   ├── Sidebar.tsx
│   │   ├── Header.tsx
│   │   └── Breadcrumb.tsx
│   └── [modulo]/
│       ├── [Modulo]Table.tsx
│       ├── [Modulo]Form.tsx
│       └── [Modulo]Badge.tsx
└── lib/
    ├── db.ts                    # Connessione pg
    ├── auth.ts                  # Session management
    ├── permissions.ts           # RBAC helper
    ├── audit.ts                 # Audit trail
    └── notifiche.ts             # Sistema notifiche
```

## RBAC — Due Livelli

**Livello 1: Ruoli globali**
- `admin` — accesso totale
- `manager` — accesso a tutto tranne impostazioni sistema
- `operatore` — accesso solo al proprio lavoro
- `readonly` — solo lettura

**Livello 2: Permessi per modulo (opzionale)**
```ts
// lib/permissions.ts
type Permission = 'read' | 'write' | 'delete' | 'export'
type Module = 'clienti' | 'ordini' | 'fatture' | 'magazzino'

const ROLE_PERMISSIONS: Record<Role, Record<Module, Permission[]>> = {
  admin: { clienti: ['read','write','delete','export'], ... },
  operatore: { clienti: ['read','write'], ... }
}

export function can(user: User, module: Module, action: Permission): boolean {
  return ROLE_PERMISSIONS[user.role][module]?.includes(action) ?? false
}
```

## Audit Trail (OBBLIGATORIO su ogni write)
```ts
// lib/audit.ts
export async function logAudit(db: Pool, params: {
  userId: string
  action: 'CREATE' | 'UPDATE' | 'DELETE'
  table: string
  recordId: string
  oldData?: object
  newData?: object
}) {
  await db.query(
    `INSERT INTO audit_log (user_id, action, table_name, record_id, old_data, new_data, created_at)
     VALUES ($1, $2, $3, $4, $5, $6, NOW())`,
    [params.userId, params.action, params.table, params.recordId,
     JSON.stringify(params.oldData), JSON.stringify(params.newData)]
  )
}
```

Schema audit_log:
```sql
CREATE TABLE audit_log (
  id SERIAL PRIMARY KEY,
  user_id VARCHAR NOT NULL,
  action VARCHAR NOT NULL,
  table_name VARCHAR NOT NULL,
  record_id VARCHAR NOT NULL,
  old_data JSONB,
  new_data JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

## Advisory Lock (numerazioni atomiche)
```ts
// Numerazione fattura atomica — previene race conditions
export async function getNextFatturaNumber(db: Pool, anno: number): Promise<string> {
  const lockKey = anno * 1000 + 1  // chiave unica per anno
  await db.query('SELECT pg_advisory_xact_lock($1)', [lockKey])
  const { rows } = await db.query(
    `SELECT COALESCE(MAX(numero_progressivo), 0) + 1 as next
     FROM fatture WHERE anno = $1`, [anno]
  )
  return `${anno}/${String(rows[0].next).padStart(4, '0')}`
}
```

## IDOR Protection
```ts
// SEMPRE filtrare per user/azienda su ogni query
// MAI fare: SELECT * FROM ordini WHERE id = $1
// SEMPRE fare:
const { rows } = await db.query(
  'SELECT * FROM ordini WHERE id = $1 AND azienda_id = $2',
  [ordineId, session.user.aziendaId]
)
if (rows.length === 0) throw new Error('Not found or unauthorized')
```

## Pattern Sidebar
```tsx
// components/layout/Sidebar.tsx
const navItems = [
  { href: '/dashboard', icon: LayoutDashboard, label: 'Dashboard' },
  { href: '/clienti', icon: Users, label: 'Clienti', permission: ['clienti', 'read'] },
  { href: '/ordini', icon: ShoppingCart, label: 'Ordini', permission: ['ordini', 'read'] },
]
// Active state: bg-primary/10 text-primary border-l-2 border-primary
```

## Componenti Specifici
- `DataTable`: sortabile, filtrable, paginata, selezione multipla, export CSV
- `FilterBar`: filtri per stato, data range, ricerca testo
- `AllegatiSection`: upload/download file allegati con drag&drop
- `BadgeStato`: colore semantico per stati (approvato/in-attesa/rifiutato/archiviato)
- `ConfirmDialog`: modale conferma per azioni destructive
- `FormSection`: raggruppamento campi form con titolo sezione

## Sicurezza Predefinita
- Session check su OGNI route protetta (middleware Next.js)
- Zod su OGNI input utente (form, query params, body API)
- WHERE azienda_id su OGNI query (mai esporre dati cross-tenant)
- Rate limiting su API routes (upstash/ratelimit o simile)
- CSRF protection (next-auth built-in o custom)
- Log di tutti gli accessi falliti
