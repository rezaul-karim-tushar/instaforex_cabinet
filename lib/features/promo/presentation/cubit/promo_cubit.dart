import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/promo_repository.dart';
import '../../../../core/errors/failures.dart';
import 'promo_state.dart';

class PromoCubit extends Cubit<PromoState> {
  final PromoRepository promoRepository;

  PromoCubit({required this.promoRepository}) : super(PromoInitial());

  Future<void> loadPromo() async {
    emit(PromoLoading());
    try {
      final items = await promoRepository.getPromoMaterials();
      emit(PromoLoaded(items));
    } on NetworkFailure catch (e) {
      emit(PromoError(e.message));
    } on ServerFailure catch (e) {
      emit(PromoError(e.message));
    } catch (e) {
      emit(const PromoError('Failed to load promo materials.'));
    }
  }
}
