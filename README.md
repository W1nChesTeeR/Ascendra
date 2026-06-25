# 🚀 Ascendra — MVP v1.0

> Talabalar va rivojlanayotgan yoshlar uchun premium vazifa, odat va rivojlanish platformasi.

---

## 📁 Loyiha tuzilmasi

```
ascendra/
├── app/
│   ├── (auth)/                     # Auth sahifalari (sidebar yo'q)
│   │   ├── login/page.tsx          # Kirish
│   │   └── register/page.tsx       # Ro'yxatdan o'tish
│   ├── (app)/                      # Asosiy sahifalar (sidebar bor)
│   │   ├── layout.tsx              # Auth tekshiruvi + sidebar wrapper
│   │   ├── dashboard/page.tsx      # Bosh sahifa — Server Component
│   │   ├── vazifalar/page.tsx      # Vazifalar CRUD — Client Component
│   │   ├── odatlar/page.tsx        # Odatlar CRUD — Client Component
│   │   └── profil/page.tsx         # Profil statistikasi — Server Component
│   ├── api/
│   │   ├── tasks/
│   │   │   ├── route.ts            # GET (ro'yxat), POST (yaratish)
│   │   │   └── [id]/route.ts       # PUT (tahrir), DELETE, PATCH (bajarish)
│   │   └── habits/
│   │       ├── route.ts            # GET (ro'yxat), POST (yaratish)
│   │       ├── [id]/route.ts       # PUT (tahrir), DELETE
│   │       └── [id]/complete/      # POST (bugun bajarildi)
│   │           └── route.ts
│   ├── globals.css
│   ├── layout.tsx                  # Root layout
│   └── page.tsx                    # / → /dashboard yoki /login
├── components/
│   └── layout/
│       ├── AppSidebar.tsx          # Desktop yon menyu
│       └── MobileBottomNav.tsx     # Mobil quyi navigatsiya
├── lib/
│   ├── supabase/
│   │   ├── client.ts               # Browser Supabase client
│   │   └── server.ts               # Server Supabase client
│   └── utils.ts                    # cn() yordamchi funksiya
├── types/
│   └── index.ts                    # Barcha TypeScript turlari + XP hisoblash
├── middleware.ts                    # Auth yo'naltirish
├── supabase-schema.sql             # To'liq database schema
├── .env.local.example
├── next.config.ts
├── tailwind.config.ts
├── tsconfig.json
└── package.json
```

---

## 🗄️ Database jadvallari

| Jadval | Vazifasi |
|--------|----------|
| `profiles` | Foydalanuvchi XP, Level, Streak |
| `tasks` | Vazifalar (nomi, qiyinlik, muddat) |
| `habits` | Odatlar (nomi, icon, streak) |
| `habit_completions` | Kunlik odat bajarilishi |

---

## ⚙️ O'rnatish — Qadam baqadam

### 1. Supabase loyihasi yarating

1. [supabase.com](https://supabase.com) → **New Project**
2. Loyiha nomi: `ascendra`
3. Ma'lumotlar bazasi paroli kiriting (eslab qoling)
4. Region: **Frankfurt** yoki **Singapore**
5. **Create new project** → 2 daqiqa kuting

---

### 2. Database schemani o'rnating

1. Supabase Dashboard → **SQL Editor** oching
2. `supabase-schema.sql` faylini to'liq nusxalang
3. SQL Editor ga joylashtiring → **Run** bosing
4. ✅ Xato yo'q bo'lsa muvaffaqiyatli

---

### 3. Email tasdiqlashni o'chiring *(development uchun)*

```
Supabase Dashboard
  → Authentication
  → Providers
  → Email
  → "Confirm email" → OFF
  → Save
```

> ⚠️ Production da bu ni yoqiq qoldiring!

---

### 4. API kalitlarni oling

```
Supabase Dashboard → Settings → API

Project URL:   https://xxxxxxxxxxxx.supabase.co
anon key:      eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

---

### 5. Muhit o'zgaruvchilarini sozlang

```bash
cp .env.local.example .env.local
```

`.env.local` faylini oching va to'ldiring:

```env
NEXT_PUBLIC_SUPABASE_URL=https://your-project-id.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key-here
```

---

### 6. Dependencylarni o'rnating va ishga tushiring

```bash
npm install
npm run dev
```

Brauzerda oching: **http://localhost:3000**

---

## 🌐 Vercel Deploy

### 1. GitHub ga yuklang

```bash
git init
git add .
git commit -m "feat: Ascendra MVP v1.0"
git branch -M main
git remote add origin https://github.com/username/ascendra.git
git push -u origin main
```

### 2. Vercel ga ulang

1. [vercel.com](https://vercel.com) → **Add New Project**
2. GitHub reponi tanlang
3. Framework: **Next.js** (avtomatik)
4. **Environment Variables** qo'shing:

| Kalit | Qiymat |
|-------|--------|
| `NEXT_PUBLIC_SUPABASE_URL` | `https://xxx.supabase.co` |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | `eyJhbGci...` |

5. **Deploy** → 2-3 daqiqada tayyor! 🎉

---

## 🎮 XP Tizimi

| Vazifa qiyinligi | XP |
|------------------|----|
| Oson             | +10 XP |
| O'rta            | +20 XP |
| Qiyin            | +40 XP |
| Epik             | +80 XP |
| Odat (kunlik)    | +15 XP |

## 📈 Level Tizimi

```
Level = floor(XP / 100) + 1

  0 –  99 XP  →  Level 1–2  (Yangi boshlagan)
100 – 299 XP  →  Level 2–3  (Izlovchi)
300 – 699 XP  →  Level 4–7  (Rivojlanuvchi)
700 –1199 XP  →  Level 8–12 (Ustoz)
1200–1999 XP  →  Level 13+  (Ekspert)
3000+     XP  →  Level 31+  (Legenda)
```

## 🔥 Streak Tizimi

- Har kuni kamida **1 ta vazifa yoki 1 ta odat** bajarilsa streak davom etadi
- Kecha ham, bugun ham faol bo'lsa: `streak + 1`
- Orada kun o'tkazib yuborilsa: `streak = 1` (reset)

---

## 🔒 Xavfsizlik

- **Row Level Security (RLS)** — barcha jadvallarda yoqilgan
- Foydalanuvchi faqat **o'z ma'lumotlarini** ko'radi va o'zgartiradi
- **JWT token** orqali autentifikatsiya (Supabase Auth)
- **Middleware** — har sahifa serverda auth tekshiriladi
- API routelar ham serverda `auth.getUser()` orqali tekshiriladi

---

## 🛠️ Texnologiyalar

| Qatlam | Texnologiya |
|--------|------------|
| Frontend | Next.js 15, TypeScript, Tailwind CSS v3 |
| Auth + DB | Supabase (PostgreSQL, RLS) |
| Deploy | Vercel |

---

*Ascendra MVP v1.0 — 2025*
