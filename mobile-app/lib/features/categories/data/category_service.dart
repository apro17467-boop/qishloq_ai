import 'package:qishloq_ai_mobile/core/network/api_client.dart';
import 'package:qishloq_ai_mobile/features/categories/data/category_models.dart';

class CategoryService {
  final ApiClient _apiClient;

  CategoryService(this._apiClient);

  Future<List<Category>> getCategories() async {
    final response = await _apiClient.get('/reference/categories');
    if (response is Map<String, dynamic> && response.containsKey('data')) {
      final data = response['data'] as List<dynamic>;
      return data.map((json) => Category.fromJson(json as Map<String, dynamic>)).toList();
    }
    throw Exception('Kategoriyalarni yuklashda xatolik yuz berdi');
  }
}
