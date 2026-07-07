import 'package:flutter/material.dart';
import 'package:qishloq_ai_mobile/core/network/api_response.dart';

// ---------------------------------------------------------------------------
// AiQuestion model
// ---------------------------------------------------------------------------
class AiQuestion {
  final String id;
  final String question;
  final String? answer;
  final String status; // PENDING | ANSWERED | FAILED
  final bool disclaimerShown;
  final String createdAt;
  final String? updatedAt;

  AiQuestion({
    required this.id,
    required this.question,
    this.answer,
    required this.status,
    required this.disclaimerShown,
    required this.createdAt,
    this.updatedAt,
  });

  factory AiQuestion.fromJson(Map<String, dynamic> json) {
    return AiQuestion(
      id: json['id'] as String? ?? '',
      question: json['question'] as String? ?? '',
      answer: json['answer'] as String?,
      status: json['status'] as String? ?? 'PENDING',
      disclaimerShown: json['disclaimerShown'] as bool? ?? false,
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'status': status,
      'disclaimerShown': disclaimerShown,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

// ---------------------------------------------------------------------------
// Create question request
// ---------------------------------------------------------------------------
class CreateAiQuestionRequest {
  final String question;

  CreateAiQuestionRequest({required this.question});

  Map<String, dynamic> toJson() => {'question': question};
}

// ---------------------------------------------------------------------------
// Create question response: { data: {...}, message: "..." }
// ---------------------------------------------------------------------------
class CreateAiQuestionResponse {
  final AiQuestion data;
  final String? message;

  CreateAiQuestionResponse({required this.data, this.message});

  factory CreateAiQuestionResponse.fromJson(Map<String, dynamic> json) {
    return CreateAiQuestionResponse(
      data: AiQuestion.fromJson(json['data'] as Map<String, dynamic>? ?? {}),
      message: json['message'] as String?,
    );
  }
}

// ---------------------------------------------------------------------------
// My questions paginated response: { data: [...], meta: {...} }
// ---------------------------------------------------------------------------
class MyAiQuestionsResponse {
  final List<AiQuestion> data;
  final PaginatedMeta meta;

  MyAiQuestionsResponse({required this.data, required this.meta});

  factory MyAiQuestionsResponse.fromJson(Map<String, dynamic> json) {
    final list = json['data'] as List<dynamic>? ?? [];
    final items = list
        .map((item) => AiQuestion.fromJson(item as Map<String, dynamic>))
        .toList();
    final metaData = json['meta'] as Map<String, dynamic>? ?? {};

    return MyAiQuestionsResponse(
      data: items,
      meta: PaginatedMeta.fromJson(metaData),
    );
  }
}

// ---------------------------------------------------------------------------
// Extension helpers
// ---------------------------------------------------------------------------
extension AiQuestionHelpers on AiQuestion {
  String get statusLabel {
    switch (status) {
      case 'ANSWERED':
        return 'Javob berilgan';
      case 'PENDING':
        return 'Kutilmoqda';
      case 'FAILED':
        return 'Xatolik';
      default:
        return status;
    }
  }

  Color get statusColor {
    switch (status) {
      case 'ANSWERED':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'FAILED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData get statusIcon {
    switch (status) {
      case 'ANSWERED':
        return Icons.check_circle_outline;
      case 'PENDING':
        return Icons.hourglass_empty;
      case 'FAILED':
        return Icons.error_outline;
      default:
        return Icons.help_outline;
    }
  }

  String get disclaimerText {
    return disclaimerShown
        ? 'Ogohlantirish ko\'rsatilgan'
        : 'Ogohlantirish ko\'rsatilmagan';
  }

  String get formattedDate {
    try {
      final dateTime = DateTime.parse(createdAt).toLocal();
      final day = dateTime.day.toString().padLeft(2, '0');
      final month = dateTime.month.toString().padLeft(2, '0');
      final year = dateTime.year;
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$day.$month.$year $hour:$minute';
    } catch (_) {
      return createdAt;
    }
  }
}
