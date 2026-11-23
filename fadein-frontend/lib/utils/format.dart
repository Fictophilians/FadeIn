import 'package:intl/intl.dart';

/// Helper format tampilan untuk seluruh aplikasi.
///
/// Backend mengirim tanggal sebagai `YYYY-MM-DD` dan jam sebagai `HH:mm`
/// (lihat `dateStrings: true` di `fadein-backend/src/config/db.js`), jadi
/// fungsi di sini bekerja dari string tersebut.

/// Format uang Indonesia tanpa desimal.
///
/// `formatRupiah(35000)` → `Rp35.000`
String formatRupiah(num nilai) {
  final formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );
  return formatter.format(nilai);
}

/// Ubah string tanggal backend menjadi [DateTime].
///
/// Bagian jam (kalau ada) diabaikan supaya tidak terjadi pergeseran zona waktu.
DateTime _parseTanggal(String tanggal) {
  final bagian = tanggal.substring(0, 10).split('-');
  return DateTime(
    int.parse(bagian[0]),
    int.parse(bagian[1]),
    int.parse(bagian[2]),
  );
}

/// Format tanggal ringkas.
///
/// `formatTanggal('2026-11-20')` → `20 Nov 2026`
String formatTanggal(String tanggal) {
  final date = _parseTanggal(tanggal);
  return DateFormat('d MMM yyyy', 'id_ID').format(date);
}

/// Nama hari dalam bahasa Indonesia.
///
/// `formatHari('2026-11-20')` → `Jumat`
String formatHari(String tanggal) {
  final date = _parseTanggal(tanggal);
  return DateFormat('EEEE', 'id_ID').format(date);
}

/// Format jam dari `HH:mm` menjadi `HH.mm`.
///
/// `formatJam('14:30')` → `14.30`
String formatJam(String jam) {
  final bagian = jam.split(':');
  if (bagian.length < 2) return jam;

  final hh = bagian[0].padLeft(2, '0');
  final mm = bagian[1].padLeft(2, '0');
  return '$hh.$mm';
}
