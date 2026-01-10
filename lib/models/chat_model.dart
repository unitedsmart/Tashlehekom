class ChatModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String? carId; // السيارة المرتبطة بالمحادثة
  final DateTime createdAt;
  final DateTime? lastMessageAt;
  final bool isActive;

  ChatModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    this.carId,
    required this.createdAt,
    this.lastMessageAt,
    this.isActive = true,
  });

  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
      id: map['id'],
      senderId: map['sender_id'],
      receiverId: map['receiver_id'],
      carId: map['car_id'],
      createdAt: DateTime.parse(map['created_at']),
      lastMessageAt: map['last_message_at'] != null 
          ? DateTime.parse(map['last_message_at']) 
          : null,
      isActive: map['is_active'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'car_id': carId,
      'created_at': createdAt.toIso8601String(),
      'last_message_at': lastMessageAt?.toIso8601String(),
      'is_active': isActive ? 1 : 0,
    };
  }
}

class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String content;
  final MessageType type;
  final String? attachmentUrl;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;

  MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    this.type = MessageType.text,
    this.attachmentUrl,
    this.isRead = false,
    required this.createdAt,
    this.readAt,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'],
      chatId: map['chat_id'],
      senderId: map['sender_id'],
      content: map['content'],
      type: MessageType.values[map['type']],
      attachmentUrl: map['attachment_url'],
      isRead: map['is_read'] == 1,
      createdAt: DateTime.parse(map['created_at']),
      readAt: map['read_at'] != null ? DateTime.parse(map['read_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chat_id': chatId,
      'sender_id': senderId,
      'content': content,
      'type': type.index,
      'attachment_url': attachmentUrl,
      'is_read': isRead ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
    };
  }
}

enum MessageType {
  text,
  image,
  audio,
  location,
  contact,
}
