class UserModel {
  final String id;
  final String username;
  final String name; // إضافة name للتوافق مع Firebase
  final String phoneNumber;
  final String? email; // إضافة email للتوافق مع Firebase
  final UserType userType;
  final String? city;
  final bool isActive;
  final bool isApproved;
  final String? junkyard; // للعامل - اسم التشليح
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.username,
    required this.name,
    required this.phoneNumber,
    required this.userType,
    required this.createdAt,
    this.email,
    this.city,
    this.isActive = true,
    this.isApproved = false,
    this.junkyard,
    this.updatedAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      username: map['username'],
      name: map['name'] ?? map['username'], // استخدام username كـ fallback
      phoneNumber: map['phone_number'],
      email: map['email'],
      userType: UserType.values[map['user_type']],
      city: map['city'],
      isActive: map['is_active'] == 1,
      isApproved: map['is_approved'] == 1,
      junkyard: map['junkyard'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt:
          map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'phone_number': phoneNumber,
      'email': email,
      'user_type': userType.index,
      'city': city,
      'is_active': isActive ? 1 : 0,
      'is_approved': isApproved ? 1 : 0,
      'junkyard': junkyard,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? username,
    String? name,
    String? phoneNumber,
    String? email,
    UserType? userType,
    String? city,
    bool? isActive,
    bool? isApproved,
    String? junkyard,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      userType: userType ?? this.userType,
      city: city ?? this.city,
      isActive: isActive ?? this.isActive,
      isApproved: isApproved ?? this.isApproved,
      junkyard: junkyard ?? this.junkyard,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum UserType {
  user, // مستخدم عادي
  seller, // بائع
  individual, // فرد (مشتري/بائع)
  worker, // عامل
  admin, // مدير
  junkyardOwner, // مالك تشليح
  superAdmin, // مدير النظام
}

extension UserTypeExtension on UserType {
  String get displayName {
    switch (this) {
      case UserType.user:
        return 'مستخدم';
      case UserType.seller:
        return 'بائع';
      case UserType.individual:
        return 'فرد';
      case UserType.worker:
        return 'عامل';
      case UserType.admin:
        return 'مدير';
      case UserType.junkyardOwner:
        return 'مالك تشليح';
      case UserType.superAdmin:
        return 'مدير النظام';
    }
  }
}
