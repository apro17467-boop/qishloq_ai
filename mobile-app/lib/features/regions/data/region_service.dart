import 'package:qishloq_ai_mobile/core/network/api_client.dart';
import 'package:qishloq_ai_mobile/features/regions/data/region_models.dart';

class RegionService {
  final ApiClient _apiClient;

  RegionService(this._apiClient);

  Future<List<Region>> getRegions() async {
    final response = await _apiClient.get('/reference/regions');
    if (response is Map<String, dynamic> && response.containsKey('data')) {
      final list = response['data'] as List<dynamic>? ?? [];
      return list.map((item) => Region.fromJson(item as Map<String, dynamic>)).toList();
    }
    throw Exception('Hududlarni yuklashda xatolik yuz berdi');
  }
}
