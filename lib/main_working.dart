import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// Providers
import 'providers/auth_provider.dart';

// Screens
import 'screens/car/add_car_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/ai/ai_analysis_screen.dart';
import 'screens/vr/vr_main_screen.dart';
import 'screens/analytics/analytics_dashboard_screen.dart';
import 'screens/gamification/gamification_screen.dart';
import 'screens/social/social_community_screen.dart';
import 'screens/iot/iot_main_screen.dart';

// Firebase Options
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // تهيئة Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    runApp(const TashlehekomApp());
  } catch (e) {
    print('خطأ في تهيئة Firebase: $e');
    runApp(const TashlehekomApp());
  }
}

class TashlehekomApp extends StatelessWidget {
  const TashlehekomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'تشليحكم',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
          fontFamily: 'Cairo',
          textTheme: const TextTheme(
            bodyLarge: TextStyle(fontFamily: 'Cairo'),
            bodyMedium: TextStyle(fontFamily: 'Cairo'),
          ),
        ),
        home: const MainNavigationScreen(),
        routes: {
          '/add-car': (context) => const AddCarScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/ai': (context) => const AIAnalysisScreen(),
          '/vr': (context) => const VRMainScreen(),
          '/analytics': (context) => const AnalyticsDashboardScreen(),
          '/gamification': (context) => const GamificationScreen(userId: 'demo'),
          '/social': (context) => const SocialCommunityScreen(userId: 'demo'),
          '/iot': (context) => const IOTMainScreen(carId: 'demo', userId: 'demo'),
        },
      ),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const AddCarScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            label: 'البحث',
          ),
          NavigationDestination(
            icon: Icon(Icons.add),
            label: 'إضافة',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'الملف الشخصي',
          ),
        ],
      ),
      drawer: const AppDrawer(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تشليحكم'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // بطاقة ترحيب
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.green, Colors.teal],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'مرحباً بك في تشليحكم',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'منصتك الشاملة لبيع وشراء السيارات المستعملة وقطع الغيار',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // إحصائيات سريعة
            const Text(
              'إحصائيات سريعة',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard('السيارات', '1,234', Icons.directions_car),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard('قطع الغيار', '5,678', Icons.build),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard('المستخدمين', '890', Icons.people),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard('المعاملات', '2,345', Icons.receipt),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // إجراءات سريعة
            const Text(
              'إجراءات سريعة',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildActionCard(
                  'بيع سيارة',
                  Icons.sell,
                  Colors.blue,
                  () => Navigator.pushNamed(context, '/add-car'),
                ),
                _buildActionCard(
                  'شراء قطع غيار',
                  Icons.shopping_cart,
                  Colors.orange,
                  () => Navigator.pushNamed(context, '/search'),
                ),
                _buildActionCard(
                  'تقييم سيارة',
                  Icons.assessment,
                  Colors.purple,
                  () => Navigator.pushNamed(context, '/ai'),
                ),
                _buildActionCard(
                  'خدمة التوصيل',
                  Icons.local_shipping,
                  Colors.red,
                  () => Navigator.pushNamed(context, '/profile'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: Colors.green),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('البحث'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'شاشة البحث',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.green,
            ),
            child: Text(
              'تشليحكم',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text('التحليلات'),
            onTap: () => Navigator.pushNamed(context, '/analytics'),
          ),
          ListTile(
            leading: const Icon(Icons.games),
            title: const Text('الألعاب'),
            onTap: () => Navigator.pushNamed(context, '/gamification'),
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('المجتمع'),
            onTap: () => Navigator.pushNamed(context, '/social'),
          ),
          ListTile(
            leading: const Icon(Icons.devices),
            title: const Text('إنترنت الأشياء'),
            onTap: () => Navigator.pushNamed(context, '/iot'),
          ),
          ListTile(
            leading: const Icon(Icons.view_in_ar),
            title: const Text('الواقع الافتراضي'),
            onTap: () => Navigator.pushNamed(context, '/vr'),
          ),
          ListTile(
            leading: const Icon(Icons.smart_toy),
            title: const Text('الذكاء الاصطناعي'),
            onTap: () => Navigator.pushNamed(context, '/ai'),
          ),
        ],
      ),
    );
  }
}
