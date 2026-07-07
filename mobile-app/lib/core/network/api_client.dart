import 'package:dio/dio.dart';
import 'package:qishloq_ai_mobile/core/config/app_config.dart';
import 'package:qishloq_ai_mobile/core/network/api_exception.dart';
import 'package:qishloq_ai_mobile/core/storage/token_storage.dart';

class ApiClient {
  final Dio _dio;
  final TokenStorage tokenStorage;

  ApiClient({
    required this.tokenStorage,
    Dio? dio,
  })  : _dio = dio ?? Dio() {
    _dio.options.baseUrl = AppConfig.apiBaseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.options.receiveTimeout = const Duration(seconds: 15);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await tokenStorage.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<dynamic> post(String path, {Object? data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<dynamic> patch(String path, {Object? data}) async {
    try {
      final response = await _dio.patch(path, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<dynamic> uploadFile(
    String path, {
    required String fieldName,
    required String filePath,
    String? fileName,
    Map<String, dynamic>? data,
  }) async {
    try {
      final file = await MultipartFile.fromFile(
        filePath,
        filename: fileName,
      );
      
      final formData = FormData.fromMap({
        fieldName: file,
        ...?data,
      });

      final response = await _dio.post(
        path,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  ApiException _handleDioException(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return const ApiException(
        message: 'Server bilan bog‘lanish vaqti tugadi',
        statusCode: 408,
      );
    }

    if (e.type == DioExceptionType.connectionError) {
      return const ApiException(
        message: 'Server bilan bog‘lanib bo‘lmadi',
        statusCode: 503,
      );
    }

    final response = e.response;
    if (response != null) {
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return ApiException.fromJson(data, response.statusCode);
      }
      return ApiException(
        message: 'Tizimda xatolik yuz berdi (${response.statusCode})',
        statusCode: response.statusCode,
      );
    }

    return const ApiException(
      message: 'Internet aloqasini tekshiring',
    );
  }
}
