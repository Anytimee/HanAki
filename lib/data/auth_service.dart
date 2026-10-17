import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

const authTokenKey = 'auth_token';
const authApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:3000/api',
);

final apiClientProvider = Provider<Dio>((ref) => createApiClient());

final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(ref.watch(apiClientProvider)),
);

final isAuthenticatedProvider = StateProvider<bool>((_) => false);

Dio createApiClient() {
  final dio = Dio(
    BaseOptions(
      baseUrl: authApiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      contentType: Headers.jsonContentType,
      headers: const {'Accept': Headers.jsonContentType},
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = Hive.box('prefs').get(authTokenKey);
        if (token is String && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ),
  );

  return dio;
}

class AuthService {
  const AuthService(this._dio);

  final Dio _dio;

  bool get hasSavedToken {
    final token = Hive.box('prefs').get(authTokenKey);
    return token is String && token.isNotEmpty;
  }

  Future<void> login({
    required String email,
    required String password,
  }) =>
      _authenticate('/auth/login', email: email, password: password);

  Future<void> register({
    required String email,
    required String password,
  }) =>
      _authenticate('/auth/register', email: email, password: password);

  Future<void> _authenticate(
    String path, {
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      path,
      data: {'email': email, 'password': password},
    );
    final data = response.data?['data'];
    final token = data is Map<String, dynamic> ? data['token'] : null;
    if (response.data?['success'] != true ||
        token is! String ||
        token.isEmpty) {
      throw const AuthException();
    }

    await Hive.box('prefs').put(authTokenKey, token);
  }

  Future<void> logout() => Hive.box('prefs').delete(authTokenKey);
}

class AuthException implements Exception {
  const AuthException();
}
