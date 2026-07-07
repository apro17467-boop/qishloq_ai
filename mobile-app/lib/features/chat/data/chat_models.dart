import 'package:qishloq_ai_mobile/core/network/api_response.dart';

class ChatUserSummary {
  final String id;
  final String fullName;
  final String role;
  final bool isVerified;

  const ChatUserSummary({
    required this.id,
    required this.fullName,
    required this.role,
    required this.isVerified,
  });

  factory ChatUserSummary.fromJson(Map<String, dynamic> json) {
    return ChatUserSummary(
      id: json['id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? 'Foydalanuvchi',
      role: json['role'] as String? ?? 'FARMER',
      isVerified: json['isVerified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'role': role,
      'isVerified': isVerified,
    };
  }

  String get roleLabel {
    switch (role) {
      case 'FARMER':
        return 'Fermer';
      case 'LIVESTOCK_OWNER':
        return 'Chorvador';
      case 'MACHINERY_OWNER':
        return 'Texnika egasi';
      case 'BUYER':
        return 'Xaridor';
      case 'AGRONOMIST':
        return 'Agronom';
      case 'VETERINARIAN':
        return 'Veterinar';
      case 'ADMIN':
        return 'Admin';
      default:
        return role;
    }
  }
}

class ChatListingSummary {
  final String id;
  final String title;
  final String type;
  final String? priceAmount;
  final String? priceCurrency;
  final String? unit;
  final String status;

  const ChatListingSummary({
    required this.id,
    required this.title,
    required this.type,
    this.priceAmount,
    this.priceCurrency,
    this.unit,
    required this.status,
  });

  factory ChatListingSummary.fromJson(Map<String, dynamic> json) {
    return ChatListingSummary(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      type: json['type'] as String? ?? '',
      priceAmount: json['priceAmount']?.toString(),
      priceCurrency: json['priceCurrency'] as String?,
      unit: json['unit'] as String?,
      status: json['status'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'priceAmount': priceAmount,
      'priceCurrency': priceCurrency,
      'unit': unit,
      'status': status,
    };
  }

  String get typeLabel {
    switch (type) {
      case 'MACHINERY_RENT':
        return 'Texnika ijarasi';
      case 'PRODUCT_SALE':
        return 'Dehqon mahsulotlari';
      case 'LIVESTOCK_SALE':
        return 'Chorva savdosi';
      case 'MACHINERY_SALE':
        return 'Texnika savdosi';
      case 'SERVICE':
        return 'Agro xizmatlar';
      default:
        return type;
    }
  }

  String get formattedPrice {
    if (priceAmount == null || priceAmount!.isEmpty) {
      return 'Narx kelishiladi';
    }
    final currency = priceCurrency ?? 'UZS';
    if (unit == null || unit!.isEmpty) {
      return '$priceAmount $currency';
    }
    return '$priceAmount $currency / $unit';
  }
}

class ChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final String body;
  final String createdAt;
  final String? readAt;

  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.body,
    required this.createdAt,
    this.readAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String? ?? '',
      conversationId: json['conversationId'] as String? ?? '',
      senderId: json['senderId'] as String? ?? '',
      body: json['body'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      readAt: json['readAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'body': body,
      'createdAt': createdAt,
      'readAt': readAt,
    };
  }

  String get formattedTime {
    try {
      final dateTime = DateTime.parse(createdAt).toLocal();
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } catch (_) {
      return '';
    }
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

class ConversationSummary {
  final String id;
  final ChatListingSummary listing;
  final ChatUserSummary buyer;
  final ChatUserSummary seller;
  final ChatUserSummary? otherParticipant;
  final ChatMessage? lastMessage;
  final int unreadCount;
  final String createdAt;
  final String updatedAt;

  const ConversationSummary({
    required this.id,
    required this.listing,
    required this.buyer,
    required this.seller,
    this.otherParticipant,
    this.lastMessage,
    required this.unreadCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ConversationSummary.fromJson(Map<String, dynamic> json) {
    return ConversationSummary(
      id: json['id'] as String? ?? '',
      listing: ChatListingSummary.fromJson(json['listing'] as Map<String, dynamic>? ?? {}),
      buyer: ChatUserSummary.fromJson(json['buyer'] as Map<String, dynamic>? ?? {}),
      seller: ChatUserSummary.fromJson(json['seller'] as Map<String, dynamic>? ?? {}),
      otherParticipant: json['otherParticipant'] != null
          ? ChatUserSummary.fromJson(json['otherParticipant'] as Map<String, dynamic>)
          : null,
      lastMessage: json['lastMessage'] != null
          ? ChatMessage.fromJson(json['lastMessage'] as Map<String, dynamic>)
          : null,
      unreadCount: json['unreadCount'] as int? ?? 0,
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'listing': listing.toJson(),
      'buyer': buyer.toJson(),
      'seller': seller.toJson(),
      'otherParticipant': otherParticipant?.toJson(),
      'lastMessage': lastMessage?.toJson(),
      'unreadCount': unreadCount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  String get formattedUpdatedAt {
    try {
      final dateTime = DateTime.parse(updatedAt).toLocal();
      final day = dateTime.day.toString().padLeft(2, '0');
      final month = dateTime.month.toString().padLeft(2, '0');
      final year = dateTime.year;
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$day.$month.$year $hour:$minute';
    } catch (_) {
      return updatedAt;
    }
  }
}

class ConversationListResponse {
  final List<ConversationSummary> data;
  final PaginatedMeta meta;

  const ConversationListResponse({
    required this.data,
    required this.meta,
  });

  factory ConversationListResponse.fromJson(Map<String, dynamic> json) {
    final list = json['data'] as List<dynamic>? ?? [];
    final items = list
        .map((item) => ConversationSummary.fromJson(item as Map<String, dynamic>))
        .toList();
    final metaData = json['meta'] as Map<String, dynamic>? ?? {};

    return ConversationListResponse(
      data: items,
      meta: PaginatedMeta.fromJson(metaData),
    );
  }
}

class MessageListResponse {
  final List<ChatMessage> data;
  final PaginatedMeta meta;

  const MessageListResponse({
    required this.data,
    required this.meta,
  });

  factory MessageListResponse.fromJson(Map<String, dynamic> json) {
    final list = json['data'] as List<dynamic>? ?? [];
    final items = list
        .map((item) => ChatMessage.fromJson(item as Map<String, dynamic>))
        .toList();
    final metaData = json['meta'] as Map<String, dynamic>? ?? {};

    return MessageListResponse(
      data: items,
      meta: PaginatedMeta.fromJson(metaData),
    );
  }
}
