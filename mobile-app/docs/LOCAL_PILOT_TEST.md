# Local Pilot Test Checklist (Step 61)

Ushbu hujjat **Qishloq AI** mobil ilovasini local muhitda real telefon yoki emulyatorda sinovdan o'tkazish natijalarini hujjatlashtiradi.

---

## 📊 Test Natijalari Jadvali

| ID | Modul | Test qadami | Kutilgan natija | Amaldagi natija | Status | Severity | Izoh |
|:---:|:---|:---|:---|:---|:---:|:---:|:---|
| **01** | **App Start** | APK ochilishi va Splash screen chiqishi | Splash screen ko'rinadi, so'ng login sahifasiga o'tadi | Splash muvaffaqiyatli ko'rindi va login sahifasi yuklandi | **PASS** | - | - |
| **02** | **Login** | Telefon va Dev OTP yuborish | Dev OTP (`111111`) orqali tizimga kiradi, Home ochiladi | Muvaffaqiyatli kirdi va token secure storage'da saqlandi | **PASS** | - | - |
| **03** | **Profile** | Shaxsiy ma'lumotlarni ko'rish | Ism, telefon raqami va rol to'g'ri ko'rsatiladi | Profil ma'lumotlari backend'dan yuklanib to'g'ri chiqdi | **PASS** | - | - |
| **04** | **Categories** | Toifalarni ko'rish | Barcha toifalar backend'dan yuklanib ko'rinadi | Toifalar ro'yxati chiroyli kartochkalarda yuklandi | **PASS** | - | - |
| **05** | **Listings** | E'lonlar ro'yxati | Barcha faol e'lonlar to'g'ri ko'rsatiladi, filter ishlaydi | E'lonlar ro'yxati chiqdi va filtrlar xatoliksiz ishladi | **PASS** | - | - |
| **06** | **Create Listing**| Yangi e'lon formasi | Nom, toifa, viloyat va tavsif kiritib yaratish | E'lon muvaffaqiyatli yaratilib, `PENDING` holatga o'tdi | **PASS** | - | - |
| **07** | **Image Upload** | Rasm yuklash oqimi | Rasm tanlanib, backend'ga muvaffaqiyatli yuklanadi | Tanlangan rasm yuklandi va yashil muvaffaqiyat xabari chiqdi | **PASS** | - | - |
| **08** | **My Listings** | Mening e'lonlarim sahifasi | Yangi yaratilgan e'lon `PENDING` holatda ko'rinadi | O'z e'lonlarim ro'yxatida yangi e'lon PENDING sifatida chiqdi | **PASS** | - | - |
| **09** | **Admin Approve**| Admin panelda tasdiqlash | Admin panelda e'lon `ACTIVE` qilinadi, ro'yxatda chiqadi | Admin ro'yxatidan ACTIVE holatga o'tkazilgach, e'lon hamma uchun ko'rindi | **PASS** | - | - |
| **10** | **Listing Detail**| E'lon batafsil sahifasi | Rasm, narx va bog'lanish ma'lumotlari to'g'ri chiqadi | Barcha ma'lumotlar va rasm to'g'ri yuklanib ko'rsatildi | **PASS** | - | - |
| **11** | **AI Advice** | AI maslahat savoli | Savol yuboriladi va unga javob qaytadi, tarixda ko'rinadi | Savol yuborilgach status pending bo'ldi, mock javob ko'rsatildi | **PASS** | - | - |
| **12** | **Logout** | Hisobdan chiqish | Secure storage tozalanadi va login sahifasiga qaytadi | Hisobdan muvaffaqiyatli chiqildi, login sahifasiga yo'naltirildi | **PASS** | - | - |

---

## 🔍 Topilgan Muammolar va Cheklovlar (Bug Report)

*Hozirgi test davomida hech qanday **Critical** yoki **High** darajadagi xatoliklar aniqlanmadi. Ilovaning barcha oqimlari `http://172.20.10.7:3000` LAN backend API bilan barqaror ishladi.*

---
*Sana: 2026-07-07*  
*Sinovchi: Antigravity AI & Developer*
