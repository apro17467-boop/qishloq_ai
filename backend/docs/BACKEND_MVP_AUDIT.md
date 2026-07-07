# QISHLOQ AI Backend MVP Audit

## Backend MVP Umumiy Holati

QISHLOQ AI backend MVP v0.1 NestJS, TypeScript, Prisma va PostgreSQL asosida shakllantirilgan. Backend marketplace listinglari, complaint moderatsiyasi, local AI maslahat poydevori, admin monitoring, Swagger documentation, Docker production config, seed strategy va minimal test infratuzilmasini qamrab oladi.

Audit natijasi bo'yicha backend MVP asosiy API qatlamlari tayyor. Hujjatdagi known limitations MVP chegarasidan tashqaridagi yoki keyingi bosqichga qoldirilgan ishlarni ko'rsatadi.

## Tayyor Modullar

- Health endpoint
- Prisma + PostgreSQL database layer
- Category seed
- Region seed
- Public Reference API
- OTP auth poydevori
- JWT guard va `GET /auth/me`
- Public Listing Read API
- Authenticated Listing Create API
- My Listings API
- Listing update/archive API
- Listing image upload
- Admin listing moderation
- Complaint create API
- Admin complaints API
- AI questions API
- Local AI provider
- Admin users monitoring API
- Error response standard
- Pagination helper
- Security hardening: Helmet, CORS, rate limit, body limit, uploads static
- Swagger/OpenAPI docs
- Unit/e2e tests
- Docker production config
- Production seed strategy

## Endpointlar Ro'yxati

To'liq endpoint katalogi: [API_ENDPOINTS.md](./API_ENDPOINTS.md)

Asosiy guruhlar:

- Health: `GET /health`
- Auth: OTP request/verify va `GET /auth/me`
- Reference: categories va regions
- Listings: public list/detail, create, my listings, update, archive, image upload
- Complaints: user complaint create
- AI: question create, my questions
- Admin: listing moderation, complaint moderation, users monitoring

## Environment Variables

Development va umumiy backend env qiymatlari:

- `NODE_ENV`
- `PORT`
- `DATABASE_URL`
- `JWT_SECRET`
- `JWT_EXPIRES_IN`
- `OTP_SECRET`
- `OTP_EXPIRES_MINUTES`
- `DEV_OTP_CODE`
- `UPLOAD_DIR`
- `PUBLIC_BASE_URL`
- `MAX_IMAGE_SIZE_MB`
- `AI_PROVIDER`
- `CORS_ORIGIN`
- `RATE_LIMIT_TTL`
- `RATE_LIMIT_MAX`
- `BODY_LIMIT`
- `SWAGGER_ENABLED`
- `SWAGGER_PATH`

Production Docker/PostgreSQL env qiymatlari:

- `POSTGRES_DB`
- `POSTGRES_USER`
- `POSTGRES_PASSWORD`

Productionda `JWT_SECRET`, `OTP_SECRET` va `POSTGRES_PASSWORD` kuchli random qiymatlar bilan almashtirilishi shart.

## Docker Production Tartibi

Production Docker fayllari:

- `Dockerfile`
- `docker-compose.prod.yml`
- `.dockerignore`
- `.env.production.example`

Tavsiya qilingan production start tartibi:

```bash
cp .env.production.example .env.production
docker compose -f docker-compose.prod.yml up -d postgres
npm run docker:prod:migrate
npm run docker:prod:seed
docker compose -f docker-compose.prod.yml up -d app
curl http://localhost:3000/health
curl http://localhost:3000/reference/categories
curl http://localhost:3000/reference/regions
```

Docker services:

- `postgres`: PostgreSQL 16 Alpine, `postgres_data` volume bilan.
- `migrate`: Prisma migration deploy uchun alohida service.
- `seed`: production DB reference seed uchun alohida service.
- `app`: NestJS production runner, `uploads_data` volume bilan.

## Seed Tartibi

Seed fayli: `prisma/seed.ts`

Seed quyidagilarni qo'shadi:

- 5 ta MVP category
- Samarqand viloyati
- Oqdaryo tumani

Seed idempotent:

- Category `slug` orqali `upsert` qilinadi.
- Region `nameUz`, `type`, `parentId` orqali qidirilib update/create qilinadi.
- Qayta ishlatilganda duplicate yaratmasligi kerak.

Development seed:

```bash
npm run prisma:seed
```

Production seed:

```bash
npm run docker:prod:seed
```

## Test Tartibi

Build:

```bash
npm run build
```

Unit testlar:

```bash
npm test
```

E2E testlar:

```bash
npm run test:e2e
```

Coverage:

```bash
npm run test:cov
```

Hozirgi test coverage poydevori:

- Pagination helper unit tests
- OTP util unit tests
- Local AI provider unit tests
- Security config unit tests
- Health e2e test
- Validation error format e2e test

## Security Holati

Mavjud security qatlamlari:

- Helmet HTTP security headers
- CORS env orqali boshqariladi
- Global rate limit
- JSON/urlencoded body limit
- JWT access token guard
- Role guard admin endpointlar uchun
- Global ValidationPipe
- Global HttpExceptionFilter
- Upload file size/type checks
- Production Docker app non-root user bilan ishlaydi

Production checklistda quyidagilar majburiy:

- `JWT_SECRET` almashtirilgan bo'lishi
- `OTP_SECRET` almashtirilgan bo'lishi
- `POSTGRES_PASSWORD` almashtirilgan bo'lishi
- `CORS_ORIGIN` production domain bilan sozlangan bo'lishi
- `SWAGGER_ENABLED=false` yoki docs himoyalangan bo'lishi
- rate limit production trafik uchun qayta ko'rib chiqilishi
- uploads volume saqlanishi va backup strategiyasi bo'lishi

## Swagger Docs Manzili

Development muhitida Swagger UI:

```bash
GET /docs
```

OpenAPI JSON:

```bash
GET /docs-json
```

Productionda `SWAGGER_ENABLED=false` tavsiya qilinadi yoki docs alohida himoyalanishi kerak.

## Known Limitations

- Haqiqiy SMS provider hali ulanmagan.
- Real AI provider hali ulanmagan, local/mock provider ishlayapti.
- Payment/order/booking hali yo'q.
- Push notification hali yo'q.
- Image delete hali yo'q.
- Admin panel UI hali yo'q.
- Mobile app hali yo'q.
- Production observability/log monitoring hali to'liq emas.
- Refresh token hali yo'q.
- OTP phone-based advanced rate limit hali yo'q.

## Keyingi Bosqich Tavsiyalari

- Production SMS provider integratsiyasi.
- Real AI provider va prompt/safety policy.
- Refresh token va session management.
- OTP phone-based advanced rate limiting.
- Image delete/reorder va object storage strategy.
- Admin panel UI.
- Mobile app API integration.
- Observability: structured logs, metrics, alerting.
- Production backup/restore runbook.
- CI pipeline: build, test, Docker build, migration dry run.
- Expanded integration/e2e tests uchun dedicated test database.

## Audit Xulosasi

Backend MVP v0.1 asosiy API, seed, security, docs, test va Docker production poydevori bilan yopishga tayyor. Known limitations MVP scope tashqarisidagi keyingi bosqich ishlaridir.
