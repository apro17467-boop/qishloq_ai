# QISHLOQ AI Admin Panel Audit

## Admin Panel Umumiy Holati

QISHLOQ AI admin panel v0.1 Next.js, TypeScript, Tailwind CSS va App Router asosida tayyorlangan. Panel backend MVP API'lariga ulangan va admin foydalanuvchi uchun login, protected routes, dashboard monitoring, listing moderation, complaint status update, users monitoring va AI questions monitoring oqimlarini qamrab oladi.

Admin panel backenddan alohida ishlaydi. Local backend default `http://localhost:3000`, admin panel esa `http://localhost:3001` portida ishlaydi.

## Tayyor Sahifalar

- `/login` - admin OTP login flow.
- `/dashboard` - asosiy admin statistikalar.
- `/listings` - e'lonlar ro'yxati, filterlar, pagination va moderation.
- `/complaints` - shikoyatlar ro'yxati, status filter va status update.
- `/users` - foydalanuvchilar monitoringi, filterlar, search, pagination va detail modal.
- `/ai-questions` - AI savollar monitoringi, status/search filter, pagination va detail modal.

## Ulangan Backend API'lar

- Auth: `POST /auth/request-otp`, `POST /auth/verify-otp`, `GET /auth/me`
- Dashboard: `GET /admin/users`, `GET /admin/listings`, `GET /admin/complaints`
- Listings: `GET /admin/listings`, `PATCH /admin/listings/:id/moderate`
- Complaints: `GET /admin/complaints`, `PATCH /admin/complaints/:id/status`
- Users: `GET /admin/users`, `GET /admin/users/:id`
- AI Questions: `GET /admin/ai-questions`, `GET /admin/ai-questions/:id`

## Auth Flow

Admin login telefon raqam orqali OTP so'rash va OTP tasdiqlash oqimidan foydalanadi. Development rejimida backend `devCode` qaytaradi. Login muvaffaqiyatli bo'lsa access token `localStorage` ichida `qishloq_ai_admin_token` key bilan saqlanadi.

`GET /auth/me` orqali token validligi, user active holati va `ADMIN` role tekshiriladi.

## Protected Routes

Quyidagi sahifalar `ProtectedAdminRoute` bilan himoyalangan:

- `/dashboard`
- `/listings`
- `/complaints`
- `/users`
- `/ai-questions`

Token yo'q, invalid, inactive yoki non-admin bo'lsa token tozalanadi va user `/login` sahifasiga qaytariladi.

## Dashboard Stats

Dashboard alohida backend dashboard endpoint talab qilmaydi. Mavjud paginated endpointlardan `meta.total` qiymatlarini o'qiydi:

- users total
- pending listings
- active listings
- open complaints

## Listings Va Moderation

`/listings` sahifasi e'lonlarni status, type va search orqali ko'rsatadi. `PENDING` e'lonlar uchun `ACTIVE` yoki `REJECTED` moderation actionlari mavjud. Final holatdagi e'lonlarda action o'rniga yakuniy status ko'rsatiladi.

## Complaints Va Status Update

`/complaints` sahifasi shikoyatlarni status bo'yicha ko'rsatadi. `OPEN` shikoyatlarni `IN_REVIEW` yoki `REJECTED` qilish, `IN_REVIEW` shikoyatlarni `RESOLVED` yoki `REJECTED` qilish mumkin.

## Users Monitoring

`/users` sahifasi foydalanuvchilarni role, active, verified va search bo'yicha ko'rsatadi. Detail modal foydalanuvchi profile, stats va oxirgi activity ma'lumotlarini ko'rsatadi. Role update, block yoki delete actionlari mavjud emas.

## AI Questions Monitoring

`/ai-questions` sahifasi barcha foydalanuvchilarning AI savollarini ko'rsatadi. Status filter, search, pagination va detail modal mavjud. AI question uchun update/action yo'q, faqat monitoring bor.

## Known Limitations

- Admin panel hali serverga deploy qilinmagan.
- Real production domain yo'q.
- Refresh token yo'q, token `localStorage`da saqlanmoqda.
- Role management yo'q.
- User block/delete yo'q.
- Listing detail alohida sahifa yo'q, faqat ro'yxat va moderation bor.
- Complaint detail alohida sahifa yo'q, jadval/action bor.
- AI question update/action yo'q, faqat monitoring.
- Settings sahifasi hali yo'q.
- Automated browser test framework hali yo'q.

## Keyingi Bosqich Tavsiyalari

- Production hosting va domain sozlash.
- Refresh token yoki xavfsizroq session strategy.
- Role management va user block/unblock oqimlari.
- Listing va complaint detail sahifalari.
- Browser E2E test framework: Playwright yoki Cypress.
- UI accessibility va loading skeleton polish.
- Flutter mobile app MVP bosqichini boshlash.
