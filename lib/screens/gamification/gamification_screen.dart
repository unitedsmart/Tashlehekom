import 'package:flutter/material.dart';
import 'package:tashlehekomv2/services/gamification_service.dart';
import 'package:tashlehekomv2/models/gamification_models.dart';
import 'package:tashlehekomv2/utils/enhanced_animations.dart';
import 'package:tashlehekomv2/widgets/enhanced_card_widget.dart';
import 'package:tashlehekomv2/widgets/stats_card.dart' as stats;
import 'package:tashlehekomv2/utils/app_theme.dart';

class _StatCardData {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  _StatCardData({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
}

/// شاشة الألعاب والمكافآت
class GamificationScreen extends StatefulWidget {
  final String userId;

  const GamificationScreen({
    super.key,
    required this.userId,
  });

  @override
  State<GamificationScreen> createState() => _GamificationScreenState();
}

class _GamificationScreenState extends State<GamificationScreen>
    with TickerProviderStateMixin {
  final GamificationService _gamificationService = GamificationService();

  UserGameProfile? _userProfile;
  List<Achievement> _availableAchievements = [];
  List<LeaderboardEntry> _leaderboard = [];
  List<GameActivity> _recentActivities = [];
  DailyChallenge? _dailyChallenge;

  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadGamificationData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadGamificationData() async {
    setState(() => _isLoading = true);

    try {
      final futures = await Future.wait([
        _gamificationService.getUserGameProfile(widget.userId),
        _gamificationService.getAvailableAchievements(widget.userId),
        _gamificationService.getLeaderboard(),
        _gamificationService.getUserActivities(widget.userId),
        _gamificationService.createDailyChallenge(),
      ]);

      setState(() {
        _userProfile = futures[0] as UserGameProfile;
        _availableAchievements = futures[1] as List<Achievement>;
        _leaderboard = futures[2] as List<LeaderboardEntry>;
        _recentActivities = futures[3] as List<GameActivity>;
        _dailyChallenge = futures[4] as DailyChallenge;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تحميل بيانات الألعاب: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الألعاب والمكافآت'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadGamificationData,
            icon: const Icon(Icons.refresh),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'الملف الشخصي', icon: Icon(Icons.person)),
            Tab(text: 'الإنجازات', icon: Icon(Icons.emoji_events)),
            Tab(text: 'المتصدرون', icon: Icon(Icons.leaderboard)),
            Tab(text: 'الأنشطة', icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: _isLoading
          ? _buildLoadingScreen()
          : TabBarView(
              controller: _tabController,
              children: [
                _buildProfileTab(),
                _buildAchievementsTab(),
                _buildLeaderboardTab(),
                _buildActivitiesTab(),
              ],
            ),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'جاري تحميل بيانات الألعاب...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    if (_userProfile == null) return const SizedBox();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserProfileCard(),
          const SizedBox(height: 20),
          _buildLevelProgressCard(),
          const SizedBox(height: 20),
          _buildStatsGrid(),
          const SizedBox(height: 20),
          if (_dailyChallenge != null && _dailyChallenge!.isActive)
            _buildDailyChallengeCard(),
        ],
      ),
    );
  }

  Widget _buildUserProfileCard() {
    return EnhancedAnimations.fadeIn(
      child: EnhancedCard(
        child: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white.withOpacity(0.2),
                backgroundImage: _userProfile!.avatar != null
                    ? NetworkImage(_userProfile!.avatar!)
                    : null,
                child: _userProfile!.avatar == null
                    ? Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.white,
                      )
                    : null,
              ),
              const SizedBox(height: 12),
              Text(
                _userProfile!.username,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                _userProfile!.levelTitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildProfileStat('المستوى', _userProfile!.level.toString()),
                  _buildProfileStat(
                      'النقاط', _userProfile!.totalPoints.toString()),
                  _buildProfileStat('الإنجازات',
                      _userProfile!.achievements.length.toString()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
        ),
      ],
    );
  }

  Widget _buildLevelProgressCard() {
    return EnhancedAnimations.slideUp(
      child: EnhancedCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: AppTheme.successColor),
                const SizedBox(width: 8),
                Text(
                  'تقدم المستوى',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'المستوى ${_userProfile!.level}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Spacer(),
                Text(
                  'المستوى ${_userProfile!.level + 1}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: _userProfile!.levelProgress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.successColor),
            ),
            const SizedBox(height: 8),
            Text(
              '${_userProfile!.currentLevelPoints} / ${_userProfile!.pointsToNextLevel + _userProfile!.currentLevelPoints} نقطة',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    final statsData = [
      _StatCardData(
        title: 'إجمالي النقاط',
        value: _userProfile!.totalPoints.toString(),
        icon: Icons.stars,
        color: Colors.amber,
      ),
      _StatCardData(
        title: 'المستوى الحالي',
        value: _userProfile!.level.toString(),
        icon: Icons.trending_up,
        color: Colors.green,
      ),
      _StatCardData(
        title: 'الإنجازات',
        value: _userProfile!.achievements.length.toString(),
        icon: Icons.emoji_events,
        color: Colors.orange,
      ),
      _StatCardData(
        title: 'الشارات',
        value: _userProfile!.badges.length.toString(),
        icon: Icons.military_tech,
        color: Colors.purple,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: statsData.length,
      itemBuilder: (context, index) {
        return EnhancedAnimations.scaleIn(
          delay: Duration(milliseconds: index * 100),
          child: stats.StatsCard(
            title: statsData[index].title,
            value: statsData[index].value,
            icon: statsData[index].icon,
            color: statsData[index].color,
          ),
        );
      },
    );
  }

  Widget _buildDailyChallengeCard() {
    return EnhancedAnimations.slideUp(
      child: EnhancedCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.today, color: AppTheme.warningColor),
                const SizedBox(width: 8),
                Text(
                  'التحدي اليومي',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.warningColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_dailyChallenge!.points} نقطة',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.warningColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _dailyChallenge!.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              _dailyChallenge!.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: 0.0, // يجب جلب التقدم الفعلي
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.warningColor),
            ),
            const SizedBox(height: 8),
            Text(
              '0 / ${_dailyChallenge!.target}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الإنجازات المتاحة',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          if (_availableAchievements.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.emoji_events,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد إنجازات متاحة حالياً',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            )
          else
            ...(_availableAchievements.map((achievement) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: EnhancedAnimations.slideUp(
                    child: _buildAchievementCard(achievement),
                  ),
                ))),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    return EnhancedCard(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getAchievementColor(achievement.rarity).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            achievement.icon,
            style: const TextStyle(fontSize: 24),
          ),
        ),
        title: Text(
          achievement.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(achievement.description),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getAchievementColor(achievement.rarity)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    achievement.rarity.displayName,
                    style: TextStyle(
                      fontSize: 10,
                      color: _getAchievementColor(achievement.rarity),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  achievement.category.displayName,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.stars, color: Colors.amber, size: 16),
            Text(
              '${achievement.points}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'قائمة المتصدرين',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          if (_leaderboard.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.leaderboard,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد بيانات متصدرين',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            )
          else
            ...(_leaderboard.asMap().entries.map((entry) {
              final index = entry.key;
              final leaderboardEntry = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: EnhancedAnimations.slideUp(
                  delay: Duration(milliseconds: index * 50),
                  child: _buildLeaderboardCard(leaderboardEntry),
                ),
              );
            })),
        ],
      ),
    );
  }

  Widget _buildLeaderboardCard(LeaderboardEntry entry) {
    final isCurrentUser = entry.userId == widget.userId;

    return EnhancedCard(
      child: Container(
        decoration: isCurrentUser
            ? BoxDecoration(
                border: Border.all(color: AppTheme.primaryColor, width: 2),
                borderRadius: BorderRadius.circular(12),
              )
            : null,
        child: ListTile(
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: _getRankColor(entry.rank),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${entry.rank}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 20,
                backgroundImage:
                    entry.avatar != null ? NetworkImage(entry.avatar!) : null,
                child: entry.avatar == null ? const Icon(Icons.person) : null,
              ),
            ],
          ),
          title: Text(
            entry.username,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isCurrentUser ? AppTheme.primaryColor : null,
            ),
          ),
          subtitle:
              Text('المستوى ${entry.level} • ${entry.achievementsCount} إنجاز'),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.points}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Text(
                'نقطة',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivitiesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الأنشطة الأخيرة',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          if (_recentActivities.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد أنشطة حتى الآن',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            )
          else
            ...(_recentActivities.map((activity) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: EnhancedAnimations.slideUp(
                    child: _buildActivityCard(activity),
                  ),
                ))),
        ],
      ),
    );
  }

  Widget _buildActivityCard(GameActivity activity) {
    return EnhancedCard(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getActivityColor(activity.activityType).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getActivityIcon(activity.activityType),
            color: _getActivityColor(activity.activityType),
            size: 20,
          ),
        ),
        title: Text(
          activity.description,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          _formatDateTime(activity.timestamp),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        trailing: activity.points > 0
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: Colors.green, size: 16),
                  Text(
                    '${activity.points}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              )
            : null,
      ),
    );
  }

  Color _getAchievementColor(AchievementRarity rarity) {
    switch (rarity) {
      case AchievementRarity.common:
        return Colors.grey;
      case AchievementRarity.uncommon:
        return Colors.green;
      case AchievementRarity.rare:
        return Colors.blue;
      case AchievementRarity.epic:
        return Colors.purple;
      case AchievementRarity.legendary:
        return Colors.orange;
    }
  }

  Color _getRankColor(int rank) {
    if (rank == 1) return Colors.amber;
    if (rank == 2) return Colors.grey;
    if (rank == 3) return Colors.brown;
    return AppTheme.primaryColor;
  }

  Color _getActivityColor(ActivityType type) {
    switch (type) {
      case ActivityType.pointsEarned:
        return Colors.green;
      case ActivityType.achievementUnlocked:
        return Colors.orange;
      case ActivityType.levelUp:
        return Colors.blue;
      case ActivityType.badgeEarned:
        return Colors.purple;
      case ActivityType.challengeCompleted:
        return Colors.red;
      case ActivityType.other:
        return Colors.grey;
    }
  }

  IconData _getActivityIcon(ActivityType type) {
    switch (type) {
      case ActivityType.pointsEarned:
        return Icons.stars;
      case ActivityType.achievementUnlocked:
        return Icons.emoji_events;
      case ActivityType.levelUp:
        return Icons.trending_up;
      case ActivityType.badgeEarned:
        return Icons.military_tech;
      case ActivityType.challengeCompleted:
        return Icons.flag;
      case ActivityType.other:
        return Icons.info;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} يوم';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }
}
