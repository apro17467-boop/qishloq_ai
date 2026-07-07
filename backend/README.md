# QISHLOQ AI Backend

NestJS backend skeleton for the QISHLOQ AI MVP.

## Backend MVP Status

Backend MVP v0.1 poydevori tayyor: health, Prisma/PostgreSQL, seed, reference API, OTP auth, JWT `/auth/me`, listings, image upload, complaints, admin moderation, admin users monitoring, admin AI questions monitoring, AI questions, error standard, pagination, security, Swagger, tests va production Docker config mavjud.

Yakuniy audit va release hujjatlari:

- [Backend MVP Audit](docs/BACKEND_MVP_AUDIT.md)
- [API Endpoints](docs/API_ENDPOINTS.md)
- [Release Checklist](docs/RELEASE_CHECKLIST.md)

## Ishga tushirish

```bash
npm install
```

```bash
docker compose up -d
```

```bash
npm run start:dev
```

Health check:

```bash
GET http://localhost:3000/health
```

Expected response:

```json
{
  "status": "ok",
  "service": "qishloq-ai-backend"
}
```

## Testing

Unit testlarni ishga tushirish:

```bash
npm test
```

Minimal e2e testlarni ishga tushirish:

```bash
npm run test:e2e
```

Coverage hisoboti:

```bash
npm run test:cov
```

Unit testlar pagination helperlar, OTP util funksiyalari, local AI provider va security config helperlarini qamrab oladi.

Hozircha e2e testlar faqat databasega yozmaydigan yengil holatlarni tekshiradi: `GET /health` va invalid `POST /auth/request-otp` validation error formati. Database integration testlari keyingi bosqichda alohida setup/cleanup bilan qo'shiladi.

## Production Docker

Production compose uchun avval `.env.production.example` asosida `.env.production` yarating va barcha maxfiy qiymatlarni almashtiring:

```bash
cp .env.production.example .env.production
```

Albatta `JWT_SECRET`, `OTP_SECRET` va `POSTGRES_PASSWORD` qiymatlarini kuchli random secretlarga almashtiring. Production muhitida `SWAGGER_ENABLED=false` tavsiya qilinadi.

To'liq production start tartibi:

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

Image build:

```bash
npm run docker:prod:build
```

PostgreSQL start:

```bash
docker compose -f docker-compose.prod.yml up -d postgres
```

Migration:

```bash
npm run docker:prod:migrate
```

Production seed:

```bash
npm run docker:prod:seed
```

App start:

```bash
docker compose -f docker-compose.prod.yml up -d app
```

Logs:

```bash
npm run docker:prod:logs
```

Health check:

```bash
curl http://localhost:3000/health
```

Reference data tekshirish:

```bash
curl http://localhost:3000/reference/categories
curl http://localhost:3000/reference/regions
```

`docker-compose.prod.yml` ichida `postgres_data` volume database fayllarini, `uploads_data` volume esa `/app/uploads` ichidagi upload fayllarni saqlaydi.

Agar local Docker Compose `service_completed_successfully` shartini qo'llamasa, quyidagi tartibdan foydalaning:

```bash
docker compose -f docker-compose.prod.yml up -d postgres
npm run docker:prod:migrate
npm run docker:prod:seed
docker compose -f docker-compose.prod.yml up -d app
```

## Production Seed

Production seed migrationdan keyin bajarilishi kerak:

```bash
npm run docker:prod:seed
```

Seed Category va pilot Region ma'lumotlarini qo'shadi:

- 5 ta MVP category
- Samarqand viloyati
- Oqdaryo tumani

Seed idempotent: qayta ishga tushirilsa duplicate category yoki region yaratmaydi.

Tekshirish:

```bash
curl http://localhost:3000/reference/categories
curl http://localhost:3000/reference/regions
```

## Seed

Reference data seed Category va pilot Region ma'lumotlarini qo'shadi:

```bash
npm run prisma:seed
```

## Public Reference Endpoints

```bash
GET /reference/categories
```

```bash
GET /reference/regions
```

## Public Listing API

```bash
GET /listings
```

Query parametrlari:

- `page`
- `limit`
- `type`
- `categoryId`
- `regionId`
- `search`

```bash
GET /listings/:id
```

Public listing endpointlari faqat `ACTIVE` va o'chirilmagan e'lonlarni qaytaradi.

## Favorites API

Favorites endpointlari JWT auth talab qiladi va faqat joriy user ma'lumotlari bilan ishlaydi:

```bash
GET /favorites/my?page=1&limit=10
GET /favorites/ids
POST /favorites/:listingId
DELETE /favorites/:listingId
```

Favorite qo'shish idempotent: e'lon allaqachon sevimlilarda bo'lsa ham xato qaytarmaydi. O'chirish ham idempotent: favorite mavjud bo'lmasa ham muvaffaqiyatli javob qaytaradi.

## Public Seller API

Seller profile endpointlari public ishlaydi va faqat xavfsiz public ma'lumotlarni qaytaradi. Seller profilida telefon raqam chiqmaydi; aloqa raqami faqat listing `contactPhone` fieldida qoladi.

```bash
GET /sellers/:sellerId
GET /sellers/:sellerId/listings?page=1&limit=10
```

`GET /sellers/:sellerId/listings` faqat sellerning `ACTIVE` va o'chirilmagan e'lonlarini qaytaradi. Request JWT bilan kelsa, listinglarda `isFavorite` joriy userga mos hisoblanadi; tokensiz request ham ishlaydi.

## Pagination

Paginated endpointlar umumiy `meta` formatidan foydalanadi:

```json
{
  "page": 1,
  "limit": 20,
  "total": 10,
  "totalPages": 1
}
```

Default qiymatlar: `page=1`, `limit=20`. Maksimal `limit=50`.

```bash
POST /listings
```

`POST /listings` uchun `Authorization: Bearer <accessToken>` header kerak. Yangi e'lonlar `PENDING` statusida yaratiladi va public listing ro'yxatida faqat `ACTIVE` e'lonlar ko'rinadi.

## My Listings API

```bash
GET /listings/my
```

`GET /listings/my` uchun `Authorization: Bearer <accessToken>` header kerak.

Query parametrlari:

- `page`
- `limit`
- `status`
- `type`

Bu endpoint foydalanuvchining o'z e'lonlarini ko'rsatadi. `PENDING` e'lonlar public ro'yxatda ko'rinmaydi, lekin `/listings/my` javobida ko'rinadi.

## Listing Update And Archive API

```bash
PATCH /listings/:id
```

```bash
PATCH /listings/:id/archive
```

Bu endpointlar uchun `Authorization: Bearer <accessToken>` header kerak. Faqat owner o'z listingini tahrirlashi yoki arxivga olishi mumkin.

Tahrirdan keyin listing statusi `PENDING` bo'ladi. Archive qilingandan keyin listing public ro'yxatda ko'rinmaydi.

## Listing Image Upload

```bash
POST /listings/:id/images
```

`POST /listings/:id/images` uchun `Authorization: Bearer <accessToken>` header kerak.

Request `multipart/form-data` bo'lishi kerak:

- field name: `image`
- allowed: `jpg`, `png`, `webp`
- max size: `5MB`
- max images per listing: `5`

MVP bosqichida rasmlar local storage orqali `uploads/listings/` ichiga saqlanadi va `/uploads` static prefix orqali ochiladi. Keyingi bosqichda shu qatlam S3/CDN ga ko'chirishga tayyor.

## Complaint API

```bash
POST /complaints
```

`POST /complaints` uchun `Authorization: Bearer <accessToken>` header kerak.

Body maydonlari:

- `listingId`: shikoyat qilinayotgan listing UUID qiymati
- `reason`: `FRAUD`, `WRONG_INFO`, `SOLD_ALREADY`, `SPAM`, `PROHIBITED_ITEM`, `OTHER`
- `message`: optional, maksimal `1000` belgi

Foydalanuvchi o'z listingi ustidan shikoyat yubora olmaydi. Bitta user bitta listing bo'yicha `OPEN` yoki `IN_REVIEW` holatdagi takroriy complaint yubora olmaydi.

## AI API

AI provider hozircha local/mock rejimda ishlaydi:

```bash
AI_PROVIDER=local
```

Haqiqiy AI provider hali ulanmagan va tashqi AI API chaqirilmaydi.

```bash
POST /ai/questions
```

```bash
GET /ai/questions/my
```

AI endpointlari uchun `Authorization: Bearer <accessToken>` header kerak.

`POST /ai/questions` body:

- `question`: required, minimum `10` belgi, maksimum `3000` belgi

`GET /ai/questions/my` query parametrlari:

- `page`
- `limit`
- `status`

`POST /ai/questions` local/mock provider orqali javob yaratadi va muvaffaqiyatli holatda savol `ANSWERED` status bilan qaytadi.

AI maslahat yakuniy agronom yoki veterinar xulosasi o'rnini bosmaydi.

## Security

Backend security sozlamalari:

- Helmet HTTP security headerlarini qo'shadi.
- CORS `CORS_ORIGIN` orqali comma-separated originlar ro'yxatidan o'qiladi.
- Rate limit `RATE_LIMIT_TTL` va `RATE_LIMIT_MAX` orqali sozlanadi.
- JSON va urlencoded body size `BODY_LIMIT` orqali cheklanadi.
- `uploads/listings/` static fayllari `/uploads` prefix orqali ishlashda davom etadi.

`.env` qiymatlari:

```bash
CORS_ORIGIN=http://localhost:3000,http://localhost:3001,http://localhost:5173
RATE_LIMIT_TTL=60
RATE_LIMIT_MAX=100
BODY_LIMIT=2mb
```

Rate limit oshib ketganda API `429 TOO_MANY_REQUESTS` qaytaradi va error response global standard formatda bo'ladi.

## API Documentation

Swagger/OpenAPI documentation development muhitida quyidagi manzilda ochiladi:

```bash
GET /docs
```

`.env` qiymatlari:

```bash
SWAGGER_ENABLED=true
SWAGGER_PATH=docs
```

Swagger UI ichida Bearer tokenni `Authorize` tugmasi orqali kiritish mumkin. Production muhitida Swagger documentationni `SWAGGER_ENABLED=false` yoki envda `true` qilmaslik orqali o'chirish tavsiya qilinadi.

## Error Response Standard

Success response formatlari o'zgarmagan: mavjud endpointlar avvalgidek `data`, `meta` yoki `message` maydonlarini qaytaradi. Faqat error response yagona formatga keltirilgan.

Umumiy error response:

```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human readable message",
    "details": []
  },
  "statusCode": 400,
  "path": "/api/path",
  "timestamp": "2026-07-06T00:00:00.000Z"
}
```

Validation error misoli:

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": [
      "phone must match /^\\+998\\d{9}$/ regular expression"
    ]
  },
  "statusCode": 400,
  "path": "/auth/request-otp",
  "timestamp": "2026-07-06T00:00:00.000Z"
}
```

401/403/404 xatolar mos ravishda `UNAUTHORIZED`, `FORBIDDEN`, `NOT_FOUND` kodlari bilan qaytadi. Katta fayl yuborilganda `PAYLOAD_TOO_LARGE`, kutilmagan xatolarda `INTERNAL_SERVER_ERROR` ishlatiladi.

## Admin Moderation API

```bash
GET /admin/listings
```

```bash
PATCH /admin/listings/:id/moderate
```

Admin moderation endpointlari uchun `Authorization: Bearer <adminAccessToken>` header kerak. Faqat `ADMIN` role ishlatishi mumkin.

`ACTIVE` qilingan listing public ro'yxatda ko'rinadi. `REJECTED` qilingan listing public ro'yxatda ko'rinmaydi, lekin owner `/listings/my` orqali ko'ra oladi.

## Admin Complaints API

```bash
GET /admin/complaints
```

```bash
PATCH /admin/complaints/:id/status
```

Admin complaint endpointlari uchun `Authorization: Bearer <adminAccessToken>` header kerak. Faqat `ADMIN` role ishlatishi mumkin.

`GET /admin/complaints` query parametrlari:

- `page`
- `limit`
- `status`
- `listingId`
- `reporterId`

Default `status` qiymati `OPEN`. Complaint statuslari: `OPEN`, `IN_REVIEW`, `RESOLVED`, `REJECTED`. Admin statusni faqat `IN_REVIEW`, `RESOLVED` yoki `REJECTED` ga o'zgartira oladi; `RESOLVED` va `REJECTED` complaintlar final hisoblanadi.

## Admin Users Monitoring API

```bash
GET /admin/users
```

```bash
GET /admin/users/:id
```

Admin users endpointlari uchun `Authorization: Bearer <adminAccessToken>` header kerak. Faqat `ADMIN` role ishlatishi mumkin.

`GET /admin/users` query parametrlari:

- `page`
- `limit`
- `role`
- `isActive`
- `isVerified`
- `search`

Endpointlar read-only: user block/unblock, role update yoki delete amallari bajarilmaydi. Response foydalanuvchi profile, region va monitoring statslarini qaytaradi.

## Admin AI Questions Monitoring API

```bash
GET /admin/ai-questions
```

```bash
GET /admin/ai-questions/:id
```

Admin AI questions endpointlari uchun `Authorization: Bearer <adminAccessToken>` header kerak. Faqat `ADMIN` role ishlatishi mumkin.

`GET /admin/ai-questions` query parametrlari:

- `page`
- `limit`
- `status`
- `userId`
- `search`

Endpointlar read-only: admin barcha foydalanuvchilarning AI savollarini monitoring qiladi. Real AI provider hali ulanmagan, local/mock provider ishlaydi.

## Auth

```bash
POST /auth/request-otp
```

```bash
POST /auth/verify-otp
```

```bash
GET /auth/me
```

Development rejimida `request-otp` javobida `devCode` qaytadi. Haqiqiy SMS provider hali ulanmagan.

`/auth/me` uchun `Authorization: Bearer <accessToken>` header kerak.
