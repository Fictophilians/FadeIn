# FadeIn — Aplikasi Client Flutter

Aplikasi Android untuk booking barbershop FadeIn. Pelanggan melihat layanan dan
barber, memilih jadwal, lalu memantau status booking. Admin mengelola barber,
layanan, foto, dan status setiap booking.

Backend-nya REST API Express + MySQL di `../fadein-backend/`, sudah ter-deploy di
`https://fadein-backend.vercel.app/api`.

## Menjalankan

```bash
flutter pub get
flutter run
```

Secara bawaan aplikasi memakai backend yang sudah ter-deploy, jadi server lokal
tidak wajib dinyalakan.

Menunjuk backend lain:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:3000/api
```

## Pemeriksaan

```bash
flutter analyze     # harus "No issues found!"
flutter test        # seluruh tes harus lulus
```

## Struktur

| Folder | Isi |
|---|---|
| `lib/constants/` | Palet "Ivory & Ink", skala jarak, radius, tema |
| `lib/models/` | Model data dan `BookingStatus` |
| `lib/pages/` | Splash, Login, Register, Menu, Beranda, Booking, Pesanan, Profil, tiga layar admin |
| `lib/service/api.dart` | Satu pintu seluruh request HTTP + `ApiException` |
| `lib/utils/` | `formatRupiah`, `formatTanggal`, `formatJam`, pesan snackbar |
| `lib/widgets/` | Komponen bersama (card, chip, dialog, tombol) |
| `test/` | Unit test dan widget test |

## Akun uji

| Peran | Email | Password |
|---|---|---|
| Admin | `admin@fadein.com` | `admin123` |
| Customer | `budi@gmail.com` | `customer123` |
| Customer | `rina@gmail.com` | `customer123` |

Registrasi lewat aplikasi selalu membuat akun **customer**; akun admin hanya
berasal dari seed database.
