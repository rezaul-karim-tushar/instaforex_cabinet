import 'package:dio/dio.dart';
import '../models/auth_request_model.dart';
import '../models/auth_response_model.dart';
import '../../../../core/errors/failures.dart';

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
      // Call both services in parallel
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
    } on DioException catch (e) {
      throw NetworkFailure(_parseDioError(e));
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  Future<String> _loginPeanut(AuthRequestModel request) async {
    final response = await peanutDio.post(
      '/api/clientcabinet/IsAccountCredentialsCorrect',
      data: request.toJson(),
    );

    final data = response.data;

    // Check if credentials are correct
    if (data is bool && data == false) {
      throw const AuthFailure('Invalid login or password.');
    }

    // Peanut returns the token directly or inside a field
    if (data is String && data.isNotEmpty) return data;
    if (data is Map && data['Token'] != null) return data['Token'];
    if (data is Map && data['token'] != null) return data['token'];

    throw const AuthFailure('Invalid login or password.');
  }

  Future<String> _loginPartner(AuthRequestModel request) async {
    final response = await partnerDio.post(
      '/api/Authentication/RequestMoblieCabinetApiToken',
      data: request.toJson(),
    );

    final data = response.data;

    if (data is String && data.isNotEmpty) return data;
    if (data is Map && data['Token'] != null) return data['Token'];
    if (data is Map && data['token'] != null) return data['token'];

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
