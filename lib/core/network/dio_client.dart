import 'package:dio/dio.dart';
import '../constants/app_constants.dart';

class DioClient {
  static Dio peanutDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.peanutBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
    return dio;
  }

  static Dio partnerDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.partnerBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
    return dio;
  }
}
