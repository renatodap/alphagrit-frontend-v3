import 'package:dio/dio.dart';
import 'package:alphagrit/infra/api/errors.dart';

/// Repository for admin operations
class AdminRepository {
  final Dio dio;
  AdminRepository(this.dio);

  // ===== WINTER ARC PREMIUM POSTS =====

  /// Get premium posts queue for Wagner to respond to
  Future<List<Map<String, dynamic>>> getPremiumPostsQueue({int programId = 1}) async {
    try {
      final res = await dio.get(
        '/admin/winter-arc/premium-posts',
        queryParameters: {'programId': programId},
      );
      if (res.statusCode == 200) {
        return (res.data as List).cast<Map<String, dynamic>>();
      }
      throwApiError(res.statusCode, res.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Admin access required');
      }
      rethrow;
    }
  }

  /// Mark a post as responded to by Wagner
  Future<Map<String, dynamic>> markPostResponded(
    int postId, {
    String? notes,
  }) async {
    final res = await dio.post(
      '/admin/winter-arc/posts/$postId/mark-responded',
      data: {
        if (notes != null) 'notes': notes,
      },
    );
    if (res.statusCode == 200) {
      return res.data as Map<String, dynamic>;
    }
    throwApiError(res.statusCode, res.data);
  }

  /// Get premium tier statistics
  Future<Map<String, dynamic>> getPremiumStats({int programId = 1}) async {
    final res = await dio.get(
      '/admin/winter-arc/premium-stats',
      queryParameters: {'programId': programId},
    );
    if (res.statusCode == 200) {
      return res.data as Map<String, dynamic>;
    }
    throwApiError(res.statusCode, res.data);
  }
}
