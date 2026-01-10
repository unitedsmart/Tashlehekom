class FavoriteModel {
  final String id;
  final String userId;
  final String carId;
  final DateTime createdAt;

  FavoriteModel({
    required this.id,
    required this.userId,
    required this.carId,
    required this.createdAt,
  });

  factory FavoriteModel.fromMap(Map<String, dynamic> map) {
    return FavoriteModel(
      id: map['id'],
      userId: map['user_id'],
      carId: map['car_id'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'car_id': carId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class SavedSearchModel {
  final String id;
  final String userId;
  final String name;
  final Map<String, dynamic> searchCriteria;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastNotified;

  SavedSearchModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.searchCriteria,
    this.isActive = true,
    required this.createdAt,
    this.lastNotified,
  });

  factory SavedSearchModel.fromMap(Map<String, dynamic> map) {
    return SavedSearchModel(
      id: map['id'],
      userId: map['user_id'],
      name: map['name'],
      searchCriteria: Map<String, dynamic>.from(map['search_criteria']),
      isActive: map['is_active'] == 1,
      createdAt: DateTime.parse(map['created_at']),
      lastNotified: map['last_notified'] != null 
          ? DateTime.parse(map['last_notified']) 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'search_criteria': searchCriteria,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'last_notified': lastNotified?.toIso8601String(),
    };
  }
}
