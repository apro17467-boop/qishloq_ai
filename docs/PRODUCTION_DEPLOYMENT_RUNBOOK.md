# Production Deployment Runbook

This runbook describes the safe production deployment flow for QISHLOQ AI. Do not commit real `.env`, token, password, private key, or provider credential values.

## Server Requirements

- Ubuntu/Linux VPS
- Node.js LTS for direct Node deployment, or Docker and Docker Compose for container deployment
- PostgreSQL database
- Nginx reverse proxy
- HTTPS/SSL certificate
- Domain or subdomain pointed to the server
- Firewall allowing only required ports, usually `22`, `80`, and `443`
- Persistent storage for PostgreSQL data and uploaded files

## Backend Deployment

1. Clone the repository:

```bash
git clone <repository-url>
cd qishloq-ai/backend
```

2. Create production environment file from placeholders:

```bash
cp .env.production.example .env.production
```

3. Fill `.env.production` on the server only. Use strong secret values and never commit this file.
   For real OTP delivery set `SMS_PROVIDER=generic`, fill the provider send endpoint in `SMS_API_BASE_URL`, and configure either `SMS_API_TOKEN` or `SMS_API_LOGIN` + `SMS_API_PASSWORD`.

4. Install dependencies:

```bash
npm install
```

5. Apply database migrations:

```bash
npx prisma migrate deploy
```

6. Generate Prisma Client:

```bash
npx prisma generate
```

7. Build the backend:

```bash
npm run build
```

8. Start production server:

```bash
npm run start:prod
```

Use a process manager such as systemd or PM2 in real production so the process restarts after server reboot or crash.

## Docker Compose Production Flow

If using the production Docker Compose setup:

```bash
cd qishloq-ai/backend
cp .env.production.example .env.production
docker compose -f docker-compose.prod.yml up -d postgres
npm run docker:prod:migrate
npm run docker:prod:seed
docker compose -f docker-compose.prod.yml up -d app
```

Check logs:

```bash
docker compose -f docker-compose.prod.yml logs -f app
```

Restart app after configuration changes:

```bash
docker compose -f docker-compose.prod.yml up -d app
```

## Nginx Reverse Proxy Example

Replace domains and ports with production values:

```nginx
server {
    listen 80;
    server_name api.your-domain.uz;

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /uploads/ {
        proxy_pass http://127.0.0.1:3000/uploads/;
        proxy_set_header Host $host;
    }
}
```

After HTTPS is enabled, redirect HTTP to HTTPS and serve the API only through TLS.

## HTTPS / Let's Encrypt Checklist

- Domain or subdomain points to the server IP.
- Nginx config is valid:

```bash
sudo nginx -t
```

- Install Certbot for the server OS.
- Issue certificate for the API domain:

```bash
sudo certbot --nginx -d api.your-domain.uz
```

- Confirm auto-renewal:

```bash
sudo certbot renew --dry-run
```

- Confirm `https://api.your-domain.uz/health` works.

## CORS Checklist

- Set production `CORS_ORIGIN` to exact allowed frontend/admin/mobile web origins.
- Do not use wildcard origins for authenticated endpoints.
- Include admin panel domain only if admin panel is deployed.
- Re-test mobile app API calls after changing CORS.

## SMS OTP Provider Checklist

- Development mode uses `SMS_PROVIDER=dev` and `SMS_DEV_CODE=111111`; real SMS is not sent.
- Production mode should use `SMS_PROVIDER=generic`.
- `SMS_API_BASE_URL` must be the exact SMS provider send endpoint.
- Configure `SMS_API_TOKEN` or `SMS_API_LOGIN` + `SMS_API_PASSWORD` only in server `.env.production` or secret manager.
- Configure `SMS_FROM` with the approved sender name.
- Configure `SMS_MESSAGE_TEMPLATE`, for example `QISHLOQ AI tasdiqlash kodi: {{code}}`.
- Production `/auth/request-otp` response must not include `devCode`, `devOtp`, or the OTP code.
- OTP code and provider credentials must not appear in logs.
- Do not public launch until a real SMS request reaches a real phone number and `/auth/verify-otp` succeeds.

## Uploads / Static Files Checklist

- Set `UPLOAD_DIR` to a persistent path or Docker volume.
- Ensure app process has read/write permission to the upload directory.
- Ensure Nginx/proxy can serve uploaded file URLs.
- Keep upload file type and size limits enabled.
- Include uploads in backup strategy if uploads are business-critical.

## Database Backup Checklist

- Schedule daily PostgreSQL backups.
- Store backups outside the application container.
- Keep at least several recent backups.
- Periodically test restore into a staging/local database.
- Backup before every risky deploy or migration.

Example backup command:

```bash
pg_dump "$DATABASE_URL" > backup-$(date +%Y%m%d-%H%M%S).sql
```

## Log Monitoring Checklist

- Monitor app logs for startup errors, database errors, OTP provider failures, and repeated 4xx/5xx responses.
- Do not log access tokens, OTP codes, SMS provider credentials, database passwords, or JWT secrets.
- Keep production logs rotated.
- Consider uptime and error monitoring after MVP launch.

## Rollback Checklist

- Record deployed commit SHA before deployment.
- Keep previous backend build/container image available.
- Backup database before deploying migrations.
- If app deployment fails before migration: roll back to previous commit/image.
- If migration was applied: confirm whether it is backward-compatible before rolling back code.
- Re-run smoke tests after rollback.

## Smoke Test Endpoints

Run these after deploy. Use production domain and safe test accounts only.

- `GET /health`
- `POST /auth/request-otp`
- `POST /auth/verify-otp`
- `GET /listings`
- `GET /favorites/ids`
- `GET /sellers/:id`
- `GET /conversations/my`

Examples:

```bash
curl https://api.your-domain.uz/health
curl https://api.your-domain.uz/listings
```

Authenticated endpoints such as `/favorites/ids` and `/conversations/my` require a valid Bearer token.
