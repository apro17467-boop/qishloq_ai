# Android Release Checklist

Use this checklist before distributing QISHLOQ AI Android builds.

## Debug APK vs Release APK

- Debug APK is for development and local testing.
- Debug APK is signed with a debug key and should not be published.
- Release APK/AAB is optimized and signed with a production release key.
- Release builds must point to the production HTTPS API domain.

## Production API Build

Build release APK:

```bash
flutter build apk --release --dart-define=API_BASE_URL=https://your-api-domain.uz
```

Build Android App Bundle for Play Store:

```bash
flutter build appbundle --release --dart-define=API_BASE_URL=https://your-api-domain.uz
```

## Release Signing

- Create a release keystore before production distribution.
- Keep keystore file private and backed up securely.
- `key.properties` must not be committed to Git.
- Verify `.gitignore` excludes local signing files.
- Store passwords only in local secure storage or CI/CD secret manager.

## Versioning

- Update `versionName` for user-visible release version.
- Increment `versionCode` for every Play Store upload.
- Confirm generated artifact includes the intended version.

## Android Permissions And Queries

- Confirm Android internet permission is present.
- Confirm `url_launcher` phone/SMS usage works on real phones.
- Confirm Android package visibility queries include required `tel:` and `sms:` intents if needed.

## Real Phone Smoke Test

Test on at least one real Android phone:

- App opens and reaches login.
- OTP request/verify works with production SMS provider.
- Listings load from HTTPS API.
- Listing detail opens.
- Contact actions work.
- Favorites work after login.
- Seller profile opens from listing detail.
- Chat conversation list and message screen load.
- Logout/login persistence behaves correctly.

## Before Play Store

- Final app name and icon are set.
- Screenshots are prepared.
- Privacy policy is prepared and reachable.
- Real SMS OTP is enabled.
- Backend uses HTTPS.
- Production API domain is stable.
- Crash monitoring can be added later.
