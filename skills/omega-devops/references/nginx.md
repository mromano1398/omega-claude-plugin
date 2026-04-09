# Nginx — Configurazione Completa

Doc ufficiale: https://nginx.org/en/docs

## nginx.conf (production-ready con SSL + security headers)

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

## Certbot SSL (Let's Encrypt)

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

## Nginx — Routing ibrido Strangler Fig

Per migrazione legacy (vecchio PHP + nuovo Next.js):

```nginx
server {
    listen 443 ssl;
    server_name mioapp.com;

    # Nuove sezioni già migrate → Next.js
    location /commesse { proxy_pass http://nextjs:3000; }
    location /articoli  { proxy_pass http://nextjs:3000; }
    location /api/v2    { proxy_pass http://nextjs:3000; }

    # Tutto il resto → PHP legacy
    location / {
        proxy_pass http://php_legacy:80;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```
