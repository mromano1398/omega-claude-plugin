---
name: omega-ai
description: Use when building AI-powered features — chatbots, text generation, image analysis, RAG (retrieval-augmented generation), AI agents, tool calling, or structured output with LLMs. Triggered by mentions of "AI", "chatbot", "LLM", "GPT", "Claude", "Anthropic", "OpenAI", "streaming", "RAG", "intelligenza artificiale".
user-invocable: false
---

# omega-ai — LLM · Streaming · RAG · Tool Calling · AI Agents

**Lingua:** Sempre italiano. Riferimenti ufficiali:
- Vercel AI SDK v6: https://sdk.vercel.ai/docs
- Anthropic SDK: https://docs.anthropic.com/en/api/getting-started
- Vercel AI Gateway: https://vercel.com/docs/ai-gateway

**Versione:** Tutti i pattern usano **AI SDK v6** (breaking changes rispetto a v5).

## QUANDO USARE

- Chat con streaming (chatbot, assistente AI)
- Text generation, classification, extraction strutturata
- Analisi immagini (vision)
- RAG (risponde basandosi su documenti tuoi)
- Tool calling / AI agents che eseguono azioni
- Output strutturato (JSON garantito con schema Zod)

## FLUSSO DECISIONALE

```
App Next.js + streaming UI     → Vercel AI SDK v6 (useChat)
Controllo totale sul prompt    → Anthropic SDK diretto
Multi-provider / switch facile → Vercel AI SDK v6 (cambia provider con 1 riga)
Python / FastAPI               → Anthropic SDK Python
Deploy su Vercel               → Usa AI Gateway (OIDC auth, cost tracking, failover)

Scelta modello:
Classificazione / extraction rapida → claude-haiku-4.5 (12x più economico)
Chat / RAG / tool calling           → claude-sonnet-4.6 (default)
Analisi complessa / ragionamento    → claude-opus-4.6
```

## REGOLE CHIAVE

1. **Credenziali AI via `vercel env pull`** (AI Gateway su Vercel) — mai hardcoded
2. **`maxTokens` sempre impostato** — evita costi illimitati per risposta
3. **Rate limiting per utente** (o IP per anonimi) — obbligatorio
4. **Input validation + lunghezza massima** prima di chiamare il modello
5. **System prompt con scope chiaro + anti-injection** — mai omettere
6. **Streaming per risposte lunghe** — UX migliore, non aspettare risposta completa
7. **Errori gestiti**: timeout, rate limit provider, risposta malformata
8. **Tool calling: ogni tool verifica auth** prima di eseguire
9. **RAG: cita le fonti** nella risposta, non inventare
10. **AI SDK v6 breaking changes**: `useChat` usa `transport`, `message.parts` non `content`, `stopWhen: stepCountIs(N)` non `maxSteps`

## CHECKLIST SINTETICA

- [ ] Credenziali AI via AI Gateway o variabili d'ambiente — mai hardcoded
- [ ] Rate limiting per utente (o IP per anonimi)
- [ ] Input validation + lunghezza massima prima del modello
- [ ] System prompt con scope chiaro e anti-injection
- [ ] `maxTokens` sempre impostato
- [ ] Streaming per risposte lunghe
- [ ] Errori gestiti: timeout, rate limit provider, risposta malformata
- [ ] [Se tool calling] Ogni tool verifica auth prima di eseguire
- [ ] [Se RAG] Citazione fonti nella risposta
- [ ] [Se Vercel deploy] AI Gateway per OIDC auth e cost tracking

## REFERENCES

Per dettagli tecnici completi, leggi:
- [references/vercel-ai-sdk.md] — setup AI SDK v6, chat UI, structured output, tool calling, vision, rate limiting, guardrails, modelli
- [references/rag.md] — schema pgvector, indicizzazione documenti, query RAG, scelta SDK
