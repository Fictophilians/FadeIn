import 'dart:async';
import 'dart:convert';

import 'package:fadein_app/constants/theme.dart';
import 'package:fadein_app/pages/AdminBarberPage.dart';
import 'package:fadein_app/pages/AdminBookingPage.dart';
import 'package:fadein_app/pages/AdminHomePage.dart';
import 'package:fadein_app/pages/AdminServicePage.dart';
import 'package:fadein_app/pages/BookingPage.dart';
import 'package:fadein_app/pages/HomePage.dart';
import 'package:fadein_app/pages/MyBookingPage.dart';
import 'package:fadein_app/pages/ProfilePage.dart';
import 'package:fadein_app/service/api.dart';
import 'package:fadein_app/utils/format.dart';
import 'package:fadein_app/widgets/BarberCard.dart';
import 'package:fadein_app/widgets/BookingCard.dart';
import 'package:fadein_app/widgets/FadeInButton.dart';
import 'package:fadein_app/widgets/ServiceCard.dart';
import 'package:fadein_app/widgets/SlotChip.dart';
import 'package:fadein_app/widgets/StatCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Layar uji 360x640 — HP kecil. Semua layar baru wajib muat di sini.
void _layarHp(WidgetTester tester) {
  tester.view.physicalSize = const Size(360, 640);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

Widget _app(Widget home) {
  return MaterialApp(
    theme: AppTheme.light,
    home: home,
    routes: {
      '/login': (_) => const Scaffold(body: Text('HALAMAN LOGIN')),
      '/home': (_) => const Scaffold(body: Text('HALAMAN HOME')),
      '/booking': (_) => const Scaffold(body: Text('HALAMAN BOOKING')),
    },
  );
}

http.Response _json(Object body, [int status = 200]) => http.Response(
      jsonEncode(body),
      status,
      headers: {'content-type': 'application/json'},
    );

const _layanan = [
  {'id': 1, 'name': 'Haircut', 'price': 35000, 'duration': 30},
  {'id': 2, 'name': 'Haircut + Wash + Styling', 'price': 70000, 'duration': 60},
];

const _barber = [
  {
    'id': 1,
    'name': 'Amba',
    'description': 'Spesialis fade dan pompadour, pengalaman 5 tahun.',
    'photo': '',
  },
];

const _booking = {
  'id': 7,
  'user_id': 2,
  'barber_id': 1,
  'service_id': 2,
  'booking_date': '2026-12-01',
  'booking_time': '14:00',
  'status': 'pending',
  'customer_name': 'Budi Santoso',
  'barber_name': 'Amba',
  'service_name': 'Haircut + Wash',
  'price': 50000,
  'duration': 45,
};

/// Backend palsu untuk semua endpoint yang dipakai layar baru.
///
/// [statusBooking] selain 200 membuat POST `/bookings` ditolak — dipakai
/// menguji penanganan 409 (slot direbut orang lain).
http.Client _client({List<dynamic> bookings = const [], int statusBooking = 200}) {
  return MockClient((request) async {
    final path = request.url.path;

    if (path.endsWith('/services')) {
      return _json({'message': 'ok', 'data': _layanan});
    }
    if (path.endsWith('/barbers')) {
      return _json({'message': 'ok', 'data': _barber});
    }
    if (path.contains('/bookings/slots')) {
      return _json({
        'message': 'ok',
        'data': {
          'barber_id': 1,
          'date': '2026-12-01',
          'slots': [
            {'time': '09:00', 'available': true},
            {'time': '10:00', 'available': false},
          ],
        },
      });
    }
    if (path.endsWith('/users/profile')) {
      return _json({
        'message': 'ok',
        'data': {
          'id': 2,
          'name': 'Budi Santoso',
          'email': 'budi@gmail.com',
          'role': 'customer',
        },
      });
    }
    if (path.endsWith('/bookings')) {
      if (request.method == 'POST' && statusBooking != 200) {
        return _json(
          {'message': 'Jadwal tersebut sudah dipesan!'},
          statusBooking,
        );
      }
      return _json({'message': 'ok', 'data': bookings});
    }

    return _json({'message': 'ok', 'data': <dynamic>[]});
  });
}

void main() {
  setUpAll(() async {
    // formatTanggal/formatHari memakai locale id_ID
    await initializeDateFormatting('id_ID');
  });

  setUp(() {
    Apiservice.tanpaSecureStorage = true;
    Apiservice.setTokenCache('token-uji');
    Apiservice.setUserCache({'id': 2, 'name': 'Budi', 'role': 'customer'});
    Apiservice.client = _client(bookings: [_booking]);
  });

  tearDown(() {
    Apiservice.client = http.Client();
    Apiservice.setTokenCache(null);
    Apiservice.setUserCache(null);
    Apiservice.tanpaSecureStorage = false;
  });

  group('BookingPage', () {
    testWidgets('muat di 360x640 tanpa overflow', (tester) async {
      _layarHp(tester);

      await tester.pumpWidget(_app(const BookingPage()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('LANGKAH 1/5'), findsOneWidget);
      expect(find.byType(ServiceCard), findsNWidgets(2));
    });

    testWidgets('Lanjut mati sampai layanan dipilih', (tester) async {
      _layarHp(tester);

      await tester.pumpWidget(_app(const BookingPage()));
      await tester.pumpAndSettle();

      // tombol Lanjut ada tapi belum bisa ditekan → masih di langkah 1
      await tester.tap(find.text('Lanjut'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.text('LANGKAH 1/5'), findsOneWidget);

      await tester.tap(find.text('Haircut'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();

      expect(find.text('LANGKAH 2/5'), findsOneWidget);
      expect(find.byType(BarberCard), findsOneWidget);
    });

    testWidgets('pilihan bertahan saat mundur', (tester) async {
      _layarHp(tester);

      await tester.pumpWidget(_app(const BookingPage()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Haircut'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();

      // mundur ke langkah 1
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('LANGKAH 1/5'), findsOneWidget);
      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();

      // masih lolos ke langkah 2 → pilihan tidak hilang
      expect(find.text('LANGKAH 2/5'), findsOneWidget);
    });

    testWidgets('slot terisi tampil nonaktif', (tester) async {
      _layarHp(tester);

      await tester.pumpWidget(_app(const BookingPage()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Haircut'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pilih'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();

      // langkah 3: tanggal
      expect(find.text('LANGKAH 3/5'), findsOneWidget);
      expect(find.text('Hari ini'), findsOneWidget);

      // pilih hari ini → langkah 4 memuat slot
      await tester.tap(find.text('Hari ini'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();

      expect(find.text('LANGKAH 4/5'), findsOneWidget);

      final chip = tester.widgetList<SlotChip>(find.byType(SlotChip)).toList();
      expect(chip.length, 2);
      // 10:00 sudah dibooking → nonaktif, apa pun jam test dijalankan
      expect(chip[1].time, '10:00');
      expect(chip[1].available, isFalse);
      // 09:00 tersedia di server; bisa ikut nonaktif kalau hari ini sudah lewat
      expect(chip[0].time, '09:00');
    });

    test('slot hari ini yang jamnya sudah lewat ditolak', () {
      const tersedia = true;

      // jam sekarang 14:30 → 15:00 masih boleh, 14:00 dan 14:30 tidak
      expect(
        BookingPage.slotBolehDipakai(
          tersedia: tersedia,
          tanggal: '2026-12-01',
          hariIni: '2026-12-01',
          jam: '15:00',
          jamSekarang: '14:30',
        ),
        isTrue,
      );
      expect(
        BookingPage.slotBolehDipakai(
          tersedia: tersedia,
          tanggal: '2026-12-01',
          hariIni: '2026-12-01',
          jam: '14:00',
          jamSekarang: '14:30',
        ),
        isFalse,
      );
      expect(
        BookingPage.slotBolehDipakai(
          tersedia: tersedia,
          tanggal: '2026-12-01',
          hariIni: '2026-12-01',
          jam: '14:30',
          jamSekarang: '14:30',
        ),
        isFalse,
      );

      // tanggal lain: jam berapa pun boleh
      expect(
        BookingPage.slotBolehDipakai(
          tersedia: tersedia,
          tanggal: '2026-12-02',
          hariIni: '2026-12-01',
          jam: '09:00',
          jamSekarang: '23:00',
        ),
        isTrue,
      );

      // slot terisi atau tanggal belum dipilih: selalu ditolak
      expect(
        BookingPage.slotBolehDipakai(
          tersedia: false,
          tanggal: '2026-12-02',
          hariIni: '2026-12-01',
          jam: '09:00',
          jamSekarang: '08:00',
        ),
        isFalse,
      );
      expect(
        BookingPage.slotBolehDipakai(
          tersedia: tersedia,
          tanggal: null,
          hariIni: '2026-12-01',
          jam: '09:00',
          jamSekarang: '08:00',
        ),
        isFalse,
      );
    });

    testWidgets('409 mengembalikan ke langkah jam', (tester) async {
      _layarHp(tester);
      Apiservice.client = _client(statusBooking: 409);

      await tester.pumpWidget(_app(const BookingPage()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Haircut'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pilih'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();

      // pilih besok supaya jam 09:00 pasti belum lewat
      final kartuTanggal = find.byWidgetPredicate(
        (w) => w.runtimeType.toString() == '_KartuTanggal',
      );
      await tester.tap(kartuTanggal.at(1));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('09:00'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();
      expect(find.text('LANGKAH 5/5'), findsOneWidget);

      await tester.tap(find.text('Konfirmasi Booking'));
      await tester.pumpAndSettle();

      // kembali ke langkah jam, bukan menutup form
      expect(find.text('LANGKAH 4/5'), findsOneWidget);
      expect(
        find.text('Jadwal tersebut sudah dipesan, silakan pilih jam lain!'),
        findsOneWidget,
      );
    });

    testWidgets('back sistem mundur satu langkah, bukan menutup form', (
      tester,
    ) async {
      _layarHp(tester);

      await tester.pumpWidget(_app(const BookingPage()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Haircut'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();
      expect(find.text('LANGKAH 2/5'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.byType(BookingPage), findsOneWidget);
      expect(find.text('LANGKAH 1/5'), findsOneWidget);
    });
  });

  group('HomePage', () {
    testWidgets('jadwal hari ini yang sudah lewat tidak ditampilkan', (
      tester,
    ) async {
      _layarHp(tester);

      Apiservice.client = _client(
        bookings: [
          {
            ..._booking,
            'booking_date': tanggalHariIniWib(),
            'booking_time': '00:00',
          },
        ],
      );

      await tester.pumpWidget(_app(const HomePage()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('JADWAL BERIKUTNYA'), findsNothing);
    });
  });

  group('MyBookingPage', () {
    testWidgets('menampilkan kartu booking', (tester) async {
      _layarHp(tester);

      await tester.pumpWidget(_app(const MyBookingPage()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('PESANAN'), findsOneWidget);
      expect(find.byType(BookingCard), findsOneWidget);
      expect(find.text('Batalkan'), findsOneWidget);
    });

    testWidgets('filter status menyaring daftar', (tester) async {
      _layarHp(tester);

      await tester.pumpWidget(_app(const MyBookingPage()));
      await tester.pumpAndSettle();

      // chip filter ada di ListView horizontal; geser dulu ke kiri
      await tester.drag(find.text('Semua'), const Offset(-260, 0));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Selesai'));
      await tester.pumpAndSettle();

      expect(find.byType(BookingCard), findsNothing);
      expect(find.text('Tidak ada di filter ini'), findsOneWidget);
    });

    testWidgets('daftar kosong punya ajakan booking', (tester) async {
      _layarHp(tester);
      Apiservice.client = _client();

      await tester.pumpWidget(_app(const MyBookingPage()));
      await tester.pumpAndSettle();

      expect(find.text('Belum ada pesanan'), findsOneWidget);
      expect(find.text('Booking sekarang'), findsOneWidget);
    });

    testWidgets('muat ulang tidak mengosongkan daftar', (tester) async {
      _layarHp(tester);

      var panggilan = 0;
      final tunda = Completer<void>();
      Apiservice.client = MockClient((request) async {
        panggilan++;
        if (panggilan > 1) await tunda.future;
        return _json({'message': 'ok', 'data': [_booking]});
      });

      await tester.pumpWidget(_app(const MyBookingPage()));
      await tester.pumpAndSettle();
      expect(find.byType(BookingCard), findsOneWidget);

      final state = tester.state<MyBookingPageState>(
        find.byType(MyBookingPage),
      );
      state.muatData();
      await tester.pump();

      // daftar lama tetap tampil selama request berjalan
      expect(find.byType(BookingCard), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      tunda.complete();
      await tester.pump();
      await tester.pump();

      expect(find.byType(BookingCard), findsOneWidget);
    });
  });

  group('ProfilePage', () {
    testWidgets('muat di 360x640 tanpa overflow', (tester) async {
      _layarHp(tester);

      await tester.pumpWidget(_app(const ProfilePage()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Budi Santoso'), findsWidgets);
      expect(find.text('budi@gmail.com'), findsWidgets);
      expect(find.text('Ganti foto'), findsOneWidget);
      expect(find.text('Keluar'), findsOneWidget);
    });
  });

  group('AdminBarberPage', () {
    testWidgets('muat di 360x640 tanpa overflow', (tester) async {
      _layarHp(tester);

      await tester.pumpWidget(_app(const AdminBarberPage()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('BARBER'), findsOneWidget);
      expect(find.text('Amba'), findsOneWidget);
      expect(find.text('Tambah'), findsOneWidget);
    });

    testWidgets('form tambah tidak tertutup navigation bar', (tester) async {
      _layarHp(tester);
      tester.view.padding = const FakeViewPadding(bottom: 48);
      addTearDown(tester.view.resetPadding);

      await tester.pumpWidget(_app(const AdminBarberPage()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Tambah'));
      await tester.pumpAndSettle();

      expect(find.text('Barber baru'), findsOneWidget);

      // tombol simpan harus berhenti di atas area navigation bar (48)
      final tombol = tester.getBottomLeft(
        find.widgetWithText(FadeInButton, 'Tambah barber'),
      );
      expect(tombol.dy, lessThanOrEqualTo(640 - 48));
      expect(tester.takeException(), isNull);
    });
  });

  group('AdminServicePage', () {
    testWidgets('muat di 360x640 tanpa overflow', (tester) async {
      _layarHp(tester);

      await tester.pumpWidget(_app(const AdminServicePage()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('LAYANAN'), findsOneWidget);
      expect(find.text('Rp35.000'), findsOneWidget);
      expect(find.text('01'), findsOneWidget);
    });

    testWidgets('form tambah tidak tertutup navigation bar', (tester) async {
      _layarHp(tester);
      tester.view.padding = const FakeViewPadding(bottom: 48);
      addTearDown(tester.view.resetPadding);

      await tester.pumpWidget(_app(const AdminServicePage()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Tambah'));
      await tester.pumpAndSettle();

      expect(find.text('Layanan baru'), findsOneWidget);

      // tombol simpan harus berhenti di atas area navigation bar (48)
      final tombol = tester.getBottomLeft(
        find.widgetWithText(FadeInButton, 'Tambah layanan'),
      );
      expect(tombol.dy, lessThanOrEqualTo(640 - 48));
      expect(tester.takeException(), isNull);
    });
  });

  group('AdminBookingPage', () {
    testWidgets('muat di 360x640 tanpa overflow', (tester) async {
      _layarHp(tester);

      await tester.pumpWidget(_app(const AdminBookingPage()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('BOOKING'), findsOneWidget);
      expect(find.text('Budi Santoso'), findsOneWidget);
      // pending → tombol Konfirmasi + Batalkan
      expect(find.text('Konfirmasi'), findsOneWidget);
      expect(find.text('Batalkan'), findsOneWidget);
    });

    testWidgets('Selesai minta konfirmasi dan bisa dibatalkan', (tester) async {
      _layarHp(tester);
      Apiservice.client = _client(
        bookings: [
          {..._booking, 'status': 'confirmed'},
        ],
      );

      await tester.pumpWidget(_app(const AdminBookingPage()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Selesai'));
      await tester.pumpAndSettle();

      expect(find.text('Selesaikan booking?'), findsOneWidget);
      expect(find.text('Ya, selesaikan'), findsOneWidget);

      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();

      expect(find.text('Selesaikan booking?'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('SlotChip', () {
    testWidgets('tersedia vs terisi', (tester) async {
      _layarHp(tester);

      await tester.pumpWidget(
        _app(
          const Scaffold(
            body: Row(
              children: [
                SlotChip(time: '09:00', available: true),
                SlotChip(time: '10:00', available: false),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('09:00'), findsOneWidget);
      expect(find.text('10:00'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('AdminHomePage', () {
    /// Booking bertanggal hari ini (WIB) supaya masuk hitungan bulan berjalan
    /// tanpa bergantung pada tanggal saat tes dijalankan.
    Map<String, dynamic> booking({
      required String layanan,
      required num harga,
      required String status,
      required String tanggal,
      int id = 1,
    }) {
      return {
        'id': id,
        'user_id': 2,
        'barber_id': 1,
        'service_id': 1,
        'booking_date': tanggal,
        'booking_time': '10:00',
        'status': status,
        'customer_name': 'Budi',
        'barber_name': 'Amba',
        'service_name': layanan,
        'price': harga,
        'duration': 45,
      };
    }

    testWidgets('menampilkan angka ringkasan dari data bulan ini', (
      tester,
    ) async {
      _layarHp(tester);

      final hariIni = tanggalHariIniWib();
      Apiservice.client = MockClient((request) async {
        final path = request.url.path;
        if (path.endsWith('/barbers')) {
          return _json({
            'message': 'ok',
            'data': [
              {'id': 1, 'name': 'Amba', 'description': 'Fade', 'photo': null},
            ],
          });
        }
        if (path.endsWith('/bookings')) {
          return _json({
            'message': 'ok',
            'data': [
              booking(
                id: 1,
                layanan: 'Haircut',
                harga: 50000,
                status: 'completed',
                tanggal: hariIni,
              ),
              booking(
                id: 2,
                layanan: 'Haircut',
                harga: 70000,
                status: 'completed',
                tanggal: hariIni,
              ),
              booking(
                id: 3,
                layanan: 'Cukur Jenggot',
                harga: 30000,
                status: 'pending',
                tanggal: hariIni,
              ),
            ],
          });
        }
        return _json({'message': 'ok', 'data': <dynamic>[]});
      });

      await tester.pumpWidget(_app(const AdminHomePage()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('DASHBOARD'), findsOneWidget);
      expect(find.byType(StatCard), findsNWidgets(4));

      // pendapatan dan rata-rata sama karena hanya satu hari aktif
      expect(find.text('Rp120.000'), findsNWidgets(2));
      // 3 booking dari 12 slot (1 barber x 12 jam)
      expect(find.text('25%'), findsOneWidget);
      // modus layanan 2 dari 3 booking
      expect(find.text('Haircut'), findsOneWidget);
      expect(find.text('67%'), findsOneWidget);
    });

    testWidgets('bulan lalu kosong menampilkan selisih nominal, bukan error', (
      tester,
    ) async {
      _layarHp(tester);

      final hariIni = tanggalHariIniWib();
      Apiservice.client = MockClient((request) async {
        final path = request.url.path;
        if (path.endsWith('/barbers')) {
          return _json({'message': 'ok', 'data': <dynamic>[]});
        }
        if (path.endsWith('/bookings')) {
          return _json({
            'message': 'ok',
            'data': [
              booking(
                layanan: 'Haircut',
                harga: 50000,
                status: 'completed',
                tanggal: hariIni,
              ),
            ],
          });
        }
        return _json({'message': 'ok', 'data': <dynamic>[]});
      });

      await tester.pumpWidget(_app(const AdminHomePage()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      // persentase tidak dihitung (pembagi nol), tapi selisihnya tampil
      expect(find.text('+Rp50.000'), findsOneWidget);
      expect(find.text('bulan lalu belum ada transaksi'), findsOneWidget);
    });

    testWidgets('dua bulan kosong tetap menampilkan tanda pisah', (
      tester,
    ) async {
      _layarHp(tester);

      Apiservice.client = MockClient((request) async {
        return _json({'message': 'ok', 'data': <dynamic>[]});
      });

      await tester.pumpWidget(_app(const AdminHomePage()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('—'), findsOneWidget);
      expect(
        find.text('belum ada transaksi bulan ini & bulan lalu'),
        findsOneWidget,
      );
    });

    testWidgets('kegagalan jaringan menampilkan tombol coba lagi', (
      tester,
    ) async {
      _layarHp(tester);

      Apiservice.client = MockClient((request) async {
        return _json({'message': 'Server mati'}, 500);
      });

      await tester.pumpWidget(_app(const AdminHomePage()));
      await tester.pumpAndSettle();

      expect(find.text('Gagal memuat ringkasan'), findsOneWidget);
      expect(find.text('Coba lagi'), findsOneWidget);
    });
  });
}
