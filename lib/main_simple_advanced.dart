import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// Providers
import 'providers/auth_provider.dart';

// Screens
import 'screens/car/add_car_screen.dart';
import 'screens/profile/profile_screen.dart';

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
        title: 'تشليحكم - النسخة المتطورة',
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
        title: const Text('تشليحكم - النسخة المتطورة'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // بطاقة ترحيب متطورة
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.green, Colors.teal, Colors.blue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome, color: Colors.white, size: 32),
                      SizedBox(width: 12),
                      Text(
                        'مرحباً بك في تشليحكم المتطور',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    'منصة شاملة مع الذكاء الاصطناعي، الواقع الافتراضي، إنترنت الأشياء، والتحليلات المتقدمة',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.verified, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'تقنيات متطورة • أمان عالي • تجربة استثنائية',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // إحصائيات متطورة
            const Text(
              '📊 إحصائيات المنصة',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _buildAdvancedStatCard('السيارات المتاحة', '12,450', Icons.directions_car, Colors.blue),
                _buildAdvancedStatCard('قطع الغيار', '45,678', Icons.build_circle, Colors.orange),
                _buildAdvancedStatCard('المستخدمين النشطين', '8,920', Icons.people, Colors.purple),
                _buildAdvancedStatCard('المعاملات اليومية', '2,345', Icons.trending_up, Colors.green),
              ],
            ),
            const SizedBox(height: 24),
            
            // الميزات المتطورة
            const Text(
              '🚀 الميزات المتطورة',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.3,
              children: [
                _buildFeatureCard(
                  'الذكاء الاصطناعي',
                  'تحليل السيارات وتقدير الأسعار',
                  Icons.psychology,
                  Colors.indigo,
                  () => _showFeatureDialog(context, 'الذكاء الاصطناعي', 'تحليل متطور للسيارات باستخدام الذكاء الاصطناعي'),
                ),
                _buildFeatureCard(
                  'الواقع الافتراضي',
                  'جولات افتراضية للسيارات',
                  Icons.view_in_ar,
                  Colors.pink,
                  () => _showFeatureDialog(context, 'الواقع الافتراضي', 'تجربة السيارات في بيئة افتراضية'),
                ),
                _buildFeatureCard(
                  'إنترنت الأشياء',
                  'مراقبة السيارات عن بُعد',
                  Icons.devices,
                  Colors.teal,
                  () => _showFeatureDialog(context, 'إنترنت الأشياء', 'مراقبة وتحكم ذكي في السيارات'),
                ),
                _buildFeatureCard(
                  'التحليلات المتقدمة',
                  'تقارير وإحصائيات شاملة',
                  Icons.analytics,
                  Colors.deepOrange,
                  () => _showFeatureDialog(context, 'التحليلات المتقدمة', 'تحليلات شاملة لسوق السيارات'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 32, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: color.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  static void _showFeatureDialog(BuildContext context, String title, String description) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(description),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
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
        title: const Text('البحث المتطور'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text(
              'البحث المتطور',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'ابحث عن السيارات وقطع الغيار بتقنيات متطورة',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
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
              gradient: LinearGradient(
                colors: [Colors.green, Colors.teal],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.auto_awesome, color: Colors.white, size: 48),
                SizedBox(height: 12),
                Text(
                  'تشليحكم المتطور',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'النسخة المتطورة',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(Icons.psychology, 'الذكاء الاصطناعي', 'تحليل متطور للسيارات', context),
          _buildDrawerItem(Icons.view_in_ar, 'الواقع الافتراضي', 'جولات افتراضية', context),
          _buildDrawerItem(Icons.analytics, 'التحليلات', 'تقارير وإحصائيات', context),
          _buildDrawerItem(Icons.games, 'الألعاب والمكافآت', 'نظام نقاط وتحديات', context),
          _buildDrawerItem(Icons.people, 'المجتمع', 'منتديات ومناقشات', context),
          _buildDrawerItem(Icons.devices, 'إنترنت الأشياء', 'مراقبة ذكية', context),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info, color: Colors.blue),
            title: const Text('حول التطبيق'),
            subtitle: const Text('النسخة 2.9 المتطورة'),
            onTap: () => _showAboutDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, String subtitle, BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم النقر على $title')),
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'تشليحكم المتطور',
      applicationVersion: '2.9',
      applicationIcon: const Icon(Icons.auto_awesome, size: 48, color: Colors.green),
      children: const [
        Text('تطبيق متطور لبيع وشراء السيارات المستعملة وقطع الغيار مع تقنيات الذكاء الاصطناعي والواقع الافتراضي.'),
      ],
    );
  }
}
