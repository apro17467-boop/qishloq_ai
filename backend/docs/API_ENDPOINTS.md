# QISHLOQ AI Backend API Endpoints

## Health

- `GET /health`

## Auth

- `POST /auth/request-otp`
- `POST /auth/verify-otp`
- `GET /auth/me`

## Reference

- `GET /reference/categories`
- `GET /reference/regions`

## Listings

- `GET /listings`
- `GET /listings/:id`
- `POST /listings`
- `GET /listings/my`
- `PATCH /listings/:id`
- `PATCH /listings/:id/archive`
- `POST /listings/:id/images`

## Favorites

- `GET /favorites/my`
- `GET /favorites/ids`
- `POST /favorites/:listingId`
- `DELETE /favorites/:listingId`

## Sellers

- `GET /sellers/:sellerId`
- `GET /sellers/:sellerId/listings`

## Complaints

- `POST /complaints`

## AI

- `POST /ai/questions`
- `GET /ai/questions/my`

## Admin

- `GET /admin/listings`
- `PATCH /admin/listings/:id/moderate`
- `GET /admin/complaints`
- `PATCH /admin/complaints/:id/status`
- `GET /admin/users`
- `GET /admin/users/:id`
- `GET /admin/ai-questions`
- `GET /admin/ai-questions/:id`

## Auth Requirements

Public endpoints:

- `GET /health`
- `POST /auth/request-otp`
- `POST /auth/verify-otp`
- `GET /reference/categories`
- `GET /reference/regions`
- `GET /listings`
- `GET /listings/:id`
- `GET /sellers/:sellerId`
- `GET /sellers/:sellerId/listings`

Authenticated user endpoints:

- `GET /auth/me`
- `POST /listings`
- `GET /listings/my`
- `PATCH /listings/:id`
- `PATCH /listings/:id/archive`
- `POST /listings/:id/images`
- `GET /favorites/my`
- `GET /favorites/ids`
- `POST /favorites/:listingId`
- `DELETE /favorites/:listingId`
- `POST /complaints`
- `POST /ai/questions`
- `GET /ai/questions/my`

Admin-only endpoints:

- `GET /admin/listings`
- `PATCH /admin/listings/:id/moderate`
- `GET /admin/complaints`
- `PATCH /admin/complaints/:id/status`
- `GET /admin/users`
- `GET /admin/users/:id`
- `GET /admin/ai-questions`
- `GET /admin/ai-questions/:id`
