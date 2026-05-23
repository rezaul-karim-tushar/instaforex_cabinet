import '../../domain/entities/signal_entity.dart';
import '../../domain/entities/signals_filter.dart';
import '../../domain/repositories/signals_repository.dart';
import '../datasources/signals_remote_datasource.dart';

class SignalsRepositoryImpl implements SignalsRepository {
  final SignalsRemoteDataSource remoteDataSource;

  SignalsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<SignalEntity>> getSignals({
    required String login,
    required String partnerToken,
    required SignalsFilter filter,
  }) async {
    return remoteDataSource.getSignals(
      login: login,
      partnerToken: partnerToken,
      filter: filter,
    );
  }
}
