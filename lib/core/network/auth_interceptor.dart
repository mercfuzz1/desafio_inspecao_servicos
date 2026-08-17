import 'package:dio/dio.dart';

import '../storage/secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorage secureStorage;

  AuthInterceptor(this.secureStorage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await secureStorage.getAccessToken();

    // Endpoints públicos que não precisam de autenticação.
    final isPublicRoute = options.path == '/auth/login';

    if (!isPublicRoute && (token == null || token.isEmpty)) {
      handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.cancel,
          error: 'Usuário não autenticado.',
        ),
      );

      return;
    }

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      await secureStorage.deleteAccessToken();
    }

    handler.next(err);
  }
}