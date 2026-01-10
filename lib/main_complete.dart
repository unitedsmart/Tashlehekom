import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Services
import 'services/logging_service.dart';
import 'services/enhanced_error_handler.dart';
import 'services/performance_service.dart';
import 'services/enhanced_cache_service.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/search/search_screen.dart';
import 'screens/car/add_car_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/ai/ai_main_screen.dart';
import 'screens/vr/vr_main_screen.dart';
import 'screens/analytics/analytics_dashboard_screen.dart';
import 'screens/gamification/gamification_screen.dart';
import 'screens/social/social_community_screen.dart';
import 'screens/iot/iot_main_screen.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';

/// تطبيق تشليحكم الكامل مع جميع الميزات
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // تهيئة Firebase
    await Firebase.initializeApp();
    
    // تهيئة الخدمات
    await _initializeServices();
    
    LoggingService.success('تم تشغيل التطبيق بنجاح');
  } catch (e, stackTrace) {
    LoggingService.error('خطأ في تشغيل التطبيق', error: e, stackTrace: stackTrace);
  }
  
  runApp(const TashlehekomApp());
}

/// تهيئة جميع الخدمات
Future<void> _initializeServices() async {
  await Future.wait([
    LoggingService.initialize(),
    EnhancedErrorHandler.initialize(),
    PerformanceService.initialize(),
    EnhancedCacheService.instance.initialize(),
  ]);
}

class TashlehekomApp extends StatelessWidget {
  const TashlehekomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'تشليحكم',
            debugShowCheckedModeBanner: false,
            
            // الثيم والألوان
            theme: _buildLightTheme(),
            darkTheme: _buildDarkTheme(),
            themeMode: themeProvider.themeMode,
            
            // اللغة والمحلية
            locale: const Locale('ar', 'SA'),
            supportedLocales: const [
              Locale('ar', 'SA'),
              Locale('en', 'US'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
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
              '/gamification': (context) => const GamificationScreen(),
              '/social': (context) => const SocialCommunityScreen(),
              '/iot': (context) => IOTMainScreen(carId: 'demo', userId: 'demo'),
            },
          );
        },
      ),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.green,
        brightness: Brightness.light,
      ),
      fontFamily: 'Cairo',
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.green,
        brightness: Brightness.dark,
      ),
      fontFamily: 'Cairo',
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
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
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const AddCarScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
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
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Colors.green),
                ),
                SizedBox(height: 10),
                Text(
                  'تشليحكم',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'منصة قطع غيار السيارات',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.smart_toy,
            title: 'الذكاء الاصطناعي',
            route: '/ai',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.view_in_ar,
            title: 'الواقع الافتراضي',
            route: '/vr',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.analytics,
            title: 'التحليلات',
            route: '/analytics',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.games,
            title: 'الألعاب والمكافآت',
            route: '/gamification',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.people,
            title: 'المجتمع',
            route: '/social',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.devices,
            title: 'إنترنت الأشياء',
            route: '/iot',
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('الإعدادات'),
            onTap: () {
              Navigator.pop(context);
              _showComingSoon(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('المساعدة'),
            onTap: () {
              Navigator.pop(context);
              _showComingSoon(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, route);
      },
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('هذه الميزة قيد التطوير...'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
