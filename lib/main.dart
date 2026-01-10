import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Services
import 'services/logging_service.dart';
import 'services/enhanced_error_handler.dart';
import 'services/performance_service.dart';
import 'services/enhanced_cache_service.dart';

// Firebase Options
import 'firebase_options.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/car/add_car_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/ai/ai_main_screen.dart';
import 'screens/vr/vr_main_screen.dart';
import 'screens/analytics/analytics_dashboard_screen.dart';
import 'screens/gamification/gamification_screen.dart';
import 'screens/social/social_community_screen.dart';
import 'screens/iot/iot_main_screen.dart';

// Providers
import 'providers/firebase_auth_provider.dart';
import 'providers/car_provider.dart';
import 'providers/user_provider.dart';
import 'providers/language_provider.dart';
import 'providers/theme_provider.dart';

// Localization
import 'l10n/app_localizations.dart';

// Widgets
import 'widgets/app_drawer.dart';

// Services
import 'services/sample_data_service.dart';

/// تطبيق تشليحكم الكامل مع جميع الميزات
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // تهيئة Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // تعطيل Firebase App Check تماماً لحل مشكلة Play Integrity
    // هذا يحل مشكلة "missing a valid app identifier"

    // إعدادات Firebase Auth للإنتاج
    if (kReleaseMode) {
      // في وضع الإنتاج، تأكد من إعدادات Firebase Auth
      print('🚀 تشغيل في وضع الإنتاج - تطبيق إعدادات Firebase Auth');
    } else {
      // في وضع التطوير
      print('🔧 تشغيل في وضع التطوير');
    }

    // تهيئة الخدمات
    await _initializeServices();

    LoggingService.success('تم تشغيل التطبيق بنجاح');
  } catch (e, stackTrace) {
    LoggingService.error('خطأ في تشغيل التطبيق',
        error: e, stackTrace: stackTrace);
  }

  runApp(const TashlehekomApp());
}

/// تهيئة جميع الخدمات
Future<void> _initializeServices() async {
  try {
    // تهيئة خدمة التخزين المؤقت
    await EnhancedCacheService().initialize();

    // تهيئة معالج الأخطاء
    EnhancedErrorHandler.initialize();

    // إضافة البيانات التجريبية (لغير وضع الإنتاج فقط)
    if (!kReleaseMode) {
      try {
        await SampleDataService.initializeSampleData();
        LoggingService.info('تم تهيئة البيانات التجريبية بنجاح');
      } catch (e) {
        LoggingService.warning('تعذر إضافة البيانات التجريبية: $e');
      }
    } else {
      LoggingService.info('تخطي إضافة البيانات التجريبية في وضع الإنتاج');
    }

    LoggingService.info('تم تهيئة جميع الخدمات بنجاح');
  } catch (e, stackTrace) {
    LoggingService.error('خطأ في تهيئة الخدمات',
        error: e, stackTrace: stackTrace);
  }
}

class TashlehekomApp extends StatelessWidget {
  const TashlehekomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FirebaseAuthProvider()),
        ChangeNotifierProvider(create: (_) => CarProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer2<LanguageProvider, ThemeProvider>(
        builder: (context, languageProvider, themeProvider, child) {
          return MaterialApp(
            title: 'تشليحكم',
            debugShowCheckedModeBanner: false,

            // الثيم
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.themeMode,

            // اللغة والترجمة
            locale: languageProvider.currentLocale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ar', 'SA'), // العربية
              Locale('en', 'US'), // الإنجليزية
            ],

            // الشاشة الأولى
            home: const SplashScreen(),

            // المسارات
            routes: {
              '/login': (context) => const LoginScreen(),
              '/home': (context) => const MainNavigationScreen(),
              '/ai': (context) => const AIMainScreen(),
              '/vr': (context) => const VRMainScreen(),
              '/analytics': (context) => const AnalyticsDashboardScreen(),
              '/gamification': (context) =>
                  const GamificationScreen(userId: 'demo'),
              '/social': (context) =>
                  const SocialCommunityScreen(userId: 'demo'),
              '/iot': (context) =>
                  const IoTMainScreen(carId: 'demo', userId: 'demo'),
            },
          );
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
    const AddCarScreenWrapper(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'البحث',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'إضافة',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
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
                  child:
                      _buildStatCard('السيارات', '1,234', Icons.directions_car),
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
                  () {
                    final authProvider = Provider.of<FirebaseAuthProvider>(
                        context,
                        listen: false);
                    if (!authProvider.isLoggedIn) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
                      );
                    } else if (authProvider.canAddCar()) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AddCarScreen()),
                      );
                    } else if (authProvider.needsApproval()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'حسابك قيد المراجعة، بانتظار موافقة الإدارة'),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('يجب تسجيل الدخول لإضافة سيارة'),
                        ),
                      );
                    }
                  },
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
                  () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('قريباً - ميزة تقييم السيارات')),
                  ),
                ),
                _buildActionCard(
                  'خدمة التوصيل',
                  Icons.local_shipping,
                  Colors.red,
                  () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ProfileScreen())),
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
            color: Colors.grey.withValues(alpha: 0.1),
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

  Widget _buildActionCard(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
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

// Wrapper لصفحة إضافة السيارة مع فحص تسجيل الدخول
class AddCarScreenWrapper extends StatelessWidget {
  const AddCarScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FirebaseAuthProvider>(
      builder: (context, authProvider, child) {
        if (!authProvider.isLoggedIn) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('إضافة سيارة'),
              backgroundColor: Colors.green,
            ),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.login,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'يجب تسجيل الدخول أولاً',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              label: const Text('تسجيل الدخول'),
              icon: const Icon(Icons.login),
            ),
          );
        } else if (!authProvider.canAddCar()) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('إضافة سيارة'),
              backgroundColor: Colors.green,
            ),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.block,
                    size: 80,
                    color: Colors.red,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'ليس لديك صلاحية لإضافة السيارات',
                    style: TextStyle(fontSize: 18, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'يرجى التواصل مع الإدارة',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        } else {
          return const AddCarScreen();
        }
      },
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
            onTap: () => _showComingSoonSnackBar(context, 'التحليلات'),
          ),
          ListTile(
            leading: const Icon(Icons.games),
            title: const Text('الألعاب'),
            onTap: () => _showComingSoonSnackBar(context, 'الألعاب'),
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('المجتمع'),
            onTap: () => _showComingSoonSnackBar(context, 'المجتمع'),
          ),
          ListTile(
            leading: const Icon(Icons.devices),
            title: const Text('إنترنت الأشياء'),
            onTap: () => _showComingSoonSnackBar(context, 'إنترنت الأشياء'),
          ),
          ListTile(
            leading: const Icon(Icons.view_in_ar),
            title: const Text('الواقع الافتراضي'),
            onTap: () => _showComingSoonSnackBar(context, 'الواقع الافتراضي'),
          ),
          ListTile(
            leading: const Icon(Icons.smart_toy),
            title: const Text('الذكاء الاصطناعي'),
            onTap: () => _showComingSoonSnackBar(context, 'الذكاء الاصطناعي'),
          ),
        ],
      ),
    );
  }

  void _showComingSoonSnackBar(BuildContext context, String feature) {
    Navigator.pop(context); // إغلاق القائمة الجانبية
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('قريباً - ميزة $feature')),
    );
  }
}
