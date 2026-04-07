---
name: omega-devops
description: Use when deploying to production, configuring Docker, setting up CI/CD pipelines, configuring Nginx/SSL, setting up monitoring, or managing VPS infrastructure. Triggered by menu options [10] Deploy, [DP], or when project type requires infrastructure guidance.
user-invocable: false
---

# omega-devops — Docker · CI/CD · Deploy · Monitoring

**Lingua:** Sempre italiano. Consulta sempre la doc ufficiale prima di scrivere config:
- Docker: https://docs.docker.com/build/building/best-practices
- GitHub Actions: https://docs.github.com/en/actions
- Nginx: https://nginx.org/en/docs

---

## DEPLOY — Scegli la piattaforma

```
Tipo progetto → Piattaforma raccomandata
Next.js/Astro  → Vercel (zero config, CI/CD integrato)
Node.js/Python → Railway o Render (PaaS semplice)
Docker custom  → VPS + Docker Compose (controllo totale)
```

---

## VERCEL

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

---

## RAILWAY / RENDER

```bash
# Railway
railway login && railway link
railway vars set DATABASE_URL=... NEXTAUTH_SECRET=...
railway up

# Render: usa Dashboard web → collegato a GitHub → auto-deploy su push
```

---

## VPS + DOCKER

### Prerequisito: `next.config.js`

```js
// OBBLIGATORIO per standalone mode
module.exports = { output: 'standalone' }
```

### Dockerfile (COMPLETO — tutti i COPY obbligatori)

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

### docker-compose.yml (production-ready)

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

### nginx.conf

```nginx
server {
    listen 80;
    server_name mioapp.com www.mioapp.com;

    # Certbot challenge
    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    location / {
        return 301 https://$host$request_uri;
    }
}

server {
    listen 443 ssl http2;
    server_name mioapp.com www.mioapp.com;

    ssl_certificate /etc/letsencrypt/live/mioapp.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/mioapp.com/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256;
    ssl_prefer_server_ciphers off;

    # Security headers
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    add_header Permissions-Policy "camera=(), microphone=(), geolocation=()" always;

    # Rate limiting (login + API)
    limit_req_zone $binary_remote_addr zone=login:10m rate=5r/m;
    location /api/auth { limit_req zone=login burst=10 nodelay; proxy_pass http://app:3000; }

    location / {
        proxy_pass http://app:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # Gzip
    gzip on;
    gzip_types text/plain text/css application/json application/javascript;
}
```

### Certbot SSL (Let's Encrypt)

```bash
# Prima volta
docker run --rm -v /etc/letsencrypt:/etc/letsencrypt \
  -v $(pwd)/certbot-www:/var/www/certbot \
  certbot/certbot certonly --webroot \
  -w /var/www/certbot -d mioapp.com -d www.mioapp.com \
  --email admin@mioapp.com --agree-tos --no-eff-email

# Rinnovo automatico (crontab)
0 3 * * * docker run --rm -v /etc/letsencrypt:/etc/letsencrypt certbot/certbot renew --quiet && docker exec nginx nginx -s reload
```

---

## CI/CD — GitHub Actions

### `.github/workflows/deploy.yml`

```yaml
name: Deploy to Production

on:
  push:
    tags: ['v*']   # Trigger su tag versione (es. v1.2.0)

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:18
        env:
          POSTGRES_PASSWORD: testpass
          POSTGRES_DB: testdb
        options: >-
          --health-cmd pg_isready --health-interval 10s
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: '22' }
      - run: npm ci
      - run: npm run build
      - run: tsc --noEmit
      - run: npm test
        env:
          DATABASE_URL_TEST: postgresql://postgres:testpass@localhost:5432/testdb

  build-push:
    needs: test
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write
    steps:
      - uses: actions/checkout@v4
      - uses: docker/setup-buildx-action@v3
      - uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
          tags: |
            type=semver,pattern={{version}}
            type=sha,prefix=sha-
      - uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          cache-from: type=gha
          cache-to: type=gha,mode=max

  deploy:
    needs: build-push
    runs-on: ubuntu-latest
    environment: production
    steps:
      - name: Deploy via SSH
        uses: appleboy/ssh-action@v1
        with:
          host: ${{ secrets.VPS_HOST }}
          username: ${{ secrets.VPS_USER }}
          key: ${{ secrets.VPS_SSH_KEY }}
          script: |
            cd /app
            docker pull ghcr.io/${{ github.repository }}:${{ github.ref_name }}
            VERSION=${{ github.ref_name }} docker-compose up -d --no-deps app
            docker-compose ps
            # Smoke test
            sleep 10
            curl -f http://localhost:3000/api/health || (docker-compose logs app && exit 1)
```

---

## IMAGE TAGGING STRATEGY

```bash
# ❌ MAI fare questo — tag mobile, non riproducibile
docker build -t myapp:latest .

# ✅ Usa semver + SHA
docker build -t myapp:v1.2.0 -t myapp:sha-$(git rev-parse --short HEAD) .

# Tag immutabili: v1.2.0 non viene mai riusato
# Retention: mantieni ultime 10 versioni + stable + latest
```

---

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

---

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

---

## MONITORING

### Stack consigliato (docker-compose aggiuntivo)

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
