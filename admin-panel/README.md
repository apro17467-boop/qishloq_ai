# QISHLOQ AI Admin Panel

Admin panel skeleton for the QISHLOQ AI backend MVP. Login, protected dashboard access, logout, and dashboard totals are wired to existing backend APIs, while full admin list pages are intentionally left for later steps.

## Tech Stack

- Next.js
- TypeScript
- Tailwind CSS
- ESLint
- App Router

## Getting Started

```bash
npm install
npm run dev
```

Open:

```bash
http://localhost:3001/login
http://localhost:3001/dashboard
```

## Environment Variables

Create `.env.local` from `.env.example` when needed:

```bash
NEXT_PUBLIC_API_BASE_URL=http://localhost:3000
```

The backend API must be running separately. The default API base URL points to the local backend.

## Auth Login

Backend must be running at:

```bash
http://localhost:3000
```

Admin panel usually runs at:

```bash
http://localhost:3001
```

Connected backend auth endpoints:

- `POST /auth/request-otp`
- `POST /auth/verify-otp`
- `GET /auth/me`

During development, the backend allows creating an `ADMIN` role through the OTP verify flow. In production, admin users should be created through a controlled internal process.

The access token is stored in browser `localStorage` under `qishloq_ai_admin_token`.

## Protected Admin Routes

`/dashboard` requires a valid localStorage token and an active `ADMIN` user from `GET /auth/me`. If the token is missing, invalid, inactive, or belongs to a non-admin user, the app clears the token and redirects back to `/login`.

The header includes a `Chiqish` button. Logout clears `qishloq_ai_admin_token` from localStorage and redirects to `/login`.

## Dashboard Data

The dashboard cards read real totals from existing backend APIs. The app uses `meta.total` from paginated responses and does not require a dedicated dashboard endpoint yet.

Used endpoints:

- `GET /admin/users?page=1&limit=1`
- `GET /admin/listings?page=1&limit=1&status=PENDING`
- `GET /admin/listings?page=1&limit=1&status=ACTIVE`
- `GET /admin/complaints?page=1&limit=1&status=OPEN`

The backend and admin panel must run at the same time for dashboard data to load.

Next step: connect listings, complaints, and users screens to real backend APIs.

## Listings Page

`/listings` shows admin listing data from the existing backend endpoint:

- `GET /admin/listings`

Supported UI controls:

- Status filter: `PENDING`, `ACTIVE`, `REJECTED`, `ARCHIVED`
- Type filter: `MACHINERY_RENT`, `PRODUCT_SALE`, `LIVESTOCK_SALE`, `MACHINERY_SALE`, `SERVICE`
- Search input with explicit `Qidirish` and `Tozalash` buttons
- Pagination with `Oldingi` and `Keyingi`

Moderation actions are available for `PENDING` listings.

## Listings Moderation

Pending listings can be moderated from `/listings` using the existing backend endpoint:

- `PATCH /admin/listings/:id/moderate`

Backend DTO body:

```json
{
  "status": "ACTIVE"
}
```

Allowed `status` values are `ACTIVE` and `REJECTED`. Only `PENDING` rows show moderation buttons. `ACTIVE`, `REJECTED`, and `ARCHIVED` rows show their finalized state instead.

Next step: connect the complaints page.

## Complaints Page

`/complaints` shows admin complaint data from:

- `GET /admin/complaints`

### Query Parameters

| Param  | Type            | Default | Description                      |
|--------|-----------------|---------|----------------------------------|
| page   | number (min 1)  | 1       | Page number                      |
| limit  | number (1–50)   | 10      | Items per page                   |
| status | ComplaintStatus | OPEN    | Required — always sent to backend |

> **Note:** Backend DTO da `reason` va `search` parametrlari mavjud emas.
> `status` har doim aniq qiymat bilan yuboriladi (default: `OPEN`).

### UI Filters

- **Status filter** — 4 ta variant: `OPEN`, `IN_REVIEW`, `RESOLVED`, `REJECTED`
- **"Barchasi"** varianti yo'q — backend barcha statusni bir request da qo'llamaydi
- **Reason filter UI da yo'q** — backend DTO da `reason` query param qo'llanmaydi
- Reason faqat jadvalda o'zbekcha **label** sifatida ko'rsatiladi

### Status Values

| Value     | Label              | Badge colour |
|-----------|--------------------|--------------|
| OPEN      | Ochiq              | Amber        |
| IN_REVIEW | Ko'rib chiqilmoqda | Blue         |
| RESOLVED  | Hal qilingan       | Emerald      |
| REJECTED  | Rad etilgan        | Slate/grey   |

### Reason Labels (client-side display only)

Backend `reason` fieldi oddiy `String` saqlanadi (Prisma enumi emas).
Jadvalda o'zbekcha ko'rsatiladi:

| Raw value     | Label              |
|---------------|--------------------|
| FRAUD         | Firibgarlik        |
| SPAM          | Spam               |
| WRONG_INFO    | Noto'g'ri ma'lumot |
| INAPPROPRIATE | Nomaqbul kontent   |
| DUPLICATE     | Takroriy e'lon     |
| OTHER         | Boshqa             |

Noma'lum qiymatlar raw holida ko'rsatiladi.

### Empty State

Tanlangan statusga mos matn chiqadi:
- OPEN → "Ochiq shikoyatlar topilmadi."
- IN_REVIEW → "Ko'rib chiqilayotgan shikoyatlar topilmadi."
- RESOLVED → "Hal qilingan shikoyatlar topilmadi."
- REJECTED → "Rad etilgan shikoyatlar topilmadi."

### Table Columns

- Sabab, Status, E'lon, Shikoyatchi, E'lon egasi, Xabar, Sana, Amal

Xabar 90 belgidan uzun bo'lsa qisqartiriladi.

### Pagination

Pastda `Oldingi` / `Keyingi` tugmalari va jami hisobi ko'rsatiladi.

### Complaint Status Update (Step 39)

`PATCH /admin/complaints/:id/status` endpointi ulangan.
- `OPEN` shikoyatlarni `IN_REVIEW` yoki `REJECTED` qilish mumkin.
- `IN_REVIEW` shikoyatlarni `RESOLVED` yoki `REJECTED` qilish mumkin.
- `RESOLVED` / `REJECTED` holatlar yakuniy hisoblanadi.
- Backend DTO qabul qiladigan parametr faqat `{ status }`.

## Current Scope

- Login screen connected to backend OTP auth
- Protected dashboard with real backend totals
- Protected listings table with filters, pagination, and moderation
- Protected complaints table with status filter and pagination
- Admin layout shell (Sidebar, Header, AdminShell)
- Shared UI primitives (Badge, Button, Card, Input)
- API and environment helpers

Next step: complaint status update (Step 39).
