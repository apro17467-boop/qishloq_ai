import 'package:qishloq_ai_mobile/core/network/api_client.dart';
import 'package:qishloq_ai_mobile/features/listings/data/listing_models.dart';

class ListingService {
  final ApiClient _apiClient;

  ListingService(this._apiClient);

  Future<ListingListResponse> getListings({
    int page = 1,
    int limit = 10,
    String? type,
    String? categoryId,
    String? regionId,
    String? search,
  }) async {
    final Map<String, dynamic> queryParameters = {
      'page': page,
      'limit': limit,
    };

    if (type != null && type.isNotEmpty) {
      queryParameters['type'] = type;
    }
    if (categoryId != null && categoryId.isNotEmpty) {
      queryParameters['categoryId'] = categoryId;
    }
    if (regionId != null && regionId.isNotEmpty) {
      queryParameters['regionId'] = regionId;
    }
    if (search != null && search.isNotEmpty) {
      queryParameters['search'] = search;
    }

    final response = await _apiClient.get('/listings', queryParameters: queryParameters);
    if (response is Map<String, dynamic>) {
      return ListingListResponse.fromJson(response);
    }
    throw Exception('E’lonlarni yuklashda xatolik yuz berdi');
  }
}
