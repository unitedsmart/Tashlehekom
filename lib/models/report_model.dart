class ReportModel {
  final String id;
  final String reporterId;
  final String? reportedUserId;
  final String? reportedCarId;
  final ReportType type;
  final String reason;
  final String? description;
  final List<String>? attachments;
  final ReportStatus status;
  final String? adminResponse;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  ReportModel({
    required this.id,
    required this.reporterId,
    this.reportedUserId,
    this.reportedCarId,
    required this.type,
    required this.reason,
    this.description,
    this.attachments,
    this.status = ReportStatus.pending,
    this.adminResponse,
    required this.createdAt,
    this.resolvedAt,
  });

  factory ReportModel.fromMap(Map<String, dynamic> map) {
    return ReportModel(
      id: map['id'],
      reporterId: map['reporter_id'],
      reportedUserId: map['reported_user_id'],
      reportedCarId: map['reported_car_id'],
      type: ReportType.values[map['type']],
      reason: map['reason'],
      description: map['description'],
      attachments: map['attachments'] != null 
          ? List<String>.from(map['attachments']) 
          : null,
      status: ReportStatus.values[map['status']],
      adminResponse: map['admin_response'],
      createdAt: DateTime.parse(map['created_at']),
      resolvedAt: map['resolved_at'] != null 
          ? DateTime.parse(map['resolved_at']) 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reporter_id': reporterId,
      'reported_user_id': reportedUserId,
      'reported_car_id': reportedCarId,
      'type': type.index,
      'reason': reason,
      'description': description,
      'attachments': attachments,
      'status': status.index,
      'admin_response': adminResponse,
      'created_at': createdAt.toIso8601String(),
      'resolved_at': resolvedAt?.toIso8601String(),
    };
  }
}

enum ReportType {
  user, // بلاغ على مستخدم
  car, // بلاغ على سيارة
  content, // بلاغ على محتوى
  technical, // مشكلة تقنية
  suggestion, // اقتراح
}

enum ReportStatus {
  pending, // قيد المراجعة
  inProgress, // قيد المعالجة
  resolved, // تم الحل
  rejected, // مرفوض
  closed, // مغلق
}
