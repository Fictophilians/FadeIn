import 'dart:convert';

import 'package:fadein_app/pages/MenuPage.dart';
import 'package:fadein_app/pages/RuteTerjaga.dart';
import 'package:fadein_app/service/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Backend palsu: semua daftar kosong, profil berisi satu user.
///
/// Tanpa ini `MyBookingPage` dan `ProfilePage` akan menembak jaringan
/// sungguhan dan test tidak pernah selesai.
http.Client _clientKosong() {
  return MockClient((request) async {
    final path = request.url.path;

    if (path.endsWith('/users/profile')) {
      return http.Response(
        jsonEncode({
          'message': 'ok',
          'data': {
            'id': 2,
            'name': 'Budi',
            'email': 'budi@gmail.com',
            'role': 'customer',
          },
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    }

    return http.Response(
      jsonEncode({'message': 'ok', 'data': <dynamic>[]}),
      200,
      headers: {'content-type': 'application/json'},
    );
  });
}

void main() {
  setUp(() {
    Apiservice.tanpaSecureStorage = true;
    Apiservice.client = _clientKosong();
  });

  tearDown(() {
    Apiservice.client = http.Client();
    Apiservice.tanpaSecureStorage = false;
    Apiservice.setTokenCache(null);
    Apiservice.setUserCache(null);
  });

  group('MenuPage customer', () {
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
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // AppBar tab Pesanan, sekaligus membuktikan tab benar-benar berganti
      expect(find.text('PESANAN'), findsOneWidget);
    });

    testWidgets('tab lain tetap hidup walau tidak terlihat', (tester) async {
      Apiservice.setTokenCache('token');
      Apiservice.setUserCache({'id': 2, 'role': 'customer'});

      await tester.pumpWidget(const MaterialApp(home: MenuPage()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // IndexedStack menjaga state semua tab; hanya satu yang onstage.
      expect(
        find.text('Belum ada pesanan', skipOffstage: false),
        findsOneWidget,
      );
      expect(find.text('Profil', skipOffstage: false), findsWidgets);
    });
  });

  group('MenuPage admin', () {
    testWidgets('menampilkan empat tab admin', (tester) async {
      Apiservice.setTokenCache('token');
      Apiservice.setUserCache({'id': 1, 'role': 'admin'});

      await tester.pumpWidget(
        const MaterialApp(home: MenuPage(role: 'admin')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Barber'), findsOneWidget);
      expect(find.text('Layanan'), findsOneWidget);
      expect(find.text('Booking'), findsOneWidget);
      expect(find.text('Profil'), findsOneWidget);
      expect(find.text('Beranda'), findsNothing);
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
      expect(RuteTerjaga.beranda('admin'), '/admin');
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
          '/admin': (_) => const Scaffold(body: Text('HALAMAN ADMIN ASLI')),
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
