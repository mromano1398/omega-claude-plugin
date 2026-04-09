---
name: omega-tier-system
description: Use when the user needs to choose a visual design tier (1-4), understand tier differences, or configure the design system for a new or existing project. Triggered by omega-wizard step 2, [DS] menu, or when user says "cambia design", "che tier", "livello visivo".
user-invocable: false
---

# omega-tier-system — I 4 Tier di Design

**Lingua:** Sempre italiano.
**Principio:** Il tier definisce il livello di complessità visiva. La palette NON è mai fissa — viene personalizzata per ogni progetto. Il tier è una scelta dell'utente, non un default automatico.

## I 4 TIER

| Tier | Nome | Animazioni | Use case tipico | Stack extra |
|------|------|------------|-----------------|-------------|
| 1 | FUNZIONALE | Nessuna | Gestionali, ERP, tool interni | shadcn base |
| 2 | PROFESSIONALE | Framer Motion base | SaaS B2C, dashboard | shadcn + framer |
| 3 | CINEMATIC | GSAP + Lenis | Landing premium, portfolio dev | + GSAP |
| 4 | IMMERSIVO | Three.js/R3F | Showcase 3D, esperienze | + Three.js |

## FLUSSO SCELTA TIER

Fai queste 3 domande:
1. "Che impatto visivo vuoi? [1] Pulito e funzionale → [2] Curato e moderno → [3] Cinematografico → [4] Immersivo 3D"
2. "Chi è l'utente principale?" (professionisti interni → tier 1-2, consumatori → tier 2-3, showcase → 3-4)
3. "Hai vincoli di performance o browser?" (IE/browser vecchi, device lenti → tier 1-2)

## PALETTE (sempre personalizzata)

Ogni tier ha colori consigliati ma MAI fissi. La palette va sempre discussa con l'utente.
Usa token semantici: `primary`, `secondary`, `surface`, `border`, `danger`, `warning`, `success`.

## REGOLE CHIAVE

- Tier 1: zero animazioni, desktop-first, tabelle dense 14px
- Tier 2: microinterazioni ok, mobile-first, skeleton states
- Tier 3: dark theme preferito, font display separato dal body
- Tier 4: fallback 2D obbligatorio, WebGL feature detection richiesta
- MAI scegliere tier 4 per gestionali o tool interni
- Il tier può essere cambiato in qualsiasi momento con /omega:omega-reskin

## REFERENCES
Per definizione tecnica completa di ogni tier:
- [references/tier-1.md] — Tier 1 FUNZIONALE: componenti, font, spacing, regole
- [references/tier-2.md] — Tier 2 PROFESSIONALE: animazioni permesse, componenti avanzati
- [references/tier-3.md] — Tier 3 CINEMATIC: GSAP setup, dark theme, font display
- [references/tier-4.md] — Tier 4 IMMERSIVO: Three.js/R3F setup, fallback, performance
