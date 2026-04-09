# RAG — Retrieval Augmented Generation

Doc ufficiale:
- Anthropic SDK: https://docs.anthropic.com/en/api/getting-started
- Vercel AI SDK: https://sdk.vercel.ai/docs

## Setup

```bash
npm install @ai-sdk/anthropic ai pg pgvector
```

## Schema DB con pgvector

```sql
CREATE EXTENSION IF NOT EXISTS vector;

CREATE TABLE documenti (
  id BIGSERIAL PRIMARY KEY,
  contenuto TEXT NOT NULL,
  metadata JSONB,
  embedding VECTOR(1536),
  creato_il TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX ON documenti USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);
```

## Indicizzazione + Query RAG

```typescript
// lib/rag.ts
import { embed, generateText } from 'ai'
import { openai } from '@ai-sdk/openai'
import { anthropic } from '@ai-sdk/anthropic'

const EMBEDDING_MODEL = openai.embedding('text-embedding-3-small')

export async function indicizzaDocumento(testo: string, metadata?: object) {
  const chunks = splitInChunks(testo, 500)
  for (const chunk of chunks) {
    const { embedding } = await embed({ model: EMBEDDING_MODEL, value: chunk })
    await db.query(
      `INSERT INTO documenti (contenuto, metadata, embedding) VALUES ($1, $2, $3::vector)`,
      [chunk, JSON.stringify(metadata), JSON.stringify(embedding)]
    )
  }
}

export async function rispondiConRAG(domanda: string): Promise<string> {
  const { embedding } = await embed({ model: EMBEDDING_MODEL, value: domanda })

  const { rows } = await db.query(
    `SELECT contenuto FROM documenti ORDER BY embedding <=> $1::vector LIMIT 5`,
    [JSON.stringify(embedding)]
  )

  const contesto = rows.map((r: any) => r.contenuto).join('\n\n---\n\n')

  const { text } = await generateText({
    model: anthropic('claude-sonnet-4.6'),
    system: `Rispondi basandoti SOLO sul contesto fornito. Se l'informazione non è nel contesto, dì "Non ho questa informazione". Non inventare.`,
    messages: [{ role: 'user', content: `Contesto:\n${contesto}\n\nDomanda: ${domanda}` }],
    maxTokens: 1000,
  })

  return text
}
```

## Scelta SDK

| Scenario | SDK consigliato |
|---|---|
| App Next.js con streaming UI | **Vercel AI SDK v6** (useChat, streaming integrato) |
| Controllo massimo su prompt | **Anthropic SDK** diretto |
| Compatibilità multi-provider | **Vercel AI SDK v6** (switch con 1 riga) |
| Python / FastAPI | **Anthropic SDK Python** |
| Deployment Vercel con osservabilità | **Vercel AI Gateway** (OIDC auth, routing, cost tracking) |
