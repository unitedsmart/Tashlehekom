import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tashlehekomv2/services/logging_service.dart';
import 'package:tashlehekomv2/services/enhanced_error_handler.dart';
import 'package:tashlehekomv2/services/performance_service.dart';
import 'package:tashlehekomv2/services/enhanced_cache_service.dart';
import 'package:tashlehekomv2/models/gamification_models.dart';

/// خدمة الألعاب والمكافآت
class GamificationService {
  static final GamificationService _instance = GamificationService._internal();
  factory GamificationService() => _instance;
  GamificationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final EnhancedCacheService _cache = EnhancedCacheService();

  /// الحصول على ملف المستخدم الشخصي للألعاب
  Future<UserGameProfile> getUserGameProfile(String userId) async {
    final result =
        await EnhancedErrorHandler.executeWithErrorHandling<UserGameProfile>(
      () async {
        return PerformanceService.measureAsync('get_user_game_profile',
            () async {
          final cacheKey = 'user_game_profile_$userId';

          // التحقق من التخزين المؤقت
          final cachedProfile =
              await _cache.get<Map<String, dynamic>>(cacheKey);
          if (cachedProfile != null) {
            return UserGameProfile.fromMap(cachedProfile);
          }

          // جلب من قاعدة البيانات
          final doc = await _firestore
              .collection('user_game_profiles')
              .doc(userId)
              .get();

          UserGameProfile profile;
          if (doc.exists) {
            profile = UserGameProfile.fromMap(doc.data()!);
          } else {
            // إنشاء ملف جديد
            profile = UserGameProfile.createNew(userId);
            await _firestore
                .collection('user_game_profiles')
                .doc(userId)
                .set(profile.toMap());
          }

          // حفظ في التخزين المؤقت
          await _cache.set(
            cacheKey,
            profile.toMap(),
            expiration: const Duration(minutes: 30),
          );

          return profile;
        });
      },
      'جلب ملف المستخدم الشخصي للألعاب',
    );
    return result ?? UserGameProfile.createNew(userId);
  }

  /// إضافة نقاط للمستخدم
  Future<void> addPoints({
    required String userId,
    required int points,
    required String reason,
    String? actionType,
  }) async {
    return EnhancedErrorHandler.executeWithErrorHandling(
      () async {
        await PerformanceService.measureAsync('add_points', () async {
          final profile = await getUserGameProfile(userId);

          // إضافة النقاط
          final updatedProfile = profile.copyWith(
            totalPoints: profile.totalPoints + points,
            currentLevelPoints: profile.currentLevelPoints + points,
          );

          // التحقق من ترقية المستوى
          final leveledUpProfile = _checkLevelUp(updatedProfile);

          // حفظ التحديث
          await _firestore
              .collection('user_game_profiles')
              .doc(userId)
              .update(leveledUpProfile.toMap());

          // تسجيل النشاط
          await _logActivity(
            userId: userId,
            activityType: ActivityType.pointsEarned,
            points: points,
            description: reason,
            metadata: {'actionType': actionType},
          );

          // إزالة من التخزين المؤقت
          await _cache.remove('user_game_profile_$userId');

          // إشعار بالترقية إذا حدثت
          if (leveledUpProfile.level > profile.level) {
            await _notifyLevelUp(userId, leveledUpProfile.level);
          }

          LoggingService.success('تم إضافة $points نقطة للمستخدم $userId');
        });
      },
      'إضافة النقاط',
    );
  }

  /// إنجاز مهمة
  Future<void> completeAchievement({
    required String userId,
    required String achievementId,
  }) async {
    return EnhancedErrorHandler.executeWithErrorHandling(
      () async {
        await PerformanceService.measureAsync('complete_achievement', () async {
          final profile = await getUserGameProfile(userId);

          // التحقق من عدم إنجاز المهمة مسبقاً
          if (profile.achievements.contains(achievementId)) {
            LoggingService.warning(
                'المهمة $achievementId مُنجزة مسبقاً للمستخدم $userId');
            return;
          }

          // الحصول على تفاصيل المهمة
          final achievement = await _getAchievementDetails(achievementId);
          if (achievement == null) {
            LoggingService.error('المهمة $achievementId غير موجودة');
            return;
          }

          // إضافة المهمة والنقاط
          final updatedProfile = profile.copyWith(
            achievements: [...profile.achievements, achievementId],
            totalPoints: profile.totalPoints + achievement.points,
            currentLevelPoints: profile.currentLevelPoints + achievement.points,
          );

          // التحقق من ترقية المستوى
          final leveledUpProfile = _checkLevelUp(updatedProfile);

          // حفظ التحديث
          await _firestore
              .collection('user_game_profiles')
              .doc(userId)
              .update(leveledUpProfile.toMap());

          // تسجيل النشاط
          await _logActivity(
            userId: userId,
            activityType: ActivityType.achievementUnlocked,
            points: achievement.points,
            description: 'إنجاز: ${achievement.title}',
            metadata: {'achievementId': achievementId},
          );

          // إزالة من التخزين المؤقت
          await _cache.remove('user_game_profile_$userId');

          LoggingService.success(
              'تم إنجاز المهمة $achievementId للمستخدم $userId');
        });
      },
      'إنجاز المهمة',
    );
  }

  /// الحصول على قائمة المتصدرين
  Future<List<LeaderboardEntry>> getLeaderboard({
    LeaderboardType type = LeaderboardType.totalPoints,
    int limit = 50,
  }) async {
    final result = await EnhancedErrorHandler.executeWithErrorHandling<
        List<LeaderboardEntry>>(
      () async {
        return PerformanceService.measureAsync('get_leaderboard', () async {
          final cacheKey = 'leaderboard_${type.name}_$limit';

          // التحقق من التخزين المؤقت
          final cachedLeaderboard = await _cache.get<List<dynamic>>(cacheKey);
          if (cachedLeaderboard != null) {
            return cachedLeaderboard
                .map((item) => LeaderboardEntry.fromMap(item))
                .toList();
          }

          // جلب من قاعدة البيانات
          String orderByField;
          switch (type) {
            case LeaderboardType.totalPoints:
              orderByField = 'totalPoints';
              break;
            case LeaderboardType.level:
              orderByField = 'level';
              break;
            case LeaderboardType.achievements:
              orderByField = 'achievementsCount';
              break;
          }

          final snapshot = await _firestore
              .collection('user_game_profiles')
              .orderBy(orderByField, descending: true)
              .limit(limit)
              .get();

          final leaderboard = snapshot.docs.asMap().entries.map((entry) {
            final index = entry.key;
            final doc = entry.value;
            final data = doc.data();

            return LeaderboardEntry(
              rank: index + 1,
              userId: doc.id,
              username: data['username'] ?? 'مستخدم',
              avatar: data['avatar'],
              points: data['totalPoints'] ?? 0,
              level: data['level'] ?? 1,
              achievementsCount: (data['achievements'] as List?)?.length ?? 0,
            );
          }).toList();

          // حفظ في التخزين المؤقت
          await _cache.set(
            cacheKey,
            leaderboard.map((entry) => entry.toMap()).toList(),
            expiration: const Duration(minutes: 15),
          );

          return leaderboard;
        });
      },
      'جلب قائمة المتصدرين',
    );
    return result ?? [];
  }

  /// الحصول على المهام المتاحة
  Future<List<Achievement>> getAvailableAchievements(String userId) async {
    final result =
        await EnhancedErrorHandler.executeWithErrorHandling<List<Achievement>>(
      () async {
        return PerformanceService.measureAsync('get_available_achievements',
            () async {
          final profile = await getUserGameProfile(userId);

          // جلب جميع المهام
          final snapshot = await _firestore.collection('achievements').get();
          final allAchievements = snapshot.docs
              .map((doc) => Achievement.fromMap({...doc.data(), 'id': doc.id}))
              .toList();

          // فلترة المهام غير المُنجزة
          final availableAchievements = allAchievements
              .where((achievement) =>
                  !profile.achievements.contains(achievement.id))
              .toList();

          return availableAchievements;
        });
      },
      'جلب المهام المتاحة',
    );
    return result ?? [];
  }

  /// الحصول على أنشطة المستخدم
  Future<List<GameActivity>> getUserActivities(String userId,
      {int limit = 20}) async {
    final result =
        await EnhancedErrorHandler.executeWithErrorHandling<List<GameActivity>>(
      () async {
        return PerformanceService.measureAsync('get_user_activities', () async {
          final snapshot = await _firestore
              .collection('game_activities')
              .where('userId', isEqualTo: userId)
              .orderBy('timestamp', descending: true)
              .limit(limit)
              .get();

          return snapshot.docs
              .map((doc) => GameActivity.fromMap({...doc.data(), 'id': doc.id}))
              .toList();
        });
      },
      'جلب أنشطة المستخدم',
    );
    return result ?? [];
  }

  /// إنشاء تحدي يومي
  Future<DailyChallenge> createDailyChallenge() async {
    final result =
        await EnhancedErrorHandler.executeWithErrorHandling<DailyChallenge>(
      () async {
        final today = DateTime.now();
        final challengeId = 'daily_${today.year}_${today.month}_${today.day}';

        // التحقق من وجود تحدي اليوم
        final existingDoc = await _firestore
            .collection('daily_challenges')
            .doc(challengeId)
            .get();
        if (existingDoc.exists) {
          return DailyChallenge.fromMap(
              {...existingDoc.data()!, 'id': challengeId});
        }

        // إنشاء تحدي جديد
        final challenges = [
          ChallengeTemplate(
            title: 'مستكشف السيارات',
            description: 'شاهد 10 سيارات مختلفة',
            target: 10,
            points: 50,
            type: ChallengeType.viewCars,
          ),
          ChallengeTemplate(
            title: 'باحث نشط',
            description: 'قم بـ 5 عمليات بحث',
            target: 5,
            points: 30,
            type: ChallengeType.search,
          ),
          ChallengeTemplate(
            title: 'متواصل اجتماعي',
            description: 'أرسل 3 رسائل',
            target: 3,
            points: 40,
            type: ChallengeType.sendMessages,
          ),
        ];

        final randomChallenge = challenges[Random().nextInt(challenges.length)];

        final dailyChallenge = DailyChallenge(
          id: challengeId,
          title: randomChallenge.title,
          description: randomChallenge.description,
          target: randomChallenge.target,
          points: randomChallenge.points,
          type: randomChallenge.type,
          date: today,
          isActive: true,
        );

        await _firestore
            .collection('daily_challenges')
            .doc(challengeId)
            .set(dailyChallenge.toMap());

        return dailyChallenge;
      },
      'إنشاء تحدي يومي',
    );
    return result ?? DailyChallenge.empty();
  }

  /// تتبع تقدم التحدي اليومي
  Future<void> trackChallengeProgress({
    required String userId,
    required ChallengeType challengeType,
    int increment = 1,
  }) async {
    return EnhancedErrorHandler.executeWithErrorHandling(
      () async {
        final today = DateTime.now();
        final challengeId = 'daily_${today.year}_${today.month}_${today.day}';

        // الحصول على التحدي اليومي
        final challengeDoc = await _firestore
            .collection('daily_challenges')
            .doc(challengeId)
            .get();
        if (!challengeDoc.exists) return;

        final challenge = DailyChallenge.fromMap(
            {...challengeDoc.data()!, 'id': challengeId});
        if (challenge.type != challengeType) return;

        // تحديث التقدم
        final progressId = '${challengeId}_$userId';
        final progressDoc = await _firestore
            .collection('challenge_progress')
            .doc(progressId)
            .get();

        int currentProgress = 0;
        if (progressDoc.exists) {
          currentProgress = progressDoc.data()?['progress'] ?? 0;
        }

        final newProgress = currentProgress + increment;

        await _firestore.collection('challenge_progress').doc(progressId).set({
          'userId': userId,
          'challengeId': challengeId,
          'progress': newProgress,
          'completed': newProgress >= challenge.target,
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        // إذا تم إكمال التحدي، إضافة النقاط
        if (newProgress >= challenge.target &&
            currentProgress < challenge.target) {
          await addPoints(
            userId: userId,
            points: challenge.points,
            reason: 'إكمال التحدي اليومي: ${challenge.title}',
            actionType: 'daily_challenge',
          );
        }
      },
      'تتبع تقدم التحدي',
    );
  }

  // الطرق المساعدة
  UserGameProfile _checkLevelUp(UserGameProfile profile) {
    final pointsForNextLevel = _getPointsRequiredForLevel(profile.level + 1);

    if (profile.currentLevelPoints >= pointsForNextLevel) {
      return profile.copyWith(
        level: profile.level + 1,
        currentLevelPoints: profile.currentLevelPoints - pointsForNextLevel,
      );
    }

    return profile;
  }

  int _getPointsRequiredForLevel(int level) {
    // معادلة تصاعدية للنقاط المطلوبة
    return (level * 100) + ((level - 1) * 50);
  }

  Future<Achievement?> _getAchievementDetails(String achievementId) async {
    final doc =
        await _firestore.collection('achievements').doc(achievementId).get();
    if (!doc.exists) return null;

    return Achievement.fromMap({...doc.data()!, 'id': achievementId});
  }

  Future<void> _logActivity({
    required String userId,
    required ActivityType activityType,
    required int points,
    required String description,
    Map<String, dynamic>? metadata,
  }) async {
    await _firestore.collection('game_activities').add({
      'userId': userId,
      'activityType': activityType.name,
      'points': points,
      'description': description,
      'metadata': metadata ?? {},
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _notifyLevelUp(String userId, int newLevel) async {
    // إرسال إشعار ترقية المستوى
    LoggingService.success('المستخدم $userId ترقى إلى المستوى $newLevel');

    // يمكن إضافة إشعارات push هنا
  }
}
