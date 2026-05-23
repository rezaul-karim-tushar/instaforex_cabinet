import 'package:dio/dio.dart';
import '../../../../core/errors/failures.dart';

abstract class ProfileRemoteDataSource {
  Future<Map<String, dynamic>> getAccountInformation({
    required String login,
    required String token,
  });

  Future<String> getLastFourPhone({
    required String login,
    required String token,
  });
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio peanutDio;

  ProfileRemoteDataSourceImpl({required this.peanutDio});

  @override
  Future<Map<String, dynamic>> getAccountInformation({
    required String login,
    required String token,
  }) async {
    final endpoints = [
      '/clientcabinet/GetAccountInformation',
      '/api/GetAccountInformation',
      '/GetAccountInformation',
      '/api/clientcabinet/account/GetAccountInformation',
    ];

    for (final endpoint in endpoints) {
      try {
        print('=== PROFILE TRYING: $endpoint ===');
        final response = await peanutDio.post(
          endpoint,
          data: {'Login': login, 'Token': token},
        );

        print('=== PROFILE RESPONSE ===');
        print('Type: ${response.data.runtimeType}');
        print('Value: ${response.data}');

        if (response.data == null) continue;
        if (response.data is Map) {
          return response.data as Map<String, dynamic>;
        }
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) continue;
        throw NetworkFailure(_parseDioError(e));
      }
    }

    // All endpoints 404 — return dummy data so app doesn't crash
    // We'll show what we have from the login (just the login number)
    print('=== PROFILE: all endpoints 404, returning fallback ===');
    return {
      'Login': login,
      'FirstName': '',
      'LastName': '',
      'Email': '',
      'Country': '',
      'Currency': '',
    };
  }

  @override
  Future<String> getLastFourPhone({
    required String login,
    required String token,
  }) async {
    final endpoints = [
      '/clientcabinet/GetLastFourNumbersPhone',
      '/api/GetLastFourNumbersPhone',
      '/GetLastFourNumbersPhone',
      '/api/clientcabinet/account/GetLastFourNumbersPhone',
    ];

    for (final endpoint in endpoints) {
      try {
        print('=== PHONE TRYING: $endpoint ===');
        final response = await peanutDio.post(
          endpoint,
          data: {'Login': login, 'Token': token},
        );

        print('=== PHONE RESPONSE ===');
        print('Type: ${response.data.runtimeType}');
        print('Value: ${response.data}');

        final data = response.data;
        if (data is String && data.isNotEmpty) return data;
        if (data is Map) {
          return data['PhoneLastFour']?.toString() ??
              data['lastFour']?.toString() ??
              data['phone']?.toString() ??
              '';
        }
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) continue;
        // Phone is non-critical — fail silently
        return '';
      }
    }

    return '';
  }

  String _parseDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timed out. Please try again.';
      case DioExceptionType.connectionError:
        return 'No internet connection.';
      default:
        return e.message ?? 'Something went wrong.';
    }
  }
}
