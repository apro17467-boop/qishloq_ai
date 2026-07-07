class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? code;
  final dynamic details;

  const ApiException({
    required this.message,
    this.statusCode,
    this.code,
    this.details,
  });

  factory ApiException.fromJson(Map<String, dynamic> json, [int? fallbackStatusCode]) {
    final errorData = json['error'] as Map<String, dynamic>?;
    final int? statusCode = json['statusCode'] as int? ?? fallbackStatusCode;
    
    if (errorData != null) {
      return ApiException(
        message: errorData['message'] as String? ?? 'Noma’lum xatolik',
        statusCode: statusCode,
        code: errorData['code'] as String?,
        details: errorData['details'],
      );
    }

    return ApiException(
      message: json['message'] as String? ?? 'Noma’lum xatolik',
      statusCode: statusCode,
    );
  }

  @override
  String toString() => 'ApiException(message: $message, statusCode: $statusCode, code: $code)';
}
