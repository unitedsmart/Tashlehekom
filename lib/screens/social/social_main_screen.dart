import 'package:flutter/material.dart';
import 'dart:math';

class SocialMainScreen extends StatefulWidget {
  const SocialMainScreen({super.key});

  @override
  State<SocialMainScreen> createState() => _SocialMainScreenState();
}

class _SocialMainScreenState extends State<SocialMainScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المجتمع الاجتماعي'),
        backgroundColor: Colors.indigo[600],
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.forum), text: 'المنتدى'),
            Tab(icon: Icon(Icons.group), text: 'المجموعات'),
            Tab(icon: Icon(Icons.share), text: 'التجارب'),
            Tab(icon: Icon(Icons.event), text: 'الأحداث'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildForumTab(),
          _buildGroupsTab(),
          _buildExperiencesTab(),
          _buildEventsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewPost,
        backgroundColor: Colors.indigo[600],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildForumTab() {
    final posts = [
      {
        'user': 'أحمد محمد',
        'avatar': Icons.person,
        'time': 'منذ ساعتين',
        'title': 'تجربتي مع تويوتا كامري 2020',
        'content': 'اشتريت سيارة كامري من التطبيق والتجربة كانت ممتازة...',
        'likes': 24,
        'comments': 8,
        'image': true,
      },
      {
        'user': 'سارة أحمد',
        'avatar': Icons.person_2,
        'time': 'منذ 4 ساعات',
        'title': 'نصائح للمبتدئين في شراء السيارات',
        'content': 'هذه أهم النصائح التي تعلمتها من خبرتي...',
        'likes': 45,
        'comments': 12,
        'image': false,
      },
      {
        'user': 'محمد علي',
        'avatar': Icons.person_3,
        'time': 'منذ يوم',
        'title': 'مقارنة بين هوندا وتويوتا',
        'content': 'بعد تجربة السيارتين، هذه مقارنة شاملة...',
        'likes': 67,
        'comments': 23,
        'image': true,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.indigo[100],
                      child: Icon(post['avatar'] as IconData, color: Colors.indigo[600]),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post['user'] as String,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            post['time'] as String,
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'report', child: Text('إبلاغ')),
                        const PopupMenuItem(value: 'share', child: Text('مشاركة')),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  post['title'] as String,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  post['content'] as String,
                  style: TextStyle(color: Colors.grey[700]),
                ),
                if (post['image'] as bool) ...[
                  const SizedBox(height: 12),
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.image, size: 64, color: Colors.grey[400]),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildActionButton(Icons.thumb_up, '${post['likes']}', Colors.blue),
                    const SizedBox(width: 16),
                    _buildActionButton(Icons.comment, '${post['comments']}', Colors.green),
                    const SizedBox(width: 16),
                    _buildActionButton(Icons.share, 'مشاركة', Colors.orange),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGroupsTab() {
    final groups = [
      {
        'name': 'عشاق تويوتا',
        'members': '2.5K',
        'posts': '145',
        'icon': Icons.directions_car,
        'color': Colors.red,
        'joined': true,
      },
      {
        'name': 'خبراء السيارات الألمانية',
        'members': '1.8K',
        'posts': '89',
        'icon': Icons.engineering,
        'color': Colors.blue,
        'joined': false,
      },
      {
        'name': 'سيارات كلاسيكية',
        'members': '3.2K',
        'posts': '234',
        'icon': Icons.history,
        'color': Colors.brown,
        'joined': true,
      },
      {
        'name': 'السيارات الكهربائية',
        'members': '1.1K',
        'posts': '67',
        'icon': Icons.electric_car,
        'color': Colors.green,
        'joined': false,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        final isJoined = group['joined'] as bool;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: (group['color'] as Color).withOpacity(0.1),
              child: Icon(group['icon'] as IconData, color: group['color'] as Color),
            ),
            title: Text(
              group['name'] as String,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${group['members']} عضو • ${group['posts']} منشور'),
            trailing: ElevatedButton(
              onPressed: () => _toggleGroupMembership(group['name'] as String, isJoined),
              style: ElevatedButton.styleFrom(
                backgroundColor: isJoined ? Colors.grey[300] : Colors.indigo[600],
                foregroundColor: isJoined ? Colors.grey[700] : Colors.white,
                minimumSize: const Size(80, 32),
              ),
              child: Text(isJoined ? 'مشترك' : 'انضمام'),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExperiencesTab() {
    final experiences = [
      {
        'user': 'خالد أحمد',
        'rating': 5,
        'car': 'BMW X5 2019',
        'experience': 'تجربة رائعة مع البائع، السيارة كما هو موصوف تماماً...',
        'time': 'منذ يوم',
      },
      {
        'user': 'فاطمة محمد',
        'rating': 4,
        'car': 'مرسيدس C200 2020',
        'experience': 'سيارة ممتازة ولكن كان هناك تأخير في التسليم...',
        'time': 'منذ 3 أيام',
      },
      {
        'user': 'عبدالله سالم',
        'rating': 5,
        'car': 'تويوتا كامري 2021',
        'experience': 'أفضل تجربة شراء سيارة في حياتي، شكراً للتطبيق...',
        'time': 'منذ أسبوع',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: experiences.length,
      itemBuilder: (context, index) {
        final experience = experiences[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.indigo[100],
                      child: Icon(Icons.person, color: Colors.indigo[600]),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            experience['user'] as String,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            experience['car'] as String,
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: List.generate(5, (i) => Icon(
                        Icons.star,
                        size: 16,
                        color: i < (experience['rating'] as int) ? Colors.amber : Colors.grey[300],
                      )),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  experience['experience'] as String,
                  style: TextStyle(color: Colors.grey[700]),
                ),
                const SizedBox(height: 8),
                Text(
                  experience['time'] as String,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEventsTab() {
    final events = [
      {
        'title': 'معرض السيارات الكلاسيكية',
        'date': '15 ديسمبر 2024',
        'location': 'الرياض',
        'attendees': '234',
        'type': 'معرض',
        'color': Colors.purple,
      },
      {
        'title': 'ورشة صيانة السيارات',
        'date': '20 ديسمبر 2024',
        'location': 'جدة',
        'attendees': '89',
        'type': 'ورشة',
        'color': Colors.blue,
      },
      {
        'title': 'مزاد السيارات الشهري',
        'date': '25 ديسمبر 2024',
        'location': 'الدمام',
        'attendees': '156',
        'type': 'مزاد',
        'color': Colors.green,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (event['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.event,
                        color: event['color'] as Color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event['title'] as String,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                event['date'] as String,
                                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                              ),
                              const SizedBox(width: 12),
                              Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                event['location'] as String,
                                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: event['color'] as Color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        event['type'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.people, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${event['attendees']} مشارك',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () => _joinEvent(event['title'] as String),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo[600],
                        foregroundColor: Colors.white,
                        minimumSize: const Size(80, 32),
                      ),
                      child: const Text('انضمام'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color) {
    return InkWell(
      onTap: () {},
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _createNewPost() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('منشور جديد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'عنوان المنشور',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'اكتب منشورك هنا...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم نشر المنشور بنجاح!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo[600]),
            child: const Text('نشر', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _toggleGroupMembership(String groupName, bool isJoined) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isJoined ? 'تم إلغاء الاشتراك من $groupName' : 'تم الانضمام إلى $groupName'),
        backgroundColor: Colors.indigo[600],
      ),
    );
  }

  void _joinEvent(String eventName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم التسجيل في $eventName'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
