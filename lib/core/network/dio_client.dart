import 'package:dio/dio.dart';

import '../storage/secure_storage.dart';
import 'auth_interceptor.dart';

class DioClient {
  late final Dio dio;

  DioClient({
    required SecureStorage secureStorage,
  }) {
    dio = Dio(
      BaseOptions(
        baseUrl: 'http://10.0.2.2:3000',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      AuthInterceptor(secureStorage),
    );
  }
}