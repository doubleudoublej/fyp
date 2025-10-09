import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  final Dio dio;
  final FlutterSecureStorage storage;

  ApiClient._(this.dio, this.storage) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final token = await storage.read(key: 'jwt');
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          } catch (_) {
            // ignore storage errors
          }
          return handler.next(options);
        },
        onError: (DioException err, handler) async {
          return handler.next(err);
        },
      ),
    );
  }

  /// Create ApiClient. If [overrideBaseUrl] is provided it will be used.
  /// Defaults to port 8080 (your backend currently runs on 8080).
  factory ApiClient({
    String? overrideBaseUrl,
    int port = 8080,
    FlutterSecureStorage? storage,
  }) {
    final baseUrl = overrideBaseUrl ?? _determineBaseUrl(port);
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
      ),
    );
    return ApiClient._(dio, storage ?? const FlutterSecureStorage());
  }

  static String _determineBaseUrl(int port) {
    final p = port.toString();
    if (kIsWeb) return 'http://localhost:$p';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:$p';
      if (Platform.isIOS) return 'http://localhost:$p';
      return 'http://localhost:$p';
    } catch (e) {
      return 'http://localhost:$p';
    }
  }

  // Example request helper:
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) {
    return dio.post(path, data: data);
  }
}
