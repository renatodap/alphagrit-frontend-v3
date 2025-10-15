import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:alphagrit/core/constants/env.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ApiClient {
  final Dio _dio;
  ApiClient._(this._dio);

  static Future<ApiClient> create(Locale locale) async {
    final dio = Dio(BaseOptions(baseUrl: '${Env.backendBaseUrl}/api/v1', connectTimeout: const Duration(seconds: 10), receiveTimeout: const Duration(seconds: 20)));
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) async {
      final session = Supabase.instance.client.auth.currentSession;
      final token = session?.accessToken;
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      options.headers['Accept-Language'] = locale.languageCode;
      return handler.next(options);
    }));
    return ApiClient._(dio);
  }

  Dio get dio => _dio;
}

