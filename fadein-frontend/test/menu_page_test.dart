import 'package:fadein_app/pages/MenuPage.dart';
import 'package:fadein_app/pages/RuteTerjaga.dart';
import 'package:fadein_app/service/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  tearDown(() {
    Apiservice.client = http.Client();
    Apiservice.setTokenCache(null);
    Apiservice.setUserCache(null);
  });

  group('MenuPage', () {
    testWidgets('menampilkan tiga tab berurutan', (tester) async {
      Apiservice.setTokenCache('token');
      Apiservice.setUserCache({'id': 2, 'role': 'customer'});

      await tester.pumpWidget(const MaterialApp(home: MenuPage()));
      await tester.pump();

      expect(find.text('Beranda'), findsOneWidget);
      expect(find.text('Pesanan'), findsOneWidget);
      expect(find.text('Profil'), findsOneWidget);
    });

    testWidgets('menekan tab mengganti isi', (tester) async {
      Apiservice.setTokenCache('token');
      Apiservice.setUserCache({'id': 2, 'role': 'customer'});

      await tester.pumpWidget(const MaterialApp(home: MenuPage()));
      await tester.pump();

      await tester.tap(find.text('Pesanan'));
      await tester.pumpAndSettle();

      expect(find.text('Belum ada pesanan'), findsOneWidget);
    });

    testWidgets('tab lain tetap hidup walau tidak terlihat', (tester) async {
      Apiservice.setTokenCache('token');
      Apiservice.setUserCache({'id': 2, 'role': 'customer'});

      await tester.pumpWidget(const MaterialApp(home: MenuPage()));
      await tester.pump();

      // IndexedStack menjaga state semua tab; hanya satu yang onstage.
      expect(find.text('Belum ada pesanan', skipOffstage: false), findsOneWidget);
      expect(find.text('Profil', skipOffstage: false), findsWidgets);
    });
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
}
