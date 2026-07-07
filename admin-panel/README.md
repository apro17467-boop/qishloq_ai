# QISHLOQ AI Admin Panel

Admin panel skeleton for the QISHLOQ AI backend MVP. Login is wired to the backend auth API, while protected layouts and full admin pages are intentionally left for later steps.

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

Next step: connect dashboard, listings, complaints, and users screens to real backend APIs.

## Current Scope

- Login screen connected to backend OTP auth
- Protected dashboard skeleton
- Admin layout shell
- Shared UI primitives
- API and environment helpers

Next step: connect dashboard real APIs.
