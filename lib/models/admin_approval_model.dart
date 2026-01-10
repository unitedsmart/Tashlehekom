class PendingCar {
  final String id;
  final String userId;
  final String userName;
  final String userPhone;
  final String brand;
  final String model;
  final int year;
  final String city;
  final double price;
  final String condition;
  final String description;
  final List<String> images;
  final DateTime submittedAt;
  final ApprovalStatus status;
  final String? adminNotes;
  final String? rejectionReason;
  final DateTime? reviewedAt;
  final String? reviewedBy;

  PendingCar({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.brand,
    required this.model,
    required this.year,
    required this.city,
    required this.price,
    required this.condition,
    required this.description,
    required this.images,
    required this.submittedAt,
    this.status = ApprovalStatus.pending,
    this.adminNotes,
    this.rejectionReason,
    this.reviewedAt,
    this.reviewedBy,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'brand': brand,
      'model': model,
      'year': year,
      'city': city,
      'price': price,
      'condition': condition,
      'description': description,
      'images': images.join(','),
      'submittedAt': submittedAt.toIso8601String(),
      'status': status.toString().split('.').last,
      'adminNotes': adminNotes,
      'rejectionReason': rejectionReason,
      'reviewedAt': reviewedAt?.toIso8601String(),
      'reviewedBy': reviewedBy,
    };
  }

  factory PendingCar.fromJson(Map<String, dynamic> json) {
    return PendingCar(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      userPhone: json['userPhone'],
      brand: json['brand'],
      model: json['model'],
      year: json['year'],
      city: json['city'],
      price: json['price'].toDouble(),
      condition: json['condition'],
      description: json['description'],
      images: json['images'].toString().split(',').where((s) => s.isNotEmpty).toList(),
      submittedAt: DateTime.parse(json['submittedAt']),
      status: ApprovalStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => ApprovalStatus.pending,
      ),
      adminNotes: json['adminNotes'],
      rejectionReason: json['rejectionReason'],
      reviewedAt: json['reviewedAt'] != null ? DateTime.parse(json['reviewedAt']) : null,
      reviewedBy: json['reviewedBy'],
    );
  }
}

enum ApprovalStatus {
  pending,
  approved,
  rejected,
  needsRevision,
}

class AdminUser {
  final String id;
  final String name;
  final String phone;
  final String email;
  final AdminRole role;
  final List<AdminPermission> permissions;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  AdminUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.role,
    required this.permissions,
    this.isActive = true,
    required this.createdAt,
    this.lastLoginAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'role': role.toString().split('.').last,
      'permissions': permissions.map((p) => p.toString().split('.').last).join(','),
      'isActive': isActive ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      role: AdminRole.values.firstWhere(
        (e) => e.toString().split('.').last == json['role'],
        orElse: () => AdminRole.moderator,
      ),
      permissions: json['permissions'].toString().split(',')
          .where((s) => s.isNotEmpty)
          .map((p) => AdminPermission.values.firstWhere(
                (e) => e.toString().split('.').last == p,
                orElse: () => AdminPermission.viewCars,
              ))
          .toList(),
      isActive: json['isActive'] == 1,
      createdAt: DateTime.parse(json['createdAt']),
      lastLoginAt: json['lastLoginAt'] != null ? DateTime.parse(json['lastLoginAt']) : null,
    );
  }
}

enum AdminRole {
  superAdmin,
  admin,
  moderator,
  reviewer,
}

enum AdminPermission {
  viewCars,
  approveCars,
  rejectCars,
  editCars,
  deleteCars,
  manageUsers,
  viewReports,
  manageSettings,
  viewAnalytics,
  manageAdmins,
}

class ApprovalAction {
  final String id;
  final String pendingCarId;
  final String adminId;
  final String adminName;
  final ApprovalStatus action;
  final String? notes;
  final String? rejectionReason;
  final DateTime actionDate;

  ApprovalAction({
    required this.id,
    required this.pendingCarId,
    required this.adminId,
    required this.adminName,
    required this.action,
    this.notes,
    this.rejectionReason,
    required this.actionDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pendingCarId': pendingCarId,
      'adminId': adminId,
      'adminName': adminName,
      'action': action.toString().split('.').last,
      'notes': notes,
      'rejectionReason': rejectionReason,
      'actionDate': actionDate.toIso8601String(),
    };
  }

  factory ApprovalAction.fromJson(Map<String, dynamic> json) {
    return ApprovalAction(
      id: json['id'],
      pendingCarId: json['pendingCarId'],
      adminId: json['adminId'],
      adminName: json['adminName'],
      action: ApprovalStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['action'],
        orElse: () => ApprovalStatus.pending,
      ),
      notes: json['notes'],
      rejectionReason: json['rejectionReason'],
      actionDate: DateTime.parse(json['actionDate']),
    );
  }
}

class AdminStats {
  final int totalPendingCars;
  final int totalApprovedCars;
  final int totalRejectedCars;
  final int todaySubmissions;
  final int todayApprovals;
  final int todayRejections;
  final double averageApprovalTime; // in hours
  final List<String> topBrands;
  final List<String> topCities;

  AdminStats({
    required this.totalPendingCars,
    required this.totalApprovedCars,
    required this.totalRejectedCars,
    required this.todaySubmissions,
    required this.todayApprovals,
    required this.todayRejections,
    required this.averageApprovalTime,
    required this.topBrands,
    required this.topCities,
  });
}
