import 'package:dio/dio.dart';

class WaitlistApi {
  final Dio _dio;
  WaitlistApi(this._dio);

  /// Join waitlist. Returns true on success, false if duplicate email (409).
  Future<bool> join({required String email, String language = 'en'}) async {
    try {
      final res = await _dio.post('/waitlist', data: {
        'email': email.toLowerCase(),
        'language': language,
      });
      return res.statusCode == 201 || (res.statusCode ?? 0) < 300;
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        return false; // duplicate
      }
      rethrow;
    }
  }
}

