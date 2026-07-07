import 'package:qishloq_ai_mobile/core/network/api_client.dart';
import 'package:qishloq_ai_mobile/features/listings/data/listing_models.dart';

class FavoriteService {
  final ApiClient _apiClient;

  FavoriteService(this._apiClient);

  Future<List<String>> getFavoriteIds() async {
    final response = await _apiClient.get('/favorites/ids');
    if (response is Map<String, dynamic>) {
      final list = response['data'] as List<dynamic>? ?? [];
      return list.map((item) => item.toString()).toList();
    }
    throw Exception('Sevimli e’lon IDlarini yuklashda xatolik yuz berdi');
  }

  Future<ListingListResponse> getMyFavorites({
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _apiClient.get(
      '/favorites/my',
      queryParameters: {'page': page, 'limit': limit},
    );
    if (response is Map<String, dynamic>) {
      return ListingListResponse.fromJson(response);
    }
    throw Exception('Sevimlilarni yuklashda xatolik yuz berdi');
  }

  Future<void> addFavorite(String listingId) async {
    await _apiClient.post('/favorites/$listingId');
  }

  Future<void> removeFavorite(String listingId) async {
    await _apiClient.delete('/favorites/$listingId');
  }
}
