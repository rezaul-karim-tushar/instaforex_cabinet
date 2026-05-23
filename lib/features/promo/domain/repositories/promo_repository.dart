import '../entities/promo_entity.dart';

abstract class PromoRepository {
  Future<List<PromoEntity>> getPromoMaterials();
}
