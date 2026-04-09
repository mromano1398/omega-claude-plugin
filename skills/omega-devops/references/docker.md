# Docker — Configurazioni Complete

Doc ufficiale: https://docs.docker.com/build/building/best-practices

## Prerequisito Next.js — `next.config.js`

```js
// OBBLIGATORIO per standalone mode
module.exports = { output: 'standalone' }
```

## Dockerfile (COMPLETO — tutti i COPY obbligatori)

```dockerfile
FROM node:22-alpine AS builder
WORKDIR /app
COPY package*.json ./          # Cache layer separato — npm ci usa questo
RUN npm ci
COPY . .
RUN npm run build

FROM node:22-alpine AS runner
WORKDIR /app

# ⚠️ TUTTI E 3 OBBLIGATORI — mancarne uno rompe l'app in produzione
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static    # ← CSS/JS senza questo = 404
COPY --from=builder /app/public ./public

# Sicurezza: non girare come root
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

# Health check integrato
HEALTHCHECK --interval=30s --timeout=3s \
  CMD wget -qO- http://localhost:3000/api/health || exit 1

ENV NODE_ENV=production PORT=3000
CMD ["node", "server.js"]
```

## docker-compose.yml (production-ready)

```yaml
services:
  app:
    image: registry.io/myapp:${VERSION:-latest}
    restart: unless-stopped
    ports:
      - "3000:3000"
    environment:
      - DATABASE_URL=${DATABASE_URL}
      - NEXTAUTH_SECRET=${NEXTAUTH_SECRET}
      - NEXTAUTH_URL=${NEXTAUTH_URL}
    env_file:
      - .env.production    # File separato da .env dev, mai in git
    healthcheck:
      test: ["CMD", "wget", "-qO-", "http://localhost:3000/api/health"]
      interval: 30s
      timeout: 5s
      retries: 3
      start_period: 30s
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: '0.5'
    networks:
      - app-net
    volumes:
      - app-logs:/app/logs
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  nginx:
    image: nginx:alpine
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/conf.d/default.conf:ro
      - /etc/letsencrypt:/etc/letsencrypt:ro
      - certbot-www:/var/www/certbot:ro
    depends_on:
      app:
        condition: service_healthy
    networks:
      - app-net

networks:
  app-net:
    driver: bridge

volumes:
  app-logs:
  certbot-www:
```

## IMAGE TAGGING STRATEGY

```bash
# ❌ MAI fare questo — tag mobile, non riproducibile
docker build -t myapp:latest .

# ✅ Usa semver + SHA
docker build -t myapp:v1.2.0 -t myapp:sha-$(git rev-parse --short HEAD) .

# Tag immutabili: v1.2.0 non viene mai riusato
# Retention: mantieni ultime 10 versioni + stable + latest
```

## STAGING vs PRODUZIONE

| Config | Staging | Produzione |
|---|---|---|
| DATABASE_URL | DB staging (dati test) | DB prod (dati reali) |
| NEXTAUTH_URL | https://staging.mioapp.com | https://mioapp.com |
| Email | Mailtrap/sandbox | Provider reale |
| Stripe | Test keys | Live keys |
| Log level | debug | warn/error |
| Sentry DSN | Sentry staging project | Sentry prod project |

**Regola assoluta:** Mai testare su prod. Staging deve essere identico al codice di prod, diverso solo nelle chiavi e nei dati.

## MIGRAZIONE DB — Protocollo deploy

```bash
# SEMPRE in questo ordine
# 1. Backup PRIMA della migrazione
pg_dump $DATABASE_URL > backup_$(date +%Y%m%d_%H%M).sql

# 2. Applica migrazione su staging → verifica
# 3. Applica migrazione su produzione
npx prisma migrate deploy  # oppure il tuo migration tool

# 4. Verifica count record
psql $DATABASE_URL -c "SELECT COUNT(*) FROM tabella_critica;"

# 5. Se qualcosa va storto → rollback
psql $DATABASE_URL < backup_20260407_1430.sql
```

## MONITORING — Stack docker-compose

```yaml
# Aggiungere a docker-compose.yml
  prometheus:
    image: prom/prometheus:latest
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml:ro
    ports:
      - "9090:9090"
    networks: [app-net]

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3001:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=${GRAFANA_PASSWORD}
    networks: [app-net]

  node_exporter:
    image: prom/node-exporter:latest
    networks: [app-net]

  cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:ro
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
    networks: [app-net]
```

### `prometheus.yml`

```yaml
global:
  scrape_interval: 15s
scrape_configs:
  - job_name: node
    static_configs:
      - targets: ['node_exporter:9100']
  - job_name: cadvisor
    static_configs:
      - targets: ['cadvisor:8080']
```

### Health check endpoint (Next.js)

```typescript
// app/api/health/route.ts
import { query } from '@/lib/db'
export async function GET() {
  try {
    await query('SELECT 1')
    return Response.json({ status: 'ok', db: 'ok', ts: Date.now() })
  } catch {
    return Response.json({ status: 'error', db: 'unreachable' }, { status: 503 })
  }
}
```

## DEPLOY VERCEL

```bash
# 1. Installa CLI
npm i -g vercel

# 2. Collega progetto (prima volta)
vercel link

# 3. Configura variabili production
vercel env add DATABASE_URL production
vercel env add NEXTAUTH_SECRET production
vercel env add NEXTAUTH_URL production
# Aggiungi tutte le var da .env.example

# 4. Deploy preview (staging)
vercel deploy

# 5. Smoke test su URL preview → poi promuovi a prod
vercel promote [deployment-url]

# 6. Deploy produzione
vercel --prod
```

**Checklist Vercel:**
- [ ] `vercel env ls` — tutte le env production presenti
- [ ] `DATABASE_URL` punta a DB production (non localhost)
- [ ] `NEXTAUTH_URL` = dominio production (es. `https://mioapp.com`)
- [ ] Custom domain: `vercel domains add mioapp.com`
- [ ] Function timeout configurato se necessario (default 300s)
- [ ] `next.config.js` verifica: niente hardcoded localhost

Doc Vercel CLI: https://vercel.com/docs/cli

## RAILWAY / RENDER

```bash
# Railway
railway login && railway link
railway vars set DATABASE_URL=... NEXTAUTH_SECRET=...
railway up

# Render: usa Dashboard web → collegato a GitHub → auto-deploy su push
```
