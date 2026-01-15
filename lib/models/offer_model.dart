import 'package:cloud_firestore/cloud_firestore.dart';

/// نموذج عرض سعر من تشليح
class Offer {
  final String id;
  final String requestId; // رقم الطلب
  final String shopId; // معرف التشليح
  final String shopName; // اسم التشليح
  final String shopPhone; // رقم التشليح
  final bool isVerified; // هل التشليح موثق؟
  final double price; // السعر
  final String? description; // وصف العرض
  final String? warranty; // الضمان
  final String? deliveryInfo; // معلومات التوصيل
  final List<String> images; // صور القطعة المعروضة
  final OfferStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Offer({
    required this.id,
    required this.requestId,
    required this.shopId,
    required this.shopName,
    required this.shopPhone,
    this.isVerified = false,
    required this.price,
    this.description,
    this.warranty,
    this.deliveryInfo,
    this.images = const [],
    this.status = OfferStatus.pending,
    required this.createdAt,
    this.updatedAt,
  });

  factory Offer.fromMap(Map<String, dynamic> map, String id) {
    return Offer(
      id: id,
      requestId: map['requestId'] ?? '',
      shopId: map['shopId'] ?? '',
      shopName: map['shopName'] ?? '',
      shopPhone: map['shopPhone'] ?? '',
      isVerified: map['isVerified'] ?? false,
      price: (map['price'] ?? 0).toDouble(),
      description: map['description'],
      warranty: map['warranty'],
      deliveryInfo: map['deliveryInfo'],
      images: List<String>.from(map['images'] ?? []),
      status: OfferStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => OfferStatus.pending,
      ),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'requestId': requestId,
      'shopId': shopId,
      'shopName': shopName,
      'shopPhone': shopPhone,
      'isVerified': isVerified,
      'price': price,
      'description': description,
      'warranty': warranty,
      'deliveryInfo': deliveryInfo,
      'images': images,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  Offer copyWith({
    String? id,
    String? requestId,
    String? shopId,
    String? shopName,
    String? shopPhone,
    bool? isVerified,
    double? price,
    String? description,
    String? warranty,
    String? deliveryInfo,
    List<String>? images,
    OfferStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Offer(
      id: id ?? this.id,
      requestId: requestId ?? this.requestId,
      shopId: shopId ?? this.shopId,
      shopName: shopName ?? this.shopName,
      shopPhone: shopPhone ?? this.shopPhone,
      isVerified: isVerified ?? this.isVerified,
      price: price ?? this.price,
      description: description ?? this.description,
      warranty: warranty ?? this.warranty,
      deliveryInfo: deliveryInfo ?? this.deliveryInfo,
      images: images ?? this.images,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// حالة العرض
enum OfferStatus {
  pending, // قيد الانتظار
  accepted, // مقبول
  rejected, // مرفوض
  expired, // منتهي
}

extension OfferStatusExtension on OfferStatus {
  String get displayName {
    switch (this) {
      case OfferStatus.pending:
        return 'قيد الانتظار';
      case OfferStatus.accepted:
        return 'مقبول';
      case OfferStatus.rejected:
        return 'مرفوض';
      case OfferStatus.expired:
        return 'منتهي';
    }
  }
}

