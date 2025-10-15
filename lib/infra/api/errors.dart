class ApiException implements Exception {
  final int? statusCode;
  final String code;
  final String message;
  ApiException({this.statusCode, required this.code, required this.message});
  @override
  String toString() => 'ApiException($statusCode, $code, $message)';
}

Map<String, dynamic> _asMap(dynamic data) => data is Map<String, dynamic> ? data : <String, dynamic>{};

Never throwApiError(int? status, dynamic data) {
  final m = _asMap(data);
  final err = _asMap(m['error']);
  final code = (err['code'] ?? 'UNKNOWN').toString();
  final msg = (err['message'] ?? 'Unknown error').toString();
  throw ApiException(statusCode: status, code: code, message: msg);
}

