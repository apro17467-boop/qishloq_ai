# QISHLOQ AI Admin Panel Release Checklist

## Local Development

- [ ] Backend `http://localhost:3000` da ishga tushgan.
- [ ] Admin panel `.env.local` sozlangan.
- [ ] `npm install`
- [ ] `npm run lint`
- [ ] `npm run build`
- [ ] `npm run dev`
- [ ] `http://localhost:3001/login` ochiladi.

## Production Build Local Test

- [ ] `npm run build`
- [ ] `npm run start`
- [ ] `/login`
- [ ] `/dashboard`
- [ ] `/listings`
- [ ] `/complaints`
- [ ] `/users`
- [ ] `/ai-questions`

## Security / Config

- [ ] `NEXT_PUBLIC_API_BASE_URL` production backend URLga almashtiriladi.
- [ ] Backend CORS admin panel production domainiga ruxsat beradi.
- [ ] Token storage masalasi keyingi bosqichlarda qayta ko'rib chiqiladi.
- [ ] Productionda HTTPS ishlatiladi.
- [ ] Production admin userlar controlled internal process orqali yaratiladi.

## Manual Smoke Tests

- [ ] Login: OTP so'rash va tasdiqlash.
- [ ] Logout: token o'chadi va user `/login`ga qaytadi.
- [ ] Protected routes: token yo'q holatda `/login`ga redirect.
- [ ] Dashboard stats: cards backenddan yuklanadi.
- [ ] Listing moderation: `PENDING` listingni approve/reject qilish.
- [ ] Complaint status update: `OPEN` yoki `IN_REVIEW` complaint statusini yangilash.
- [ ] Users detail: user detail modal ochiladi.
- [ ] AI question detail: AI question detail modal ochiladi.

## Final Notes

- [ ] Browser console critical error yo'q.
- [ ] Jadval sahifalarida horizontal scroll ishlaydi.
- [ ] Mobile/tablet viewportda navigation buzilmaydi.
- [ ] README va docs fayllar yangilangan.
