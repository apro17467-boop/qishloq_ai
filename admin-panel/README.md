# QISHLOQ AI Admin Panel

Admin panel skeleton for the QISHLOQ AI backend MVP. This app is prepared for future backend API integration, but login, token storage, and full admin pages are intentionally not implemented yet.

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
http://localhost:3000/login
http://localhost:3000/dashboard
```

## Environment Variables

Create `.env.local` from `.env.example` when needed:

```bash
NEXT_PUBLIC_API_BASE_URL=http://localhost:3000
```

The backend API must be running separately. The default API base URL points to the local backend.

## Current Scope

- Login screen skeleton
- Dashboard skeleton
- Admin layout shell
- Shared UI primitives
- API and environment helpers

Next step: connect admin auth flow to `/auth/request-otp`, `/auth/verify-otp`, and authenticated admin endpoints.
