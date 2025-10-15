import 'package:alphagrit/domain/models/metric.dart';
import 'package:alphagrit/infra/api/errors.dart';
import 'package:dio/dio.dart';

class MetricsRepository {
  final Dio dio;
  MetricsRepository(this.dio);

  Future<List<Metric>> list() async {
    final res = await dio.get('/me/metrics');
    if (res.statusCode == 200) {
      final data = (res.data as List).cast<Map<String, dynamic>>();
      return data.map(Metric.fromJson).toList();
    }
    throwApiError(res.statusCode, res.data);
  }

  Future<Metric> create({required String date, double? weight, double? bodyFat, String? photoUrl, String? note}) async {
    final res = await dio.post('/me/metrics', data: {
      'date': date,
      'weight': weight,
      'body_fat': bodyFat,
      'photo_url': photoUrl,
      'note': note,
    });
    if (res.statusCode == 200) {
      return Metric.fromJson(res.data as Map<String, dynamic>);
    }
    throwApiError(res.statusCode, res.data);
  }

  Future<void> delete(int id) async {
    final res = await dio.delete('/me/metrics/$id');
    if (res.statusCode == 200) return;
    throwApiError(res.statusCode, res.data);
  }
}

