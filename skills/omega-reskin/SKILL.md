---
name: omega-reskin
description: Use when changing the visual design of an existing project without touching business logic. Triggered by "cambia design", "reskin", "nuovo stile", "cambia tier", "rifai l'aspetto", or [RESKIN] shortcut.
user-invocable: false
---

# omega-reskin — Reskin Chirurgico

**Lingua:** Sempre italiano.
**Principio:** Cambiare l'aspetto visivo SENZA toccare la business logic. Ogni modifica è chirurgica, verificata, reversibile.

---

## CASO SPECIALE — Reskin verso Tier 4 (IMMERSIVO)

Reskin da qualsiasi tier verso Tier 4 richiede ristrutturazione architetturale,
non solo un cambio di stile. Questo va comunicato all'utente prima di iniziare.

**Prerequisiti da verificare:**
- `three` / `@react-three/fiber` / `@react-three/drei` non installati → devono essere aggiunti
- Layout root (`app/layout.tsx`) deve poter wrappare un `<Canvas>` R3F
- Componenti con `"use server"` non possono contenere R3F direttamente → servono wrapper `"use client"`
- Next.js richiede `dynamic(() => import(...), { ssr: false })` per tutto R3F

**Avviso obbligatorio da mostrare all'utente prima di procedere:**
```
⚠️ Il Tier 4 richiede modifiche architetturali al layout del progetto,
non solo al CSS. Alcuni componenti potrebbero dover essere riscritti.

Vuoi:
[A] Analisi impatto (raccomandato) — vedo prima cosa cambia
[B] Procedi direttamente con il piano
```

**Flusso per Tier 4 (dopo conferma utente):**
1. Installa dipendenze 3D: `npm install three @react-three/fiber @react-three/drei`
2. Aggiorna layout root per supportare il Canvas R3F
3. Identifica componenti incompatibili con RSC → converte a client components
4. Poi procedi con il flusso reskin standard per design system e componenti UI

**Nota:** questo caso speciale NON si applica al reskin tra Tier 1/2/3 tra di loro,
che rimane una modifica puramente di stile/CSS.

---

## STEP 1 — Analisi Separazione

Prima di toccare qualsiasi file, classifica ogni file del progetto in 3 categorie:

**DESIGN** (modificabile liberamente):
- `src/app/globals.css` — variabili CSS, colori, font
- `src/components/ui/` — tutti i componenti shadcn
- `src/components/layout/` — Sidebar, Header, Footer
- `tailwind.config.ts` — tema, colori custom
- File con solo JSX/className senza logica
- `public/fonts/`, `public/images/`

**LOGICA** (MAI toccare):
- `src/modules/*/queries.ts` — query DB
- `src/modules/*/actions.ts` — server actions
- `src/lib/db.ts`, `src/lib/auth.ts`, `src/lib/permissions.ts`
- File con `export async function` di business logic
- Schema DB, migrations
- `src/app/api/` — route handlers
- Hook custom con logica (`useAuth`, `usePermissions`)

**MISTO** (chirurgia necessaria — isola prima):
- `src/app/(dashboard)/[modulo]/page.tsx` — ha sia UI che data fetching
- Componenti con logica inline (form con validazione)
- Server Components con query dirette

**Output Step 1:** Mostra lista categorizzata all'utente prima di procedere.

---

## STEP 2 — Nuovo Design System

1. Chiama **omega-tier-system** per scegliere il nuovo tier
2. (Opzionale) Se l'utente ha un design esterno: chiama **omega-stitch**
3. Definisci nuova palette con l'utente (token semantici)
4. Aggiorna `omega/design-system.md` con nuovo tier e palette
5. Aggiorna sezione `[DESIGN SYSTEM]` in `CLAUDE.md`

---

## STEP 3 — Piano Chirurgico

Esegui in questo ordine ESATTO:

### a. Design System Base
1. Aggiorna `tailwind.config.ts` — nuovi colori e token
2. Aggiorna `src/app/globals.css` — CSS variables, font imports
3. Aggiorna `CLAUDE.md` — sezione design system
4. Verifica: `omega-build-checker` → deve passare prima di continuare

### b. Componenti UI
5. Aggiorna componenti `src/components/ui/` (shadcn base)
6. Aggiorna `src/components/layout/Sidebar.tsx`
7. Aggiorna `src/components/layout/Header.tsx`
8. Installa nuove dipendenze se tier cambia (framer-motion, gsap, ecc.)
9. Verifica: `omega-build-checker`

### c. Layout Pagine
10. Aggiorna layout files (`src/app/(dashboard)/layout.tsx`, ecc.)
11. Aggiorna componenti sezione pura UI
12. Verifica: `omega-build-checker`

### d. Pagine Miste (la parte più delicata)
Per ogni pagina MISTO:
- Isola la UI in un componente presentazionale separato
- Mantieni il data fetching nel page.tsx originale
- Passa i dati come props al componente UI
- MAI spostare query o logica
- Verifica dopo OGNI pagina: `omega-build-checker`

---

## STEP 4 — Verifica dopo ogni Pagina

Dopo ogni file MISTO modificato:
```
omega-build-checker → 
  ✅ OK → continua alla prossima pagina
  ❌ ERRORE → risolvi prima di procedere (max 3 tentativi poi STOP)
```

---

## STEP 5 — Verifica Finale

Quando tutte le pagine sono aggiornate:
1. `omega-audit-ui` — verifica che il design non sia "slop"
2. `omega-build-checker` — verifica build finale pulita
3. `omega-context-updater` — aggiorna CLAUDE.md e state.md

---

## REGOLA ASSOLUTA — File MAI da Toccare durante Reskin

Questi file non si toccano MAI durante un reskin, senza eccezioni:

```
src/modules/*/queries.ts
src/modules/*/actions.ts
src/modules/*/types.ts
src/lib/db.ts
src/lib/auth.ts
src/lib/permissions.ts
src/lib/audit.ts
src/app/api/**/*
prisma/schema.prisma
drizzle/schema.ts
migrations/
*.sql
middleware.ts (logica auth)
src/hooks/useAuth.ts
src/hooks/usePermissions.ts
```

Se un file in questa lista ha UI da aggiornare → isola la UI in un componente separato e importa quello. MAI modificare la logica esistente.

---

## OUTPUT ATTESO

Al completamento del reskin:
- Build pulita senza errori TypeScript
- Nessuna regressione funzionale (test passano se presenti)
- `omega/design-system.md` aggiornato
- `CLAUDE.md` aggiornato con nuovo tier e palette
- `omega/state.md` aggiornato con data reskin
