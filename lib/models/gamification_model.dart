import 'package:flutter/foundation.dart';

/// نموذج نقاط الولاء
class LoyaltyPoints {
  final String id;
  final String userId;
  final int totalPoints;
  final int availablePoints;
  final int usedPoints;
  final List<PointTransaction> transactions;
  final LoyaltyTier tier;
  final DateTime lastUpdated;
  final Map<String, int> categoryPoints;
  final List<String> achievements;

  const LoyaltyPoints({
    required this.id,
    required this.userId,
    required this.totalPoints,
    required this.availablePoints,
    required this.usedPoints,
    required this.transactions,
    required this.tier,
    required this.lastUpdated,
    required this.categoryPoints,
    required this.achievements,
  });

  factory LoyaltyPoints.fromJson(Map<String, dynamic> json) {
    return LoyaltyPoints(
      id: json['id'],
      userId: json['userId'],
      totalPoints: json['totalPoints'],
      availablePoints: json['availablePoints'],
      usedPoints: json['usedPoints'],
      transactions: (json['transactions'] as List)
          .map((t) => PointTransaction.fromJson(t))
          .toList(),
      tier: LoyaltyTier.values[json['tier']],
      lastUpdated: DateTime.parse(json['lastUpdated']),
      categoryPoints: Map<String, int>.from(json['categoryPoints']),
      achievements: List<String>.from(json['achievements']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'totalPoints': totalPoints,
      'availablePoints': availablePoints,
      'usedPoints': usedPoints,
      'transactions': transactions.map((t) => t.toJson()).toList(),
      'tier': tier.index,
      'lastUpdated': lastUpdated.toIso8601String(),
      'categoryPoints': categoryPoints,
      'achievements': achievements,
    };
  }
}

/// معاملة النقاط
class PointTransaction {
  final String id;
  final TransactionType type;
  final int points;
  final String reason;
  final DateTime timestamp;
  final String? referenceId;
  final Map<String, dynamic> metadata;

  const PointTransaction({
    required this.id,
    required this.type,
    required this.points,
    required this.reason,
    required this.timestamp,
    this.referenceId,
    required this.metadata,
  });

  factory PointTransaction.fromJson(Map<String, dynamic> json) {
    return PointTransaction(
      id: json['id'],
      type: TransactionType.values[json['type']],
      points: json['points'],
      reason: json['reason'],
      timestamp: DateTime.parse(json['timestamp']),
      referenceId: json['referenceId'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.index,
      'points': points,
      'reason': reason,
      'timestamp': timestamp.toIso8601String(),
      'referenceId': referenceId,
      'metadata': metadata,
    };
  }
}

/// أنواع معاملات النقاط
enum TransactionType {
  earned,
  spent,
  bonus,
  penalty,
  expired,
  refund
}

/// مستويات الولاء
enum LoyaltyTier {
  bronze,
  silver,
  gold,
  platinum,
  diamond,
  vip
}

/// نموذج التحدي اليومي
class DailyChallenge {
  final String id;
  final String title;
  final String description;
  final ChallengeType type;
  final int targetValue;
  final int rewardPoints;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> participants;
  final Map<String, int> progress;
  final ChallengeDifficulty difficulty;
  final List<String> requirements;

  const DailyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.targetValue,
    required this.rewardPoints,
    required this.startDate,
    required this.endDate,
    required this.participants,
    required this.progress,
    required this.difficulty,
    required this.requirements,
  });

  factory DailyChallenge.fromJson(Map<String, dynamic> json) {
    return DailyChallenge(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: ChallengeType.values[json['type']],
      targetValue: json['targetValue'],
      rewardPoints: json['rewardPoints'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      participants: List<String>.from(json['participants']),
      progress: Map<String, int>.from(json['progress']),
      difficulty: ChallengeDifficulty.values[json['difficulty']],
      requirements: List<String>.from(json['requirements']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.index,
      'targetValue': targetValue,
      'rewardPoints': rewardPoints,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'participants': participants,
      'progress': progress,
      'difficulty': difficulty.index,
      'requirements': requirements,
    };
  }
}

/// أنواع التحديات
enum ChallengeType {
  search,
  view,
  share,
  review,
  purchase,
  social,
  learning,
  streak
}

/// صعوبة التحدي
enum ChallengeDifficulty {
  easy,
  medium,
  hard,
  expert,
  legendary
}

/// نموذج المسابقة التفاعلية
class InteractiveContest {
  final String id;
  final String title;
  final String description;
  final ContestType type;
  final DateTime startTime;
  final DateTime endTime;
  final List<ContestPrize> prizes;
  final List<String> participants;
  final Map<String, dynamic> rules;
  final ContestStatus status;
  final String? winnerId;
  final Map<String, int> leaderboard;

  const InteractiveContest({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.startTime,
    required this.endTime,
    required this.prizes,
    required this.participants,
    required this.rules,
    required this.status,
    this.winnerId,
    required this.leaderboard,
  });

  factory InteractiveContest.fromJson(Map<String, dynamic> json) {
    return InteractiveContest(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: ContestType.values[json['type']],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      prizes: (json['prizes'] as List)
          .map((p) => ContestPrize.fromJson(p))
          .toList(),
      participants: List<String>.from(json['participants']),
      rules: json['rules'],
      status: ContestStatus.values[json['status']],
      winnerId: json['winnerId'],
      leaderboard: Map<String, int>.from(json['leaderboard']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.index,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'prizes': prizes.map((p) => p.toJson()).toList(),
      'participants': participants,
      'rules': rules,
      'status': status.index,
      'winnerId': winnerId,
      'leaderboard': leaderboard,
    };
  }
}

/// أنواع المسابقات
enum ContestType {
  quiz,
  prediction,
  photo,
  review,
  referral,
  treasure,
  trivia,
  creative
}

/// حالة المسابقة
enum ContestStatus {
  upcoming,
  active,
  ended,
  cancelled,
  judging
}

/// جائزة المسابقة
class ContestPrize {
  final String id;
  final String name;
  final PrizeType type;
  final dynamic value;
  final int position;
  final String description;
  final String? imageUrl;

  const ContestPrize({
    required this.id,
    required this.name,
    required this.type,
    required this.value,
    required this.position,
    required this.description,
    this.imageUrl,
  });

  factory ContestPrize.fromJson(Map<String, dynamic> json) {
    return ContestPrize(
      id: json['id'],
      name: json['name'],
      type: PrizeType.values[json['type']],
      value: json['value'],
      position: json['position'],
      description: json['description'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.index,
      'value': value,
      'position': position,
      'description': description,
      'imageUrl': imageUrl,
    };
  }
}

/// أنواع الجوائز
enum PrizeType {
  points,
  cash,
  discount,
  product,
  service,
  badge,
  title,
  access
}

/// نموذج الإنجاز
class Achievement {
  final String id;
  final String title;
  final String description;
  final AchievementType type;
  final String iconUrl;
  final int pointsReward;
  final List<String> requirements;
  final AchievementRarity rarity;
  final DateTime? unlockedAt;
  final bool isUnlocked;
  final double progress;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.iconUrl,
    required this.pointsReward,
    required this.requirements,
    required this.rarity,
    this.unlockedAt,
    required this.isUnlocked,
    required this.progress,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: AchievementType.values[json['type']],
      iconUrl: json['iconUrl'],
      pointsReward: json['pointsReward'],
      requirements: List<String>.from(json['requirements']),
      rarity: AchievementRarity.values[json['rarity']],
      unlockedAt: json['unlockedAt'] != null 
          ? DateTime.parse(json['unlockedAt']) 
          : null,
      isUnlocked: json['isUnlocked'],
      progress: json['progress'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.index,
      'iconUrl': iconUrl,
      'pointsReward': pointsReward,
      'requirements': requirements,
      'rarity': rarity.index,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'isUnlocked': isUnlocked,
      'progress': progress,
    };
  }
}

/// أنواع الإنجازات
enum AchievementType {
  activity,
  social,
  purchase,
  milestone,
  special,
  seasonal,
  competitive,
  exploration
}

/// ندرة الإنجاز
enum AchievementRarity {
  common,
  uncommon,
  rare,
  epic,
  legendary,
  mythic
}
