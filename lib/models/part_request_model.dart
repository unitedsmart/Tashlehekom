import 'package:cloud_firestore/cloud_firestore.dart';

/// نموذج طلب قطعة غيار
class PartRequest {
  final String id;
  final String userId;
  final String userName;
  final String userPhone;
  final String carBrand; // ماركة السيارة
  final String carModel; // موديل السيارة
  final String? carYear; // سنة الصنع
  final String partName; // اسم القطعة المطلوبة
  final String? partDescription; // وصف إضافي
  final List<String> images; // صور للقطعة المطلوبة
  final String city; // المدينة
  final PartRequestStatus status;
  final int offersCount; // عدد العروض المستلمة
  final DateTime createdAt;
  final DateTime? updatedAt;

  PartRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.carBrand,
    required this.carModel,
    this.carYear,
    required this.partName,
    this.partDescription,
    this.images = const [],
    required this.city,
    this.status = PartRequestStatus.active,
    this.offersCount = 0,
    required this.createdAt,
    this.updatedAt,
  });

  factory PartRequest.fromMap(Map<String, dynamic> map, String id) {
    return PartRequest(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userPhone: map['userPhone'] ?? '',
      carBrand: map['carBrand'] ?? '',
      carModel: map['carModel'] ?? '',
      carYear: map['carYear'],
      partName: map['partName'] ?? '',
      partDescription: map['partDescription'],
      images: List<String>.from(map['images'] ?? []),
      city: map['city'] ?? '',
      status: PartRequestStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => PartRequestStatus.active,
      ),
      offersCount: map['offersCount'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'carBrand': carBrand,
      'carModel': carModel,
      'carYear': carYear,
      'partName': partName,
      'partDescription': partDescription,
      'images': images,
      'city': city,
      'status': status.name,
      'offersCount': offersCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  PartRequest copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userPhone,
    String? carBrand,
    String? carModel,
    String? carYear,
    String? partName,
    String? partDescription,
    List<String>? images,
    String? city,
    PartRequestStatus? status,
    int? offersCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PartRequest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhone: userPhone ?? this.userPhone,
      carBrand: carBrand ?? this.carBrand,
      carModel: carModel ?? this.carModel,
      carYear: carYear ?? this.carYear,
      partName: partName ?? this.partName,
      partDescription: partDescription ?? this.partDescription,
      images: images ?? this.images,
      city: city ?? this.city,
      status: status ?? this.status,
      offersCount: offersCount ?? this.offersCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// حالة الطلب
enum PartRequestStatus {
  active, // نشط - يستقبل عروض
  closed, // مغلق - تم اختيار عرض
  cancelled, // ملغي
  expired, // منتهي الصلاحية
}

extension PartRequestStatusExtension on PartRequestStatus {
  String get displayName {
    switch (this) {
      case PartRequestStatus.active:
        return 'نشط';
      case PartRequestStatus.closed:
        return 'مغلق';
      case PartRequestStatus.cancelled:
        return 'ملغي';
      case PartRequestStatus.expired:
        return 'منتهي';
    }
  }
}

