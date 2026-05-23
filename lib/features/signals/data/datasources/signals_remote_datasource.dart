import 'package:dio/dio.dart';
import '../../../../core/errors/failures.dart';
import '../models/signal_model.dart';
import '../../domain/entities/signals_filter.dart';

abstract class SignalsRemoteDataSource {
  Future<List<SignalModel>> getSignals({
    required String login,
    required String partnerToken,
    required SignalsFilter filter,
  });
}

class SignalsRemoteDataSourceImpl implements SignalsRemoteDataSource {
  final Dio partnerDio;

  SignalsRemoteDataSourceImpl({required this.partnerDio});

  @override
  Future<List<SignalModel>> getSignals({
    required String login,
    required String partnerToken,
    required SignalsFilter filter,
  }) async {
    try {
      final response = await partnerDio.get(
        '/clientmobile/GetAnalyticSignals/$login',
        queryParameters: {
          'tradingsystem': 3,
          'pairs': filter.pairsParam,
          'from': filter.fromTimestamp,
          'to': filter.toTimestamp,
        },
        options: Options(
          headers: {'passkey': partnerToken},
        ),
      );

      final data = response.data;

      if (data == null) return [];

      List<dynamic> list = [];
      if (data is List) {
        list = data;
      } else if (data is Map && data['Data'] != null) {
        list = data['Data'] as List;
      } else if (data is Map && data['data'] != null) {
        list = data['data'] as List;
      } else if (data is Map && data['Signals'] != null) {
        list = data['Signals'] as List;
      }

      return list
          .map((e) => SignalModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw NetworkFailure(_parseDioError(e));
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure(e.toString());
    }
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
