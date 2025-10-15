import 'package:alphagrit/domain/models/affiliate_product.dart';
import 'package:alphagrit/infra/api/errors.dart';
import 'package:dio/dio.dart';

class StoreRepository {
  final Dio dio;
  StoreRepository(this.dio);
  Future<List<AffiliateProduct>> list() async {
    final res = await dio.get('/affiliate/products');
    if (res.statusCode == 200) {
      final data = (res.data as List).cast<Map<String, dynamic>>();
      return data.map(AffiliateProduct.fromJson).toList();
    }
    throwApiError(res.statusCode, res.data);
  }
}

