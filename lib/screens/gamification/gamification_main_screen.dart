import 'package:flutter/material.dart';
import 'dart:math';

class GamificationMainScreen extends StatefulWidget {
  const GamificationMainScreen({super.key});

  @override
  State<GamificationMainScreen> createState() => _GamificationMainScreenState();
}

class _GamificationMainScreenState extends State<GamificationMainScreen>
    with TickerProviderStateMixin {
  late AnimationController _coinController;
  late Animation<double> _coinAnimation;
  int _userPoints = 2450;
  int _userLevel = 7;
  String _userRank = 'خبير السيارات';

  @override
  void initState() {
    super.initState();
    _coinController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _coinAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(_coinController);
    _coinController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الألعاب والمكافآت'),
        backgroundColor: Colors.amber[600],
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _coinAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _coinAnimation.value,
                      child: Icon(Icons.monetization_on, color: Colors.yellow[300]),
                    );
                  },
                ),
                const SizedBox(width: 4),
                Text('$_userPoints', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserProfileCard(),
            const SizedBox(height: 20),
            _buildDailyChallenges(),
            const SizedBox(height: 20),
            _buildAchievements(),
            const SizedBox(height: 20),
            _buildRewardsShop(),
            const SizedBox(height: 20),
            _buildLeaderboard(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfileCard() {
    return Card(
      elevation: 4,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.amber[600]!, Colors.amber[400]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Colors.amber[600]),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'مستخدم تشليحكم',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _userRank,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.yellow[300], size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'المستوى $_userLevel',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildProfileStat('النقاط', '$_userPoints'),
                  _buildProfileStat('الإنجازات', '23'),
                  _buildProfileStat('الترتيب', '#142'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildDailyChallenges() {
    final challenges = [
      {'title': 'إضافة سيارة جديدة', 'reward': '50 نقطة', 'progress': 0.8, 'icon': Icons.add_circle},
      {'title': 'تقييم 3 سيارات', 'reward': '30 نقطة', 'progress': 0.6, 'icon': Icons.star_rate},
      {'title': 'مشاركة في المنتدى', 'reward': '20 نقطة', 'progress': 0.0, 'icon': Icons.forum},
      {'title': 'استخدام الذكاء الاصطناعي', 'reward': '40 نقطة', 'progress': 1.0, 'icon': Icons.psychology},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'التحديات اليومية',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '18:45:32',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...challenges.map((challenge) => _buildChallengeItem(challenge)),
      ],
    );
  }

  Widget _buildChallengeItem(Map<String, dynamic> challenge) {
    final isCompleted = challenge['progress'] == 1.0;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isCompleted ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                challenge['icon'],
                color: isCompleted ? Colors.green : Colors.grey[600],
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    challenge['title'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    challenge['reward'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.amber[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: challenge['progress'],
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isCompleted ? Colors.green : Colors.amber[600]!,
                    ),
                  ),
                ],
              ),
            ),
            if (isCompleted)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'مكتمل',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievements() {
    final achievements = [
      {'title': 'بائع محترف', 'desc': 'باع 10 سيارات', 'icon': Icons.sell, 'unlocked': true},
      {'title': 'خبير التقييم', 'desc': 'قيّم 50 سيارة', 'icon': Icons.star, 'unlocked': true},
      {'title': 'مستكشف VR', 'desc': 'استخدم الواقع الافتراضي', 'icon': Icons.view_in_ar, 'unlocked': false},
      {'title': 'عضو نشط', 'desc': 'شارك في المنتدى 20 مرة', 'icon': Icons.forum, 'unlocked': true},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'الإنجازات',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: achievements.length,
          itemBuilder: (context, index) {
            final achievement = achievements[index];
            final isUnlocked = achievement['unlocked'] as bool;
            
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isUnlocked 
                            ? Colors.amber.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        achievement['icon'] as IconData,
                        size: 32,
                        color: isUnlocked ? Colors.amber[600] : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      achievement['title'] as String,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: isUnlocked ? Colors.black : Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      achievement['desc'] as String,
                      style: TextStyle(
                        fontSize: 10,
                        color: isUnlocked ? Colors.grey[600] : Colors.grey[400],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (isUnlocked)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber[600],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'مفتوح',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRewardsShop() {
    final rewards = [
      {'title': 'خصم 10%', 'cost': '100 نقطة', 'icon': Icons.discount, 'color': Colors.green},
      {'title': 'ترقية VIP', 'cost': '500 نقطة', 'icon': Icons.star, 'color': Colors.purple},
      {'title': 'تقييم مجاني', 'cost': '200 نقطة', 'icon': Icons.assessment, 'color': Colors.blue},
      {'title': 'إعلان مميز', 'cost': '300 نقطة', 'icon': Icons.campaign, 'color': Colors.orange},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'متجر المكافآت',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          itemCount: rewards.length,
          itemBuilder: (context, index) {
            final reward = rewards[index];
            final cost = int.parse((reward['cost'] as String).split(' ')[0]);
            final canAfford = _userPoints >= cost;
            
            return Card(
              child: InkWell(
                onTap: canAfford ? () => _purchaseReward(reward) : null,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (reward['color'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          reward['icon'] as IconData,
                          size: 28,
                          color: canAfford ? reward['color'] as Color : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        reward['title'] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: canAfford ? Colors.black : Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: canAfford ? Colors.amber[600] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          reward['cost'] as String,
                          style: TextStyle(
                            color: canAfford ? Colors.white : Colors.grey[600],
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLeaderboard() {
    final leaders = [
      {'name': 'أحمد محمد', 'points': '5,240', 'rank': 1},
      {'name': 'سارة أحمد', 'points': '4,890', 'rank': 2},
      {'name': 'محمد علي', 'points': '4,650', 'rank': 3},
      {'name': 'فاطمة خالد', 'points': '4,200', 'rank': 4},
      {'name': 'أنت', 'points': '$_userPoints', 'rank': 142},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.leaderboard, color: Colors.amber[600]),
                const SizedBox(width: 8),
                const Text(
                  'لوحة المتصدرين',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...leaders.map((leader) => _buildLeaderItem(leader)),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderItem(Map<String, dynamic> leader) {
    final isCurrentUser = leader['name'] == 'أنت';
    final rank = leader['rank'] as int;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentUser ? Colors.amber.withOpacity(0.1) : null,
        borderRadius: BorderRadius.circular(8),
        border: isCurrentUser ? Border.all(color: Colors.amber[600]!) : null,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: rank <= 3 ? Colors.amber[600] : Colors.grey[300],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: TextStyle(
                  color: rank <= 3 ? Colors.white : Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              leader['name'] as String,
              style: TextStyle(
                fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                color: isCurrentUser ? Colors.amber[600] : Colors.black,
              ),
            ),
          ),
          Text(
            '${leader['points']} نقطة',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isCurrentUser ? Colors.amber[600] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _purchaseReward(Map<String, dynamic> reward) {
    final cost = int.parse((reward['cost'] as String).split(' ')[0]);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('شراء ${reward['title']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(reward['icon'] as IconData, size: 48, color: reward['color'] as Color),
            const SizedBox(height: 16),
            Text('هل تريد شراء ${reward['title']} مقابل $cost نقطة؟'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _userPoints -= cost;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم شراء ${reward['title']} بنجاح!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber[600]),
            child: const Text('شراء', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _coinController.dispose();
    super.dispose();
  }
}
