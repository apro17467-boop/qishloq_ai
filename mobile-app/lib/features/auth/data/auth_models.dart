class RequestOtpResponse {
  final String message;
  final int? expiresInMinutes;
  final String? devCode;

  const RequestOtpResponse({
    required this.message,
    this.expiresInMinutes,
    this.devCode,
  });

  factory RequestOtpResponse.fromJson(Map<String, dynamic> json) {
    return RequestOtpResponse(
      message: json['message'] as String? ?? 'Kodni yuborish muvaffaqiyatli yakunlandi',
      expiresInMinutes: json['expiresInMinutes'] as int?,
      devCode: json['devCode']?.toString(),
    );
  }
}
