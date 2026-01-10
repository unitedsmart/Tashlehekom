/// نماذج الألعاب والمكافآت

/// ملف المستخدم الشخصي للألعاب
class UserGameProfile {
  final String userId;
  final String username;
  final String? avatar;
  final int totalPoints;
  final int level;
  final int currentLevelPoints;
  final List<String> achievements;
  final List<String> badges;
  final DateTime joinDate;
  final DateTime lastActive;
  final Map<String, int> statistics;

  const UserGameProfile({
    required this.userId,
    required this.username,
    this.avatar,
    required this.totalPoints,
    required this.level,
    required this.currentLevelPoints,
    required this.achievements,
    required this.badges,
    required this.joinDate,
    required this.lastActive,
    required this.statistics,
  });

  factory UserGameProfile.createNew(String userId) {
    return UserGameProfile(
      userId: userId,
      username: 'مستخدم جديد',
      totalPoints: 0,
      level: 1,
      currentLevelPoints: 0,
      achievements: [],
      badges: [],
      joinDate: DateTime.now(),
      lastActive: DateTime.now(),
      statistics: {},
    );
  }

  factory UserGameProfile.fromMap(Map<String, dynamic> map) {
    return UserGameProfile(
      userId: map['userId'],
      username: map['username'] ?? 'مستخدم',
      avatar: map['avatar'],
      totalPoints: map['totalPoints'] ?? 0,
      level: map['level'] ?? 1,
      currentLevelPoints: map['currentLevelPoints'] ?? 0,
      achievements: List<String>.from(map['achievements'] ?? []),
      badges: List<String>.from(map['badges'] ?? []),
      joinDate: DateTime.parse(map['joinDate']),
      lastActive: DateTime.parse(map['lastActive']),
      statistics: Map<String, int>.from(map['statistics'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'username': username,
      'avatar': avatar,
      'totalPoints': totalPoints,
      'level': level,
      'currentLevelPoints': currentLevelPoints,
      'achievements': achievements,
      'badges': badges,
      'joinDate': joinDate.toIso8601String(),
      'lastActive': lastActive.toIso8601String(),
      'statistics': statistics,
      'achievementsCount': achievements.length,
    };
  }

  UserGameProfile copyWith({
    String? username,
    String? avatar,
    int? totalPoints,
    int? level,
    int? currentLevelPoints,
    List<String>? achievements,
    List<String>? badges,
    DateTime? lastActive,
    Map<String, int>? statistics,
  }) {
    return UserGameProfile(
      userId: userId,
      username: username ?? this.username,
      avatar: avatar ?? this.avatar,
      totalPoints: totalPoints ?? this.totalPoints,
      level: level ?? this.level,
      currentLevelPoints: currentLevelPoints ?? this.currentLevelPoints,
      achievements: achievements ?? this.achievements,
      badges: badges ?? this.badges,
      joinDate: joinDate,
      lastActive: lastActive ?? this.lastActive,
      statistics: statistics ?? this.statistics,
    );
  }

  int get pointsToNextLevel {
    return (level * 100) + ((level - 1) * 50) - currentLevelPoints;
  }

  double get levelProgress {
    final pointsForCurrentLevel = (level * 100) + ((level - 1) * 50);
    return currentLevelPoints / pointsForCurrentLevel;
  }

  String get levelTitle {
    if (level <= 5) return 'مبتدئ';
    if (level <= 10) return 'متوسط';
    if (level <= 20) return 'متقدم';
    if (level <= 35) return 'خبير';
    if (level <= 50) return 'محترف';
    return 'أسطورة';
  }
}

/// إنجاز
class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int points;
  final AchievementCategory category;
  final AchievementRarity rarity;
  final Map<String, dynamic> requirements;
  final bool isHidden;
  final DateTime createdAt;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.points,
    required this.category,
    required this.rarity,
    required this.requirements,
    required this.isHidden,
    required this.createdAt,
  });

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      icon: map['icon'],
      points: map['points'] ?? 0,
      category: AchievementCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => AchievementCategory.general,
      ),
      rarity: AchievementRarity.values.firstWhere(
        (e) => e.name == map['rarity'],
        orElse: () => AchievementRarity.common,
      ),
      requirements: Map<String, dynamic>.from(map['requirements'] ?? {}),
      isHidden: map['isHidden'] ?? false,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'points': points,
      'category': category.name,
      'rarity': rarity.name,
      'requirements': requirements,
      'isHidden': isHidden,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

/// فئات الإنجازات
enum AchievementCategory {
  general('عام'),
  social('اجتماعي'),
  trading('تجاري'),
  exploration('استكشاف'),
  milestone('معلم');

  const AchievementCategory(this.displayName);
  final String displayName;
}

/// ندرة الإنجازات
enum AchievementRarity {
  common('شائع'),
  uncommon('غير شائع'),
  rare('نادر'),
  epic('ملحمي'),
  legendary('أسطوري');

  const AchievementRarity(this.displayName);
  final String displayName;
}

/// مدخل قائمة المتصدرين
class LeaderboardEntry {
  final int rank;
  final String userId;
  final String username;
  final String? avatar;
  final int points;
  final int level;
  final int achievementsCount;

  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.username,
    this.avatar,
    required this.points,
    required this.level,
    required this.achievementsCount,
  });

  factory LeaderboardEntry.fromMap(Map<String, dynamic> map) {
    return LeaderboardEntry(
      rank: map['rank'],
      userId: map['userId'],
      username: map['username'],
      avatar: map['avatar'],
      points: map['points'] ?? 0,
      level: map['level'] ?? 1,
      achievementsCount: map['achievementsCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'rank': rank,
      'userId': userId,
      'username': username,
      'avatar': avatar,
      'points': points,
      'level': level,
      'achievementsCount': achievementsCount,
    };
  }
}

/// نوع قائمة المتصدرين
enum LeaderboardType {
  totalPoints('إجمالي النقاط'),
  level('المستوى'),
  achievements('الإنجازات');

  const LeaderboardType(this.displayName);
  final String displayName;
}

/// نشاط اللعبة
class GameActivity {
  final String id;
  final String userId;
  final ActivityType activityType;
  final int points;
  final String description;
  final Map<String, dynamic> metadata;
  final DateTime timestamp;

  const GameActivity({
    required this.id,
    required this.userId,
    required this.activityType,
    required this.points,
    required this.description,
    required this.metadata,
    required this.timestamp,
  });

  factory GameActivity.fromMap(Map<String, dynamic> map) {
    return GameActivity(
      id: map['id'],
      userId: map['userId'],
      activityType: ActivityType.values.firstWhere(
        (e) => e.name == map['activityType'],
        orElse: () => ActivityType.other,
      ),
      points: map['points'] ?? 0,
      description: map['description'],
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
      timestamp: DateTime.parse(map['timestamp']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'activityType': activityType.name,
      'points': points,
      'description': description,
      'metadata': metadata,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// نوع النشاط
enum ActivityType {
  pointsEarned('كسب نقاط'),
  achievementUnlocked('إنجاز مهمة'),
  levelUp('ترقية مستوى'),
  badgeEarned('كسب شارة'),
  challengeCompleted('إكمال تحدي'),
  other('أخرى');

  const ActivityType(this.displayName);
  final String displayName;
}

/// التحدي اليومي
class DailyChallenge {
  final String id;
  final String title;
  final String description;
  final int target;
  final int points;
  final ChallengeType type;
  final DateTime date;
  final bool isActive;

  const DailyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.target,
    required this.points,
    required this.type,
    required this.date,
    required this.isActive,
  });

  factory DailyChallenge.empty() {
    return DailyChallenge(
      id: '',
      title: '',
      description: '',
      target: 0,
      points: 0,
      type: ChallengeType.viewCars,
      date: DateTime.now(),
      isActive: false,
    );
  }

  factory DailyChallenge.fromMap(Map<String, dynamic> map) {
    return DailyChallenge(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      target: map['target'] ?? 0,
      points: map['points'] ?? 0,
      type: ChallengeType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => ChallengeType.viewCars,
      ),
      date: DateTime.parse(map['date']),
      isActive: map['isActive'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'target': target,
      'points': points,
      'type': type.name,
      'date': date.toIso8601String(),
      'isActive': isActive,
    };
  }
}

/// نوع التحدي
enum ChallengeType {
  viewCars('مشاهدة السيارات'),
  search('البحث'),
  sendMessages('إرسال الرسائل'),
  addCars('إضافة السيارات'),
  shareContent('مشاركة المحتوى');

  const ChallengeType(this.displayName);
  final String displayName;
}

/// قالب التحدي
class ChallengeTemplate {
  final String title;
  final String description;
  final int target;
  final int points;
  final ChallengeType type;

  const ChallengeTemplate({
    required this.title,
    required this.description,
    required this.target,
    required this.points,
    required this.type,
  });
}

/// تقدم التحدي
class ChallengeProgress {
  final String userId;
  final String challengeId;
  final int progress;
  final bool completed;
  final DateTime lastUpdated;

  const ChallengeProgress({
    required this.userId,
    required this.challengeId,
    required this.progress,
    required this.completed,
    required this.lastUpdated,
  });

  factory ChallengeProgress.fromMap(Map<String, dynamic> map) {
    return ChallengeProgress(
      userId: map['userId'],
      challengeId: map['challengeId'],
      progress: map['progress'] ?? 0,
      completed: map['completed'] ?? false,
      lastUpdated: DateTime.parse(map['lastUpdated']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'challengeId': challengeId,
      'progress': progress,
      'completed': completed,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}

/// الشارة
class Badge {
  final String id;
  final String title;
  final String description;
  final String icon;
  final BadgeCategory category;
  final Map<String, dynamic> requirements;
  final DateTime createdAt;

  const Badge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
    required this.requirements,
    required this.createdAt,
  });

  factory Badge.fromMap(Map<String, dynamic> map) {
    return Badge(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      icon: map['icon'],
      category: BadgeCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => BadgeCategory.general,
      ),
      requirements: Map<String, dynamic>.from(map['requirements'] ?? {}),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'category': category.name,
      'requirements': requirements,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

/// فئات الشارات
enum BadgeCategory {
  general('عام'),
  social('اجتماعي'),
  trading('تجاري'),
  loyalty('ولاء'),
  special('خاص');

  const BadgeCategory(this.displayName);
  final String displayName;
}
