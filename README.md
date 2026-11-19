# FadeIn — Sistem Aplikasi Booking Barbershop

FadeIn adalah aplikasi pemesanan (booking) barbershop. Pelanggan dapat melihat daftar
layanan dan barber, memilih jadwal, lalu memantau status booking. Admin mengelola data
barber, layanan, foto, serta status setiap booking.

Repositori ini berisi **REST API (backend)**. Aplikasi client Flutter dikembangkan pada
tahap berikutnya (`feat/flutter-ui`).

## Teknologi

| Bagian | Teknologi |
|---|---|
| Bahasa backend | JavaScript (ES Modules) |
| Framework | Express.js 5 |
| Database | MySQL 8 (`db_fadein`) |
| Autentikasi | JWT (JSON Web Token) + bcryptjs |
| Upload foto | Multer (memory storage) + Cloudinary |
| Deploy backend | Vercel (serverless) |

## Struktur Repositori

```
FadeIn/
├── README.md
├── .gitignore
└── fadein-backend/
    ├── api/index.js              # entry point Vercel
    ├── server.js                 # entry point lokal
    ├── vercel.json               # konfigurasi routing Vercel
    ├── package.json
    ├── .env.example              # contoh variabel environment
    ├── database/
    │   └── db_fadein.sql         # skema + data seed
    └── src/
        ├── app.js                # konfigurasi Express
        ├── config/               # koneksi MySQL & Cloudinary
        ├── controllers/          # logika auth, user, barber, service, booking
        ├── middlewares/          # auth JWT, role, upload, error handler
        ├── routes/               # definisi endpoint
        └── utils/                # helper respons & validasi
```

## Skema Database

Empat tabel dengan relasi Primary Key dan Foreign Key, dua index, tanpa trigger,
tanpa generated column, dan tanpa CHECK constraint.

| Tabel | Fungsi |
|---|---|
| `users` | Akun admin dan customer (password di-hash bcrypt) |
| `barbers` | Data kapster beserta URL foto dari Cloudinary |
| `services` | Daftar layanan, harga, dan durasi |
| `bookings` | Transaksi booking: user, barber, layanan, tanggal, jam, status |

Pencegahan double booking dilakukan di backend melalui transaksi database
(`SELECT ... FOR UPDATE`). Bila slot sudah terpakai, API membalas **409 Conflict**.

## Menjalankan Secara Lokal

### 1. Siapkan database

```bash
mysql -u root -p < fadein-backend/database/db_fadein.sql
```

### 2. Konfigurasi environment

```bash
cd fadein-backend
cp .env.example .env
```

Sesuaikan isi `.env` (host/port/user/password MySQL serta kredensial Cloudinary).
Berkas `.env` **tidak** disertakan di repositori.

### 3. Install & jalankan

```bash
npm install
npm start          # http://localhost:3000
# atau
npm run dev        # dengan auto-reload
```

Cek status server:

```bash
curl http://localhost:3000/api/health
```

## Daftar Endpoint

Semua endpoint (kecuali register/login) memerlukan header
`Authorization: Bearer <token>`.

### Autentikasi

| Method | Endpoint | Akses |
|---|---|---|
| POST | `/api/auth/register` | Publik |
| POST | `/api/auth/login` | Publik |

### Profil

| Method | Endpoint | Akses |
|---|---|---|
| GET | `/api/users/profile` | Login |
| PUT | `/api/users/photo` | Login (multipart, field `photo`) |

### Barber

| Method | Endpoint | Akses |
|---|---|---|
| GET | `/api/barbers` | Login |
| GET | `/api/barbers/:id` | Login |
| POST | `/api/barbers` | Admin (multipart, field `photo`) |
| PUT | `/api/barbers/:id` | Admin |
| DELETE | `/api/barbers/:id` | Admin |

### Layanan

| Method | Endpoint | Akses |
|---|---|---|
| GET | `/api/services` | Login |
| GET | `/api/services/:id` | Login |
| POST | `/api/services` | Admin |
| PUT | `/api/services/:id` | Admin |
| DELETE | `/api/services/:id` | Admin |

### Booking

| Method | Endpoint | Akses |
|---|---|---|
| GET | `/api/bookings` | Login |
| GET | `/api/bookings/:id` | Login |
| GET | `/api/bookings/slots?barber_id=&date=` | Login |
| POST | `/api/bookings` | Login |
| PATCH | `/api/bookings/:id/cancel` | Login (pemilik booking) |
| PATCH | `/api/bookings/:id/status` | Admin |

### Aturan Booking

- `booking_time` berformat `HH:MM` dan hanya tersedia pukul **09:00–20:00**.
- Tanggal lampau ditolak; jam hari ini yang sudah lewat juga ditolak.
- Satu slot (barber + tanggal + jam) tidak boleh dipakai dua booking aktif.

## Akun Seed

Diperoleh dari `database/db_fadein.sql`:

| Role | Email | Password |
|---|---|---|
| Admin | `admin@fadein.com` | `admin123` |
| Customer | `budi@gmail.com` | `customer123` |
| Customer | `rina@gmail.com` | `customer123` |

Registrasi lewat API selalu membuat akun **customer**; akun admin hanya berasal dari seed.

## Pengujian

Pengujian blackbox dilakukan terhadap REST API yang berjalan lokal:

| Hasil | Jumlah |
|---|---|
| Pass (REST API) | 27 test case |
| Belum dijalankan (UI Flutter) | 3 test case |
| Fail | 0 |

Mencakup autentikasi, otorisasi role (403), CRUD barber & layanan, validasi unggah foto
(400), pembuatan booking, penolakan bentrok jadwal (409), pembatalan, dan pembaruan status.

## Alur Branch

| Branch | Isi |
|---|---|
| `main` | Rilis stabil |
| `dev` | Integrasi fitur |
| `feat/database` | Skema `db_fadein.sql` |
| `feat/backend-api` | Implementasi REST API |
| `feat/flutter-ui` | Aplikasi client Flutter (rencana) |

## Lisensi

Dibuat untuk keperluan tugas sekolah (ASAS RPL, SMK Taruna Bhakti).
