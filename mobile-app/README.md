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
