import 'package:fadein_app/models/Booking.dart';
import 'package:fadein_app/models/BookingStatus.dart';
import 'package:fadein_app/utils/statistik.dart';
import 'package:flutter_test/flutter_test.dart';

Booking _b({
  required String tanggal,
  required BookingStatus status,
  String layanan = 'Haircut',
  num harga = 50000,
  String jam = '10:00',
}) {
  return Booking(
    id: 1,
    userId: 2,
    barberId: 1,
    serviceId: 1,
    bookingDate: tanggal,
    bookingTime: jam,
    status: status,
    customerName: 'Budi',
    barberName: 'Amba',
    serviceName: layanan,
    price: harga,
    duration: 45,
  );
}

void main() {
  group('Statistik.hitung', () {
    test('data kosong menghasilkan nol, bukan error', () {
      final s = Statistik.hitung(
        const [],
        jumlahBarber: 2,
        hariIni: '2026-11-28',
      );

      expect(s.bookingBulanIni, 0);
      expect(s.pendapatanBulanIni, 0);
      expect(s.hariAktif, 0);
      expect(s.rataRataPerHari, 0);
      expect(s.layananTerpopuler, isNull);
      expect(s.persenLayananTerpopuler, 0);
      expect(s.pertumbuhan, isNull);
      expect(s.okupansiPersen, 0);
      expect(s.totalSlotHariIni, 24);
    });

    test('pendapatan hanya menjumlah booking selesai bulan ini', () {
      final s = Statistik.hitung(
        [
          _b(tanggal: '2026-11-02', status: BookingStatus.completed, harga: 50000),
          _b(tanggal: '2026-11-03', status: BookingStatus.completed, harga: 70000),
          // belum selesai -> tidak dihitung pendapatan
          _b(tanggal: '2026-11-04', status: BookingStatus.pending, harga: 90000),
          // dibatalkan -> tidak dihitung
          _b(tanggal: '2026-11-05', status: BookingStatus.cancelled, harga: 90000),
          // bulan lain -> tidak dihitung
          _b(tanggal: '2026-10-09', status: BookingStatus.completed, harga: 999999),
        ],
        jumlahBarber: 1,
        hariIni: '2026-11-28',
      );

      expect(s.pendapatanBulanIni, 120000);
      expect(s.bookingBulanIni, 4);
    });

    test('rata-rata memakai tanggal unik, bukan jumlah booking', () {
      final s = Statistik.hitung(
        [
          _b(tanggal: '2026-11-02', status: BookingStatus.completed, harga: 40000),
          _b(tanggal: '2026-11-02', status: BookingStatus.completed, harga: 60000),
          _b(tanggal: '2026-11-07', status: BookingStatus.completed, harga: 50000),
        ],
        jumlahBarber: 1,
        hariIni: '2026-11-28',
      );

      // 150.000 dibagi 2 hari aktif, bukan 3 booking
      expect(s.hariAktif, 2);
      expect(s.rataRataPerHari, 75000);
    });

    test('layanan terpopuler memakai modus dan persennya', () {
      final s = Statistik.hitung(
        [
          _b(tanggal: '2026-11-02', status: BookingStatus.completed, layanan: 'Haircut'),
          _b(tanggal: '2026-11-03', status: BookingStatus.completed, layanan: 'Haircut'),
          _b(tanggal: '2026-11-04', status: BookingStatus.confirmed, layanan: 'Haircut'),
          _b(tanggal: '2026-11-05', status: BookingStatus.pending, layanan: 'Cukur Jenggot'),
        ],
        jumlahBarber: 1,
        hariIni: '2026-11-28',
      );

      expect(s.layananTerpopuler, 'Haircut');
      expect(s.jumlahLayananTerpopuler, 3);
      expect(s.persenLayananTerpopuler, 75);
    });

    test('layanan dibatalkan tidak dihitung saat mencari modus', () {
      final s = Statistik.hitung(
        [
          _b(tanggal: '2026-11-02', status: BookingStatus.completed, layanan: 'Haircut'),
          _b(tanggal: '2026-11-03', status: BookingStatus.cancelled, layanan: 'Cukur Jenggot'),
          _b(tanggal: '2026-11-04', status: BookingStatus.cancelled, layanan: 'Cukur Jenggot'),
        ],
        jumlahBarber: 1,
        hariIni: '2026-11-28',
      );

      expect(s.layananTerpopuler, 'Haircut');
      expect(s.persenLayananTerpopuler, 100);
      // penyebut persentase hanya booking yang tidak dibatalkan
      expect(s.bookingDihitung, 1);
      expect(s.bookingBulanIni, 3);
    });

    test('pertumbuhan positif terhadap bulan lalu', () {
      final s = Statistik.hitung(
        [
          _b(tanggal: '2026-10-10', status: BookingStatus.completed, harga: 100000),
          _b(tanggal: '2026-11-10', status: BookingStatus.completed, harga: 150000),
        ],
        jumlahBarber: 1,
        hariIni: '2026-11-28',
      );

      expect(s.pendapatanBulanLalu, 100000);
      expect(s.pertumbuhan, 50);
    });

    test('pertumbuhan negatif saat pendapatan turun', () {
      final s = Statistik.hitung(
        [
          _b(tanggal: '2026-10-10', status: BookingStatus.completed, harga: 200000),
          _b(tanggal: '2026-11-10', status: BookingStatus.completed, harga: 150000),
        ],
        jumlahBarber: 1,
        hariIni: '2026-11-28',
      );

      expect(s.pertumbuhan, -25);
    });

    test('pertumbuhan null kalau bulan lalu belum ada pendapatan', () {
      final s = Statistik.hitung(
        [
          _b(tanggal: '2026-11-10', status: BookingStatus.completed, harga: 150000),
        ],
        jumlahBarber: 1,
        hariIni: '2026-11-28',
      );

      // pembagian dengan nol tidak dipaksakan jadi angka
      expect(s.pertumbuhan, isNull);
    });

    test('Januari membandingkan dengan Desember tahun sebelumnya', () {
      final s = Statistik.hitung(
        [
          _b(tanggal: '2025-12-15', status: BookingStatus.completed, harga: 80000),
          _b(tanggal: '2026-01-15', status: BookingStatus.completed, harga: 100000),
        ],
        jumlahBarber: 1,
        hariIni: '2026-01-20',
      );

      expect(s.pendapatanBulanLalu, 80000);
      expect(s.pertumbuhan, 25);
    });

    test('okupansi memakai slot per barber per hari dan dibatasi 100', () {
      final penuh = Statistik.hitung(
        [
          for (var i = 0; i < 10; i++)
            _b(tanggal: '2026-11-28', status: BookingStatus.pending, jam: '1$i:00'),
        ],
        jumlahBarber: 1,
        hariIni: '2026-11-28',
      );

      expect(penuh.totalSlotHariIni, 12);
      expect(penuh.slotTerisiHariIni, 10);
      expect(penuh.okupansiPersen, closeTo(83.33, 0.01));

      final lebih = Statistik.hitung(
        [
          for (var i = 0; i < 15; i++)
            _b(tanggal: '2026-11-28', status: BookingStatus.pending),
        ],
        jumlahBarber: 1,
        hariIni: '2026-11-28',
      );

      // data berlebih tidak boleh menghasilkan 125%
      expect(lebih.okupansiPersen, 100);
    });

    test('booking batal hari ini tidak mengisi slot', () {
      final s = Statistik.hitung(
        [
          _b(tanggal: '2026-11-28', status: BookingStatus.cancelled),
          _b(tanggal: '2026-11-28', status: BookingStatus.confirmed),
        ],
        jumlahBarber: 2,
        hariIni: '2026-11-28',
      );

      expect(s.slotTerisiHariIni, 1);
      expect(s.totalSlotHariIni, 24);
    });
  });
}
