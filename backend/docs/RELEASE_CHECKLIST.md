# QISHLOQ AI Backend Release Checklist

## Development

- [ ] `npm install`
- [ ] `docker compose up -d`
- [ ] `npm run prisma:migrate`
- [ ] `npm run prisma:seed`
- [ ] `npm run build`
- [ ] `npm test`
- [ ] `npm run test:e2e`
- [ ] `GET /health` returns `status: ok`
- [ ] `GET /reference/categories` returns seeded categories
- [ ] `GET /reference/regions` returns seeded pilot regions
- [ ] Swagger opens at `GET /docs` when enabled

## Production

- [ ] Create `.env.production` from `.env.production.example`
- [ ] Replace all placeholder secrets
- [ ] `docker compose -f docker-compose.prod.yml config`
- [ ] `npm run docker:prod:build`
- [ ] `docker compose -f docker-compose.prod.yml up -d postgres`
- [ ] `npm run docker:prod:migrate`
- [ ] `npm run docker:prod:seed`
- [ ] `docker compose -f docker-compose.prod.yml up -d app`
- [ ] `curl http://localhost:3000/health`
- [ ] `curl http://localhost:3000/reference/categories`
- [ ] `curl http://localhost:3000/reference/regions`
- [ ] `npm run docker:prod:logs`
- [ ] Confirm `postgres_data` volume exists
- [ ] Confirm `uploads_data` volume exists

## Security

- [ ] `JWT_SECRET` changed from placeholder
- [ ] `OTP_SECRET` changed from placeholder
- [ ] `POSTGRES_PASSWORD` changed from placeholder
- [ ] `CORS_ORIGIN` configured with production domain
- [ ] `SWAGGER_ENABLED=false` in production, or Swagger is protected
- [ ] `RATE_LIMIT_TTL` reviewed for production traffic
- [ ] `RATE_LIMIT_MAX` reviewed for production traffic
- [ ] `BODY_LIMIT` reviewed
- [ ] `MAX_IMAGE_SIZE_MB` reviewed
- [ ] Uploads volume configured
- [ ] Database volume backup strategy defined
- [ ] Production logs/monitoring plan defined

## Smoke Tests

- [ ] `GET /health`
- [ ] `GET /reference/categories`
- [ ] `GET /reference/regions`
- [ ] `POST /auth/request-otp` with invalid phone returns `VALIDATION_ERROR`
- [ ] `GET /listings`
- [ ] Protected endpoint without token returns `UNAUTHORIZED`
- [ ] Admin endpoint with regular user returns `FORBIDDEN`

## Release Notes

- [ ] Record Docker image tag
- [ ] Record migration versions applied
- [ ] Record seed run timestamp
- [ ] Record environment name
- [ ] Record rollback plan
- [ ] Record known limitations from `docs/BACKEND_MVP_AUDIT.md`

## Step 75 — Production Hardening (Added by Audit)

### SMS / OTP
- [ ] `SMS_PROVIDER` set to `generic` or `eskiz` in production
- [ ] `SMS_API_BASE_URL` set to the exact provider send endpoint
- [ ] `SMS_API_TOKEN` or `SMS_API_LOGIN` + `SMS_API_PASSWORD` set via secrets manager or server env (never committed to git)
- [ ] `SMS_FROM` configured for the approved sender name
- [ ] `SMS_MESSAGE_TEMPLATE` reviewed and contains `{{code}}`
- [ ] Verify `devCode`/`devOtp` does NOT appear in production API response (`SMS_PROVIDER != dev`)
- [ ] OTP code is not logged to stdout in production
- [ ] Real SMS request tested with a real phone number before public release

### Chat
- [ ] Chat endpoints restricted to authenticated participants only
- [ ] Self-chat correctly blocked at backend
- [ ] Conversations only created on ACTIVE listings
- [ ] Message body max 2000 chars enforced
- [ ] All chat endpoints return 401 without valid JWT

### Admin
- [ ] Admin endpoints return 403 for non-ADMIN users
- [ ] Swagger disabled in production (`SWAGGER_ENABLED=false`)

### AI
- [ ] Confirm `AI_PROVIDER=local` for MVP pilot (mock responses)
- [ ] Document plan for real AI provider integration

### Database
- [ ] Production database backup strategy defined
- [ ] `postgres_data` volume on host disk confirmed
- [ ] Migration rollback plan documented

### Monitoring
- [ ] Application logs accessible (`npm run docker:prod:logs`)
- [ ] 500-level error alerting plan defined
