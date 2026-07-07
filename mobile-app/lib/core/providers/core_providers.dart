import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:qishloq_ai_mobile/core/network/api_client.dart';
import 'package:qishloq_ai_mobile/core/storage/token_storage.dart';
import 'package:qishloq_ai_mobile/features/auth/application/auth_controller.dart';
import 'package:qishloq_ai_mobile/features/auth/application/auth_state.dart';
import 'package:qishloq_ai_mobile/features/auth/data/auth_service.dart';
import 'package:qishloq_ai_mobile/features/categories/data/category_service.dart';
import 'package:qishloq_ai_mobile/features/health/data/health_service.dart';
import 'package:qishloq_ai_mobile/features/listings/data/listing_service.dart';
import 'package:qishloq_ai_mobile/features/regions/data/region_service.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return TokenStorage(storage);
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  return ApiClient(tokenStorage: tokenStorage);
});

final healthServiceProvider = Provider<HealthService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return HealthService(apiClient);
});

final authServiceProvider = Provider<AuthService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthService(apiClient);
});

final authControllerProvider = NotifierProvider<AuthController, AuthState>(() {
  return AuthController();
});

final categoryServiceProvider = Provider<CategoryService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CategoryService(apiClient);
});

final listingServiceProvider = Provider<ListingService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ListingService(apiClient);
});

final regionServiceProvider = Provider<RegionService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return RegionService(apiClient);
});
