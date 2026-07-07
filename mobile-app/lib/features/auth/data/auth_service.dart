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

  Future<VerifyOtpResponse> verifyOtp({
    required String phone,
    required String code,
    required String role,
    required String fullName,
    String? regionId,
    String? address,
  }) async {
    final response = await _apiClient.post(
      '/auth/verify-otp',
      data: {
        'phone': phone,
        'code': code,
        'role': role,
        'fullName': fullName,
        if (regionId != null && regionId.isNotEmpty) 'regionId': regionId,
        if (address != null && address.isNotEmpty) 'address': address,
      },
    );
    if (response is Map<String, dynamic>) {
      return VerifyOtpResponse.fromJson(response);
    }
    throw const FormatException('Kutilmagan server javobi');
  }

  Future<AuthUser> getMe() async {
    final response = await _apiClient.get('/auth/me');
    if (response is Map<String, dynamic>) {
      final meResponse = MeResponse.fromJson(response);
      return meResponse.user;
    }
    throw const FormatException('Kutilmagan server javobi');
  }
}
