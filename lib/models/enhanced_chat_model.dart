import 'package:flutter/foundation.dart';

/// نموذج المحادثة المحسن
class EnhancedChat {
  final String id;
  final String carId;
  final String buyerId;
  final String sellerId;
  final String buyerName;
  final String sellerName;
  final String? buyerAvatar;
  final String? sellerAvatar;
  final String carTitle;
  final String? carImage;
  final List<ChatMessage> messages;
  final DateTime createdAt;
  final DateTime lastMessageAt;
  final ChatStatus status;
  final bool isReadByBuyer;
  final bool isReadBySeller;
  final Map<String, dynamic> metadata;

  const EnhancedChat({
    required this.id,
    required this.carId,
    required this.buyerId,
    required this.sellerId,
    required this.buyerName,
    required this.sellerName,
    required this.carTitle,
    required this.messages,
    required this.createdAt,
    required this.lastMessageAt,
    required this.status,
    required this.isReadByBuyer,
    required this.isReadBySeller,
    this.buyerAvatar,
    this.sellerAvatar,
    this.carImage,
    this.metadata = const {},
  });

  factory EnhancedChat.fromMap(Map<String, dynamic> map) {
    return EnhancedChat(
      id: map['id'] ?? '',
      carId: map['carId'] ?? '',
      buyerId: map['buyerId'] ?? '',
      sellerId: map['sellerId'] ?? '',
      buyerName: map['buyerName'] ?? '',
      sellerName: map['sellerName'] ?? '',
      buyerAvatar: map['buyerAvatar'],
      sellerAvatar: map['sellerAvatar'],
      carTitle: map['carTitle'] ?? '',
      carImage: map['carImage'],
      messages: (map['messages'] as List<dynamic>?)
              ?.map((m) => ChatMessage.fromMap(m))
              .toList() ??
          [],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      lastMessageAt: DateTime.fromMillisecondsSinceEpoch(map['lastMessageAt'] ?? 0),
      status: ChatStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => ChatStatus.active,
      ),
      isReadByBuyer: map['isReadByBuyer'] ?? false,
      isReadBySeller: map['isReadBySeller'] ?? false,
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'carId': carId,
      'buyerId': buyerId,
      'sellerId': sellerId,
      'buyerName': buyerName,
      'sellerName': sellerName,
      'buyerAvatar': buyerAvatar,
      'sellerAvatar': sellerAvatar,
      'carTitle': carTitle,
      'carImage': carImage,
      'messages': messages.map((m) => m.toMap()).toList(),
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastMessageAt': lastMessageAt.millisecondsSinceEpoch,
      'status': status.name,
      'isReadByBuyer': isReadByBuyer,
      'isReadBySeller': isReadBySeller,
      'metadata': metadata,
    };
  }

  EnhancedChat copyWith({
    String? id,
    String? carId,
    String? buyerId,
    String? sellerId,
    String? buyerName,
    String? sellerName,
    String? buyerAvatar,
    String? sellerAvatar,
    String? carTitle,
    String? carImage,
    List<ChatMessage>? messages,
    DateTime? createdAt,
    DateTime? lastMessageAt,
    ChatStatus? status,
    bool? isReadByBuyer,
    bool? isReadBySeller,
    Map<String, dynamic>? metadata,
  }) {
    return EnhancedChat(
      id: id ?? this.id,
      carId: carId ?? this.carId,
      buyerId: buyerId ?? this.buyerId,
      sellerId: sellerId ?? this.sellerId,
      buyerName: buyerName ?? this.buyerName,
      sellerName: sellerName ?? this.sellerName,
      buyerAvatar: buyerAvatar ?? this.buyerAvatar,
      sellerAvatar: sellerAvatar ?? this.sellerAvatar,
      carTitle: carTitle ?? this.carTitle,
      carImage: carImage ?? this.carImage,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      status: status ?? this.status,
      isReadByBuyer: isReadByBuyer ?? this.isReadByBuyer,
      isReadBySeller: isReadBySeller ?? this.isReadBySeller,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// رسالة الدردشة
class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final MessageType type;
  final String content;
  final Map<String, dynamic>? attachments;
  final DateTime timestamp;
  final MessageStatus status;
  final String? replyToMessageId;
  final bool isEdited;
  final DateTime? editedAt;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.type,
    required this.content,
    required this.timestamp,
    required this.status,
    this.senderAvatar,
    this.attachments,
    this.replyToMessageId,
    this.isEdited = false,
    this.editedAt,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      senderAvatar: map['senderAvatar'],
      type: MessageType.values.firstWhere(
        (t) => t.name == map['type'],
        orElse: () => MessageType.text,
      ),
      content: map['content'] ?? '',
      attachments: map['attachments'] != null
          ? Map<String, dynamic>.from(map['attachments'])
          : null,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
      status: MessageStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => MessageStatus.sent,
      ),
      replyToMessageId: map['replyToMessageId'],
      isEdited: map['isEdited'] ?? false,
      editedAt: map['editedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['editedAt'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
      'type': type.name,
      'content': content,
      'attachments': attachments,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'status': status.name,
      'replyToMessageId': replyToMessageId,
      'isEdited': isEdited,
      'editedAt': editedAt?.millisecondsSinceEpoch,
    };
  }
}

/// حالة المحادثة
enum ChatStatus {
  active,
  archived,
  blocked,
  completed,
}

/// نوع الرسالة
enum MessageType {
  text,
  image,
  voice,
  location,
  contact,
  file,
  offer,
  system,
}

/// حالة الرسالة
enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
}

/// عرض سعر
class PriceOffer {
  final String id;
  final String chatId;
  final String senderId;
  final double originalPrice;
  final double offeredPrice;
  final String? message;
  final DateTime createdAt;
  final OfferStatus status;
  final DateTime? respondedAt;

  const PriceOffer({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.originalPrice,
    required this.offeredPrice,
    required this.createdAt,
    required this.status,
    this.message,
    this.respondedAt,
  });

  factory PriceOffer.fromMap(Map<String, dynamic> map) {
    return PriceOffer(
      id: map['id'] ?? '',
      chatId: map['chatId'] ?? '',
      senderId: map['senderId'] ?? '',
      originalPrice: (map['originalPrice'] ?? 0).toDouble(),
      offeredPrice: (map['offeredPrice'] ?? 0).toDouble(),
      message: map['message'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      status: OfferStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => OfferStatus.pending,
      ),
      respondedAt: map['respondedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['respondedAt'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'originalPrice': originalPrice,
      'offeredPrice': offeredPrice,
      'message': message,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'status': status.name,
      'respondedAt': respondedAt?.millisecondsSinceEpoch,
    };
  }
}

/// حالة العرض
enum OfferStatus {
  pending,
  accepted,
  rejected,
  countered,
}
