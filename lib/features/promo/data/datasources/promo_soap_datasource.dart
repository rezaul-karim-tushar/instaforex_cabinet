import 'package:dio/dio.dart';
import 'package:xml/xml.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/constants/app_constants.dart';

abstract class PromoSoapDataSource {
  Future<List<Map<String, String>>> getPromoMaterials();
}

class PromoSoapDataSourceImpl implements PromoSoapDataSource {
  final Dio dio;

  PromoSoapDataSourceImpl({required this.dio});

  @override
  Future<List<Map<String, String>>> getPromoMaterials() async {
    try {
      const soapBody = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
               xmlns:tem="http://tempuri.org/">
  <soap:Header/>
  <soap:Body>
    <tem:GetCCPromo>
      <tem:lang>en</tem:lang>
    </tem:GetCCPromo>
  </soap:Body>
</soap:Envelope>''';

      final response = await dio.post(
        AppConstants.soapBaseUrl,
        data: soapBody,
        options: Options(
          headers: {
            'Content-Type': 'text/xml; charset=utf-8',
            'SOAPAction': 'http://tempuri.org/ICabinetMicroService/GetCCPromo',
          },
        ),
      );

      return _parseResponse(response.data.toString());
    } on DioException catch (e) {
      throw NetworkFailure(_parseDioError(e));
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Failed to load promo materials.');
    }
  }

  List<Map<String, String>> _parseResponse(String xmlString) {
    try {
      // Fix image domain
      final fixed = xmlString.replaceAll(
        AppConstants.oldImageDomain,
        AppConstants.newImageDomain,
      );
      final fixedDoc = XmlDocument.parse(fixed);

      // Try to find promo items — structure may vary
      final items = fixedDoc.findAllElements('PromoItem').toList().isNotEmpty
          ? fixedDoc.findAllElements('PromoItem').toList()
          : fixedDoc.findAllElements('CCPromo').toList().isNotEmpty
              ? fixedDoc.findAllElements('CCPromo').toList()
              : fixedDoc.findAllElements('Promo').toList();

      if (items.isEmpty) {
        return _fallbackParse(fixedDoc);
      }

      return items
          .map((item) {
            return {
              'title': _childText(item, ['Title', 'title', 'Name', 'name']),
              'description':
                  _childText(item, ['Description', 'description', 'Desc']),
              'imageUrl':
                  _childText(item, ['ImageUrl', 'imageUrl', 'Image', 'image']),
              'link': _childText(item, ['Link', 'link', 'Url', 'url', 'URL']),
              'code': _childText(item, ['Code', 'code', 'Html', 'html']),
            };
          })
          .where((e) => e['title']!.isNotEmpty || e['imageUrl']!.isNotEmpty)
          .toList();
    } catch (e) {
      throw ServerFailure('Failed to parse promo response.');
    }
  }

  List<Map<String, String>> _fallbackParse(XmlDocument doc) {
    final results = <Map<String, String>>[];

    for (final element in doc.descendants.whereType<XmlElement>()) {
      final text = element.innerText.trim();
      if (text.contains('http') &&
          (text.contains('.jpg') ||
              text.contains('.png') ||
              text.contains('.gif'))) {
        results.add({
          'title': '',
          'description': '',
          'imageUrl': text,
          'link': '',
          'code': '',
        });
      }
    }
    return results;
  }

  String _childText(XmlElement element, List<String> tags) {
    for (final tag in tags) {
      final found = element.findElements(tag);
      if (found.isNotEmpty) return found.first.innerText.trim();
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
