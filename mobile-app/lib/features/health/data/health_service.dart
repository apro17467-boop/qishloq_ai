import 'package:qishloq_ai_mobile/core/network/api_client.dart';

class HealthService {
  final ApiClient _apiClient;

  const HealthService(this._apiClient);

  Future<String> checkHealth() async {
    final response = await _apiClient.get('/health');
    if (response is Map<String, dynamic> && response.containsKey('status')) {
      return response['status'] as String;
    }
    return 'ok';
  }
}
