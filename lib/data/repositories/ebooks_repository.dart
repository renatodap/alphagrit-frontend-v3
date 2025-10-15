import 'package:alphagrit/domain/models/ebook.dart';
import 'package:alphagrit/infra/api/errors.dart';
import 'package:dio/dio.dart';

class EbooksRepository {
  final Dio dio;
  EbooksRepository(this.dio);

  Future<List<Ebook>> list() async {
    final res = await dio.get('/ebooks');
    if (res.statusCode == 200) {
      final data = (res.data as List).cast<Map<String, dynamic>>();
      return data.map(Ebook.fromJson).toList();
    }
    throwApiError(res.statusCode, res.data);
  }

  Future<Ebook> getBySlug(String slug) async {
    final res = await dio.get('/ebooks/$slug');
    if (res.statusCode == 200) {
      return Ebook.fromJson(res.data as Map<String, dynamic>);
    }
    throwApiError(res.statusCode, res.data);
  }

  Future<String> checkoutEbook(int id) async {
    final res = await dio.post('/ebooks/checkout/ebooks/$id');
    if (res.statusCode == 200) {
      return (res.data as Map<String, dynamic>)['checkout_url'] as String;
    }
    throwApiError(res.statusCode, res.data);
  }

  Future<String> checkoutCombo(int ebookId, {String tier = 'standard'}) async {
    final res = await dio.post('/ebooks/checkout/combo/$ebookId', queryParameters: {'tier': tier});
    if (res.statusCode == 200) {
      return (res.data as Map<String, dynamic>)['checkout_url'] as String;
    }
    throwApiError(res.statusCode, res.data);
  }
}

