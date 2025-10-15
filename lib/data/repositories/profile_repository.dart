import 'package:alphagrit/domain/models/profile.dart';
import 'package:alphagrit/infra/api/errors.dart';
import 'package:dio/dio.dart';

class ProfileRepository {
  final Dio dio;
  ProfileRepository(this.dio);

  Future<UserProfile> me() async {
    final res = await dio.get('/users/me');
    if (res.statusCode == 200) {
      final data = res.data;
      // backend returns a row or simple dict; normalize
      final map = (data is List && data.isNotEmpty) ? data.first as Map<String, dynamic> : data as Map<String, dynamic>;
      return UserProfile.fromJson(map);
    }
    throwApiError(res.statusCode, res.data);
  }

  Future<UserProfile> update(UserProfile update) async {
    final res = await dio.put('/users/me', data: update.toUpdateJson());
    if (res.statusCode == 200) {
      final map = res.data as Map<String, dynamic>;
      return UserProfile.fromJson(map);
    }
    throwApiError(res.statusCode, res.data);
  }
}

