import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
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
    return 'http://10.0.2.2:3000/api';
  }

  /// Client yang bisa diganti `MockClient` saat unit test.
  static http.Client client = http.Client();

  static const _storage = FlutterSecureStorage();
  static const _keyToken = 'token';
  static const _keyUser = 'user';

  static const _timeout = Duration(seconds: 15);

  // cache di memori supaya tidak baca storage di setiap request
  static String? _token;

  // ---------- token & sesi ----------

  static Future<void> saveToken(String token) async {
    _token = token;
    await _storage.write(key: _keyToken, value: token);
  }

  static Future<String?> getToken() async {
    if (_token != null) return _token;
    _token = await _storage.read(key: _keyToken);
    return _token;
  }

  static Future<void> saveUser(Map<String, dynamic> user) async {
    await _storage.write(key: _keyUser, value: jsonEncode(user));
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final raw = await _storage.read(key: _keyUser);
    if (raw == null || raw.isEmpty) return null;

    final data = jsonDecode(raw);
    return data is Map<String, dynamic> ? data : null;
  }

  static Future<void> logout() async {
    _token = null;
    await _storage.delete(key: _keyToken);
    await _storage.delete(key: _keyUser);
  }

  /// Dipakai unit test agar tidak menyentuh secure storage.
  @visibleForTesting
  static void setTokenCache(String? token) {
    _token = token;
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