# QISHLOQ AI - Technical Planning

## 1. Project overview

QISHLOQ AI - dehqon, chorvador, texnika egasi, xaridor, agronom va veterinarlarni yagona agro marketplace va AI maslahat platformasida birlashtiradigan mobil-first ekotizim.

MVP maqsadi 6-8 oy ichida Android mobil ilova, backend API, admin panel va matnli AI maslahat servisidan iborat ishlaydigan birinchi versiyani ishlab chiqishdir.

Asosiy MVP qiymati:

- Dehqon va chorvadorlar mahsulot, chorva yoki texnika bo‘yicha e’lon joylaydi.
- Texnika egalari ijara e’lonlarini joylaydi.
- Xaridorlar va foydalanuvchilar e’lonlarni ko‘radi, filterlaydi va telefon orqali bog‘lanadi.
- Foydalanuvchilar qishloq xo‘jaligi bo‘yicha matnli savol beradi va AI’dan dastlabki maslahat oladi.
- Administratorlar e’lonlar, foydalanuvchilar, kategoriyalar, shikoyatlar va moderatsiyani boshqaradi.

MVP cheklovlari:

- Online to‘lov, ichki chat, GPS tracking va logistika yo‘q.
- AI rasm tahlili MVPga kirmaydi.
- iOS ilova MVPdan keyingi bosqichga qoldiriladi.
- Platforma yakuniy agronomik yoki veterinariya tashxisini bermaydi; AI javoblari maslahat xarakterida bo‘ladi.

Mahsulot tamoyillari:

- Oddiy ro‘yxatdan o‘tish: telefon raqam va OTP.
- Qishloq hududlari uchun yengil interfeys va past internet sharoitida ishlash.
- E’lonlarda ishonch, moderatsiya va shikoyat mexanizmi.
- Uzbek tilini asosiy til sifatida qo‘llab-quvvatlash, keyinchalik rus tili qo‘shilishi mumkin.

## 2. User roles

### Guest

- E’lonlar ro‘yxatini cheklangan ko‘rishi mumkin.
- E’lon tafsilotlarini ko‘rishi mumkin.
- E’lon joylash, telefon raqamni ko‘rish yoki AI savol berish uchun ro‘yxatdan o‘tishi kerak.

### Registered user

Umumiy ro‘yxatdan o‘tgan foydalanuvchi. Profilida telefon, ism, hudud, foydalanuvchi turi va rasm bo‘ladi.

Huquqlari:

- Profilni to‘ldirish va tahrirlash.
- Texnika, mahsulot yoki chorva bo‘yicha e’lon joylash.
- O‘z e’lonlarini tahrirlash, arxivlash yoki o‘chirish.
- AI maslahat bo‘limida savol berish.
- Shubhali e’lon yoki foydalanuvchi ustidan shikoyat yuborish.

### Dehqon

- Mahsulot sotish e’lonlarini joylaydi.
- Texnika ijarasi e’lonlarini ko‘radi.
- AI’dan ekin, kasallik, sug‘orish, o‘g‘itlash va mavsumiy ishlar bo‘yicha maslahat oladi.

### Chorvador

- Chorva sotish yoki xarid qilish bo‘yicha e’lon joylaydi.
- Yem, parvarish va umumiy veterinariya savollari bo‘yicha AI maslahat oladi.

### Texnika egasi

- Texnika ijarasi e’lonlarini joylaydi.
- Texnika turi, narxi, hududi, mavjudligi va aloqa ma’lumotlarini boshqaradi.

### Xaridor

- Mahsulot, chorva va texnika e’lonlarini izlaydi.
- Telefon orqali sotuvchi yoki texnika egasi bilan bog‘lanadi.

### Agronom

- MVPda oddiy foydalanuvchi roli sifatida saqlanadi.
- Keyingi bosqichda ekspert profili, pullik maslahat va tasdiqlangan mutaxassis belgisi qo‘shilishi mumkin.

### Veterinar

- MVPda oddiy foydalanuvchi roli sifatida saqlanadi.
- Keyingi bosqichda ekspert maslahati, klinika profili yoki tasdiqlangan veterinar belgisi qo‘shilishi mumkin.

### Moderator

- Admin panel orqali e’lonlar va shikoyatlarni ko‘rib chiqadi.
- E’lonni tasdiqlaydi, rad etadi, yashiradi yoki foydalanuvchini ogohlantiradi.

### Administrator

- Barcha admin funksiyalariga ega.
- Foydalanuvchilar, e’lonlar, kategoriyalar, hududlar, shikoyatlar, moderatsiya qarorlari va tizim sozlamalarini boshqaradi.

## 3. MVP modules

### Auth va profil

Funksiyalar:

- Telefon raqam orqali OTP yuborish va tasdiqlash.
- JWT access token va refresh token asosida sessiya.
- Profil yaratish: ism, telefon, hudud, foydalanuvchi turi, avatar.
- Profil tahrirlash.
- Foydalanuvchi statuslari: active, blocked, deleted.

MVP qoidalari:

- Telefon raqam yagona identifikator bo‘ladi.
- OTP urinishlari rate limit bilan himoyalanadi.
- Bloklangan foydalanuvchi e’lon joylay olmaydi va AI xizmatidan foydalana olmaydi.

### Texnika ijarasi

Funksiyalar:

- Texnika ijarasi e’loni yaratish.
- Texnika turi, nomi, tavsifi, narxi, narx birligi, hudud, telefon raqam va rasmlar.
- E’lon ro‘yxati, filterlar va qidiruv.
- E’lon tafsilotlari.
- Telefon orqali bog‘lanish tugmasi.
- O‘z e’lonlarini tahrirlash, arxivlash, o‘chirish.

MVP qoidalari:

- Bron qilish kalendari bo‘lmaydi.
- To‘lov ilova ichida amalga oshirilmaydi.
- E’lon admin yoki moderator tomonidan tasdiqlangandan keyin ommaga ko‘rinadi.

### Mahsulot/chorva bozori

Funksiyalar:

- Mahsulot, chorva yoki texnika sotuv e’loni yaratish.
- Kategoriya, nom, tavsif, narx, narx birligi, hudud, rasm va telefon raqam.
- Mahsulot, chorva va texnika bo‘yicha alohida filterlar.
- E’lon tafsilotlari va telefon orqali bog‘lanish.
- Shikoyat yuborish.

MVP qoidalari:

- Savdo kelishuvi platformadan tashqarida telefon orqali amalga oshadi.
- Platforma e’lon va aloqa kanalini beradi, lekin to‘lov yoki yetkazib berishni kafolatlamaydi.

### AI maslahat

Funksiyalar:

- Matnli savol yuborish.
- AI javobini chat ko‘rinishida olish.
- AI suhbatlar tarixini saqlash.
- Har bir AI javobida xavfsizlik ogohlantirishi ko‘rsatish.
- Nomaqbul yoki mavzudan tashqari savollarga cheklangan javob qaytarish.

MVP qoidalari:

- AI faqat dastlabki maslahat beradi.
- Har bir javobda “Yakuniy qaror uchun agronom yoki veterinar bilan maslahat qiling” mazmunidagi ogohlantirish bo‘ladi.
- AI dori dozalari, xavfli kimyoviy ishlovlar yoki aniq veterinariya tashxislari bo‘yicha yakuniy ko‘rsatma bermaydi.

### Admin panel

Funksiyalar:

- Admin login.
- Dashboard: foydalanuvchilar, e’lonlar, shikoyatlar va AI savollar statistikasi.
- Foydalanuvchilarni ko‘rish, bloklash, blokdan chiqarish.
- E’lonlarni tasdiqlash, rad etish, yashirish.
- Kategoriyalar va hududlarni boshqarish.
- Shikoyatlarni ko‘rib chiqish.
- Moderatsiya tarixini ko‘rish.

MVP qoidalari:

- Admin panel web ilova sifatida ishlaydi.
- Har bir muhim admin harakati audit logga yoziladi.

### Moderatsiya va shikoyatlar

Funksiyalar:

- Foydalanuvchi e’lon yoki profil ustidan shikoyat yuboradi.
- Shikoyat sababi: scam, noto‘g‘ri narx, noto‘g‘ri kategoriya, haqoratli kontent, takroriy e’lon, boshqa.
- Moderator shikoyatni open, in_review, resolved, rejected statuslari bilan boshqaradi.
- E’lon statuslari: draft, pending_review, published, rejected, archived, hidden.
- Moderatsiya qarori uchun izoh saqlanadi.

MVP qoidalari:

- Avtomatik moderatsiya minimal bo‘ladi: majburiy maydonlar, rasm soni, telefon formati va taqiqlangan so‘zlar tekshiriladi.
- Yakuniy qaror moderator tomonidan beriladi.

## 4. Database entities

### users

- id
- phone
- full_name
- role
- region_id
- district_id
- avatar_url
- status
- last_login_at
- created_at
- updated_at

### auth_sessions

- id
- user_id
- refresh_token_hash
- device_name
- ip_address
- expires_at
- revoked_at
- created_at

### otp_codes

- id
- phone
- code_hash
- purpose
- attempts_count
- expires_at
- consumed_at
- created_at

### regions

- id
- name
- sort_order
- is_active

### districts

- id
- region_id
- name
- sort_order
- is_active

### categories

- id
- parent_id
- type
- name
- slug
- sort_order
- is_active

Category type qiymatlari:

- machinery_rental
- product_sale
- livestock_sale
- machinery_sale

### listings

- id
- owner_id
- category_id
- type
- title
- description
- price
- currency
- price_unit
- region_id
- district_id
- contact_phone
- status
- moderation_reason
- metadata
- view_count
- contact_click_count
- published_at
- created_at
- updated_at

Metadata misollari:

- Texnika: brand, model, year, condition, service_area.
- Mahsulot: quantity, unit, harvest_date, quality_grade.
- Chorva: animal_type, breed, age, weight, gender.

### listing_media

- id
- listing_id
- file_url
- file_type
- sort_order
- created_at

### complaints

- id
- reporter_id
- target_type
- target_id
- reason
- description
- status
- assigned_admin_id
- resolution_note
- created_at
- updated_at

Target type qiymatlari:

- listing
- user
- ai_response

### moderation_actions

- id
- admin_id
- target_type
- target_id
- action
- reason
- created_at

### ai_conversations

- id
- user_id
- title
- language
- created_at
- updated_at

### ai_messages

- id
- conversation_id
- role
- content
- safety_label
- model_name
- token_usage
- created_at

Role qiymatlari:

- user
- assistant
- system

### ai_feedback

- id
- message_id
- user_id
- rating
- comment
- created_at

### file_assets

- id
- owner_id
- url
- storage_key
- mime_type
- size_bytes
- purpose
- created_at

### audit_logs

- id
- actor_id
- action
- entity_type
- entity_id
- before_data
- after_data
- ip_address
- created_at

## 5. API modules

API v1 REST formatida ishlab chiqiladi. Backend OpenAPI/Swagger dokumentatsiyasini avtomatik taqdim etishi kerak.

### Auth API

- POST /auth/request-otp
- POST /auth/verify-otp
- POST /auth/refresh
- POST /auth/logout
- GET /auth/me

### Profile API

- GET /profile
- PATCH /profile
- POST /profile/avatar
- DELETE /profile/avatar

### Regions and categories API

- GET /regions
- GET /regions/:id/districts
- GET /categories

### Listings API

- GET /listings
- GET /listings/:id
- POST /listings
- PATCH /listings/:id
- DELETE /listings/:id
- POST /listings/:id/archive
- POST /listings/:id/contact-click

Asosiy query filterlar:

- type
- category_id
- region_id
- district_id
- min_price
- max_price
- search
- sort
- page
- limit

### Media API

- POST /media/upload
- DELETE /media/:id

### AI API

- GET /ai/conversations
- POST /ai/conversations
- GET /ai/conversations/:id/messages
- POST /ai/conversations/:id/messages
- POST /ai/messages/:id/feedback

### Complaints API

- POST /complaints
- GET /complaints/my
- GET /complaints/:id

### Admin API

- GET /admin/dashboard
- GET /admin/users
- GET /admin/users/:id
- PATCH /admin/users/:id/status
- GET /admin/listings
- PATCH /admin/listings/:id/status
- GET /admin/complaints
- PATCH /admin/complaints/:id
- GET /admin/categories
- POST /admin/categories
- PATCH /admin/categories/:id
- GET /admin/audit-logs

### System API

- GET /health
- GET /version

API xavfsizlik talablari:

- JWT authentication.
- Role-based access control.
- Request validation.
- Rate limiting: OTP, AI savollar, media upload.
- File upload uchun mime type va size cheklovlari.
- Admin endpointlar uchun alohida permission tekshiruvi.

## 6. Mobile app screens

MVP mobil ilova Android-first bo‘ladi.

### Auth flow

- Splash screen
- Til tanlash yoki avtomatik til aniqlash
- Telefon raqam kiritish
- OTP tasdiqlash
- Profilni to‘ldirish
- Foydalanuvchi turini tanlash

### Main navigation

- Home
- Texnika
- Bozor
- AI maslahat
- Profil

### Home

- Qidiruv inputi
- Asosiy kategoriyalar
- Yaqin hududdagi e’lonlar
- Oxirgi joylangan e’lonlar
- AI maslahatga tezkor kirish

### Texnika ijarasi

- Texnika e’lonlari ro‘yxati
- Filter: hudud, kategoriya, narx, narx birligi
- Texnika tafsilotlari
- Telefon orqali bog‘lanish
- Shikoyat yuborish

### Mahsulot/chorva bozori

- Bozor kategoriyalari
- Mahsulot e’lonlari ro‘yxati
- Chorva e’lonlari ro‘yxati
- Sotuvdagi texnika e’lonlari ro‘yxati
- E’lon tafsilotlari
- Telefon orqali bog‘lanish

### E’lon yaratish

- E’lon turini tanlash
- Kategoriya tanlash
- Asosiy ma’lumotlar formasi
- Narx va narx birligi
- Hudud tanlash
- Rasm yuklash
- Aloqa telefoni
- Preview
- Moderatsiyaga yuborish

### My listings

- Mening e’lonlarim
- Status bo‘yicha tablar: pending, published, rejected, archived
- E’lonni tahrirlash
- E’lonni arxivlash

### AI maslahat

- AI chat ro‘yxati
- Yangi savol yozish
- Suhbat oynasi
- AI javobida xavfsizlik ogohlantirishi
- Javobni baholash
- Oldingi suhbatlar tarixi

### Profile

- Profil ma’lumotlari
- Telefon raqam
- Hudud
- Foydalanuvchi turi
- Avatar
- Mening e’lonlarim
- Shikoyatlarim
- Chiqish

### Common states

- Loading state
- Empty state
- Error state
- Offline yoki zaif internet holati
- Rasm yuklash progressi
- Moderatsiya status bannerlari

## 7. Admin panel screens

### Admin login

- Telefon yoki email orqali admin login.
- Parol va kerak bo‘lsa OTP.
- Faqat admin/moderator rollari kira oladi.

### Dashboard

- Jami foydalanuvchilar.
- Yangi foydalanuvchilar.
- Pending e’lonlar.
- Published e’lonlar.
- Ochiq shikoyatlar.
- AI savollar soni.
- Oxirgi moderatsiya harakatlari.

### Users

- Foydalanuvchilar ro‘yxati.
- Qidiruv va filter: role, status, hudud.
- Foydalanuvchi profili.
- Bloklash yoki blokdan chiqarish.
- Foydalanuvchining e’lonlari va shikoyatlari.

### Listings moderation

- Pending e’lonlar ro‘yxati.
- E’lon tafsilotlari.
- Rasmlarni ko‘rish.
- Tasdiqlash.
- Rad etish.
- Yashirish.
- Moderatsiya izohi.

### Categories and regions

- Kategoriyalar ro‘yxati.
- Kategoriya qo‘shish va tahrirlash.
- Hudud va tumanlar ro‘yxati.
- Aktiv yoki noaktiv qilish.

### Complaints

- Shikoyatlar ro‘yxati.
- Filter: status, reason, target_type.
- Shikoyat tafsilotlari.
- Target e’lon yoki profilni ko‘rish.
- Qaror qabul qilish: resolved yoki rejected.
- Zarur bo‘lsa e’lonni yashirish yoki foydalanuvchini bloklash.

### AI safety review

- AI suhbatlar ro‘yxati.
- Shikoyat tushgan AI javoblarini ko‘rish.
- Javobni safety label bilan belgilash.
- Noto‘g‘ri javoblarni product improvement uchun belgilash.

### Audit logs

- Admin harakatlari tarixi.
- Filter: actor, action, entity_type, date range.
- O‘zgargan ma’lumotlarning before/after ko‘rinishi.

## 8. AI service scope

AI xizmatining MVP scope’i matnli agro maslahat bilan cheklanadi.

Qo‘llab-quvvatlanadigan mavzular:

- Ekin ekish, parvarish, sug‘orish va o‘g‘itlash bo‘yicha umumiy maslahat.
- O‘simlik kasalliklari belgilari bo‘yicha ehtimoliy sabablar va umumiy choralar.
- Chorva parvarishi, yemlash va umumiy sog‘liq bo‘yicha dastlabki maslahat.
- Texnika tanlash yoki mavsumiy agro ishlar bo‘yicha umumiy tavsiyalar.
- Mahsulotni saqlash, saralash va bozorga tayyorlash bo‘yicha maslahat.

AI javob formati:

- Muammoni qisqa qayta ifodalash.
- Ehtimoliy sabablar.
- Amaliy birinchi qadamlar.
- Xavfsizlik va ehtiyot choralari.
- Qachon mutaxassisga murojaat qilish kerakligi.
- Majburiy ogohlantirish: yakuniy qaror uchun agronom yoki veterinar bilan maslahat qilish.

AI guardrails:

- Aniq tashxis yoki kafolatlangan natija bermaydi.
- Dorilar, pestitsidlar va kimyoviy moddalar bo‘yicha xavfli dozalarni tavsiya qilmaydi.
- Favqulodda veterinariya holatlarida darhol mutaxassisga murojaat qilishni tavsiya qiladi.
- Mavzudan tashqari, noqonuniy yoki zararli so‘rovlarga javob bermaydi.
- Har bir foydalanuvchi uchun AI savollariga kunlik limit qo‘yilishi mumkin.

AI servis arxitekturasi:

- Mobile app AI savolni backend API’ga yuboradi.
- Backend foydalanuvchi autentifikatsiyasi, rate limit va safety pre-check qiladi.
- AI service prompt template va foydalanuvchi kontekstini tayyorlaydi.
- Model provider’dan javob olinadi.
- Javob post-checkdan o‘tadi va ai_messages jadvaliga saqlanadi.
- Javob mobil ilovaga qaytariladi.

MVPda AI context:

- Foydalanuvchi roli.
- Hudud.
- Savol matni.
- Foydalanuvchi bergan ekin yoki chorva turi.
- Oldingi suhbatdagi qisqa kontekst.

MVPga kirmaydigan AI imkoniyatlari:

- Rasm orqali kasallik aniqlash.
- Audio savol-javob.
- Avtomatik ekspertga ulash.
- To‘liq agro reja generatori.
- Real-time ob-havo yoki IoT sensorlar bilan integratsiya.

## 9. Non-MVP features

Quyidagi funksiyalar MVPdan keyingi bosqichlarga qoldiriladi:

- Online to‘lov va escrow.
- Ilova ichidagi chat.
- Bron qilish kalendari.
- GPS tracking va texnika harakatini kuzatish.
- Avtomatik logistika va yetkazib berish.
- Reyting va review tizimi.
- Tasdiqlangan agronom/veterinar marketplace.
- Pullik ekspert maslahati.
- AI rasm tahlili: ekin kasalligi, zararkunanda yoki chorva holatini rasm orqali baholash.
- AI audio maslahat.
- Ob-havo, bozor narxlari va mavsumiy ogohlantirishlar.
- Push notificationlar.
- Ko‘p tillilikni kengaytirish.
- iOS mobil ilova.
- Davlat tizimlari bilan integratsiya.
- Eksport shartnomalari va B2B savdo moduli.
- Suv, o‘g‘it va resurs taqsimoti modullari.
- Advanced analytics va BI dashboard.

## 10. Suggested technology stack

### Mobile app

- Flutter va Dart.
- Android-first release.
- Material 3 asosidagi yengil UI.
- State management: Riverpod yoki Bloc.
- Networking: Dio.
- Local cache: Hive yoki SQLite.

Tanlov sababi: Flutter bitta codebase bilan keyinchalik iOSga chiqish imkonini beradi, Android MVP uchun tez prototiplash va barqaror UI ishlab chiqishga mos.

### Backend

- Node.js LTS.
- NestJS va TypeScript.
- REST API.
- OpenAPI/Swagger documentation.
- Prisma ORM.
- PostgreSQL.

Tanlov sababi: NestJS modulli arxitektura, validation, guards, services, testing va OpenAPI integratsiyasi uchun qulay. Marketplace, admin panel va AI gateway kabi modullarni tartibli ajratishga mos.

### Admin panel

- Next.js va TypeScript.
- React Hook Form.
- TanStack Query.
- Tailwind CSS yoki shadcn/ui komponentlari.

Tanlov sababi: Admin panel uchun tez ishlab chiqish, server-side rendering shart bo‘lmagan sahifalarda ham kuchli routing va form handling imkoniyatlari beradi.

### Database and storage

- PostgreSQL asosiy relational database.
- S3-compatible object storage: MinIO dev muhitda, productionda AWS S3, Cloudflare R2 yoki DigitalOcean Spaces.
- Redis optional: OTP rate limit, queue va cache uchun.

Tanlov sababi: PostgreSQL e’lonlar, foydalanuvchilar, moderatsiya, shikoyatlar va AI loglar uchun relational modelga mos; JSONB metadata orqali turli e’lon atributlarini moslashuvchan saqlash mumkin.

### AI integration

- Backend ichida AI gateway moduli bilan boshlash.
- Provider abstraction: keyinchalik model provider almashtirish oson bo‘lishi kerak.
- Prompt templates versioning.
- AI request/response logging.
- Safety pre-check va post-check.

### Infrastructure

- Docker va Docker Compose.
- VPS yoki cloud VM.
- Nginx reverse proxy.
- Managed PostgreSQL tavsiya qilinadi, lekin MVPda self-hosted ham mumkin.
- CI/CD: GitHub Actions.
- Error monitoring: Sentry.
- Logs: structured JSON logs.

### Testing

- Backend: unit test, integration test, API e2e test.
- Mobile: widget test va asosiy flow smoke test.
- Admin panel: component test va Playwright e2e test.
- Manual QA: real Android device va past internet sharoitida tekshiruv.

## 11. Development roadmap

### Phase 0 - Product clarification and UX baseline, 1-2 hafta

Deliverables:

- MVP scope yakuniy tasdiqlanadi.
- User journey va asosiy flowlar chiziladi.
- Figma wireframe yoki low-fidelity ekranlar tayyorlanadi.
- Hududlar, kategoriyalar va e’lon turlari bo‘yicha boshlang‘ich reference data aniqlanadi.
- AI safety disclaimer matni tasdiqlanadi.

### Phase 1 - Architecture and foundation, 3-4 hafta

Deliverables:

- Monorepo yoki alohida repo strategiyasi tanlanadi.
- Backend project foundation.
- Database schema draft va migration flow.
- Auth, users, regions, categories modullari uchun API contract.
- Admin va mobile uchun design system boshlang‘ich komponentlari.
- CI/CD skeleton.

### Phase 2 - Auth, profile and reference data, 3-4 hafta

Deliverables:

- Telefon OTP login.
- Profil yaratish va tahrirlash.
- Region/district/category API.
- Mobile auth flow.
- Admin login.
- Basic audit log.

### Phase 3 - Listings marketplace, 6-8 hafta

Deliverables:

- Texnika ijarasi e’lonlari.
- Mahsulot, chorva va texnika sotuv e’lonlari.
- Media upload.
- Search va filterlar.
- E’lon tafsilotlari.
- Telefon orqali bog‘lanish.
- My listings.
- E’lon statuslari va pending moderation flow.

### Phase 4 - Admin moderation and complaints, 4-5 hafta

Deliverables:

- Admin dashboard.
- Users management.
- Listings moderation.
- Complaints management.
- Categories management.
- Moderation actions.
- Audit logs.

### Phase 5 - AI advice MVP, 3-5 hafta

Deliverables:

- AI conversation API.
- Mobile AI chat.
- Prompt templates.
- Safety disclaimer.
- AI usage limit.
- AI message logging.
- AI feedback.
- Admin AI safety review.

### Phase 6 - QA, pilot and hardening, 4-6 hafta

Deliverables:

- End-to-end testing.
- Android real device testing.
- Performance optimization for slow network.
- Security review: auth, admin permissions, upload validation, rate limits.
- Bug fixing.
- Pilot users bilan test.
- Feedback asosida MVP polish.

### Phase 7 - Release preparation, 2-3 hafta

Deliverables:

- Production deployment.
- Backup strategy.
- Monitoring and alerting.
- Admin operational guide.
- Basic support process.
- Android APK yoki Play Store release tayyorgarligi.

Roadmap umumiy davomiyligi: taxminan 6-8 oy.
