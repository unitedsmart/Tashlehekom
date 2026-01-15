import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tashlehekomv2/providers/firebase_auth_provider.dart';
import 'package:tashlehekomv2/providers/car_provider.dart';
import 'package:tashlehekomv2/providers/language_provider.dart';
import 'package:tashlehekomv2/screens/auth/login_screen.dart';
import 'package:tashlehekomv2/screens/car/add_car_screen.dart';
import 'package:tashlehekomv2/screens/car/car_details_screen.dart';
import 'package:tashlehekomv2/screens/settings/language_settings_screen.dart';
import 'package:tashlehekomv2/screens/profile/profile_screen.dart';
import 'package:tashlehekomv2/screens/notifications/notifications_screen.dart';
import 'package:tashlehekomv2/screens/parts/parts_screen.dart';
import 'package:tashlehekomv2/screens/parts/my_requests_screen.dart';
import 'package:tashlehekomv2/screens/parts/create_part_request_screen.dart';
import 'package:tashlehekomv2/screens/parts/shop_requests_screen.dart';
import 'package:tashlehekomv2/models/user_model.dart';
import 'package:tashlehekomv2/screens/search_screen.dart';
import 'package:tashlehekomv2/widgets/car_card.dart';
import 'package:tashlehekomv2/widgets/search_filter_bar.dart';
import 'package:tashlehekomv2/widgets/app_drawer.dart';
import 'package:tashlehekomv2/l10n/app_localizations.dart';
import 'package:tashlehekomv2/services/database_service.dart';
import 'package:tashlehekomv2/services/firebase_firestore_service.dart';
import 'package:tashlehekomv2/services/error_handling_service.dart';
import 'package:tashlehekomv2/models/car_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestoreService _firestoreService = FirebaseFirestoreService();
  final ErrorHandlingService _errorHandler = ErrorHandlingService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    final authProvider =
        Provider.of<FirebaseAuthProvider>(context, listen: false);
    final carProvider = Provider.of<CarProvider>(context, listen: false);

    await authProvider.checkAuthStatus();

    // تحميل البيانات الأساسية
    await carProvider.loadCarBrands();
    await carProvider.loadCities();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 32,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.directions_car, size: 32);
              },
            ),
            const SizedBox(width: 8),
            Consumer<LanguageProvider>(
              builder: (context, languageProvider, child) {
                final localizations = AppLocalizations.of(context)!;
                return Text(localizations.appName);
              },
            ),
          ],
        ),
        actions: [
          // Login/Notifications button
          Consumer<FirebaseAuthProvider>(
            builder: (context, authProvider, child) {
              if (authProvider.isLoggedIn) {
                return IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationsScreen(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.notifications,
                    color: Colors.white,
                  ),
                  tooltip: 'الإشعارات',
                );
              } else {
                // زر تسجيل الدخول للزوار
                return TextButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  icon: const Icon(
                    Icons.login,
                    color: Colors.white,
                    size: 20,
                  ),
                  label: const Text(
                    'دخول',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                );
              }
            },
          ),

          // Language toggle button
          Consumer<LanguageProvider>(
            builder: (context, languageProvider, child) {
              return IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LanguageSettingsScreen(),
                    ),
                  );
                },
                icon: Icon(
                  Icons.language,
                  color: Colors.white,
                ),
                tooltip: languageProvider.isArabic
                    ? 'تغيير اللغة'
                    : 'Change Language',
              );
            },
          ),
          Consumer<FirebaseAuthProvider>(
            builder: (context, authProvider, child) {
              if (authProvider.isLoggedIn) {
                return PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'profile':
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfileScreen(),
                          ),
                        );
                        break;
                      case 'logout':
                        authProvider.logout();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'profile',
                      child: Row(
                        children: [
                          const Icon(Icons.person),
                          const SizedBox(width: 8),
                          Text(authProvider.currentUser?.username ?? ''),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'logout',
                      child: Consumer<LanguageProvider>(
                        builder: (context, languageProvider, child) {
                          return Row(
                            children: [
                              const Icon(Icons.logout),
                              const SizedBox(width: 8),
                              Text(languageProvider.isArabic
                                  ? 'تسجيل الخروج'
                                  : 'Logout'),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                );
              } else {
                return TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()),
                    );
                  },
                  child: Consumer<LanguageProvider>(
                    builder: (context, languageProvider, child) {
                      return Text(
                        languageProvider.isArabic ? 'تسجيل الدخول' : 'Login',
                        style: const TextStyle(color: Colors.white),
                      );
                    },
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // صورة ثابتة في أعلى التطبيق - Header Banner
          Container(
            width: double.infinity,
            height: 180,
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF2E7D32),
                      Color(0xFF4CAF50),
                      Color(0xFF66BB6A),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Decorative circles
                    Positioned(
                      top: 20,
                      left: 50,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 30,
                      right: 80,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),

                    // Car icon
                    const Positioned(
                      right: 30,
                      top: 40,
                      child: Text(
                        '🚗',
                        style: TextStyle(
                          fontSize: 48,
                          color: Colors.white24,
                        ),
                      ),
                    ),

                    // Main content
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'تشليحكم',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.3),
                                  offset: const Offset(2, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'أفضل مكان لبيع وشراء قطع غيار السيارات',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.3),
                                  offset: const Offset(1, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // إحصائيات سريعة - بيانات حقيقية من Firebase
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'إحصائيات سريعة',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                FutureBuilder<Map<String, dynamic>>(
                  future: _firestoreService.getStatistics(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Row(
                        children: [
                          Expanded(
                            child: _buildStatCard('...', 'السيارات',
                                Icons.directions_car, Colors.green),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard('...', 'قطع الغيار',
                                Icons.build, Colors.orange),
                          ),
                        ],
                      );
                    }

                    final stats = snapshot.data ?? {};
                    final carsCount = stats['activeCars'] ?? 0;

                    return Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(carsCount.toString(),
                              'السيارات', Icons.directions_car, Colors.green),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                              '0', 'قطع الغيار', Icons.build, Colors.orange),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          // إجراءات سريعة
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'إجراءات سريعة',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionCard(
                          'تصفح السيارات', Icons.directions_car, Colors.green,
                          () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SearchScreen(),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionCard(
                          'طلب قطعة غيار', Icons.build, Colors.orange, () {
                        final authProvider = Provider.of<FirebaseAuthProvider>(
                            context,
                            listen: false);
                        if (authProvider.isLoggedIn) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const CreatePartRequestScreen(),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        }
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionCard(
                          'طلباتي', Icons.list_alt, Colors.blue, () {
                        final authProvider = Provider.of<FirebaseAuthProvider>(
                            context,
                            listen: false);
                        if (authProvider.isLoggedIn) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MyRequestsScreen(),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        }
                      }),
                    ),
                    const SizedBox(width: 12),
                    // زر للتشاليح فقط
                    Consumer<FirebaseAuthProvider>(
                      builder: (context, auth, _) {
                        final user = auth.currentUser;
                        final isShop = user != null &&
                            (user.userType == UserType.junkyardOwner ||
                                user.userType == UserType.worker);
                        return Expanded(
                          child: _buildActionCard(
                              isShop ? 'الطلبات الواردة' : 'قطع الغيار',
                              isShop ? Icons.inbox : Icons.build,
                              Colors.purple, () {
                            if (isShop) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ShopRequestsScreen(),
                                ),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const PartsScreen(),
                                ),
                              );
                            }
                          }),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Search and filter bar
          const SearchFilterBar(),

          // Cars list
          Expanded(
            child: StreamBuilder<List<CarModel>>(
              stream: _firestoreService.getCarsStream(
                isActive: true,
                limit: 50,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorHandler.handleGenericError(snapshot.error),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {}); // إعادة بناء الـ StreamBuilder
                          },
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  );
                }

                final cars = snapshot.data ?? [];

                if (cars.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.directions_car_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'لا توجد سيارات متاحة حالياً',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'جاري تحميل البيانات التجريبية...',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {}); // إعادة تحميل
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('إعادة التحميل'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    // إعادة بناء الـ StreamBuilder
                    setState(() {});
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: cars.length,
                    itemBuilder: (context, index) {
                      final car = cars[index];
                      return CarCard(
                        car: car,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CarDetailsScreen(car: car),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Consumer<FirebaseAuthProvider>(
        builder: (context, authProvider, child) {
          return FloatingActionButton.extended(
            onPressed: () {
              if (!authProvider.isLoggedIn) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              } else if (authProvider.canAddCar()) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddCarScreen()),
                );
              } else if (authProvider.needsApproval()) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('حسابك قيد المراجعة، بانتظار موافقة الإدارة'),
                  ),
                );
              } else {
                // Contact admin for individuals who want to sell
                _showContactAdminDialog(context);
              }
            },
            icon: const Icon(Icons.add),
            label: Consumer<LanguageProvider>(
              builder: (context, languageProvider, child) {
                return Text(languageProvider.isArabic
                    ? 'أضف سيارة أو قطعة'
                    : 'Add Car or Part');
              },
            ),
          );
        },
      ),
    );
  }

  void _showContactAdminDialog(BuildContext context) {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            languageProvider.isArabic ? 'التواصل مع الإدارة' : 'Contact Admin'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(languageProvider.isArabic
                ? 'للتواصل مع الإدارة:'
                : 'To contact admin:'),
            const SizedBox(height: 8),
            Text(languageProvider.isArabic
                ? 'البريد الإلكتروني: acc.ibrahim.arboud@gmail.com'
                : 'Email: acc.ibrahim.arboud@gmail.com'),
            Text(languageProvider.isArabic
                ? 'رقم الجوال: +966508423246'
                : 'Phone: +966508423246'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(languageProvider.isArabic ? 'حسناً' : 'OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
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
            label,
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
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
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
