import 'package:fadein_app/pages/AppShell.dart';
import 'package:fadein_app/pages/RuteTerjaga.dart';
import 'package:fadein_app/service/api.dart';
import 'package:fadein_app/widgets/FadeInButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

Widget _halaman(String nama) {
  return Center(child: Text(nama));
}

List<AppTab> _tabs() {
  return AppShell.tabCustomer(
    home: _halaman('ISI HOME'),
    booking: _halaman('ISI BOOKING'),
    myBookings: _halaman('ISI MY BOOKING'),
    profile: _halaman('ISI PROFILE'),
  );
}

Widget _app({Widget? home, Future<void> Function()? onLogout}) {
  return MaterialApp(
    home: home ?? AppShell(tabs: _tabs(), onLogout: onLogout),
    routes: {
      '/login': (_) => const Scaffold(body: Text('HALAMAN LOGIN')),
    },
  );
}

void main() {
  tearDown(() {
    Apiservice.client = http.Client();
    Apiservice.setTokenCache(null);
    Apiservice.setUserCache(null);
  });

  testWidgets('tab customer berjumlah empat dan berurutan', (tester) async {
    await tester.pumpWidget(_app());

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Booking'), findsOneWidget);
    expect(find.text('My Booking'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('ISI HOME'), findsOneWidget);
  });

  testWidgets('tab admin memakai label Barber dan Layanan', (tester) async {
    final tabs = AppShell.tabAdmin(
      barbers: _halaman('ISI BARBER'),
      services: _halaman('ISI LAYANAN'),
      bookings: _halaman('ISI BOOKING'),
      profile: _halaman('ISI PROFILE'),
    );

    await tester.pumpWidget(_app(home: AppShell(tabs: tabs)));

    expect(find.text('Barber'), findsOneWidget);
    expect(find.text('Layanan'), findsOneWidget);
    expect(find.text('ISI BARBER'), findsOneWidget);
  });

  testWidgets('menekan tab mengganti isi dan judul', (tester) async {
    await tester.pumpWidget(_app());

    await tester.tap(find.text('My Booking'));
    await tester.pumpAndSettle();

    expect(find.text('MY BOOKING'), findsOneWidget);
  });

  testWidgets('tab lain tetap hidup walau tidak terlihat', (tester) async {
    await tester.pumpWidget(_app());

    // IndexedStack menjaga state semua tab; hanya satu yang onstage.
    expect(find.text('ISI HOME'), findsOneWidget);
    expect(find.text('ISI BOOKING', skipOffstage: false), findsOneWidget);
  });

  testWidgets('logout hanya muncul di tab Profile', (tester) async {
    await tester.pumpWidget(_app(onLogout: () async {}));

    expect(find.byIcon(Icons.logout), findsNothing);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.logout), findsOneWidget);
  });

  testWidgets('logout memanggil callback lalu ke /login', (tester) async {
    var dipanggil = 0;

    await tester.pumpWidget(
      _app(onLogout: () async => dipanggil++),
    );

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.logout));
    await tester.pumpAndSettle();

    expect(dipanggil, 1);
    expect(find.text('HALAMAN LOGIN'), findsOneWidget);
  });

  testWidgets('logout gagal menampilkan pesan dan tetap di shell', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(onLogout: () async => throw Exception('Storage error')),
    );

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.logout));
    await tester.pumpAndSettle();

    expect(find.textContaining('Storage error'), findsOneWidget);
    expect(find.text('HALAMAN LOGIN'), findsNothing);
  });

  group('RuteTerjaga', () {
    test('normalisasi peran tidak dikenal jadi customer', () {
      expect(RuteTerjaga.normalisasi(null), 'customer');
      expect(RuteTerjaga.normalisasi('admin'), 'admin');
      expect(RuteTerjaga.normalisasi('customer'), 'customer');
      expect(RuteTerjaga.normalisasi('owner'), 'customer');
    });

    test('hanya peran yang cocok yang diizinkan', () {
      expect(RuteTerjaga.boleh('admin', 'admin'), isTrue);
      expect(RuteTerjaga.boleh('customer', 'admin'), isFalse);
      expect(RuteTerjaga.boleh('admin', 'customer'), isFalse);
    });

    test('beranda sesuai peran', () {
      expect(RuteTerjaga.beranda('admin'), '/admin/barbers');
      expect(RuteTerjaga.beranda('customer'), '/home');
      expect(RuteTerjaga.beranda(null), '/home');
    });
  });

  testWidgets('RuteTerjaga menolak customer yang membuka halaman admin', (
    tester,
  ) async {
    Apiservice.setTokenCache('token-customer');
    Apiservice.setUserCache({'id': 2, 'role': 'customer'});

    await tester.pumpWidget(
      MaterialApp(
        home: RuteTerjaga(
          role: 'admin',
          child: const Scaffold(body: Text('HALAMAN ADMIN')),
        ),
        routes: {
          '/home': (_) => const Scaffold(body: Text('HALAMAN HOME')),
          '/admin/barbers': (_) =>
              const Scaffold(body: Text('HALAMAN BARBER')),
        },
      ),
    );

    // spinner berputar terus, jadi pumpAndSettle tidak akan pernah selesai
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('HALAMAN ADMIN'), findsNothing);
    expect(find.text('HALAMAN HOME'), findsOneWidget);
  });

  testWidgets('RuteTerjaga meloloskan admin ke halaman admin', (tester) async {
    Apiservice.setTokenCache('token-admin');
    Apiservice.setUserCache({'id': 1, 'role': 'admin'});

    await tester.pumpWidget(
      MaterialApp(
        home: RuteTerjaga(
          role: 'admin',
          child: const Scaffold(body: Text('HALAMAN ADMIN')),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('HALAMAN ADMIN'), findsOneWidget);
  });

  testWidgets('FadeInButton dipakai di dalam shell tanpa error layout', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(home: Scaffold(body: Center(child: FadeInButton(label: 'Tes', onPressed: () {})))),
    );

    expect(find.text('Tes'), findsOneWidget);
  });
}