import 'package:qishloq_ai_mobile/core/network/api_client.dart';
import 'package:qishloq_ai_mobile/features/chat/data/chat_models.dart';

class ChatService {
  final ApiClient _apiClient;

  ChatService(this._apiClient);

  Future<ConversationSummary> createConversation(String listingId) async {
    final response = await _apiClient.post(
      '/conversations',
      data: {'listingId': listingId},
    );
    if (response is Map<String, dynamic>) {
      final data = response['data'] as Map<String, dynamic>? ?? response;
      return ConversationSummary.fromJson(data);
    }
    throw Exception('Suhbat yaratishda xatolik yuz berdi');
  }

  Future<ConversationListResponse> getMyConversations({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _apiClient.get(
      '/conversations/my',
      queryParameters: {'page': page, 'limit': limit},
    );
    if (response is Map<String, dynamic>) {
      return ConversationListResponse.fromJson(response);
    }
    throw Exception('Suhbatlar ro‘yxatini yuklashda xatolik yuz berdi');
  }

  Future<MessageListResponse> getMessages({
    required String conversationId,
    int page = 1,
    int limit = 30,
  }) async {
    final response = await _apiClient.get(
      '/conversations/$conversationId/messages',
      queryParameters: {'page': page, 'limit': limit},
    );
    if (response is Map<String, dynamic>) {
      return MessageListResponse.fromJson(response);
    }
    throw Exception('Xabarlar ro‘yxatini yuklashda xatolik yuz berdi');
  }

  Future<ChatMessage> sendMessage({
    required String conversationId,
    required String body,
  }) async {
    final response = await _apiClient.post(
      '/conversations/$conversationId/messages',
      data: {'body': body},
    );
    if (response is Map<String, dynamic>) {
      final data = response['data'] as Map<String, dynamic>? ?? response;
      return ChatMessage.fromJson(data);
    }
    throw Exception('Xabar yuborishda xatolik yuz berdi');
  }
}
