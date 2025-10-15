import 'package:alphagrit/domain/models/program.dart';
import 'package:alphagrit/infra/api/errors.dart';
import 'package:dio/dio.dart';

class ProgramsRepository {
  final Dio dio;
  ProgramsRepository(this.dio);

  Future<List<Program>> list() async {
    final res = await dio.get('/programs');
    if (res.statusCode == 200) {
      final data = (res.data as List).cast<Map<String, dynamic>>();
      return data.map(Program.fromJson).toList();
    }
    throwApiError(res.statusCode, res.data);
  }

  Future<Program> getProgram(int id) async {
    final res = await dio.get('/programs/$id');
    if (res.statusCode == 200) {
      return Program.fromJson(res.data as Map<String, dynamic>);
    }
    throwApiError(res.statusCode, res.data);
  }

  Future<List<PostItem>> listPosts(int programId) async {
    final res = await dio.get('/programs/$programId/posts');
    if (res.statusCode == 200) {
      final data = (res.data as List).cast<Map<String, dynamic>>();
      return data.map(PostItem.fromJson).toList();
    }
    throwApiError(res.statusCode, res.data);
  }

  Future<PostItem> createPost(int programId, {String? message, String? photoUrl, String visibility = 'public'}) async {
    final res = await dio.post('/programs/$programId/posts', data: {
      'message': message,
      'photo_url': photoUrl,
      'visibility': visibility,
    });
    if (res.statusCode == 200) {
      return PostItem.fromJson(res.data as Map<String, dynamic>);
    }
    throwApiError(res.statusCode, res.data);
  }

  Future<String> checkout(int programId, {String tier = 'standard'}) async {
    final res = await dio.post('/programs/$programId/checkout', queryParameters: {'tier': tier});
    if (res.statusCode == 200) {
      return (res.data as Map<String, dynamic>)['checkout_url'] as String;
    }
    throwApiError(res.statusCode, res.data);
  }
}

