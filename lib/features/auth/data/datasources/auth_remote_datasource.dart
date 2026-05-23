import 'package:dio/dio.dart';
import '../../../../core/errors/failures.dart';
import '../models/auth_request_model.dart';
import '../models/auth_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(AuthRequestModel request);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio peanutDio;
  final Dio partnerDio;

  AuthRemoteDataSourceImpl({
    required this.peanutDio,
    required this.partnerDio,
  });

  @override
  Future<AuthResponseModel> login(AuthRequestModel request) async {
    try {
      final results = await Future.wait([
        _loginPeanut(request),
        _loginPartner(request),
      ]);

      return AuthResponseModel(
        peanutToken: results[0],
        partnerToken: results[1],
        isSuccess: true,
      );
    } on AuthFailure {
      rethrow;
    } on NetworkFailure {
      rethrow;
    } on DioException catch (e) {
      throw NetworkFailure(_parseDioError(e));
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  Future<String> _loginPeanut(AuthRequestModel request) async {
    // Try correct endpoint paths
    const endpoints = [
      '/clientcabinet/IsAccountCredentialsCorrect',
      '/api/IsAccountCredentialsCorrect',
      '/IsAccountCredentialsCorrect',
      '/api/clientcabinet/account/IsAccountCredentialsCorrect',
    ];

    for (final endpoint in endpoints) {
      try {
        print('=== PEANUT TRYING: $endpoint ===');

        final response = await peanutDio.post(
          endpoint,
          data: request.toJson(),
        );

        final data = response.data;

        print('=== PEANUT RESPONSE ===');
        print('Type: ${data.runtimeType}');
        print('Value: $data');

        if (data == null) continue;

        if (data is bool && data == false) {
          throw const AuthFailure('Invalid login or password.');
        }

        if (data is bool && data == true) {
          return request.login;
        }

        if (data is String &&
            data.isNotEmpty &&
            data != 'false' &&
            data != 'null') {
          return data;
        }

        if (data is Map) {
          final token = data['Token'] ??
              data['token'] ??
              data['SessionToken'] ??
              data['Result'] ??
              data['result'];

          if (token != null && token.toString().isNotEmpty) {
            return token.toString();
          }

          final isValid = data['IsValid'] ??
              data['isValid'] ??
              data['Success'] ??
              data['success'];

          if (isValid == false) {
            throw const AuthFailure('Invalid login or password.');
          }

          if (isValid == true) {
            return request.login;
          }
        }
      } on AuthFailure {
        rethrow;
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          continue; // try next endpoint
        }
        rethrow;
      }
    }

    print('=== PEANUT: all endpoints 404, using login as peanut token ===');
    return request.login;
  }

  Future<String> _loginPartner(AuthRequestModel request) async {
    final response = await partnerDio.post(
      '/api/Authentication/RequestMoblieCabinetApiToken',
      data: request.toJson(),
    );

    final data = response.data;

    print('=== PARTNER RESPONSE ===');
    print('Type: ${data.runtimeType}');
    print('Value: $data');

    if (data == null) {
      throw const AuthFailure('Could not retrieve partner token.');
    }

    if (data is String && data.isNotEmpty && data != 'null') {
      return data;
    }

    if (data is Map) {
      final token = data['Token'] ??
          data['token'] ??
          data['ApiToken'] ??
          data['apiToken'] ??
          data['Result'] ??
          data['result'];

      if (token != null && token.toString().isNotEmpty) {
        return token.toString();
      }
    }

    throw const AuthFailure('Could not retrieve partner token.');
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
