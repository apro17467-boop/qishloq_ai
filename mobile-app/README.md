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

### Home Navigation & Categories Screen (Step 51)

- **Home sahifasida navigatsiya:** Balla asosiy bo'limlar (E'lonlar, Kategoriyalar, E'lon joylash, AI maslahat, Profil) real routelarga va sahifalarga bog'landi.
- **Kategoriyalar Ekran:** `GET /reference/categories` endpointidan kategoriyalar ro'yxatini real vaqtda yuklaydi.
- **Kategoriyalar API:**
  - Endpoint: `GET /reference/categories`
  - Model fieldlari: `id`, `nameUz`, `nameRu`, `slug`, `type`, `isActive`
- **Kategoriya Turi Helperi (Type labels translation):**
  - `MACHINERY_RENT` -> Texnika ijarasi
  - `PRODUCT_SALE` -> Dehqon mahsulotlari
  - `LIVESTOCK_SALE` -> Chorva savdosi
  - `MACHINERY_SALE` -> Texnika savdosi
  - `SERVICE` -> Agro xizmatlar
- **Foydalanuvchi interfeysi holatlari:** Loading, Error (Retry tugmasi bilan) va Empty holatlari mavjud.
- **Placeholder sahifalar:** `ListingsPlaceholderPage`, `CreateListingPlaceholderPage`, `AiAdvicePlaceholderPage` va `ProfilePlaceholderPage` yaratildi. Ularda ortga (Bosh sahifaga) qaytish tugmasi mavjud.
- **E'lonlar ro'yxati:** Keyingi 52-qadamda backend bilan ulanadi.

### Mobile Listing list API (Step 52)

- **E'lonlar ro'yxati:** `GET /listings` endpointi orqali real vaqtda faol (ACTIVE) e'lonlar ro'yxatini yuklaydi.
- **Filtrlash:**
  - Search (Qidirish) input va Qidirish / Tozalash tugmalari (darhol request jo‘natmasdan, qidirish bosilganda 1-sahifadan yuklaydi).
  - Type filter (Turi bo‘yicha dropdown: MACHINERY_RENT, PRODUCT_SALE, LIVESTOCK_SALE, MACHINERY_SALE, SERVICE).
  - Category filter (Kategoriyalardan o‘tganda categoryId bo‘yicha filtrlash, chip ko‘rinishida tozalash imkoniyati bilan).
- **Pagination (Yana yuklash):** Sahifalangan (paginated) ma'lumotlar bilan ishlash, keyingi sahifa mavjud bo'lganda (page < totalPages) ro'yxat pastida "Yana yuklash" tugmasi chiqadi.
- **Card UI va Format Helperlari:**
  - E'lon rasmlaridan birinchisi, agar rasm bo'lmasa placeholder icon ko'rsatiladi.
  - Sarlavha, hudud, telefon raqam, e'lon turi va yaratilgan vaqti (o'qishga qulay formatda).
  - Narx ko'rinishi: priceAmount bo'lsa `Amount Currency / Unit`, bo'lmasa `Narx kelishiladi`.
- **Navigatsiya:** E'lon card ustiga bosilganda `/listings/:id` route orqali tafsilot sahifasiga o'tadi.

### Mobile Listing detail (Step 53)

- **Endpoint:** `GET /listings/:id` API so'rovi orqali e'lon tafsilotlarini yuklaydi.
- **Rasm/Gallery:** Agar rasmlar bo'lsa `PageView` orqali ko'rsatiladi va `1/3` ko'rinishida joriy rasm indeksi yoziladi. Rasmlar bo'lmasa, chiroyli placeholder ko'rsatiladi.
- **Asosiy ma'lumotlar:**
  - Sarlavha, tur (type) va status (ACTIVE/PENDING va hokazo) badgelari.
  - Narxi: `formattedPrice` helperi orqali (masalan, `5000 UZS / kg` yoki `Narx kelishiladi`).
  - Kategoriya, hudud/manzil va yaratilgan/yangilangan sanalar.
  - Tavsif (description).
- **Bog'lanish:** E'lon egasining telefon raqami, "Nusxalash" tugmasi (Clipboard API orqali buferga nusxalaydi). Telefon call plugin hozircha qo'shilmagan.
- **Xatoliklar:** 404 error (e'lon topilmaganda yoki nofaol bo'lganda) va boshqa xatoliklar chiroyli retry/back buttonlar bilan handle qilingan.

### Mobile Create listing form (Step 54)

- **Endpoint:** `POST /listings` API orqali e'lon yaratadi. So'rov yuborishda faqat backend qabul qiladigan aniq fieldlar yuboriladi va bo'sh optional fieldlar tozalanadi.
- **Avtomatik Auth Header:** ApiClient orqali Bearer token avtomatik headerga qo'shiladi.
- **Kategoriya va Hududlar:**
  - `/reference/categories` va `/reference/regions` dan ma'lumotlar yuklanadi.
  - Kategoriya tanlanganda e'lon turi (`type`) avtomatik tarzda uning `category.type` qiymatiga tenglashtiriladi va UI-da ko'rsatiladi.
- **Manzil va Aloqa:**
  - Hudud tanlash (tanlanmagan / ixtiyoriy).
  - Tizimga kirgan foydalanuvchining telefon raqami default bog'lanish telefoni sifatida avtomatik formda ko'rsatiladi.
- **Form Maydonlari va Validation:**
  - Sarlavha (majburiy, 3-120 belgi).
  - Tavsif (ixtiyoriy, max 2000 belgi).
  - Narx (ixtiyoriy, 0 dan katta son bo'lishi tekshiriladi).
  - Bog'lanish telefoni (`+998XXXXXXXXX` formatda bo'lishi tekshiriladi).
- **Muvaffaqiyatli Holat (Success Screen):**
  - E'lon yaratilgach, status PENDING holatida bo'lishi to'g'risida ma'lumot beruvchi yashil oyna ochiladi.
  - "Rasm qo‘shish", "E'lonlar ro'yxatiga o'tish" va "Bosh sahifaga qaytish" navigatsiya tugmalari taqdim etiladi.
- **Image Upload & My Listings:** Ushbu bosqichda form yaratildi, rasm yuklash 55-qadamda va shaxsiy e'lonlarni boshqarish keyingi qadamlarda ulanadi.

### Mobile Image Upload (Step 55)

- **Endpoint:** `POST /listings/:id/images` API orqali rasmlarni yuklaydi.
- **Multipart Field:** `image` (backend kutgan aniq field nomi).
- **Rasm tanlash (image_picker):**
  - Gallery'dan bir vaqtning o'zida bir nechta rasm tanlash uchun `pickMultiImage` ishlatiladi.
  - Maksimal 5 ta rasm yuklashga cheklov qo'yilgan.
- **File Validation (Frontend):**
  - File extension: faqat `.jpg`, `.jpeg`, `.png`, `.webp` formatlari qabul qilinadi.
  - File size: har bir rasm hajmi 5MB dan oshmasligi tekshiriladi (XFile.length() orqali).
- **Upload Flow:**
  - Tanlangan rasmlar ro'yxatida preview va o'chirish imkoniyati mavjud.
  - "Yuklash" bosilganda rasmlar ketma-ket (sequential) upload qilinadi va `1/3 rasm yuklanmoqda...` ko'rinishida progress ma'lumoti yangilanib turadi.
  - Muvaffaqiyatli yuklansa yashil success banner, xatolik bo'lsa qizil error banner ko'rsatiladi.
  - Yuklash jarayonida tugmalar va interaction blocklanadi.
- **Auth Protection:** Sahifa faqat token bo'lgandagina ochiq bo'ladi, aks holda `/login` ga yo'naltiradi.
- **Router Integratsiyasi:** `/listings/:id/images` marshruti GoRouter-da alohida segment sifatida ro'yxatdan o'tkazildi.

## Mobile My Listings (Step 56)

### Endpoint

- **GET /listings/my** — foydalanuvchining o'z e'lonlarini qaytaradi (auth token talab qilinadi).

### Query Parametrlari (Backend DTO ga mos)

| Parametr | Turi    | Majburiy | Tavsif                              |
|----------|---------|----------|-------------------------------------|
| page     | int     | Yo'q     | Sahifa raqami (default: 1)          |
| limit    | int     | Yo'q     | Har sahifada necha ta (max: 50)     |
| status   | enum    | Yo'q     | PENDING / ACTIVE / REJECTED / ARCHIVED |
| type     | enum    | Yo'q     | MACHINERY_RENT / PRODUCT_SALE / ...  |

### Auth Token

`ApiClient` orqali `Bearer <token>` headeriga avtomatik qo'shiladi. Token `flutter_secure_storage`da saqlanadi.

### Status ko'rinishi

- **PENDING** (sariq) — "Admin tasdiqlashini kutmoqda"
- **ACTIVE** (yashil) — "Ommaga ko'rinmoqda"
- **REJECTED** (qizil) — "Admin tomonidan rad etilgan"
- **ARCHIVED** (kulrang) — "Arxivlangan"

### Funksionallik

- **Status filter (chip):** Barchasi / Moderatsiyada / Faol / Rad etilgan / Arxivda
- **Pagination:** Birinchi sahifada 10 ta, "Yana yuklash" button orqali keyingi sahifa
- **"Ko'rish" tugmasi:**
  - ACTIVE e'lon → `/listings/:id` detail sahifasiga o'tadi
  - PENDING/REJECTED/ARCHIVED → public detailga OLIB BORMASDAN SnackBar chiqaradi
- **"Rasm qo'shish" tugmasi:**
  - PENDING yoki ACTIVE e'lon → `/listings/:id/images`ga o'tadi
  - REJECTED/ARCHIVED → tugma disabled ko'rsatiladi (real action yo'q)
- **Empty state:** E'lon yo'q bo'lsa "Birinchi e'lonni joylashtirish" button, filtr bo'sh bo'lsa "Filtrni tozalash" button
- **Pull-to-refresh:** Ro'yxatni pastga tortib yangilash imkoniyati

### Create Listing Success ekrani (yangilangan)

- "Rasm qo'shish" — image upload sahifasiga o'tadi
- **"Mening e'lonlarim"** — `/my-listings`ga o'tadi (YANGI)
- "E'lonlar ro'yxatiga o'tish" — public `/listings`ga o'tadi
- "Bosh sahifaga qaytish" — home

### Image Upload sahifasi (yangilangan)

- **"Mening e'lonlarim"** button qo'shildi — `/my-listings`ga o'tadi (YANGI)

### Home sahifasi (yangilangan)

- **"Mening e'lonlarim"** card qo'shildi — subtitle: "Joylagan e'lonlaringiz holatini kuzating", route: `/my-listings`

### Route

- `/my-listings` → `MyListingsPage` (yangi)

### Xatolik holati

- Backend xatoligida to'liq xato matni ko'rsatiladi
- "Qayta urinish" button orqali qayta yuklash

### Edit / Archive

Hozircha yozilmagan. Keyingi bosqichlarda ulanadi.

---

## Mobile AI Maslahat (Step 57)

### Endpointlar

- **POST /ai/questions** — yangi savol yuborish (auth token talab qilinadi)
- **GET /ai/questions/my** — foydalanuvchining oldingi savollari (auth token talab qilinadi)

### Create AI Question DTO

| Field    | Turi   | Majburiy | Cheklov         |
|----------|--------|----------|-----------------|
| question | string | Ha       | min:10, max:3000|

### My AI Questions Query

| Parametr | Turi | Majburiy | Tavsif                              |
|----------|------|----------|-------------------------------------|
| page     | int  | Yo'q     | Sahifa raqami (default: 1)          |
| limit    | int  | Yo'q     | Har sahifada necha ta (max: 50)     |
| status   | enum | Yo'q     | PENDING / ANSWERED / FAILED         |

### AiQuestion Model Fieldlari

- `id` — UUID
- `question` — savol matni
- `answer` — AI javobi (null bo'lishi mumkin)
- `status` — PENDING | ANSWERED | FAILED
- `disclaimerShown` — ogohlantirish ko'rsatilganmi
- `createdAt`, `updatedAt` — vaqt belgilari

### AI Provider

Backend hozir **local/mock AI provider** bilan ishlaydi.
- Savol yuborilganda darhol `ANSWERED` yoki `FAILED` qaytishi mumkin.
- Real tashqi AI provider (Gemini, OpenAI va b.) **hali ulanmagan**.

### Status ko'rinishi

- **PENDING** (sariq) — Kutilmoqda
- **ANSWERED** (yashil) — Javob berilgan
- **FAILED** (qizil) — Xatolik

### Funksionallik

- Savol yuborish formasi (multiline, min 10 belgi, max 3000 belgi)
- Frontend validation (uzunlik) + backend validation (asosiy)
- Submit loading holati
- Success/error message
- Savollar ro'yxati status filtri: Barchasi / Kutilmoqda / Javob berilgan / Xatolik
- Har bir cardda: savol, AI javobi yoki kutish holati, status badge, sana
- Katta matn uchun "To'liq ko'rish" / "Qisqartirish" expandable text
- Pagination: "Yana yuklash" button (totalPages asosida)
- Pull-to-refresh
- Loading / error / empty holatlar
- Empty state: savol yo'q va filter natijasi bo'sh uchun alohida

### Route

- `/ai-advice` → `AiAdvicePage` (placeholder almashtirildi)

### Auth

`ApiClient` Bearer token avtomatik qo'shadi. Token bo'lmasa `/login`ga yo'naltiradi.

### Real AI Provider

Hali ulanmagan. Backend `LocalAiProvider` (mock) ishlatmoqda.

---

## Mobile Profile Screen (Step 58)

### Endpoint

- **GET /auth/me** — auth token orqali foydalanuvchi ma'lumotlarini oladi (AuthController.checkAuth() ichida).

### Foydalanuvchi ma'lumotlari (GET /auth/me response)

| Field       | Turi        | Tavsif                             |
|-------------|-------------|------------------------------------|
| id          | string      | Foydalanuvchi UUID                 |
| phone       | string      | Telefon raqami                     |
| role        | enum        | FARMER, LIVESTOCK_OWNER, va b.     |
| isVerified  | bool        | Telefon tasdiqlangan               |
| isActive    | bool        | Hisob faol                         |
| profile     | object/null | fullName, address, regionId        |

### Role labellar (o'zbekcha)

| Role            | Label           |
|-----------------|-----------------|
| FARMER          | Dehqon/Fermer   |
| LIVESTOCK_OWNER | Chorvador       |
| MACHINERY_OWNER | Texnika egasi   |
| BUYER           | Xaridor         |
| AGRONOMIST      | Agronom         |
| VETERINARIAN    | Veterinar       |
| ADMIN           | Admin           |

### UI tarkibi

**Avatar Card:**
- Initials (fullName "Ali Valiyev" → "AV", 1 so'z → birinchi harf, yo'q → phone oxirgi 2 raqam)
- fullName yoki "Ism kiritilmagan"
- Telefon raqami
- Role badge (o'zbekcha)

**Hisob holati Card:**
- isVerified → Tasdiqlangan (yashil) / Tasdiqlanmagan (sariq)
- isActive → Faol (yashil) / Faol emas (qizil)
- User ID (nusxalash imkoniyati)

**Profil ma'lumotlari Card:**
- fullName, address (agar mavjud)
- Bo'sh bo'lsa: "Profil ma'lumotlari to'liq emas" + "Profilni tahrirlash keyingi bosqichda"

**Tezkor harakatlar Card:**
- Mening e'lonlarim → `/my-listings`
- E'lon joylash → `/create-listing`
- AI maslahatlarim → `/ai-advice`
- Barcha e'lonlar → `/listings`

**Logout:**
- "Hisobdan chiqish" tugmasi
- Confirm dialog: "Hisobdan chiqmoqchimisiz?"
- authController.logout() → `/login`

### Refresh

- AppBar'da refresh icon va pull-to-refresh
- checkAuth() qayta chaqiriladi → ma'lumotlar yangilanadi
- Invalid token → `/login`

### Auth protection

- Auth state kuzatiladi (ref.listen)
- isAuthenticated false bo'lsa → `/login`
- isLoading → loading indikator

### Profile edit / Avatar upload

Hozircha **yozilmagan**. Keyingi bosqichlarda `PATCH /auth/profile` va avatar upload qo'shiladi.

### Route

- `/profile` → `ProfilePage` (placeholder almashtirildi)

---

## Mobile UI State Polishing (Step 59)

### Reusable UI State Widgetlari

Barcha mobil ilovadagi sahifalarda yagona UX pattern ta'minlash uchun `lib/shared/widgets/app_state_widgets.dart` faylida quyidagi widgetlar yaratildi:

1. **AppLoadingState**: Butun sahifa yoki ma'lum bir qism yuklanayotganda ko'rsatiladigan premium animatsiya va matn.
2. **AppErrorState**: Xatolik yuz berganda (masalan, tarmoq xatosi yoki 404) ko'rsatiladigan chiroyli xabar va "Qayta urinish" (Retry) hamda "Ortga qaytish" (Go Back) tugmalari.
3. **AppEmptyState**: Ro'yxatlar yoki ma'lumotlar bo'sh bo'lganda ko'rsatiladigan chiroyli ikonka va tushuntirish matni.
4. **AppSuccessState**: Muvaffaqiyatli jarayon yakunlanganda (masalan, e'lon muvaffaqiyatli yaratilganda) ko'rsatiladigan yashil banner va action tugmasi.
5. **AppInfoBox**: Har xil ogohlantiruvchi, xato yoki ma'lumot beruvchi bannerlar (alert, warning, info) uchun moslashuvchan widget.

### Yangilangan sahifalar

1. **CategoriesPage**: Kategoriya yuklanishida `AppLoadingState`, xatolikda `AppErrorState`, bo'sh bo'lsa `AppEmptyState` widgetlari integratsiya qilindi.
2. **ListingsPage**: E'lonlar yuklanishida `AppLoadingState`, xatolikda `AppErrorState`, bo'sh bo'lsa `AppEmptyState`.
3. **MyListingsPage**: Foydalanuvchining shaxsiy e'lonlari ro'yxatida yagona yuklanish, xato va bo'sh holatlar.
4. **ListingDetailPage**: E'lon batafsil ma'lumotlari yuklanishida `AppLoadingState` va topilmagan yoki yuklanmagan holatda `AppErrorState`.
5. **CreateListingPage**: Kategoriyalar va regionlar yuklanishi hamda xatoligi boshqarildi. Muvaffaqiyatli yakunlanganda `AppSuccessState` uslubida ekran chiqishi sozlindi. Formalarda `AppInfoBox` ishlatildi.
6. **ListingImageUploadPage**: Rasm yuklashdagi muvaffaqiyat va xatolik bannerlari `AppInfoBox` yordamida standartlashtirildi.
7. **AiAdvicePage**: AI savollar ro'yxatidagi loading, error, empty holatlar va yangi savol yuborishdagi xabarlar paneli.
8. **ProfilePage**: Profil yuklanishi `AppLoadingState` ga o'tkazildi, xatoliklar va to'liq bo'lmagan ma'lumotlar haqidagi bannerlar `AppInfoBox` bilan almashtirildi.
9. **LoginPage**: Xatolik, muvaffaqiyat va dasturchilar uchun dev OTP xabarlari `AppInfoBox` widgetiga o'tkazildi.

---

## APK Build Preparation (Step 60)

### Muhitni sozlash va Android SDK konfiguratsiyasi

Mobil ilovani APK ko'rinishida build qilish uchun Android qurish muhiti noldan muvaffaqiyatli sozlandi va konfiguratsiya qilindi:

1. **JDK o'rnatish:**
   - Eclipse Temurin OpenJDK 17 yuklab olindi va extract qilindi.
   - Joylashuvi: `/home/xbmb/development/jdk-17`

2. **Android SDK Command-Line Tools:**
   - Android SDK Command-line tools yuklab olindi.
   - Joylashuvi: `/home/xbmb/development/android-sdk/cmdline-tools/latest`

3. **Tizim o'zgaruvchilari (Environment Variables):**
   - Hozirgi terminal va doimiy ravishda `~/.bashrc` fayliga quyidagi o'zgaruvchilar qo'shildi:
     ```bash
     export JAVA_HOME="$HOME/development/jdk-17"
     export ANDROID_HOME="$HOME/development/android-sdk"
     export ANDROID_SDK_ROOT="$ANDROID_HOME"
     export PATH="$JAVA_HOME/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$HOME/development/flutter/bin:$PATH"
     ```

4. **Android SDK komponentlari:**
   - `sdkmanager` orqali quyidagi Android komponentlari yuklab olindi va o'rnatildi:
     - `platform-tools`
     - `build-tools;34.0.0` va `build-tools;36.0.0`
     - `platforms;android-34` va `platforms;android-35` hamda `platforms;android-36`
     - `ndk;28.2.13676358` (Native build pluginlar uchun)
     - `cmake;3.22.1`

5. **Flutter va Android Toolchain:**
   - Flutter config ga Android SDK yo'li bog'landi:
     `flutter config --android-sdk /home/xbmb/development/android-sdk`
   - Barcha Android SDK litsenziyalari qabul qilindi:
     `flutter doctor --android-licenses`
   - `flutter doctor -v` tekshirilganda **Android toolchain** to'liq yashil (muvaffaqiyatli) holatga keldi.

6. **APK Build:**
   - Quyidagi buyruq orqali Debug APK muvaffaqiyatli build qilindi:
     ```bash
     flutter build apk --debug
     ```
   - **Chiqish yo'li (APK Output Path):** [app-debug.apk](file:///home/xbmb/qishloq_loihasi/birinchi_urunish/qishloq-ai/mobile-app/build/app/outputs/flutter-apk/app-debug.apk)
   - **Hajmi:** 151 Megabayt (debug build uchun normal holat).

> [!NOTE]
> Release imzolash (release signing) ishlari hali amalga oshirilmadi. Hozirgi bosqichda faqat debug APK build muhiti to'liq tayyorlandi.

## Local Pilot Test (Step 61)

Mobil ilovani local backend serverga ulanib ishlashini tekshirish uchun local test qilish bo'yicha tayyorgarlik yakunlandi.

### Local Tarmoq va IP Sozlamalari:
- **Asosiy server IP (wlo1 Wi-Fi):** `172.20.10.7`
- **Emulator uchun standart URL:** `http://10.0.2.2:3000` (default)
- **Real telefon uchun sozlanadigan URL:** `http://172.20.10.7:3000`

### O'rnatish va Test-Run:
- APK fayli `/home/xbmb/qishloq_loihasi/birinchi_urunish/qishloq-ai/mobile-app/build/app/outputs/flutter-apk/app-debug.apk` manzilida mavjud.
- Batafsil sinovlarni amalga oshirish uchun maxsus [Local Pilot Test Checklist](file:///home/xbmb/.gemini/antigravity/brain/8d19965f-a63a-4d64-a65c-45c839ddd450/local_pilot_test_checklist.md) hujjati yaratildi. U orqali login, e'lon yaratish, rasm yuklash, mening e'lonlarim, AI maslahat va profil oqimlarini to'liq sinovdan o'tkazish mumkin.

### Keyingi qadam (Step 62)
- Local pilot test natijasida topilgan xatoliklarni tuzatish va foydalanuvchilar fikrlari asosida takomillashtirish.

## UX Foundation & Bottom Navigation (Step 62)

Mobil ilova sahifalari o'rtasida navigatsiya qilish qulayligini ta'minlash uchun bottom navigation va premium dizayn asoslari joriy etildi:

1. **AppBottomNav Widgeti:**
   - GoRouter yordamida context.go() bilan ishlaydigan navigatsiya paneli yaratildi. Stack oshib ketishini oldini oladi.
   - Bosh sahifa, E'lonlar, E'lon Joylash, AI maslahat va Profil tablari o'rnatildi.
2. **Scaffold Integratsiyasi:**
   - HomePage, ListingsPage, CreateListingPage, AiAdvicePage va ProfilePage sahifalariga bottom navigation bar qo'shildi.
3. **AppBar va Navigatsiyani tozalash:**
   - Tablar o'rtasida keraksiz back-buttonlar olib tashlandi.

## Listings UI Refinement (Step 63)

E'lonlar bo'limi (ListingsPage) bozordagi zamonaviy e'lonlar platformalari (masalan, OLX) uslubidan ilhomlangan holda yanada qulay va chiroyli qilindi:

1. **Search Panel yangilanishi:**
   - Qidiruv maydoni chiroyli Card dizayni ichiga o'tkazildi.
   - Placeholder sifatida "E'lon qidirish..." o'rnatildi, chap tomonda search icon, o'ng tomonda esa aniq va yorqin "Qidirish" tugmasi joylashtirildi.
   - Qidiruv faqat "Qidirish" tugmasi bosilganda yoki klaviaturada submit bosilganda page 1 dan qayta yuklanadi.
2. **Horizontal Type Chips:**
   - Dropdown o'rniga horizontal scrollable ChoiceChip elementlari o'rnatildi.
   - Tanlangan chip agro-yashil rangda, tanlanmagani esa oq fonda yengil kulrang border bilan ko'rinadi.
   - Barchasi, Texnika ijarasi, Dehqon mahsulotlari, Chorva savdosi, Texnika savdosi, Agro xizmatlar turlari to'liq ishlaydi, backend enum qiymatlari o'zgarmasdan saqlangan.
3. **Active Filters & Clear System:**
   - Search matni va Kategoriya filtrlari faol bo'lganda yuqorida alohida o'chirish iconi bo'lgan chip formatida chiqadi.
   - O'ng tomonda "Tozalash" buttoni chiqib, u barcha filtrlarni bir marta bosish orqali local state va URL query'lardan o'chirib yuboradi.
4. **Marketplace Card Design:**
   - E'lon cardlari border-radius 16px, oq background va ochiq kulrang ingichka border bilan chiroyli shaklga keltirildi.
   - Chap tomonda 96x96 o'lchamdagi image (yoki rasm yuklanmagan bo'lsa agro-yashil agriculture placeholder iconi) joylashdi.
   - O'ng tomonda e'lon turi badge, e'lon sanasi, 2 qatordan oshmaydigan title, yashil va qalin shriftda e'lon narxi, hudud/manzil va telefon raqami ko'rinadi.
5. **Pagination & API Logic:**
   - "Yana yuklash" tugmasi `AppButton` ga o'tkazilib, u yuklash jarayonida to'g'ri disabled/loading holatini ko'rsatadi hamda bottom nav bilan yopilib qolmaydi.
   - Pull-to-refresh uchun `RefreshIndicator` qo'shildi.
   - API va backend ulanish, GoRouter categories navigatsiyasi va detail pagega o'tish logikalari 100% buzilmasdan saqlab qolindi.

### Keyingi qadam (Step 64)
- E'lon tafsilotlari (Listing detail) sahifasi UX qismini to'liq redizayn qilish va chiroyli ko'rinishga keltirish.

## Listing Detail UX Polish (Step 64)

E'lon tafsilotlari sahifasi (`ListingDetailPage`) foydalanuvchilar uchun qulay va professional ko'rinishga keltirildi:

1. **Rasm Galereyasi (Image Gallery):**
   - Agar e'lon rasmlari mavjud bo'lsa, 300px balandlikdagi premium PageView joriy etildi. Burchaklari pastki qismda 24px radiusda yumaloqlandi.
   - O'ng pastki burchakda yorqin va qorong'u fonda `1 / 3` ko'rinishidagi rasm hisoblagichi (image counter) badge joylashtirildi.
   - Rasm yuklanmagan bo'lsa, agro-yashil agriculture placeholder iconi va "Rasm qo'shilmagan" yozuvi bilan chiroyli placeholder chiqadi.
2. **Asosiy ma'lumotlar kartasi (Main Info Card):**
   - E'lon turi (type badge) va holati (status badge: ACTIVE -> yashil, PENDING -> sariq, REJECTED -> qizil, ARCHIVED -> kulrang) aniq ajratildi.
   - Sarlavha (Title) qalin fontda va narx (`formattedPrice`) katta, yashil hamda ko'zga tashlanadigan qilib styled qilindi.
   - Yaratilgan va oxirgi yangilangan vaqti aniq ko'rsatiladi.
3. **Tavsif kartasi (Description Card):**
   - Alohida card ichida "Tavsif" sarlavhasi ostida joylashdi. Tavsif kiritilmagan bo'lsa maxsus placeholder ko'rsatiladi.
   - Matn font o'lchami 14 va line-height 1.5 qilinib, o'qilishi osonlashtirildi.
4. **Joylashuv kartasi (Location Card):**
   - Hudud (region name) va to'liq manzil (address) location icon yordamida alohida kartaga ajratildi.
5. **Bog'lanish kartasi (Contact Card):**
   - Telefon raqami yirik bold fontda chiqadi va yonida "Nusxalash" buttoni joylashdi.
   - Telefon raqami buferga nusxalanadi va yengil SnackBar ko'rsatiladi.
6. **Sticky Bottom Contact Bar:**
   - Telefon raqam mavjud bo'lganda sahifa pastiga doimiy ko'rinadigan yopishqoq contact bar joylashtirildi.
   - Telefon raqami ko'rinib, o'ng tomonda "Nusxalash" tugmasi turadi. Bu foydalanuvchi scroll qilganda ham doimiy foydalanish imkoniyatini beradi.
   - Pastki gesture/nav panel bilan yopilib qolmasligi uchun dynamic safe bottom padding qo'shildi.
7. **Loading/Error/404 tizimi:**
   - 59-qadamdagi reusable state widgetlar bilan 100% integratsiya qilindi.
   - 404 error yuz berganda "E'lon topilmadi yoki faol emas" va "E'lonlar ro'yxatiga qaytish" tugmasi saqlangan holda AppErrorState chiqadi.
8. **API & Logic:**
   - `GET /listings/:id` API call logic va uning router/detail oqimlari 100% buzilmasdan saqlab qolindi.

## Create Listing Wizard Flow (Step 65)

`CreateListingPage` bitta uzun formadan 5 bosqichli wizard flowga o'tkazildi:

1. **Kategoriya tanlash** — kategoriyalar `GET /reference/categories` orqali yuklanadi, card ko'rinishida tanlanadi va e'lon turi avtomatik `category.type`dan olinadi.
2. **Asosiy ma'lumot** — sarlavha va tavsif alohida stepda validatsiya qilinadi (`title` majburiy, 3-120 belgi; `description` max 2000 belgi).
3. **Narx va aloqa** — narx ixtiyoriy, lekin kiritilsa faqat raqam/decimal formatda tekshiriladi; valyuta `UZS` ko'rinadi va o'zgartirilmaydi; telefon `+998XXXXXXXXX` formatida validatsiya qilinadi.
4. **Joylashuv** — hudud `GET /reference/regions` orqali dropdown ko'rinishida tanlanadi, manzil ixtiyoriy va max 255 belgi bilan cheklanadi.
5. **Tasdiqlash va yuborish** — yuborishdan oldin barcha kiritilgan ma'lumotlar review ekranda ko'rsatiladi, bo'sh maydonlar `Kiritilmagan` deb belgilanadi.

### UX va validatsiya

- Yuqorida `1/5 Kategoriya`, `2/5 Ma'lumot`, `3/5 Narx va aloqa`, `4/5 Joylashuv`, `5/5 Tasdiqlash` ko'rinishidagi progress indicator saqlandi.
- Har bir stepdan keyingisiga o'tishda faqat shu step validatsiyasi ishlaydi.
- Submit oldidan barcha fieldlar yana tekshiriladi va xato bo'lsa foydalanuvchi kerakli stepga qaytariladi.
- Pastki `Ortga`, `Keyingi` va `E'lonni yuborish` tugmalari `AppButton` orqali boshqariladi.
- Bottom navigation (`AppBottomNav currentIndex: 2`), auth protection va scroll/padding flowlari saqlandi.

### API va success flow

- `POST /listings` uchun `CreateListingRequest` payload fieldlari o'zgartirilmadi.
- `ListingService.createListing` va backend endpointlar o'zgartirilmadi.
- Yaratilgandan keyingi success ekrani saqlandi: `Rasm qo'shish`, `Mening e'lonlarim`, `E'lonlar ro'yxatiga o'tish`, `Bosh sahifa`.
- Image upload flow `/listings/:id/images` yaratilgan listing ID bilan ishlashda davom etadi.

## My Listings UX Polish (Step 66)

`MyListingsPage` foydalanuvchi kabinetiga mosroq va statuslarni tez tushunadigan ko'rinishga keltirildi:

1. **Summary header:**
   - Yuqorida `E'lonlaringiz` cardi qo'shildi.
   - `GET /listings/my` javobidagi `meta.total` qiymati `N ta` ko'rinishida chiqariladi.
   - Meta hali kelmagan holatda sarlavha `E'lonlaringiz ro'yxati` bo'lib turadi.
2. **Status chips:**
   - Barchasi / Moderatsiyada / Faol / Rad etilgan / Arxivda statuslari horizontal chip ko'rinishida chiqadi.
   - Backend query qiymatlari o'zgarmadi: `null`, `PENDING`, `ACTIVE`, `REJECTED`, `ARCHIVED`.
   - Tanlangan chip status rangida, tanlanmagan chip oq fonda kulrang border bilan ko'rinadi.
3. **Marketplace card design:**
   - Har bir e'lon 96x96 rasm preview, agro placeholder, title, narx, status badge, type badge, sana va hudud/manzil bilan ko'rsatiladi.
   - Status badge ranglari: PENDING olovrang, ACTIVE yashil, REJECTED qizil, ARCHIVED kulrang.
4. **Action row:**
   - ACTIVE e'lonlarda `Ko'rish` public detailga (`/listings/:id`) olib boradi.
   - PENDING va ACTIVE e'lonlarda `Rasm qo'shish` `/listings/:id/images` image upload flowiga olib boradi.
   - REJECTED e'lonlarda `Rad sababi admin panelda`, ARCHIVED e'lonlarda `Arxivlangan` izohi ko'rsatiladi.
   - Edit/archive yoki yangi action qo'shilmadi.
5. **Empty/loading/error holatlar:**
   - Loading uchun `AppLoadingState`, error uchun `AppErrorState`, bo'sh ro'yxat uchun `AppEmptyState` saqlandi.
   - E'lon yo'q bo'lsa `E'lon joylash` actioni `/create-listing`ga olib boradi.
   - Status filter sabab bo'sh bo'lsa tushunarli izoh chiqadi.
6. **Pagination va API logic:**
   - `Yana yuklash` buttoni `AppButton`ga o'tkazildi va loading paytida disabled/loading ko'rinadi.
   - `ListingService.getMyListings`, `GET /listings/my`, query params (`page`, `limit`, `status`) va auth flow o'zgartirilmadi.

### Keyingi qadam (Step 67)
- Favorites funksiyasini qo'shish.

## Favorites / Sevimlilar (Step 67)

Favorites funksiyasi backend, database va Flutter mobile app bo'ylab qo'shildi:

1. **Database va backend:**
   - Prisma schema ichiga userga bog'langan `Favorite` modeli qo'shildi.
   - `userId + listingId` unique bo'lib, bitta user bir listingni bir marta sevimliga qo'sha oladi.
   - Favorite yozuvlari user yoki listing o'chsa cascade tarzda tozalanadi.
2. **Backend API:**
   - `GET /favorites/my` — login qilgan userning sevimli ACTIVE e'lonlarini pagination bilan qaytaradi.
   - `GET /favorites/ids` — login qilgan user favorite qilgan listing ID larini array ko'rinishida qaytaradi.
   - `POST /favorites/:listingId` — ACTIVE e'lonni sevimlilarga qo'shadi.
   - `DELETE /favorites/:listingId` — e'lonni sevimlilardan olib tashlaydi.
   - `GET /listings` va `GET /listings/:id` javoblariga authenticated user uchun `isFavorite` flag qo'shildi; public ishlash saqlandi.
3. **Mobile UI:**
   - `lib/features/favorites/data/favorite_service.dart` data layer yaratildi.
   - Listing cardlarda yurakcha tugmasi qo'shildi.
   - ListingsPage va DetailPage heart holati `GET /favorites/ids` orqali aniqlanadi.
   - Listing detail AppBar ichida favorite toggle chiqadi.
   - `/favorites` route va `FavoritesPage` qo'shildi.
   - Profile tezkor harakatlarida `Sevimlilar` bo'limi qo'shildi.
4. **Persist flow:**
   - Favorite holati local-only emas, backendda saqlanadi.
   - User qayta login qilganda sevimli listinglar API orqali qayta ko'rinadi.
5. **Chegaralar:**
   - Admin panelga tegilmadi.
   - Payment, booking, chat, notifications, seller profile, listing edit/archive qo'shilmadi.
   - Existing auth, listings, detail, create listing wizard, image upload, my listings, AI va profile flowlar saqlandi.

### Keyingi qadam (Step 68)
- Seller profile yoki Chat/contact flow.
