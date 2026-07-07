# QISHLOQ AI Mobile Application

Qishloq xo‘jaligi uchun aqlli yordamchi mobil ilovasi (Flutter skeleton).

## Maqsadi

Fermerlar, chorvadorlar va agro-tadbirkorlar uchun qulay mobil interfeys taqdim etish:
- Mahsulotlar, texnikalar va ijara e'lonlari.
- AI maslahatchi (Savol-javoblar).
- Shaxsiy profil va sozlamalar.

## Ishga tushirish yo‘riqnomasi

### Flutter versiyasini tekshirish

Ilova Flutter 3.x stable versiyasida ishlab chiqilgan. Versiyani tekshirish uchun:
```bash
flutter --version
flutter doctor
```

### Dependency-larni yuklash

```bash
flutter pub get
```

### Ilovani ishga tushirish

```bash
flutter run
```

## Mavjud Route-lar (Navigatsiya)

- `/` → SplashPage (Ilovaga kirish va start oynasi)
- `/onboarding` → OnboardingPage (Platforma afzalliklari kartalari)
- `/login` → LoginPage (Telefon raqam kiritish va Demo rejimda kirish)
- `/home` → HomePage (Asosiy bo‘limlar - E'lonlar, AI maslahat, Profil)

## API va Ma'lumotlar ulanishi (Step 46)

Ilovada API Client infratuzilmasi (Dio va Secure Storage asosida) to‘liq sozlandi.

### Konfiguratsiya va Base URL

- **Default base URL:** `http://10.0.2.2:3000` (`AppConfig.apiBaseUrl`)
- **Android Emulator:** Android emulatoridan host kompyuterdagi backend localhostiga ulanish uchun maxsus `10.0.2.2` IP manzili ishlatiladi.
- **Localhost (Web/Desktop):** Local hostdan test qilish uchun `http://localhost:3000` ishlatilishi mumkin.
- **Real Qurilma (Device):** Real telefondan test qilish uchun host kompyuter joylashgan Wi-Fi LAN IP manzili (masalan: `http://192.168.1.X:3000`) ko‘rsatilishi lozim.

### Kutubxonalar (Dependencies)

- `dio`: HTTP requestlar, headerlar, timeoutlar va xatoliklarni boshqarish uchun.
- `flutter_secure_storage`: Foydalanuvchi tokenlarini xavfsiz saqlash (`qishloq_ai_mobile_token` kaliti bilan).

### ApiClient va Token Storage xususiyatlari

- `ApiClient` so'rov jo'natishdan oldin secure storagedan tokenni avtomatik o‘qib, `Authorization: Bearer <token>` headeriga qo‘shib yuboradi.
- Backenddan qaytgan xatoliklar avtomatik `ApiException` tipiga o‘giriladi.
- `HealthService` orqali `/health` endpointiga ulanish tekshiriladi.
- **Debug:** `HomePage` ostidagi **"Backend holatini tekshirish"** tugmasi orqali local backend ishlayotganini /health orqali tekshirish mumkin.

## Keyingi qadam (Step 47)

- Auth API ulanishini integratsiya qilish (OTP so'rov yuborish va tasdiqlash, olingan tokenni saqlash).

