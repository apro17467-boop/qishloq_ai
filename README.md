# qishloq_ai
# qishloq-ai

Bu loyiha uchun asosiy papka tuzilmasi yaratildi.
Step 69 — Contact flow polish

- url_launcher dependency qo‘shildi.
- Listing detail sahifasida contact actions yaxshilandi.
- Qo‘ng‘iroq qilish, SMS yuborish va telefonni nusxalash actionlari qo‘shildi.
- Sticky contact bar yangilandi.
- Contact bottom sheet qo‘shildi.
- Seller profile’da telefon raqam ko‘rsatilmaydi, privacy saqlandi.
- Backend/admin/database o‘zgarmadi.

Step 70 — Real SMS OTP integration foundation

- Modular `SmsModule` yaratildi va dynamic `SmsService` provider routing joriy etildi (`DevSmsProvider` va `GenericHttpSmsProvider`).
- Development rejimida loglar orqali OTP kod ko'rsatiladi va API javobida `devOtp`/`devCode` qaytariladi.
- Production/Real Provider rejimida secure random 6 xonali OTP yuboriladi va u API response body hamda console loglarda yashiriladi.
- Error handling va secret validation sozlandi.
- Mobile `LoginPage` va `RequestOtpResponse` modeli backward-compatible va production ready holatga keltirildi.
- Testlar muvaffaqiyatli o'tdi, APK build muvaffaqiyatli yakunlandi.