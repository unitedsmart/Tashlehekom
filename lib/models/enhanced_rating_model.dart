import 'package:flutter/foundation.dart';

/// نموذج التقييم المحسن
class EnhancedRating {
  final String id;
  final String raterId;
  final String raterName;
  final String? raterAvatar;
  final String ratedUserId;
  final String ratedUserName;
  final String? ratedUserAvatar;
  final String carId;
  final String carTitle;
  final double overallRating;
  final Map<String, double> categoryRatings;
  final String? comment;
  final List<String> images;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isVerified;
  final RatingStatus status;
  final Map<String, dynamic> metadata;

  const EnhancedRating({
    required this.id,
    required this.raterId,
    required this.raterName,
    required this.ratedUserId,
    required this.ratedUserName,
    required this.carId,
    required this.carTitle,
    required this.overallRating,
    required this.categoryRatings,
    required this.createdAt,
    required this.status,
    this.raterAvatar,
    this.ratedUserAvatar,
    this.comment,
    this.images = const [],
    this.updatedAt,
    this.isVerified = false,
    this.metadata = const {},
  });

  factory EnhancedRating.fromMap(Map<String, dynamic> map) {
    return EnhancedRating(
      id: map['id'] ?? '',
      raterId: map['raterId'] ?? '',
      raterName: map['raterName'] ?? '',
      raterAvatar: map['raterAvatar'],
      ratedUserId: map['ratedUserId'] ?? '',
      ratedUserName: map['ratedUserName'] ?? '',
      ratedUserAvatar: map['ratedUserAvatar'],
      carId: map['carId'] ?? '',
      carTitle: map['carTitle'] ?? '',
      overallRating: (map['overallRating'] ?? 0).toDouble(),
      categoryRatings: Map<String, double>.from(
        (map['categoryRatings'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
        ) ?? {},
      ),
      comment: map['comment'],
      images: List<String>.from(map['images'] ?? []),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : null,
      isVerified: map['isVerified'] ?? false,
      status: RatingStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => RatingStatus.active,
      ),
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'raterId': raterId,
      'raterName': raterName,
      'raterAvatar': raterAvatar,
      'ratedUserId': ratedUserId,
      'ratedUserName': ratedUserName,
      'ratedUserAvatar': ratedUserAvatar,
      'carId': carId,
      'carTitle': carTitle,
      'overallRating': overallRating,
      'categoryRatings': categoryRatings,
      'comment': comment,
      'images': images,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'isVerified': isVerified,
      'status': status.name,
      'metadata': metadata,
    };
  }

  EnhancedRating copyWith({
    String? id,
    String? raterId,
    String? raterName,
    String? raterAvatar,
    String? ratedUserId,
    String? ratedUserName,
    String? ratedUserAvatar,
    String? carId,
    String? carTitle,
    double? overallRating,
    Map<String, double>? categoryRatings,
    String? comment,
    List<String>? images,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isVerified,
    RatingStatus? status,
    Map<String, dynamic>? metadata,
  }) {
    return EnhancedRating(
      id: id ?? this.id,
      raterId: raterId ?? this.raterId,
      raterName: raterName ?? this.raterName,
      raterAvatar: raterAvatar ?? this.raterAvatar,
      ratedUserId: ratedUserId ?? this.ratedUserId,
      ratedUserName: ratedUserName ?? this.ratedUserName,
      ratedUserAvatar: ratedUserAvatar ?? this.ratedUserAvatar,
      carId: carId ?? this.carId,
      carTitle: carTitle ?? this.carTitle,
      overallRating: overallRating ?? this.overallRating,
      categoryRatings: categoryRatings ?? this.categoryRatings,
      comment: comment ?? this.comment,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isVerified: isVerified ?? this.isVerified,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// إحصائيات التقييم
class RatingStats {
  final double averageRating;
  final int totalRatings;
  final Map<int, int> ratingDistribution;
  final Map<String, double> categoryAverages;
  final List<String> topPositiveComments;
  final List<String> topNegativeComments;
  final DateTime lastUpdated;

  const RatingStats({
    required this.averageRating,
    required this.totalRatings,
    required this.ratingDistribution,
    required this.categoryAverages,
    required this.topPositiveComments,
    required this.topNegativeComments,
    required this.lastUpdated,
  });

  factory RatingStats.fromMap(Map<String, dynamic> map) {
    return RatingStats(
      averageRating: (map['averageRating'] ?? 0).toDouble(),
      totalRatings: map['totalRatings'] ?? 0,
      ratingDistribution: Map<int, int>.from(
        (map['ratingDistribution'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(int.parse(key), value as int),
        ) ?? {},
      ),
      categoryAverages: Map<String, double>.from(
        (map['categoryAverages'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
        ) ?? {},
      ),
      topPositiveComments: List<String>.from(map['topPositiveComments'] ?? []),
      topNegativeComments: List<String>.from(map['topNegativeComments'] ?? []),
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(map['lastUpdated'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'averageRating': averageRating,
      'totalRatings': totalRatings,
      'ratingDistribution': ratingDistribution.map(
        (key, value) => MapEntry(key.toString(), value),
      ),
      'categoryAverages': categoryAverages,
      'topPositiveComments': topPositiveComments,
      'topNegativeComments': topNegativeComments,
      'lastUpdated': lastUpdated.millisecondsSinceEpoch,
    };
  }
}

/// فئات التقييم
enum RatingCategory {
  communication('التواصل'),
  reliability('الموثوقية'),
  carCondition('حالة السيارة'),
  pricing('السعر'),
  delivery('التسليم'),
  overall('التقييم العام');

  const RatingCategory(this.displayName);
  final String displayName;
}

/// حالة التقييم
enum RatingStatus {
  active,
  hidden,
  reported,
  verified,
}

/// نموذج الرد على التقييم
class RatingReply {
  final String id;
  final String ratingId;
  final String replierId;
  final String replierName;
  final String? replierAvatar;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isOwnerReply;

  const RatingReply({
    required this.id,
    required this.ratingId,
    required this.replierId,
    required this.replierName,
    required this.content,
    required this.createdAt,
    required this.isOwnerReply,
    this.replierAvatar,
    this.updatedAt,
  });

  factory RatingReply.fromMap(Map<String, dynamic> map) {
    return RatingReply(
      id: map['id'] ?? '',
      ratingId: map['ratingId'] ?? '',
      replierId: map['replierId'] ?? '',
      replierName: map['replierName'] ?? '',
      replierAvatar: map['replierAvatar'],
      content: map['content'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : null,
      isOwnerReply: map['isOwnerReply'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ratingId': ratingId,
      'replierId': replierId,
      'replierName': replierName,
      'replierAvatar': replierAvatar,
      'content': content,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'isOwnerReply': isOwnerReply,
    };
  }
}

/// نموذج تقرير التقييم
class RatingReport {
  final String id;
  final String ratingId;
  final String reporterId;
  final String reporterName;
  final ReportReason reason;
  final String? description;
  final DateTime createdAt;
  final ReportStatus status;
  final String? adminResponse;
  final DateTime? resolvedAt;

  const RatingReport({
    required this.id,
    required this.ratingId,
    required this.reporterId,
    required this.reporterName,
    required this.reason,
    required this.createdAt,
    required this.status,
    this.description,
    this.adminResponse,
    this.resolvedAt,
  });

  factory RatingReport.fromMap(Map<String, dynamic> map) {
    return RatingReport(
      id: map['id'] ?? '',
      ratingId: map['ratingId'] ?? '',
      reporterId: map['reporterId'] ?? '',
      reporterName: map['reporterName'] ?? '',
      reason: ReportReason.values.firstWhere(
        (r) => r.name == map['reason'],
        orElse: () => ReportReason.inappropriate,
      ),
      description: map['description'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      status: ReportStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => ReportStatus.pending,
      ),
      adminResponse: map['adminResponse'],
      resolvedAt: map['resolvedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['resolvedAt'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ratingId': ratingId,
      'reporterId': reporterId,
      'reporterName': reporterName,
      'reason': reason.name,
      'description': description,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'status': status.name,
      'adminResponse': adminResponse,
      'resolvedAt': resolvedAt?.millisecondsSinceEpoch,
    };
  }
}

/// أسباب التبليغ
enum ReportReason {
  inappropriate('محتوى غير مناسب'),
  spam('رسائل مزعجة'),
  fake('تقييم مزيف'),
  offensive('محتوى مسيء'),
  other('أخرى');

  const ReportReason(this.displayName);
  final String displayName;
}

/// حالة التبليغ
enum ReportStatus {
  pending,
  reviewed,
  resolved,
  dismissed,
}
