import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

/// Error dari backend atau dari koneksi.
///
/// [statusCode] penting supaya layar bisa membedakan `409` (slot bentrok)
/// dari error biasa. Untuk kegagalan koneksi nilainya `null`.
class ApiException implements Exception {
  ApiException(this.message, [this.statusCode]);

  final String message;
  final int? statusCode;

  bool get isUnauthorized => statusCode == 401;
  bool get isConflict => statusCode == 409;

  @override
  String toString() => message;
}

/// Satu pintu untuk semua request HTTP ke backend FadeIn.
class Apiservice {
  /// URL backend. Bisa diubah saat build:
  /// `flutter build apk --dart-define=API_BASE_URL=https://...`
  static String get baseUrl {
    const dariEnv = String.fromEnvironment('API_BASE_URL');
    if (dariEnv.isNotEmpty) return dariEnv;
    // Backend sudah deploy ke Vercel. Default ini membuat `flutter run` polos
    // langsung jalan di Chrome, HP, maupun emulator — `10.0.2.2` hanya benar
    // untuk emulator Android, dan backend lokal tidak bisa menjangkau Aiven
    // dari jaringan Indonesia.
    return 'https://fadein-backend.vercel.app/api';
  }

  /// Client yang bisa diganti `MockClient` saat unit test.
  static http.Client client = http.Client();

  static const _storage = FlutterSecureStorage();
  static const _keyToken = 'token';
  static const _keyUser = 'user';

  /// Di widget test, MethodChannel plugin tidak pernah menjawab (Future-nya
  /// menggantung), sehingga `saveToken`/`getToken` macet sebelum request
  /// berangkat. Test mengisi ini `true` agar cache memori dipakai sendirian.
  @visibleForTesting
  static bool tanpaSecureStorage = false;

  static Future<void> _tulis(String key, String value) async {
    if (tanpaSecureStorage) return;
    try {
      await _storage.write(key: key, value: value);
    } on MissingPluginException {
      // plugin tidak tersedia (desktop/test): cukup cache memori
    }
  }

  static Future<String?> _baca(String key) async {
    if (tanpaSecureStorage) return null;
    try {
      return await _storage.read(key: key);
    } on MissingPluginException {
      return null;
    }
  }

  static Future<void> _hapus(String key) async {
    if (tanpaSecureStorage) return;
    try {
      await _storage.delete(key: key);
    } on MissingPluginException {
      // plugin tidak tersedia: cache memori sudah dibersihkan
    }
  }

  static const _timeout = Duration(seconds: 15);

  // cache di memori supaya tidak baca storage di setiap request
  static String? _token;
  static Map<String, dynamic>? _user;

  // ---------- token & sesi ----------
  //
  // Di unit test (dan di desktop) plugin secure storage tidak tersedia dan
  // melempar MissingPluginException. Cache memori tetap dipakai supaya
  // alur login/logout bisa diuji tanpa perangkat.

  static Future<void> saveToken(String token) async {
    _token = token;
    await _tulis(_keyToken, token);
  }

  static Future<String?> getToken() async {
    if (_token != null) return _token;
    _token = await _baca(_keyToken);
    return _token;
  }

  static Future<void> saveUser(Map<String, dynamic> user) async {
    _user = user;
    await _tulis(_keyUser, jsonEncode(user));
  }

  static Future<Map<String, dynamic>?> getUser() async {
    if (_user != null) return _user;

    final raw = await _baca(_keyUser);
    if (raw == null || raw.isEmpty) return null;

    final data = jsonDecode(raw);
    _user = data is Map<String, dynamic> ? data : null;
    return _user;
  }

  static Future<void> logout() async {
    _token = null;
    _user = null;
    await _hapus(_keyToken);
    await _hapus(_keyUser);
  }

  /// Dipakai unit test agar tidak menyentuh secure storage.
  @visibleForTesting
  static void setTokenCache(String? token) {
    _token = token;
  }

  @visibleForTesting
  static void setUserCache(Map<String, dynamic>? user) {
    _user = user;
  }

  // ---------- request ----------

  static Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<dynamic> get(String endpoint) {
    return _safeRequest(() async {
      final response = await client
          .get(Uri.parse('$baseUrl$endpoint'), headers: await _getHeaders())
          .timeout(_timeout);
      return _prosesResponse(response);
    });
  }

  static Future<dynamic> post(String endpoint, Map<String, dynamic> data) {
    return _safeRequest(() async {
      final response = await client
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: await _getHeaders(),
            body: jsonEncode(data),
          )
          .timeout(_timeout);
      return _prosesResponse(response);
    });
  }

  static Future<dynamic> put(String endpoint, Map<String, dynamic> data) {
    return _safeRequest(() async {
      final response = await client
          .put(
            Uri.parse('$baseUrl$endpoint'),
            headers: await _getHeaders(),
            body: jsonEncode(data),
          )
          .timeout(_timeout);
      return _prosesResponse(response);
    });
  }

  static Future<dynamic> patch(String endpoint, Map<String, dynamic> data) {
    return _safeRequest(() async {
      final response = await client
          .patch(
            Uri.parse('$baseUrl$endpoint'),
            headers: await _getHeaders(),
            body: jsonEncode(data),
          )
          .timeout(_timeout);
      return _prosesResponse(response);
    });
  }

  static Future<dynamic> delete(String endpoint) {
    return _safeRequest(() async {
      final response = await client
          .delete(Uri.parse('$baseUrl$endpoint'), headers: await _getHeaders())
          .timeout(_timeout);
      return _prosesResponse(response);
    });
  }

  /// Unggah satu file gambar dengan nama field `photo`.
  ///
  /// Backend memakai `multer.single('photo')`, jadi nama field tidak boleh lain.
  static Future<dynamic> upload(
    String endpoint,
    List<int> bytes, {
    required String filename,
    String mimeType = 'image/jpeg',
    Map<String, String>? fields,
  }) {
    return _safeRequest(() async {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl$endpoint'),
      );

      final token = await getToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      if (fields != null) {
        request.fields.addAll(fields);
      }

      // multer di backend menolak file yang mimetype-nya bukan image/*
      request.files.add(
        http.MultipartFile.fromBytes(
          'photo',
          bytes,
          filename: filename,
          contentType: MediaType.parse(mimeType),
        ),
      );

      final streamed = await client.send(request).timeout(_timeout);
      final response = await http.Response.fromStream(streamed);
      return _prosesResponse(response);
    });
  }

  static Future<dynamic> _safeRequest(Future<dynamic> Function() action) async {
    try {
      return await action();
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw ApiException('Waktu tunggu habis. Server tidak merespons.');
    } on SocketException {
      throw ApiException('Tidak dapat terhubung ke server. Periksa koneksi.');
    } on http.ClientException {
      throw ApiException('Koneksi ke server gagal. Coba lagi.');
    } on FormatException {
      throw ApiException('Respons server tidak dapat dibaca.');
    }
  }

  /// Membuka bungkus `{ message, data }` dan melempar [ApiException]
  /// berisi `message` dari server untuk status non-2xx.
  static dynamic _prosesResponse(http.Response response) {
    final dynamic body = response.body.isEmpty ? null : jsonDecode(response.body);
    final pesan = (body is Map && body['message'] != null)
        ? '${body['message']}'
        : null;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (body is Map && body.containsKey('data')) return body['data'];
      return body;
    }

    throw ApiException(
      pesan ?? 'Terjadi kesalahan pada server (kode: ${response.statusCode}).',
      response.statusCode,
    );
  }
}