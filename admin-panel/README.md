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

Moderation actions are intentionally not connected yet. The table includes a disabled `Ko'rish` placeholder for the next step.

## Current Scope

- Login screen connected to backend OTP auth
- Protected dashboard with real backend totals
- Protected listings table with filters and pagination
- Admin layout shell
- Shared UI primitives
- API and environment helpers

Next step: connect admin list screens.
