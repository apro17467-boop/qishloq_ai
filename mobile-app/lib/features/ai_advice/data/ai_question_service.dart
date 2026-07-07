import 'package:qishloq_ai_mobile/core/network/api_client.dart';
import 'package:qishloq_ai_mobile/features/ai_advice/data/ai_question_models.dart';

class AiQuestionService {
  final ApiClient _apiClient;

  AiQuestionService(this._apiClient);

  /// POST /ai/questions
  /// Body: { "question": "..." }
  /// Auth: Bearer token (avtomatik)
  Future<AiQuestion> createQuestion({required String question}) async {
    final request = CreateAiQuestionRequest(question: question);
    final response = await _apiClient.post('/ai/questions', data: request.toJson());
    if (response is Map<String, dynamic>) {
      final createResponse = CreateAiQuestionResponse.fromJson(response);
      return createResponse.data;
    }
    throw Exception('Savol yuborishda xatolik yuz berdi');
  }

  /// GET /ai/questions/my
  /// Query: page, limit, status (optional)
  Future<MyAiQuestionsResponse> getMyQuestions({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    final Map<String, dynamic> queryParameters = {
      'page': page,
      'limit': limit,
    };

    if (status != null && status.isNotEmpty) {
      queryParameters['status'] = status;
    }

    final response = await _apiClient.get(
      '/ai/questions/my',
      queryParameters: queryParameters,
    );
    if (response is Map<String, dynamic>) {
      return MyAiQuestionsResponse.fromJson(response);
    }
    throw Exception('AI savollarni yuklashda xatolik yuz berdi');
  }
}
