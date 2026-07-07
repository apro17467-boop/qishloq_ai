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
