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

  Future<ListingListResponse> getMyListings({
    int page = 1,
    int limit = 10,
    String? status,
    String? type,
  }) async {
    final Map<String, dynamic> queryParameters = {
      'page': page,
      'limit': limit,
    };

    if (status != null && status.isNotEmpty) {
      queryParameters['status'] = status;
    }
    if (type != null && type.isNotEmpty) {
      queryParameters['type'] = type;
    }

    final response = await _apiClient.get('/listings/my', queryParameters: queryParameters);
    if (response is Map<String, dynamic>) {
      return ListingListResponse.fromJson(response);
    }
    throw Exception('Mening e\'lonlarimni yuklashda xatolik yuz berdi');
  }

  Future<Listing> getListingDetail(String id) async {
    final response = await _apiClient.get('/listings/$id');
    if (response is Map<String, dynamic>) {
      if (response.containsKey('data')) {
        return Listing.fromJson(response['data'] as Map<String, dynamic>);
      }
      return Listing.fromJson(response);
    }
    throw Exception('E’lon tafsilotlarini yuklashda xatolik yuz berdi');
  }

  Future<Listing> createListing(CreateListingRequest request) async {
    final response = await _apiClient.post('/listings', data: request.toJson());
    if (response is Map<String, dynamic>) {
      final createResponse = CreateListingResponse.fromJson(response);
      return createResponse.data;
    }
    throw Exception('E’lon yaratishda xatolik yuz berdi');
  }

  Future<ListingImage> uploadListingImage({
    required String listingId,
    required String filePath,
    String? fileName,
  }) async {
    final response = await _apiClient.uploadFile(
      '/listings/$listingId/images',
      fieldName: 'image',
      filePath: filePath,
      fileName: fileName,
    );
    if (response is Map<String, dynamic>) {
      final uploadResponse = UploadListingImageResponse.fromJson(response);
      return uploadResponse.data;
    }
    throw Exception('Rasm yuklashda xatolik yuz berdi');
  }
}
