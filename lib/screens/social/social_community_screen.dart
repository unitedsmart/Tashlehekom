import 'package:flutter/material.dart';
import 'package:tashlehekomv2/services/social_community_service.dart';
import 'package:tashlehekomv2/models/social_community_models.dart';
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

/// شاشة المجتمع الاجتماعي
class SocialCommunityScreen extends StatefulWidget {
  final String userId;

  const SocialCommunityScreen({
    super.key,
    required this.userId,
  });

  @override
  State<SocialCommunityScreen> createState() => _SocialCommunityScreenState();
}

class _SocialCommunityScreenState extends State<SocialCommunityScreen>
    with TickerProviderStateMixin {
  final SocialCommunityService _socialService = SocialCommunityService();

  List<Forum> _forums = [];
  List<DiscussionGroup> _groups = [];
  List<UserExperience> _experiences = [];
  CommunityStats? _communityStats;

  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadSocialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSocialData() async {
    setState(() => _isLoading = true);

    try {
      final futures = await Future.wait([
        _socialService.getForums(limit: 10),
        _socialService.getDiscussionGroups(limit: 10),
        _socialService.getUserExperiences(limit: 10),
        _socialService.getCommunityStats(),
      ]);

      setState(() {
        _forums = futures[0] as List<Forum>;
        _groups = futures[1] as List<DiscussionGroup>;
        _experiences = futures[2] as List<UserExperience>;
        _communityStats = futures[3] as CommunityStats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تحميل بيانات المجتمع: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المجتمع الاجتماعي'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadSocialData,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: _showSearchDialog,
            icon: const Icon(Icons.search),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'نظرة عامة', icon: Icon(Icons.dashboard)),
            Tab(text: 'المنتديات', icon: Icon(Icons.forum)),
            Tab(text: 'المجموعات', icon: Icon(Icons.group)),
            Tab(text: 'التجارب', icon: Icon(Icons.star)),
          ],
        ),
      ),
      body: _isLoading
          ? _buildLoadingScreen()
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildForumsTab(),
                _buildGroupsTab(),
                _buildExperiencesTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateContentDialog,
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
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
            'جاري تحميل بيانات المجتمع...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeCard(),
          const SizedBox(height: 20),
          if (_communityStats != null) _buildStatsGrid(),
          const SizedBox(height: 20),
          _buildQuickActionsGrid(),
          const SizedBox(height: 20),
          _buildRecentActivity(),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return EnhancedAnimations.fadeIn(
      child: EnhancedCard(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal.shade600, Colors.blue.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.people,
                    size: 32,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'مرحباً بك في مجتمع تشليحكم',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'شارك تجاربك، اطرح أسئلتك، وتواصل مع مجتمع محبي السيارات',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    final statsData = [
      _StatCardData(
        title: 'المنتديات',
        value: _communityStats!.totalForums.toString(),
        icon: Icons.forum,
        color: Colors.blue,
      ),
      _StatCardData(
        title: 'المنشورات',
        value: _communityStats!.totalPosts.toString(),
        icon: Icons.article,
        color: Colors.green,
      ),
      _StatCardData(
        title: 'المجموعات',
        value: _communityStats!.totalGroups.toString(),
        icon: Icons.group,
        color: Colors.orange,
      ),
      _StatCardData(
        title: 'التجارب',
        value: _communityStats!.totalExperiences.toString(),
        icon: Icons.star,
        color: Colors.purple,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إحصائيات المجتمع',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
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
        ),
      ],
    );
  }

  Widget _buildQuickActionsGrid() {
    final actions = [
      QuickAction(
        title: 'إنشاء منتدى',
        description: 'ابدأ منتدى جديد',
        icon: Icons.add_box,
        color: Colors.blue,
        onTap: () => _showCreateForumDialog(),
      ),
      QuickAction(
        title: 'إنشاء مجموعة',
        description: 'كون مجموعة نقاش',
        icon: Icons.group_add,
        color: Colors.green,
        onTap: () => _showCreateGroupDialog(),
      ),
      QuickAction(
        title: 'مشاركة تجربة',
        description: 'شارك تجربتك',
        icon: Icons.share,
        color: Colors.orange,
        onTap: () => _showShareExperienceDialog(),
      ),
      QuickAction(
        title: 'البحث',
        description: 'ابحث في المحتوى',
        icon: Icons.search,
        color: Colors.purple,
        onTap: () => _showSearchDialog(),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إجراءات سريعة',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            return EnhancedAnimations.scaleIn(
              delay: Duration(milliseconds: index * 100),
              child: _buildQuickActionCard(actions[index]),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(QuickAction action) {
    return EnhancedCard(
      onTap: action.onTap,
      enableAnimation: true,
      enableHoverEffect: true,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: action.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                action.icon,
                size: 28,
                color: action.color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              action.title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              action.description,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return EnhancedAnimations.slideUp(
      child: EnhancedCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history, color: AppTheme.infoColor),
                const SizedBox(width: 8),
                Text(
                  'النشاط الأخير',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // يمكن إضافة قائمة بالأنشطة الأخيرة هنا
            Center(
              child: Text(
                'لا توجد أنشطة حديثة',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForumsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'المنتديات',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _showCreateForumDialog,
                icon: const Icon(Icons.add),
                label: const Text('إنشاء منتدى'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_forums.isEmpty)
            _buildEmptyState('لا توجد منتديات', Icons.forum)
          else
            ...(_forums.map((forum) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: EnhancedAnimations.slideUp(
                    child: _buildForumCard(forum),
                  ),
                ))),
        ],
      ),
    );
  }

  Widget _buildForumCard(Forum forum) {
    return EnhancedCard(
      onTap: () => _openForum(forum),
      enableAnimation: true,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getCategoryColor(forum.category).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.forum,
            color: _getCategoryColor(forum.category),
            size: 20,
          ),
        ),
        title: Text(
          forum.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              forum.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.people, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${forum.membersCount} عضو',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(width: 12),
                Icon(Icons.article, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${forum.postsCount} منشور',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getCategoryColor(forum.category).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            forum.category.displayName,
            style: TextStyle(
              fontSize: 10,
              color: _getCategoryColor(forum.category),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGroupsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'مجموعات النقاش',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _showCreateGroupDialog,
                icon: const Icon(Icons.add),
                label: const Text('إنشاء مجموعة'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_groups.isEmpty)
            _buildEmptyState('لا توجد مجموعات', Icons.group)
          else
            ...(_groups.map((group) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: EnhancedAnimations.slideUp(
                    child: _buildGroupCard(group),
                  ),
                ))),
        ],
      ),
    );
  }

  Widget _buildGroupCard(DiscussionGroup group) {
    return EnhancedCard(
      onTap: () => _openGroup(group),
      enableAnimation: true,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getGroupTypeColor(group.type).withOpacity(0.1),
          child: Icon(
            _getGroupTypeIcon(group.type),
            color: _getGroupTypeColor(group.type),
          ),
        ),
        title: Text(
          group.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              group.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.people, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${group.membersCount} عضو',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                if (group.maxMembers != null) ...[
                  Text(
                    ' / ${group.maxMembers}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getGroupTypeColor(group.type).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                group.type.displayName,
                style: TextStyle(
                  fontSize: 10,
                  color: _getGroupTypeColor(group.type),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (group.isFull)
              const Text(
                'ممتلئة',
                style: TextStyle(fontSize: 10, color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperiencesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'تجارب المستخدمين',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _showShareExperienceDialog,
                icon: const Icon(Icons.add),
                label: const Text('مشاركة تجربة'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_experiences.isEmpty)
            _buildEmptyState('لا توجد تجارب', Icons.star)
          else
            ...(_experiences.map((experience) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: EnhancedAnimations.slideUp(
                    child: _buildExperienceCard(experience),
                  ),
                ))),
        ],
      ),
    );
  }

  Widget _buildExperienceCard(UserExperience experience) {
    return EnhancedCard(
      onTap: () => _openExperience(experience),
      enableAnimation: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:
                    _getExperienceTypeColor(experience.type).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getExperienceTypeIcon(experience.type),
                color: _getExperienceTypeColor(experience.type),
                size: 20,
              ),
            ),
            title: Text(
              experience.title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              experience.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: experience.isVerified
                ? Icon(Icons.verified, color: Colors.blue, size: 16)
                : null,
          ),
          if (experience.imageUrls.isNotEmpty)
            Container(
              height: 100,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: experience.imageUrls.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(experience.imageUrls[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.favorite, size: 16, color: Colors.red),
                const SizedBox(width: 4),
                Text('${experience.likesCount}'),
                const SizedBox(width: 16),
                Icon(Icons.comment, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('${experience.commentsCount}'),
                const SizedBox(width: 16),
                Icon(Icons.share, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('${experience.sharesCount}'),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getExperienceTypeColor(experience.type)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    experience.type.displayName,
                    style: TextStyle(
                      fontSize: 10,
                      color: _getExperienceTypeColor(experience.type),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  // الطرق المساعدة
  Color _getCategoryColor(ForumCategory category) {
    switch (category) {
      case ForumCategory.general:
        return Colors.grey;
      case ForumCategory.carReviews:
        return Colors.blue;
      case ForumCategory.maintenance:
        return Colors.orange;
      case ForumCategory.buying:
        return Colors.green;
      case ForumCategory.selling:
        return Colors.red;
      case ForumCategory.modifications:
        return Colors.purple;
      case ForumCategory.insurance:
        return Colors.teal;
      case ForumCategory.driving:
        return Colors.indigo;
    }
  }

  Color _getGroupTypeColor(GroupType type) {
    switch (type) {
      case GroupType.public:
        return Colors.green;
      case GroupType.private:
        return Colors.orange;
      case GroupType.secret:
        return Colors.red;
    }
  }

  IconData _getGroupTypeIcon(GroupType type) {
    switch (type) {
      case GroupType.public:
        return Icons.public;
      case GroupType.private:
        return Icons.lock_outline;
      case GroupType.secret:
        return Icons.lock;
    }
  }

  Color _getExperienceTypeColor(ExperienceType type) {
    switch (type) {
      case ExperienceType.general:
        return Colors.grey;
      case ExperienceType.carReview:
        return Colors.blue;
      case ExperienceType.buyingExperience:
        return Colors.green;
      case ExperienceType.sellingExperience:
        return Colors.red;
      case ExperienceType.maintenanceStory:
        return Colors.orange;
      case ExperienceType.accidentReport:
        return Colors.red;
      case ExperienceType.roadTrip:
        return Colors.purple;
    }
  }

  IconData _getExperienceTypeIcon(ExperienceType type) {
    switch (type) {
      case ExperienceType.general:
        return Icons.star;
      case ExperienceType.carReview:
        return Icons.rate_review;
      case ExperienceType.buyingExperience:
        return Icons.shopping_cart;
      case ExperienceType.sellingExperience:
        return Icons.sell;
      case ExperienceType.maintenanceStory:
        return Icons.build;
      case ExperienceType.accidentReport:
        return Icons.warning;
      case ExperienceType.roadTrip:
        return Icons.map;
    }
  }

  // معالجات الأحداث
  void _openForum(Forum forum) {
    // الانتقال إلى شاشة المنتدى
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('فتح منتدى: ${forum.title}')),
    );
  }

  void _openGroup(DiscussionGroup group) {
    // الانتقال إلى شاشة المجموعة
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('فتح مجموعة: ${group.name}')),
    );
  }

  void _openExperience(UserExperience experience) {
    // الانتقال إلى شاشة التجربة
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('فتح تجربة: ${experience.title}')),
    );
  }

  void _showCreateContentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إنشاء محتوى جديد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.forum),
              title: const Text('إنشاء منتدى'),
              onTap: () {
                Navigator.pop(context);
                _showCreateForumDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('إنشاء مجموعة'),
              onTap: () {
                Navigator.pop(context);
                _showCreateGroupDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text('مشاركة تجربة'),
              onTap: () {
                Navigator.pop(context);
                _showShareExperienceDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateForumDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('سيتم إضافة نموذج إنشاء المنتدى قريباً')),
    );
  }

  void _showCreateGroupDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('سيتم إضافة نموذج إنشاء المجموعة قريباً')),
    );
  }

  void _showShareExperienceDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('سيتم إضافة نموذج مشاركة التجربة قريباً')),
    );
  }

  void _showSearchDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('سيتم إضافة البحث المتقدم قريباً')),
    );
  }
}

/// إجراء سريع
class QuickAction {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const QuickAction({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
