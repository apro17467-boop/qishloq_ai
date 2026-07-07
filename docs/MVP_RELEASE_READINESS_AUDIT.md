# QISHLOQ AI — MVP Release Readiness Audit

**Audit Date:** 2026-07-07  
**Audit Step:** 75 — MVP Release Readiness Audit + Production Hardening Checklist  
**Auditor:** Antigravity AI

---

## 1. Current MVP Scope

QISHLOQ AI is a local agro-marketplace platform for Uzbekistan. The MVP connects farmers, livestock owners, machinery owners, and buyers through a mobile application backed by a REST API, with an admin panel for content moderation.

### MVP Modules

| Module              | Backend | Mobile | Admin |
|---------------------|---------|--------|-------|
| OTP Auth (SMS)      | ✅      | ✅     | ✅    |
| Listings (CRUD)     | ✅      | ✅     | ✅    |
| Image Upload        | ✅      | ✅     | N/A   |
| Favorites           | ✅      | ✅     | N/A   |
| Seller Profile      | ✅      | ✅     | N/A   |
| Contact (Call/SMS)  | N/A     | ✅     | N/A   |
| Complaints          | ✅      | N/A    | ✅    |
| AI Advice           | ✅      | ✅     | ✅    |
| Chat (REST)         | ✅      | ✅     | N/A   |
| Admin Moderation    | ✅      | N/A    | ✅    |
| Admin Users         | ✅      | N/A    | ✅    |

---

## 2. Completed Modules

### Backend
- Health endpoint (`GET /health`)
- OTP-based auth with dev/prod SMS modes (`POST /auth/request-otp`, `POST /auth/verify-otp`, `GET /auth/me`)
- Listings: create, list, detail, my listings, update, archive, image upload
- Favorites: add, remove, list, ids
- Seller public profile + seller listings
- Complaints: submit, admin review
- Admin moderation: listings moderate, complaints status update, users monitoring, AI questions monitoring
- REST Chat MVP: create conversation, list inbox, message history, send message
- AI Advice: submit question, list my questions (local/mock provider)
- Reference data: categories, regions
- Security: Helmet, CORS, rate limiting, body size limits
- Swagger (`GET /docs`, disableable via env)
- Global error format standard
- Prisma schema with 4 migrations applied
- Docker Compose for dev and production
- 9 test suites, 37 tests — **all pass**

### Mobile App (Flutter)
- Splash screen with auth routing
- OTP login flow
- Listing list with filters and pagination
- Listing detail (gallery, info cards, contact actions, seller card, favorites)
- Create listing wizard (multi-step)
- My listings management
- Favorites page
- Seller profile page
- Chat inbox + chat thread (REST-only)
- AI Advice page
- Profile page with quick actions
- Contact via call, SMS, clipboard (url_launcher)
- `flutter analyze`: **No issues found**
- `flutter test`: **All tests passed** (2 smoke tests)
- Debug APK build: **✅ Success** (app-debug.apk ~175MB)

### Admin Panel (Next.js)
- Login with OTP flow
- Protected dashboard with real backend totals
- Listings table with moderation actions
- Complaints table with status update
- Users monitoring with detail modal
- AI questions monitoring with detail modal
- `npm run build`: **✅ Success** (all 8 routes statically prerendered)

---

## 3. Build & Test Results Summary

| Component      | Command              | Result                          |
|----------------|----------------------|---------------------------------|
| Backend        | `npx prisma validate`| ✅ Schema valid                 |
| Backend        | `npx prisma migrate status` | ✅ Database schema up to date (4 migrations) |
| Backend        | `npm run build`      | ✅ Exit code 0                  |
| Backend        | `npm test`           | ✅ 37/37 tests passed           |
| Mobile         | `flutter pub get`    | ✅ Dependencies resolved        |
| Mobile         | `flutter analyze`    | ✅ No issues found              |
| Mobile         | `flutter test`       | ✅ 2/2 tests passed             |
| Mobile         | `flutter build apk --debug` | ✅ app-debug.apk built    |
| Admin Panel    | `npm run build`      | ✅ All 8 routes built           |

> **Note:** Backend does not have a `npm run lint` script. ESLint is not currently configured for backend TypeScript files. This is a known gap — not a blocker for MVP pilot.

---

## 4. Backend Readiness

### Environment Variables (`.env.example`)

| Variable             | Required | Production Note                              |
|----------------------|----------|----------------------------------------------|
| `NODE_ENV`           | ✅       | Set to `production`                          |
| `PORT`               | ✅       | Default 3000                                 |
| `DATABASE_URL`       | ✅       | Change to production PostgreSQL URL          |
| `JWT_SECRET`         | ✅ **CRITICAL** | Must be a strong random secret in production |
| `JWT_EXPIRES_IN`     | ✅       | Review expiry window for production          |
| `OTP_SECRET`         | ✅ **CRITICAL** | Must be changed from placeholder           |
| `OTP_EXPIRES_MINUTES`| ✅       | Default 5 min is reasonable                  |
| `DEV_OTP_CODE`       | ⚠️       | Only used in `SMS_PROVIDER=dev` mode         |
| `UPLOAD_DIR`         | ✅       | Use Docker volume in production              |
| `PUBLIC_BASE_URL`    | ✅       | Set to production domain                     |
| `MAX_IMAGE_SIZE_MB`  | ✅       | Default 5MB                                  |
| `AI_PROVIDER`        | ⚠️       | Currently `local` (mock). Real provider TBD  |
| `CORS_ORIGIN`        | ✅ **CRITICAL** | Set to production mobile/admin origins    |
| `RATE_LIMIT_TTL`     | ✅       | Review for production traffic                |
| `RATE_LIMIT_MAX`     | ✅       | Review for production traffic                |
| `BODY_LIMIT`         | ✅       | Default 2mb                                  |
| `SWAGGER_ENABLED`    | ⚠️       | **Set `false` in production**                |
| `SMS_PROVIDER`       | ✅ **CRITICAL** | Change to `generic` or `eskiz` for real SMS |
| `SMS_DEV_CODE`       | ⚠️       | Only active in dev mode                      |
| `SMS_API_BASE_URL`   | ⚠️       | Required when `SMS_PROVIDER=generic`         |
| `SMS_API_TOKEN`      | ⚠️       | Required for real SMS — never commit to git  |
| `SMS_API_LOGIN`      | ⚠️       | Required for real SMS — never commit to git  |
| `SMS_API_PASSWORD`   | ⚠️       | Required for real SMS — never commit to git  |

### Security Configuration
- ✅ Helmet HTTP security headers applied
- ✅ CORS configured via `CORS_ORIGIN` env variable
- ✅ Rate limiting: `ThrottlerModule` applied
- ✅ Body size limiting via `BODY_LIMIT`
- ✅ Global `ValidationPipe` with whitelist + forbidNonWhitelisted
- ✅ `HttpExceptionFilter` — standardized error format
- ✅ JWT `AuthGuard` on all protected endpoints
- ✅ Admin `RolesGuard` (ADMIN role only) on admin endpoints
- ⚠️ Swagger is enabled in development (`SWAGGER_ENABLED=true`). **Must be disabled in production.**
- ⚠️ Dev OTP code (`111111`) must NOT appear in production API responses. Enforced by `SMS_PROVIDER` flag.

### Chat Access Control
- ✅ Self-chat blocked (buyer cannot be listing owner)
- ✅ Only ACTIVE listings can start conversations
- ✅ Only conversation participants can read/send messages
- ✅ JWT required for all chat endpoints

---

## 5. Mobile Readiness

### API Base URL
- Configured via `--dart-define=API_BASE_URL=...` at build time
- Default fallback: `http://10.0.2.2:3000` (Android emulator)
- For real phone pilot: build with LAN IP, e.g. `http://192.168.1.X:3000` or `http://172.20.10.7:3000`

### Auth & Token
- ✅ JWT token stored in `flutter_secure_storage` (encrypted on-device)
- ✅ 401 responses redirect to `/login` via `authControllerProvider`
- ✅ Auth state checked on startup (`SplashPage`)

### Feature Completeness
- ✅ OTP login with dev mode notice in UI
- ✅ Listing browse, filter, pagination
- ✅ Listing detail: images, price, description, contact, seller card
- ✅ Listing creation wizard
- ✅ My listings management (view, archive, status badge)
- ✅ Favorites (add/remove/list)
- ✅ Seller profile + seller's listings
- ✅ Contact via phone call, SMS, clipboard copy
- ✅ REST Chat: inbox + conversation thread, send message, optimistic update
- ✅ AI Advice: ask question, view history
- ✅ Profile quick actions: my listings, messages, favorites, create listing

### Known Mobile Gaps (Not in MVP scope)
- ❌ Listing edit from mobile (backend PATCH exists; mobile UI not wired)
- ❌ Listing archive from mobile (backend exists; mobile UI not wired)
- ❌ Image delete (backend does not expose delete endpoint yet)
- ❌ Push notifications (no FCM integration)
- ❌ WebSocket/real-time chat (intentional: REST-only MVP)
- ❌ Chat read receipts reflected in UI count after refresh (backend does mark readAt)

---

## 6. Admin Panel Readiness

### Environment
- `NEXT_PUBLIC_API_BASE_URL` — set in `.env.local`
- Default: `http://localhost:3000`
- For LAN pilot: set to `http://172.20.10.7:3000`

### Features
- ✅ Admin login via OTP (backend ADMIN role)
- ✅ Dashboard totals (users, pending listings, active listings, open complaints)
- ✅ Listings: filter, search, pagination, moderation (ACTIVE/REJECTED)
- ✅ Complaints: filter by status, update status
- ✅ Users: search, filter, pagination, detail modal
- ✅ AI Questions: filter, search, pagination, detail modal
- ✅ Next.js `npm run build` — **all 8 routes statically prerendered, 0 errors**
- ✅ `npm run lint` script available

### Known Admin Gaps (Not in MVP scope)
- ❌ Admin chat monitoring (no backend admin chat endpoints)
- ❌ User block/unblock from admin panel
- ❌ Bulk moderation actions
- ❌ Image management from admin

---

## 7. Environment Variables Checklist

### Backend `.env` / `.env.production`

| Category        | Item                              | Status     |
|-----------------|-----------------------------------|------------|
| App             | `NODE_ENV=production`             | ⬜ Set before deploy |
| App             | `PORT=3000`                       | ⬜ Confirm port |
| Database        | `DATABASE_URL`                    | ⬜ Production DB URL |
| Auth            | `JWT_SECRET`                      | ⬜ MUST change |
| Auth            | `OTP_SECRET`                      | ⬜ MUST change |
| SMS             | `SMS_PROVIDER=generic` or `eskiz` | ⬜ Set for real SMS |
| SMS             | `SMS_API_BASE_URL`                | ⬜ Real provider URL |
| SMS             | `SMS_API_TOKEN`                   | ⬜ Real credentials |
| SMS             | `SMS_API_LOGIN`                   | ⬜ Real credentials |
| SMS             | `SMS_API_PASSWORD`                | ⬜ Real credentials |
| AI              | `AI_PROVIDER`                     | ⬜ Set `local` for MVP |
| Security        | `CORS_ORIGIN`                     | ⬜ Set production origins |
| Security        | `SWAGGER_ENABLED=false`           | ⬜ Disable in production |
| Upload          | `UPLOAD_DIR`                      | ⬜ Docker volume path |
| Upload          | `PUBLIC_BASE_URL`                 | ⬜ Production domain |

### Admin Panel `.env.local`

| Item                        | Status              |
|-----------------------------|---------------------|
| `NEXT_PUBLIC_API_BASE_URL`  | ⬜ Production API URL |

---

## 8. Local Pilot Test Checklist

### Pre-conditions
- [ ] Backend running: `npm run start:dev` (or Docker prod)
- [ ] PostgreSQL running and migrated
- [ ] Seed data applied (`npm run prisma:seed`)
- [ ] Admin panel running: `npm run dev`
- [ ] APK installed on real Android device
- [ ] Device on same LAN as backend server
- [ ] APK built with correct LAN IP: `--dart-define=API_BASE_URL=http://<LAN_IP>:3000`

### Backend Smoke Tests (curl)
```bash
# Health
curl http://<LAN_IP>:3000/health

# Request OTP (dev mode returns devCode)
curl -X POST http://<LAN_IP>:3000/auth/request-otp \
  -H "Content-Type: application/json" \
  -d '{"phone":"+998901234567"}'

# Verify OTP (use devCode from above)
curl -X POST http://<LAN_IP>:3000/auth/verify-otp \
  -H "Content-Type: application/json" \
  -d '{"phone":"+998901234567","code":"111111","role":"FARMER","fullName":"Test Farmer"}'

# Auth me (use token from above)
curl http://<LAN_IP>:3000/auth/me \
  -H "Authorization: Bearer <ACCESS_TOKEN>"

# Reference
curl http://<LAN_IP>:3000/reference/categories
curl http://<LAN_IP>:3000/reference/regions

# Listings
curl http://<LAN_IP>:3000/listings

# Favorites IDs
curl http://<LAN_IP>:3000/favorites/ids \
  -H "Authorization: Bearer <ACCESS_TOKEN>"

# Conversations
curl http://<LAN_IP>:3000/conversations/my \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

### Mobile App Flow Tests
- [ ] Launch app → splash → listing list
- [ ] Tap listing → listing detail page loads
- [ ] Register/Login with dev OTP `111111`
- [ ] Profile page shows user info
- [ ] Create listing → wizard completes → PENDING status shown in My Listings
- [ ] Add listing to favorites → appears in favorites list
- [ ] Open seller profile from listing → seller's listings visible
- [ ] Contact call/SMS/copy works from listing detail
- [ ] Open chat from listing detail → chat thread opens
- [ ] Send message → appears in chat with optimistic update
- [ ] Profile → Xabarlar → chat inbox shows conversation
- [ ] AI Advice → ask question → response received (mock)
- [ ] Logout → redirected to listing list (unauthenticated)

### Admin Panel Flow Tests
- [ ] Open `http://localhost:3001/login`
- [ ] Enter ADMIN phone number → OTP sent → login
- [ ] Dashboard totals load correctly
- [ ] Listings page → filter PENDING → moderate listing to ACTIVE
- [ ] Complaints page → open complaints visible
- [ ] Users page → user search works
- [ ] AI Questions → list visible

---

## 9. Real Phone APK Test Checklist

- [ ] APK installed via `adb install app-debug.apk` or manual file transfer
- [ ] Backend running and reachable from phone network
- [ ] LAN IP confirmed: `ip addr show` on backend machine
- [ ] APK built with correct IP: `flutter build apk --debug --dart-define=API_BASE_URL=http://<LAN_IP>:3000`
- [ ] OTP request triggers terminal log (dev mode) with code
- [ ] Login succeeds, JWT stored
- [ ] Listings load from real backend
- [ ] Image upload works (camera or gallery)
- [ ] Contact actions: phone call opens dialer, SMS opens messenger
- [ ] Chat: send/receive messages visible
- [ ] AI Advice: question + mock answer received

---

## 10. Known Limitations

> These are intentional MVP constraints. Not bugs.

| # | Limitation | Priority |
|---|------------|----------|
| 1 | Real SMS provider credentials not yet configured | HIGH — needed for public release |
| 2 | AI provider is local/mock — no real Gemini/OpenAI | HIGH — needed for real AI value |
| 3 | No push notifications (FCM) | MEDIUM — degrades chat UX without real-time updates |
| 4 | REST-only chat — no WebSocket real-time | MEDIUM — users must manually refresh |
| 5 | No listing edit from mobile app | MEDIUM — backend supports it |
| 6 | No listing archive from mobile app | MEDIUM — backend supports it |
| 7 | No image delete from mobile or admin | LOW |
| 8 | No admin chat monitoring | LOW |
| 9 | Production domain/server not yet configured | HIGH — needed for public release |
| 10 | No Play Store signing/release APK | HIGH — needed for distribution |
| 11 | No user block/unblock from admin panel | LOW — admin-only concern |
| 12 | Backend lint (ESLint) not configured | LOW — quality gap, not a blocker |
| 13 | No database backup strategy documented | MEDIUM — needed before any data-critical release |
| 14 | Swagger enabled by default in current .env.example | HIGH — must disable in production |
| 15 | Admin token stored in localStorage (not httpOnly cookie) | MEDIUM — acceptable for internal admin, not public |

---

## 11. Must-Fix Before Public Release

| Item | File/Config | Action |
|------|-------------|--------|
| Change `JWT_SECRET` from placeholder | `.env.production` | Use strong random secret |
| Change `OTP_SECRET` from placeholder | `.env.production` | Use strong random secret |
| Change `POSTGRES_PASSWORD` from placeholder | `.env.production` | Use strong password |
| Set `SMS_PROVIDER=generic` or `eskiz` | `.env.production` | Configure real SMS credentials |
| Set `SWAGGER_ENABLED=false` | `.env.production` | Disable public API docs |
| Set `CORS_ORIGIN` to production domains | `.env.production` | Restrict CORS |
| Build release APK with keystore signing | Android signing config | Required for Play Store |
| Configure production server/domain | Infra/DevOps | Required for users to connect |
| Define database backup strategy | Ops | Prevent data loss |

---

## 12. Nice-to-Have After Pilot

- Real-time chat (WebSocket + Riverpod `StreamProvider`)
- FCM push notifications for new messages
- Listing edit UI in mobile app
- Listing archive UI in mobile app
- Real AI provider integration (Gemini Flash or similar)
- Backend ESLint configuration
- E2E test suite with database reset
- CI/CD pipeline (GitHub Actions)
- S3/CDN for image storage (replace local `uploads/`)
- Admin chat monitoring module
- User block/unblock from admin panel

---

## 13. Recommended Next Steps

### Immediate (Step 76 — Pilot Test)
1. Run local end-to-end pilot with 2–3 real devices on LAN
2. Verify all mobile flows manually
3. Confirm backend logs show no unexpected errors
4. Document any bugs found during pilot

### Short-Term (Step 77–80)
1. Configure real SMS provider (Eskiz or similar Uzbekistan SMS gateway)
2. Set up production server (VPS or cloud)
3. Configure production domain + HTTPS (Let's Encrypt)
4. Create release keystore and sign APK for Play Store
5. Integrate real AI provider (Gemini Flash API)

### Medium-Term (Future)
1. Add WebSocket real-time chat
2. Add FCM push notifications
3. Add listing edit/archive in mobile
4. Build CI/CD pipeline
5. Migrate image storage to S3/CDN

---

## 14. Conclusion

**The QISHLOQ AI MVP is ready for local pilot testing.**

All three components (backend, mobile app, admin panel) build cleanly with zero errors and all automated tests pass. The architecture is sound, security fundamentals are in place, and the core user flows are functional.

**Critical actions required before public production release:**
- Configure real SMS provider credentials
- Change all placeholder secrets
- Disable Swagger in production
- Set up production server + HTTPS
- Build signed release APK

**For pilot/internal testing, the current debug APK + local backend setup is sufficient.**
