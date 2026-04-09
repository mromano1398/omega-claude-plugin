# Contribuire a omega

Grazie per l'interesse! Questo documento spiega come contribuire al plugin.

---

## Tipi di contribuzione benvenuti

- **Fix di errori** — package deprecati, link rotti, snippet di codice errati
- **Nuovi pattern** in file `references/` esistenti (Tier 3/4, legacy, security, ecc.)
- **Nuovi blueprint** in `skills/omega-blueprints/references/`
- **Traduzioni di snippet** in altri linguaggi (Python, Go, ecc.) in skill già esistenti
- **Segnalazione di bug** tramite issue

## Cosa NON accettiamo (per ora)

- Nuovi skill top-level senza discussione preventiva (issue prima del PR)
- Traduzione dell'interfaccia in inglese — è by design in italiano
- Wrapper GUI o CLI aggiuntive

---

## Struttura del progetto

```
omega/
├── .claude-plugin/plugin.json   ← manifest del plugin
├── skills/
│   └── [nome-skill]/
│       ├── SKILL.md             ← max ~150 righe (trigger, flusso, regole)
│       └── references/          ← contenuto dettagliato (codice, pattern, esempi)
├── hooks/hooks.json             ← hook automatici per Claude Code
├── commands/                    ← comandi invocabili (fetch-docs)
└── examples/                    ← progetti di esempio con BLUEPRINT.md
```

### Regola principale: progressive disclosure

**SKILL.md** deve restare compatto (≤ 150 righe idealmente):
- Descrive **quando** lo skill viene usato
- Descrive il **flusso** ad alto livello
- Lista le **regole** operative
- Rimanda a `references/` per il codice

**references/*.md** contiene il dettaglio:
- Snippet di codice completi e funzionanti
- Pattern architetturali con esempi
- Checklist dettagliate

---

## Come aggiungere un pattern a uno skill esistente

1. Fork + branch `feature/[nome-pattern]`
2. Identifica il file `references/` appropriato (es. per Tier 3 → `skills/omega-tier-system/references/tier-3.md`)
3. Aggiungi una sezione con heading `###`
4. Includi: breve spiegazione, snippet funzionante, note di compatibilità
5. Verifica che il codice sia corretto (non placeholder)
6. PR con descrizione: cosa aggiunge, perché è utile, fonte/ispirazione

---

## Come creare un nuovo blueprint

I blueprint vanno in `skills/omega-blueprints/references/[tipo].md`.

Struttura minima:

```markdown
# Blueprint: [Nome Tipo]

## Struttura cartelle consigliata
[struttura]

## Schema DB (se rilevante)
[tabelle principali]

## Moduli core
[lista funzionalità essenziali]

## Stack di default
[stack consigliato con motivazione]

## Sicurezza specifica per tipo
[checklist sicurezza tipo-specific]

## Checklist pre-lancio tipo-specifica
[checklist]
```

---

## Come segnalare un bug

Apri una issue con:
- Versione omega (vedi `plugin.json`)
- Tipo di progetto su cui stavi lavorando
- Cosa ti aspettavi vs cosa è successo
- Il file SKILL.md coinvolto (se applicabile)

---

## Convenzioni

- **Lingua:** italiano per tutto il testo narrative, inglese per codice e nomi di file/variabili
- **Codice:** TypeScript per esempi web, Python per esempi AI/data
- **Nessun placeholder:** ogni snippet deve essere copia-incollabile e funzionante
- **Nessun `any` in TypeScript** senza spiegazione del perché è necessario
