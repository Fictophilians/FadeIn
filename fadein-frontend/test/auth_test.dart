import 'dart:convert';

import 'package:fadein_app/pages/LoginPage.dart';
import 'package:fadein_app/pages/RegisterPage.dart';
import 'package:fadein_app/service/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

Widget _app(Widget home) {
  return MaterialApp(
    home: home,
    routes: {
      '/register': (_) => const Scaffold(body: Text('HALAMAN REGISTER')),
      '/login': (_) => const Scaffold(body: Text('HALAMAN LOGIN')),
      '/home': (_) => const Scaffold(body: Text('HALAMAN HOME')),
      '/admin/barbers': (_) => const Scaffold(body: Text('HALAMAN ADMIN')),
    },
  );
}

/// Pump berulang sampai [finder] muncul.
///
/// `pumpAndSettle` tidak bisa dipakai di sini: tombol loading memasang
/// `CircularProgressIndicator` yang animasinya tidak pernah selesai.
Future<void> pumpHingga(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 100; i++) {
    await tester.pump(const Duration(milliseconds: 20));
    if (finder.evaluate().isNotEmpty) return;
  }
  fail('Widget tidak muncul setelah 2 detik: $finder');
}

/// Gulir ke tombol [label] dulu lalu tekan.
///
/// Isi sheet Register lebih tinggi dari layar uji 600px, jadi tombol aksi
/// bisa berada di luar area tampil.
Future<void> tekan(WidgetTester tester, String label) async {
  await tester.ensureVisible(find.text(label));
  await tester.pumpAndSettle();
  await tester.tap(find.text(label));
}

void main() {
  // Widget test tidak punya secure storage; cache memori dipakai sendirian.
  setUp(() => Apiservice.tanpaSecureStorage = true);

  tearDown(() {
    Apiservice.client = http.Client();
    Apiservice.setTokenCache(null);
    Apiservice.setUserCache(null);
    Apiservice.tanpaSecureStorage = false;
  });

  testWidgets('login kosong menampilkan peringatan', (tester) async {
    await tester.pumpWidget(_app(const LoginPage()));

    await tester.tap(find.text('Masuk'));
    await tester.pump();

    expect(find.text('Email dan password wajib diisi!'), findsOneWidget);
  });

  testWidgets('login email tanpa @ ditolak lokal', (tester) async {
    await tester.pumpWidget(_app(const LoginPage()));

    await tester.enterText(find.byType(TextFormField).first, 'budigmail');
    await tester.enterText(find.byType(TextFormField).last, 'rahasia123');
    await tester.tap(find.text('Masuk'));
    await tester.pump();

    expect(find.text('Format email tidak valid!'), findsOneWidget);
  });

  testWidgets('login 401 menampilkan pesan di bawah form', (tester) async {
    Apiservice.client = MockClient((request) async {
      return http.Response(
        jsonEncode({'message': 'Email atau password salah!'}),
        401,
      );
    });

    await tester.pumpWidget(_app(const LoginPage()));

    await tester.enterText(find.byType(TextFormField).first, 'budi@gmail.com');
    await tester.enterText(find.byType(TextFormField).last, 'salah');
    await tester.tap(find.text('Masuk'));
    await pumpHingga(tester, find.text('Email atau password salah'));

    expect(find.text('Email atau password salah'), findsOneWidget);
  });

  testWidgets('login customer sukses menyimpan token lalu ke /home', (
    tester,
  ) async {
    Apiservice.client = MockClient((request) async {
      expect(request.url.path, endsWith('/auth/login'));
      return http.Response(
        jsonEncode({
          'message': 'Login berhasil!',
          'data': {
            'token': 'token-budi',
            'user': {
              'id': 2,
              'name': 'Budi',
              'email': 'budi@gmail.com',
              'role': 'customer',
              'photo': null,
            },
          },
        }),
        200,
      );
    });

    await tester.pumpWidget(_app(const LoginPage()));

    await tester.enterText(find.byType(TextFormField).first, 'budi@gmail.com');
    await tester.enterText(find.byType(TextFormField).last, 'customer123');
    await tester.tap(find.text('Masuk'));
    await pumpHingga(tester, find.text('HALAMAN HOME'));

    expect(find.text('HALAMAN HOME'), findsOneWidget);
    expect(await Apiservice.getToken(), 'token-budi');
    expect((await Apiservice.getUser())?['role'], 'customer');
  });

  testWidgets('login admin sukses ke halaman admin', (tester) async {
    Apiservice.client = MockClient((request) async {
      return http.Response(
        jsonEncode({
          'message': 'Login berhasil!',
          'data': {
            'token': 'token-admin',
            'user': {
              'id': 1,
              'name': 'Admin',
              'email': 'admin@fadein.com',
              'role': 'admin',
              'photo': null,
            },
          },
        }),
        200,
      );
    });

    await tester.pumpWidget(_app(const LoginPage()));

    await tester.enterText(find.byType(TextFormField).first, 'admin@fadein.com');
    await tester.enterText(find.byType(TextFormField).last, 'admin123');
    await tester.tap(find.text('Masuk'));
    await pumpHingga(tester, find.text('HALAMAN ADMIN'));

    expect(find.text('HALAMAN ADMIN'), findsOneWidget);
  });

  testWidgets('tautan Daftar membuka /register', (tester) async {
    await tester.pumpWidget(_app(const LoginPage()));

    // layar uji hanya 600px; tombol Daftar ada di bawah, gulir dulu
    await tekan(tester, 'Daftar');
    await tester.pumpAndSettle();

    expect(find.text('HALAMAN REGISTER'), findsOneWidget);
  });

  testWidgets('register: nama terlalu pendek ditolak', (tester) async {
    await tester.pumpWidget(_app(const RegisterPage()));

    await tester.enterText(find.byType(TextFormField).at(0), 'Bu');
    await tester.enterText(find.byType(TextFormField).at(1), 'baru@gmail.com');
    await tester.enterText(find.byType(TextFormField).at(2), 'rahasia123');
    await tester.enterText(find.byType(TextFormField).at(3), 'rahasia123');
    await tekan(tester, 'Daftar');
    await tester.pump();

    expect(find.text('Nama minimal 3 karakter!'), findsOneWidget);
  });

  testWidgets('register: password tidak cocok ditolak', (tester) async {
    await tester.pumpWidget(_app(const RegisterPage()));

    await tester.enterText(find.byType(TextFormField).at(0), 'Budi Baru');
    await tester.enterText(find.byType(TextFormField).at(1), 'baru@gmail.com');
    await tester.enterText(find.byType(TextFormField).at(2), 'rahasia123');
    await tester.enterText(find.byType(TextFormField).at(3), 'rahasia456');
    await tekan(tester, 'Daftar');
    await tester.pump();

    expect(find.text('Konfirmasi password tidak cocok!'), findsOneWidget);
  });

  testWidgets('register sukses kembali ke /login', (tester) async {
    Apiservice.client = MockClient((request) async {
      expect(jsonDecode(request.body)['role'], isNull);
      return http.Response(
        jsonEncode({
          'message': 'Registrasi berhasil, silakan login!',
          'data': {'id': 5, 'name': 'Budi Baru', 'role': 'customer'},
        }),
        201,
      );
    });

    await tester.pumpWidget(_app(const RegisterPage()));

    await tester.enterText(find.byType(TextFormField).at(0), 'Budi Baru');
    await tester.enterText(find.byType(TextFormField).at(1), 'baru@gmail.com');
    await tester.enterText(find.byType(TextFormField).at(2), 'rahasia123');
    await tester.enterText(find.byType(TextFormField).at(3), 'rahasia123');
    await tekan(tester, 'Daftar');
    await pumpHingga(tester, find.text('HALAMAN LOGIN'));

    expect(find.text('HALAMAN LOGIN'), findsOneWidget);
  });

  testWidgets('register email duplikat menampilkan pesan server', (
    tester,
  ) async {
    Apiservice.client = MockClient((request) async {
      return http.Response(
        jsonEncode({'message': 'Email sudah terdaftar!'}),
        409,
      );
    });

    await tester.pumpWidget(_app(const RegisterPage()));

    await tester.enterText(find.byType(TextFormField).at(0), 'Budi Baru');
    await tester.enterText(find.byType(TextFormField).at(1), 'budi@gmail.com');
    await tester.enterText(find.byType(TextFormField).at(2), 'rahasia123');
    await tester.enterText(find.byType(TextFormField).at(3), 'rahasia123');
    await tekan(tester, 'Daftar');
    await pumpHingga(tester, find.text('Email sudah terdaftar!'));

    expect(find.text('Email sudah terdaftar!'), findsOneWidget);
    expect(find.text('HALAMAN LOGIN'), findsNothing);
  });
}