import 'dart:convert';

import 'package:fadein_app/service/api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  tearDown(() {
    Apiservice.client = http.Client();
    Apiservice.setTokenCache(null);
  });

  test('200 membuka bungkus data', () async {
    Apiservice.setTokenCache('token-uji');
    Apiservice.client = MockClient((request) async {
      expect(request.headers['Authorization'], 'Bearer token-uji');
      return http.Response(
        jsonEncode({
          'message': 'Daftar barber berhasil diambil!',
          'data': [
            {'id': 1, 'name': 'Andi'},
          ],
        }),
        200,
      );
    });

    final data = await Apiservice.get('/barbers') as List;

    expect(data, hasLength(1));
    expect(data.first['name'], 'Andi');
  });

  test('200 tanpa data mengembalikan body apa adanya', () async {
    Apiservice.setTokenCache('token-uji');
    Apiservice.client = MockClient((request) async {
      return http.Response(jsonEncode({'message': 'OK'}), 200);
    });

    final data = await Apiservice.get('/health') as Map;

    expect(data['message'], 'OK');
  });

  test('401 melempar ApiException dengan pesan server', () async {
    Apiservice.setTokenCache('token-kedaluwarsa');
    Apiservice.client = MockClient((request) async {
      return http.Response(
        jsonEncode({'message': 'Token tidak valid atau sudah kedaluwarsa!'}),
        401,
      );
    });

    try {
      await Apiservice.get('/bookings');
      fail('seharusnya melempar ApiException');
    } on ApiException catch (e) {
      expect(e.statusCode, 401);
      expect(e.isUnauthorized, isTrue);
      expect(e.message, 'Token tidak valid atau sudah kedaluwarsa!');
    }
  });

  test('409 slot bentrok terbaca sebagai konflik', () async {
    Apiservice.setTokenCache('token-uji');
    Apiservice.client = MockClient((request) async {
      return http.Response(
        jsonEncode({'message': 'Jadwal tersebut sudah dipesan!'}),
        409,
      );
    });

    try {
      await Apiservice.post('/bookings', {});
      fail('seharusnya melempar ApiException');
    } on ApiException catch (e) {
      expect(e.isConflict, isTrue);
      expect(e.message, 'Jadwal tersebut sudah dipesan!');
    }
  });

  test('error tanpa message memakai pesan cadangan', () async {
    Apiservice.setTokenCache('token-uji');
    Apiservice.client = MockClient((request) async {
      return http.Response('', 500);
    });

    try {
      await Apiservice.get('/bookings');
      fail('seharusnya melempar ApiException');
    } on ApiException catch (e) {
      expect(e.statusCode, 500);
      expect(e.message, contains('500'));
    }
  });

  test('kegagalan koneksi jadi ApiException tanpa statusCode', () async {
    Apiservice.setTokenCache('token-uji');
    Apiservice.client = MockClient((request) async {
      throw http.ClientException('connection failed');
    });

    try {
      await Apiservice.get('/barbers');
      fail('seharusnya melempar ApiException');
    } on ApiException catch (e) {
      expect(e.statusCode, isNull);
      expect(e.message, contains('Koneksi'));
    }
  });

  test('post mengirim JSON dengan header yang benar', () async {
    Apiservice.setTokenCache('token-uji');
    Apiservice.client = MockClient((request) async {
      expect(request.method, 'POST');
      expect(request.headers['Content-Type'], contains('application/json'));
      expect(jsonDecode(request.body), {'email': 'budi@gmail.com'});
      return http.Response(jsonEncode({'message': 'Login berhasil!', 'data': {}}), 200);
    });

    final data = await Apiservice.post('/auth/login', {'email': 'budi@gmail.com'});

    expect(data, isA<Map>());
  });
}