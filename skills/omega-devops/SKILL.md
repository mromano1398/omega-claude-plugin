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

## QUANDO USARE

- Deploy a produzione (VPS, Vercel, Railway, Render)
- Configurazione Docker + docker-compose
- Setup CI/CD con GitHub Actions
- Configurazione Nginx + SSL Let's Encrypt
- Setup monitoring (Prometheus, Grafana)

## FLUSSO DECISIONALE — Piattaforma

```
Tipo progetto → Piattaforma raccomandata
Next.js/Astro  → Vercel (zero config, CI/CD integrato)
Node.js/Python → Railway o Render (PaaS semplice)
Docker custom  → VPS + Docker Compose (controllo totale)
```

## REGOLE CHIAVE

1. **Mai usare `latest` per Docker tag** — usa sempre semver + SHA (`v1.2.0` + `sha-abc123`)
2. **Backup PRIMA di ogni migration DB** — `pg_dump` obbligatorio
3. **Staging identico a prod** — solo le chiavi sono diverse, mai il codice
4. **Smoke test dopo ogni deploy** — verifica `/api/health` entro 10 secondi
5. **Mai testare su prod** — usa staging per ogni verifica
6. **`output: 'standalone'`** in `next.config.js` obbligatorio per Docker
7. **Tutti e 3 i COPY** nel Dockerfile Next.js: standalone + static + public
8. **Variabili d'ambiente** in `.env.production` (permessi 600), mai in git
9. **HSTS + security headers** su Nginx sempre attivi
10. **Rinnovo SSL automatico** via crontab certbot

## CHECKLIST SINTETICA

- [ ] Piattaforma scelta (Vercel / Railway / VPS+Docker)
- [ ] Variabili env production configurate e verificate
- [ ] DB production separato da staging
- [ ] Docker build: tutti i COPY presenti, non gira come root
- [ ] Nginx: SSL, HSTS, rate limiting su auth
- [ ] CI/CD: test → build → push → deploy
- [ ] Health check endpoint `/api/health` implementato
- [ ] Backup DB automatico configurato
- [ ] Monitoring attivo (almeno uptime + error rate)
- [ ] Rollback testato (sai come tornare indietro)

## REFERENCES

Per dettagli tecnici completi, leggi:
- [references/docker.md] — Dockerfile, docker-compose, monitoring, deploy Vercel/Railway
- [references/nginx.md] — nginx.conf completo, SSL Let's Encrypt, routing ibrido
- [references/cicd.md] — GitHub Actions deploy, release NPM, cron task
