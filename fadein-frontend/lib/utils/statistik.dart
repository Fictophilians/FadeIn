import 'package:fadein_app/models/Booking.dart';
import 'package:fadein_app/models/BookingStatus.dart';

/// Ringkasan angka untuk dashboard admin.
///
/// Sengaja dipisah dari layar supaya bisa diuji tanpa merender widget, dan
/// supaya rumusnya terbaca sebagai satu blok di depan guru Matematika.
///
/// Semua perhitungan memakai data yang sudah dikirim `GET /bookings`
/// (kolom `price`, `status`, `booking_date`, `service_name`), jadi backend
/// tidak perlu endpoint agregat baru.
class Statistik {
  const Statistik({
    required this.bookingBulanIni,
    required this.bookingDihitung,
    required this.pendapatanBulanIni,
    required this.hariAktif,
    required this.rataRataPerHari,
    required this.layananTerpopuler,
    required this.jumlahLayananTerpopuler,
    required this.persenLayananTerpopuler,
    required this.pendapatanBulanLalu,
    required this.pertumbuhan,
    required this.slotTerisiHariIni,
    required this.totalSlotHariIni,
    required this.okupansiPersen,
  });

  /// Jumlah jam operasional per barber per hari: `09:00` sampai `20:00`,
  /// satu slot tiap jam (lihat `buildSlots()` di `bookingController.js`).
  ///
  /// `20 - 9 + 1 = 12` — deret bilangan bulat inklusif.
  static const int slotPerBarberPerHari = 12;

  /// Jumlah booking (semua status) pada bulan berjalan.
  final int bookingBulanIni;

  /// Booking bulan ini yang tidak dibatalkan — penyebut untuk persentase
  /// layanan. Dipisah dari [bookingBulanIni] supaya "2 dari 3" dan "67%"
  /// selalu memakai angka dasar yang sama.
  final int bookingDihitung;

  /// Σ `price` booking berstatus `completed` pada bulan berjalan.
  final num pendapatanBulanIni;

  /// Banyak tanggal berbeda yang punya booking selesai bulan ini.
  /// Dipakai sebagai pembagi rata-rata, bukan jumlah hari dalam bulan,
  /// supaya hari tanpa transaksi tidak menurunkan angka secara palsu.
  final int hariAktif;

  /// `pendapatanBulanIni / hariAktif`. Nol kalau belum ada hari aktif.
  final num rataRataPerHari;

  /// Layanan paling sering dipesan bulan ini. `null` kalau belum ada data.
  final String? layananTerpopuler;

  final int jumlahLayananTerpopuler;

  /// `jumlahLayananTerpopuler / bookingBulanIni * 100`.
  final double persenLayananTerpopuler;

  /// Σ `price` booking selesai bulan lalu, untuk pembanding.
  final num pendapatanBulanLalu;

  /// `pendapatanBulanIni - pendapatanBulanLalu`.
  ///
  /// Dipakai saat bulan lalu masih nol: persentase tidak bisa dihitung
  /// (pembagi nol), tetapi selisih nominalnya tetap bermakna.
  num get selisih => pendapatanBulanIni - pendapatanBulanLalu;

  /// Persentase perubahan terhadap bulan lalu. `null` kalau bulan lalu nol —
  /// pembagian dengan nol tidak menghasilkan angka yang jujur, jadi layar
  /// menampilkan tanda pisah, bukan `∞`.
  final double? pertumbuhan;

  /// Booking yang masih memakai slot hari ini (pending/confirmed/completed).
  final int slotTerisiHariIni;

  /// `jumlahBarber * slotPerBarberPerHari`.
  final int totalSlotHariIni;

  /// `slotTerisiHariIni / totalSlotHariIni * 100`, dibatasi 100.
  final double okupansiPersen;

  /// [hariIni] berformat `YYYY-MM-DD` (WIB) — dipakai sebagai acuan bulan
  /// dan hari supaya hasilnya bisa diuji tanpa bergantung jam sistem.
  factory Statistik.hitung(
    List<Booking> bookings, {
    required int jumlahBarber,
    required String hariIni,
  }) {
    final bulanIni = hariIni.substring(0, 7);
    final bulanLalu = _bulanSebelum(bulanIni);

    final bookingBulanIni = bookings
        .where((b) => b.bookingDate.startsWith(bulanIni))
        .toList();

    // Dibatalkan tidak dihitung sebagai minat pelanggan.
    final terjual = bookingBulanIni
        .where((b) => b.status != BookingStatus.cancelled)
        .toList();

    final selesai = bookingBulanIni
        .where((b) => b.status == BookingStatus.completed)
        .toList();

    final pendapatan = selesai.fold<num>(0, (total, b) => total + b.price);

    final hari = selesai.map((b) => b.bookingDate).toSet();

    final bulanLaluSelesai = bookings.where(
      (b) =>
          b.bookingDate.startsWith(bulanLalu) &&
          b.status == BookingStatus.completed,
    );
    final pendapatanLalu = bulanLaluSelesai.fold<num>(
      0,
      (total, b) => total + b.price,
    );

    final hitungLayanan = <String, int>{};
    for (final b in terjual) {
      hitungLayanan[b.serviceName] = (hitungLayanan[b.serviceName] ?? 0) + 1;
    }

    String? populer;
    var jumlahPopuler = 0;
    for (final entry in hitungLayanan.entries) {
      if (entry.value > jumlahPopuler) {
        populer = entry.key;
        jumlahPopuler = entry.value;
      }
    }

    final totalSlot = jumlahBarber * slotPerBarberPerHari;
    final terisi = bookings
        .where((b) => b.bookingDate == hariIni)
        .where((b) => b.status != BookingStatus.cancelled)
        .length;

    return Statistik(
      bookingBulanIni: bookingBulanIni.length,
      bookingDihitung: terjual.length,
      pendapatanBulanIni: pendapatan,
      hariAktif: hari.length,
      rataRataPerHari: hari.isEmpty ? 0 : pendapatan / hari.length,
      layananTerpopuler: populer,
      jumlahLayananTerpopuler: jumlahPopuler,
      persenLayananTerpopuler:
          terjual.isEmpty ? 0 : jumlahPopuler / terjual.length * 100,
      pendapatanBulanLalu: pendapatanLalu,
      pertumbuhan: pendapatanLalu == 0
          ? null
          : (pendapatan - pendapatanLalu) / pendapatanLalu * 100,
      slotTerisiHariIni: terisi,
      totalSlotHariIni: totalSlot,
      okupansiPersen: totalSlot == 0
          ? 0
          : (terisi / totalSlot * 100).clamp(0, 100).toDouble(),
    );
  }

  /// `2026-01` menjadi `2025-12`.
  static String _bulanSebelum(String bulan) {
    final tahun = int.parse(bulan.substring(0, 4));
    final angka = int.parse(bulan.substring(5, 7));
    final sebelumnya = angka == 1 ? 12 : angka - 1;
    final tahunSebelumnya = angka == 1 ? tahun - 1 : tahun;
    return '${tahunSebelumnya.toString().padLeft(4, '0')}-'
        '${sebelumnya.toString().padLeft(2, '0')}';
  }
}
