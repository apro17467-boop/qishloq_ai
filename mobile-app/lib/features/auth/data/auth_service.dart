import 'package:qishloq_ai_mobile/core/network/api_client.dart';
import 'package:qishloq_ai_mobile/features/auth/data/auth_models.dart';

class AuthService {
  final ApiClient _apiClient;

  const AuthService(this._apiClient);

  Future<RequestOtpResponse> requestOtp(String phone) async {
    final response = await _apiClient.post(
      '/auth/request-otp',
      data: {'phone': phone},
    );
    if (response is Map<String, dynamic>) {
      return RequestOtpResponse.fromJson(response);
    }
    throw const FormatException('Kutilmagan server javobi');
  }
}
