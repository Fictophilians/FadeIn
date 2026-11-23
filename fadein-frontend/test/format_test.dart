import 'package:fadein_app/utils/format.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    // Data locale id_ID wajib dimuat sebelum DateFormat dipakai
    await initializeDateFormatting('id_ID');
  });

  group('formatRupiah', () {
    test('format standar', () {
      expect(formatRupiah(35000), 'Rp35.000');
      expect(formatRupiah(50000), 'Rp50.000');
    });

    test('nominal besar', () {
      expect(formatRupiah(1250000), 'Rp1.250.000');
    });

    test('nol', () {
      expect(formatRupiah(0), 'Rp0');
    });
  });

  group('formatTanggal', () {
    test('format ringkas', () {
      expect(formatTanggal('2026-11-20'), '20 Nov 2026');
    });

    test('abaikan bagian jam', () {
      expect(formatTanggal('2026-01-05 10:30:00'), '5 Jan 2026');
    });
  });

  group('formatHari', () {
    test('nama hari bahasa Indonesia', () {
      expect(formatHari('2026-11-20'), 'Jumat');
      expect(formatHari('2026-11-23'), 'Senin');
    });
  });

  group('formatJam', () {
    test('ganti titik dua jadi titik', () {
      expect(formatJam('14:30'), '14.30');
      expect(formatJam('09:05'), '09.05');
    });

    test('abaikan detik', () {
      expect(formatJam('14:30:00'), '14.30');
    });

    test('input tidak dikenal dikembalikan apa adanya', () {
      expect(formatJam('14.30'), '14.30');
    });
  });
}
