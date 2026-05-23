import '../../domain/entities/promo_entity.dart';
import '../../domain/repositories/promo_repository.dart';
import '../datasources/promo_soap_datasource.dart';

class PromoRepositoryImpl implements PromoRepository {
  final PromoSoapDataSource dataSource;

  PromoRepositoryImpl({required this.dataSource});

  @override
  Future<List<PromoEntity>> getPromoMaterials() async {
    final rawList = await dataSource.getPromoMaterials();
    return rawList
        .map((e) => PromoEntity(
              title: e['title'] ?? '',
              description: e['description'] ?? '',
              imageUrl: e['imageUrl'] ?? '',
              link: e['link'] ?? '',
              code: e['code'] ?? '',
            ))
        .toList();
  }
}
