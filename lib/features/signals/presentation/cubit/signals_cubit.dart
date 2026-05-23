import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/signals_filter.dart';
import '../../domain/repositories/signals_repository.dart';
import '../../../../core/errors/failures.dart';
import 'signals_state.dart';

class SignalsCubit extends Cubit<SignalsState> {
  final SignalsRepository signalsRepository;

  SignalsCubit({required this.signalsRepository})
      : super(SignalsInitial(filter: SignalsFilter.defaultFilter()));

  Future<void> loadSignals({
    required String login,
    required String partnerToken,
    SignalsFilter? filter,
  }) async {
    final activeFilter = filter ?? state.filter;
    emit(SignalsLoading(filter: activeFilter));
    try {
      final signals = await signalsRepository.getSignals(
        login: login,
        partnerToken: partnerToken,
        filter: activeFilter,
      );
      emit(SignalsLoaded(signals: signals, filter: activeFilter));
    } on NetworkFailure catch (e) {
      emit(SignalsError(message: e.message, filter: activeFilter));
    } on ServerFailure catch (e) {
      emit(SignalsError(message: e.message, filter: activeFilter));
    } catch (e) {
      emit(SignalsError(
          message: 'Failed to load signals.', filter: activeFilter));
    }
  }

  void updateFilter(SignalsFilter newFilter) {
    emit(SignalsInitial(filter: newFilter));
  }
}
