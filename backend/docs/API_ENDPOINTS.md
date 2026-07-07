# QISHLOQ AI Backend API Endpoints

## Health

- `GET /health`

## Auth

- `POST /auth/request-otp`
  - Request Body: `{"phone": "+998XXXXXXXXX"}`
  - Response (Development Mode: `SMS_PROVIDER=dev`):
    ```json
    {
      "message": "OTP code generated",
      "expiresInMinutes": 5,
      "devCode": "111111",
      "devOtp": "111111"
    }
    ```
  - Response (Real Provider Mode):
    ```json
    {
      "message": "OTP code generated",
      "expiresInMinutes": 5
    }
    ```
- `POST /auth/verify-otp`
  - Request Body:
    ```json
    {
      "phone": "+998XXXXXXXXX",
      "code": "111111",
      "role": "FARMER",
      "fullName": "Ali Valiyev",
      "address": "Oqdaryo tumani"
    }
    ```
  - Response:
    ```json
    {
      "accessToken": "jwt_token_here",
      "user": {
        "id": "user-uuid",
        "phone": "+998XXXXXXXXX",
        "role": "FARMER",
        "isVerified": true,
        "profile": {
          "fullName": "Ali Valiyev",
          "regionId": null,
          "address": "Oqdaryo tumani"
        }
      }
    }
    ```
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

## Chat (Step 72)

- `POST /conversations` - Start or fetch conversation for a listing
- `GET /conversations/my` - List current user conversations (inbox)
- `GET /conversations/:id/messages` - Get messages in a conversation
- `POST /conversations/:id/messages` - Send a message to a conversation

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
- `POST /conversations`
- `GET /conversations/my`
- `GET /conversations/:id/messages`
- `POST /conversations/:id/messages`


Admin-only endpoints:

- `GET /admin/listings`
- `PATCH /admin/listings/:id/moderate`
- `GET /admin/complaints`
- `PATCH /admin/complaints/:id/status`
- `GET /admin/users`
- `GET /admin/users/:id`
- `GET /admin/ai-questions`
- `GET /admin/ai-questions/:id`
