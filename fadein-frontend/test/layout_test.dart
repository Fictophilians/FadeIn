import 'dart:convert';

import 'package:fadein_app/constants/theme.dart';
import 'package:fadein_app/pages/HomePage.dart';
import 'package:fadein_app/pages/LoginPage.dart';
import 'package:fadein_app/pages/RegisterPage.dart';
import 'package:fadein_app/service/api.dart';
import 'package:fadein_app/widgets/BarberCard.dart';
import 'package:fadein_app/widgets/ServiceCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Layar uji 360x640 seperti HP kecil. Lebih sempit dari default 800x600
/// supaya `RenderFlex overflow` ketahuan lebih awal.
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
      '/register': (_) => const Scaffold(body: Text('HALAMAN REGISTER')),
      '/booking': (_) => const Scaffold(body: Text('HALAMAN BOOKING')),
      '/my-bookings': (_) => const Scaffold(body: Text('HALAMAN PESANAN')),
    },
  );
}

http.Response _json(Object body) =>
    http.Response(jsonEncode(body), 200, headers: {'content-type': 'application/json'});

void main() {
  setUp(() {
    Apiservice.tanpaSecureStorage = true;
    Apiservice.setTokenCache('token-uji');
    Apiservice.setUserCache({'id': 2, 'name': 'Budi Santoso', 'role': 'customer'});
  });

  tearDown(() {
    Apiservice.client = http.Client();
    Apiservice.setTokenCache(null);
    Apiservice.setUserCache(null);
    Apiservice.tanpaSecureStorage = false;
  });

  testWidgets('LoginPage muat di layar 360x640 tanpa overflow', (tester) async {
    _layarHp(tester);
    await tester.pumpWidget(_app(const LoginPage()));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Selamat datang kembali'), findsOneWidget);
  });

  testWidgets('LoginPage tidak lagi punya tombol sosial', (tester) async {
    await tester.pumpWidget(_app(const LoginPage()));
    await tester.pump();

    expect(find.text('Google'), findsNothing);
    expect(find.text('Apple'), findsNothing);
    expect(find.text('Masuk'), findsOneWidget);
  });

  testWidgets('RegisterPage muat di layar 360x640 tanpa overflow', (
    tester,
  ) async {
    _layarHp(tester);
    await tester.pumpWidget(_app(const RegisterPage()));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Nama lengkap'), findsOneWidget);
  });

  testWidgets('HomePage memuat layanan sebagai grid dan barber sebagai rail', (
    tester,
  ) async {
    _layarHp(tester);

    Apiservice.client = MockClient((request) async {
      final path = request.url.path;
      if (path.endsWith('/services')) {
        return _json({
          'message': 'OK',
          'data': [
            {'id': 1, 'name': 'Haircut', 'price': 50000, 'duration': 45},
            {'id': 2, 'name': 'Haircut + Wash', 'price': 70000, 'duration': 60},
            {'id': 3, 'name': 'Cukur Jenggot', 'price': 30000, 'duration': 20},
          ],
        });
      }
      if (path.endsWith('/barbers')) {
        return _json({
          'message': 'OK',
          'data': [
            {'id': 1, 'name': 'Andi', 'description': 'Spesialis fade', 'photo': null},
          ],
        });
      }
      // /bookings kosong: kartu jadwal tidak muncul, beranda tetap jalan
      return _json({'message': 'OK', 'data': <dynamic>[]});
    });

    await tester.pumpWidget(_app(const HomePage()));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);

    expect(find.text('MAU POTONG\nRAMBUT APA HARI INI?'), findsOneWidget);
    expect(find.text('LAYANAN'), findsOneWidget);
    expect(find.text('01'), findsOneWidget);
    expect(find.byType(ServiceCard), findsNWidgets(3));

    // rail barber ada di bawah lipatan; gulir dulu
    await tester.drag(find.byType(ListView).first, const Offset(0, -600));
    await tester.pumpAndSettle();

    expect(find.text('BARBER'), findsOneWidget);
    expect(find.byType(BarberCard), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('HomePage tetap tampil walau /bookings gagal', (tester) async {
    _layarHp(tester);

    Apiservice.client = MockClient((request) async {
      final path = request.url.path;
      if (path.endsWith('/services')) {
        return _json({
          'message': 'OK',
          'data': [
            {'id': 1, 'name': 'Haircut', 'price': 50000, 'duration': 45},
          ],
        });
      }
      if (path.endsWith('/barbers')) {
        return _json({'message': 'OK', 'data': <dynamic>[]});
      }
      return http.Response(jsonEncode({'message': 'Server error'}), 500);
    });

    await tester.pumpWidget(_app(const HomePage()));
    await tester.pumpAndSettle();

    // booking gagal tidak boleh menjatuhkan seluruh beranda
    expect(find.text('Gagal memuat data'), findsNothing);
    expect(find.byType(ServiceCard), findsOneWidget);
  });
}
