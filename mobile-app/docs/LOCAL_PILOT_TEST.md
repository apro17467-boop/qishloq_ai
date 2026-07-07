# QISHLOQ AI Mobile — Local Pilot Test Guide

This document covers end-to-end manual test steps for the Flutter mobile app during local pilot testing.

---

## Prerequisites

1. **Backend** running: `cd backend && npm run start:dev`
2. **PostgreSQL** running and migrated
3. **Android device** on the same Wi-Fi/LAN as the backend machine
4. **LAN IP** of the backend machine: run `ip addr show` and note the IP (e.g. `192.168.1.100` or `172.20.10.7`)
5. **APK** built with the correct IP:

```bash
cd mobile-app
export JAVA_HOME=/home/xbmb/development/jdk-17
export ANDROID_HOME=/home/xbmb/development/android-sdk
export PATH="$JAVA_HOME/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:/home/xbmb/development/flutter/bin:$PATH"
flutter build apk --debug --dart-define=API_BASE_URL=http://<LAN_IP>:3000
```

6. Install APK on device:
```bash
adb install build/app/outputs/flutter-apk/app-debug.apk
```
Or copy the APK file to the device manually.

---

## API Base URL Configuration

The mobile app reads `API_BASE_URL` at compile time from `--dart-define`:

| Scenario             | Value                                |
|----------------------|--------------------------------------|
| Android emulator     | `http://10.0.2.2:3000` (default)     |
| Real device on LAN   | `http://<LAN_IP>:3000`               |
| Production server    | `https://api.qishloqai.uz` (future)  |

> **Important:** Each time the LAN IP changes, rebuild the APK.

---

## Dev OTP Mode

In development (`SMS_PROVIDER=dev`), the backend does **not** send real SMS.

- The backend terminal shows the OTP code in logs.
- The API response includes `"devCode": "111111"` in the JSON body.
- The mobile app shows a yellow info banner on the login page when dev code is visible in the response.
- The default dev code is `111111` (configurable via `SMS_DEV_CODE` env var).

---

## Auth Flow

- [ ] Launch app → splash screen → redirects to listing list (if logged out)
- [ ] Tap **Kirish** (Login) → phone input field
- [ ] Enter valid phone: `+998XXXXXXXXX` → tap **OTP yuborish**
- [ ] In dev mode: check backend terminal for `OTP CODE: 111111`
- [ ] Enter OTP code `111111` → tap **Tasdiqlash**
- [ ] If new user: fullName and role selection shown → complete registration
- [ ] Profile page loads with user info

---

## Listing Browse Flow

- [ ] Listing list page loads with ACTIVE listings from backend
- [ ] Search input works (debounced)
- [ ] Category filter chips work
- [ ] Pagination loads more listings on scroll
- [ ] Pull-to-refresh works

---

## Listing Detail Flow

- [ ] Tap a listing → detail page opens
- [ ] Images gallery loads (if listing has images)
- [ ] Price, description, location, contact info visible
- [ ] Status badge visible (ACTIVE/PENDING)
- [ ] **Contact actions (if contactPhone present):**
  - [ ] Call button → device phone dialer opens
  - [ ] SMS button → device SMS app opens
  - [ ] Copy button → phone number copied to clipboard
- [ ] **Seller card:**
  - [ ] Seller name and role visible
  - [ ] "Profilni ko'rish" → opens seller profile page
  - [ ] "Xabar yozish" → creates/opens chat thread (auth required)
- [ ] Favorite toggle works (heart icon — auth required)

---

## Create Listing Flow

- [ ] Profile → "E'lon joylash" (or FAB on listing list)
- [ ] Step 1: Select listing type
- [ ] Step 2: Enter title and description
- [ ] Step 3: Set price and currency
- [ ] Step 4: Add contact phone
- [ ] Step 5: Upload images (optional — camera or gallery)
- [ ] Step 6: Review and confirm
- [ ] Listing created → status is PENDING
- [ ] Visible in My Listings with PENDING badge

---

## My Listings Flow

- [ ] Profile → "Mening e'lonlarim"
- [ ] Own listings visible with status badges (PENDING, ACTIVE, REJECTED, ARCHIVED)
- [ ] PENDING listings not visible in public listing browse

---

## Favorites Flow

- [ ] Tap heart icon on listing detail → added to favorites
- [ ] Profile → "Sevimlilar"
- [ ] Favorited listing appears in list
- [ ] Remove favorite → listing removed from list

---

## Seller Profile Flow

- [ ] Open seller profile from listing detail → seller info visible
- [ ] Seller's active listings shown in list
- [ ] **Phone number NOT shown** on seller profile (privacy: only in listing contactPhone)
- [ ] Seller listing → listing detail opens

---

## Chat Flow

- [ ] Open ACTIVE listing by another user
- [ ] Tap "Xabar yozish" → shows loading, then opens chat thread
- [ ] Type message → send button enables
- [ ] Send message → message appears in bubble (right-aligned, green)
- [ ] Pull-to-refresh → refreshes messages
- [ ] Profile → "Xabarlar" → chat inbox shows conversation
- [ ] Tap conversation → chat thread opens
- [ ] Mini listing card at top → tap "Ko'rish" → listing detail opens
- [ ] Back → inbox list shows last message preview

---

## AI Advice Flow

- [ ] Bottom nav or drawer → AI Advice
- [ ] Enter question (min 10 chars)
- [ ] Submit → loading state → answer displayed (mock/local provider)
- [ ] Disclaimer text visible
- [ ] "Mening savollarim" tab → history of past questions

---

## Error Handling Tests

- [ ] Open app without internet → graceful error state with retry button
- [ ] 401 scenario: clear token manually (via device settings → app data clear) → protected page → redirects to login
- [ ] Invalid OTP entry → error message shown
- [ ] Send message in chat → no connection → SnackBar error, input text preserved

---

## Contact Flow Tests (url_launcher)

> Requires a real Android device (url_launcher does not work on emulator for actual calls/SMS).

- [ ] Tap Call → Android dialer opens with pre-filled number
- [ ] Tap SMS → Android SMS app opens with pre-filled number
- [ ] Tap Copy → SnackBar shows "Nusxalandi", clipboard contains number

---

## Known Limitations During Pilot

| Limitation | Impact |
|------------|--------|
| REST-only chat (no WebSocket) | Messages update only on manual refresh |
| Mock AI provider | AI answers are template/mock responses |
| Dev SMS mode | OTP code must be read from backend terminal |
| Listing edit/archive not in mobile | Must be done via admin panel or API |
| Image delete not available | Cannot remove uploaded images |
| No push notifications | No alerts for new messages |
