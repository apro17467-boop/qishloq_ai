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

## API va Ma'lumotlar ulanishi (Step 46, 47, 48, 49 & 50)

Ilovada API Client infratuzilmasi, Mobil Autentifikatsiya (OTP Request & Verify) hamda Auth State Management (Notifier, Protected Home & Logout) to‘liq sozlandi.

### Konfiguratsiya va Base URL

- **Default base URL:** `http://10.0.2.2:3000` (`AppConfig.apiBaseUrl`)
- **Android Emulator:** Android emulatoridan host kompyuterdagi backend localhostiga ulanish uchun maxsus `10.0.2.2` IP manzili ishlatiladi.
- **Localhost (Web/Desktop):** Local hostdan test qilish uchun `http://localhost:3000` ishlatilishi mumkin.
- **Real Qurilma (Device):** Real telefondan test qilish uchun host kompyuter joylashgan Wi-Fi LAN IP manzili (masalan: `http://192.168.1.X:3000`) ko‘rsatilishi lozim.

### Autentifikatsiya va Holat boshqaruvi (Step 47, 48, 49 & 50)

- **OTP Request Endpoint:** `POST /auth/request-otp`
  - **Request Body:** `{"phone": "+998901234567"}`
- **OTP Verify Endpoint:** `POST /auth/verify-otp`
  - **Request Body:**
    ```json
    {
      "phone": "+998901234567",
      "code": "111111",
      "role": "FARMER",
      "fullName": "Ali Valiyev",
      "address": "Oqdaryo tumani"
    }
    ```
- **Get Me Endpoint:** `GET /auth/me` (Token faolligini va foydalanuvchi ma'lumotlarini tekshirish uchun)
- **Token Saqlash:** Muvaffaqiyatli verify bo‘lgandan keyin olingan `accessToken` xavfsiz tarzda `flutter_secure_storage` kutubxonasidan foydalanib `qishloq_ai_mobile_token` kaliti ostida saqlanadi.
- **Auth State Management (Riverpod Notifier):** `AuthController` va `AuthState` sinflari yordamida ilova boshlanganda, login bo'lganda va logout qilinganda foydalanuvchi holati va tokenlar boshqariladi.
- **Protected Home:** `HomePage` ochilganda va u ishga tushganda `checkAuth()` orqali token tekshiriladi. Token mavjud bo'lmasa yoki yaroqsiz bo'lsa, foydalanuvchi avtomatik ravishda `/login` sahifasiga qaytariladi. Loading vaqtida "Profil tekshirilmoqda..." ko'rsatiladi.
- **Logout (Tizimdan chiqish):** `HomePage` tepa o'ng burchagidagi chiqish tugmasi bosilganda tasdiqlash dialogi ko'rsatiladi. Tasdiqlansa, token secure storage'dan o'chiriladi va state `unauthenticated` qilinib `/login`ga yo'naltiriladi.
- **Demo Davom Etish:** Vaqtincha demo rejim yopildi. Bosilganda ogohlantiruvchi SnackBar chiqadi: "Demo rejim keyingi bosqichlarda qayta yoqiladi. Hozir login talab qilinadi."

### Kutubxonalar (Dependencies)

- `dio`: HTTP requestlar, headerlar, timeoutlar va xatoliklarni boshqarish uchun.
- `flutter_secure_storage`: Foydalanuvchi tokenlarini xavfsiz saqlash.
- `flutter_riverpod`: Ilova holatini (Auth state, API client) reaktiv boshqarish uchun (Riverpod v3 Notifier arxitekturasi asosida).

## Keyingi qadam (Step 51)

- Asosiy bo‘limlar (E'lonlar, AI maslahat, Mening profilim) uchun real ma'lumotlarni backend-dan olib kelish va integratsiya qilish.


