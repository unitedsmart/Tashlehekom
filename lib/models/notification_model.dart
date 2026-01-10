class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final NotificationType type;
  final String? relatedId; // ID السيارة أو المستخدم المرتبط
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.relatedId,
    this.data,
    this.isRead = false,
    required this.createdAt,
    this.readAt,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'],
      userId: map['user_id'],
      title: map['title'],
      body: map['body'],
      type: NotificationType.values[map['type']],
      relatedId: map['related_id'],
      data: map['data'] != null ? Map<String, dynamic>.from(map['data']) : null,
      isRead: map['is_read'] == 1,
      createdAt: DateTime.parse(map['created_at']),
      readAt: map['read_at'] != null ? DateTime.parse(map['read_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'body': body,
      'type': type.index,
      'related_id': relatedId,
      'data': data,
      'is_read': isRead ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
    };
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    NotificationType? type,
    String? relatedId,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? createdAt,
    DateTime? readAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      relatedId: relatedId ?? this.relatedId,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
    );
  }
}

enum NotificationType {
  newCar, // سيارة جديدة
  carSold, // تم بيع السيارة
  newMessage, // رسالة جديدة
  newRating, // تقييم جديد
  accountApproved, // تم الموافقة على الحساب
  accountRejected, // تم رفض الحساب
  systemUpdate, // تحديث النظام
  priceChange, // تغيير السعر
  carExpired, // انتهاء صلاحية الإعلان
  reminder, // تذكير
}
