import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthService(String baseUrl)
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 10),
        ),
      );

  Future<void> register(
    String username,
    String password, {
    String? email,
  }) async {
    await _dio.post(
      '/api/auth/register',
      data: {
        'username': username,
        'password': password,
        if (email != null) 'email': email,
      },
    );
  }

  Future<String?> login(String username, String password) async {
    final resp = await _dio.post(
      '/api/auth/login',
      data: {'username': username, 'password': password},
    );
    final token = resp.data['token'] as String?;
    if (token != null) {
      await _storage.write(key: 'jwt', value: token);
    }
    return token;
  }

  Future<void> logout() async {
    await _storage.delete(key: 'jwt');
  }

  Future<String?> readToken() => _storage.read(key: 'jwt');
}
