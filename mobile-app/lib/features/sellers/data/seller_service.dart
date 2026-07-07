import 'package:qishloq_ai_mobile/core/network/api_client.dart';
import 'package:qishloq_ai_mobile/features/listings/data/listing_models.dart';
import 'package:qishloq_ai_mobile/features/sellers/data/seller_models.dart';

class SellerService {
  final ApiClient _apiClient;

  SellerService(this._apiClient);

  Future<SellerProfile> getSellerProfile(String sellerId) async {
    final response = await _apiClient.get('/sellers/$sellerId');
    if (response is Map<String, dynamic>) {
      final data = response['data'] as Map<String, dynamic>? ?? response;
      return SellerProfile.fromJson(data);
    }
    throw Exception('E’lon egasi profilini yuklashda xatolik yuz berdi');
  }

  Future<ListingListResponse> getSellerListings({
    required String sellerId,
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _apiClient.get(
      '/sellers/$sellerId/listings',
      queryParameters: {'page': page, 'limit': limit},
    );
    if (response is Map<String, dynamic>) {
      return ListingListResponse.fromJson(response);
    }
    throw Exception('E’lon egasining e’lonlarini yuklashda xatolik yuz berdi');
  }
}
