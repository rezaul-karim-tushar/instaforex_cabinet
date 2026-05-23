import '../entities/signal_entity.dart';
import '../entities/signals_filter.dart';

abstract class SignalsRepository {
  Future<List<SignalEntity>> getSignals({
    required String login,
    required String partnerToken,
    required SignalsFilter filter,
  });
}
