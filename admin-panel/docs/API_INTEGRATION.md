# QISHLOQ AI Admin Panel API Integration

Admin panel backend API base URL qiymatini `NEXT_PUBLIC_API_BASE_URL` environment variable orqali oladi. Local default:

```bash
NEXT_PUBLIC_API_BASE_URL=http://localhost:3000
```

## Auth

- `POST /auth/request-otp`
- `POST /auth/verify-otp`
- `GET /auth/me`

`GET /auth/me` protected route access tekshiruvi va valid token mavjud bo'lganda login sahifasidan dashboardga redirect qilish uchun ishlatiladi.

## Dashboard

- `GET /admin/users?page=1&limit=1`
- `GET /admin/listings?page=1&limit=1&status=PENDING`
- `GET /admin/listings?page=1&limit=1&status=ACTIVE`
- `GET /admin/complaints?page=1&limit=1&status=OPEN`

Dashboard cardlari paginated responsedagi `meta.total` qiymatini ishlatadi.

## Listings

- `GET /admin/listings`
- `PATCH /admin/listings/:id/moderate`

Listing list sahifasi status/type/search UI va pagination bilan ishlaydi. Moderation body:

```json
{
  "status": "ACTIVE"
}
```

Allowed moderation values: `ACTIVE`, `REJECTED`.

## Complaints

- `GET /admin/complaints`
- `PATCH /admin/complaints/:id/status`

Complaint status update body:

```json
{
  "status": "IN_REVIEW"
}
```

Allowed update values: `IN_REVIEW`, `RESOLVED`, `REJECTED`.

## Users

- `GET /admin/users`
- `GET /admin/users/:id`

Users monitoring sahifasi role, active, verified va search query paramlarini ishlatadi.

## AI Questions

- `GET /admin/ai-questions`
- `GET /admin/ai-questions/:id`

AI questions sahifasi `page`, `limit`, `status` va `search` query paramlarini ishlatadi. `userId` lib type darajasida qo'llab-quvvatlanadi, lekin hozircha UI filter sifatida ko'rsatilmaydi.
