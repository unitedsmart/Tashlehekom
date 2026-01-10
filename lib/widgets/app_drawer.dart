import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tashlehekomv2/providers/firebase_auth_provider.dart';
import 'package:tashlehekomv2/providers/language_provider.dart';
import 'package:tashlehekomv2/screens/auth/login_screen.dart';
import 'package:tashlehekomv2/screens/favorites/favorites_screen.dart';
import 'package:tashlehekomv2/screens/reports/report_screen.dart';
import 'package:tashlehekomv2/screens/notifications/notifications_screen.dart';
// import 'package:tashlehekomv2/screens/analytics/advanced_analytics_screen.dart';
// import 'package:tashlehekomv2/screens/reports/report_screen.dart';
import 'package:tashlehekomv2/screens/settings/language_settings_screen.dart';
import 'package:tashlehekomv2/screens/admin/admin_panel_screen.dart';
import 'package:tashlehekomv2/models/user_model.dart';
import 'package:tashlehekomv2/l10n/app_localizations.dart';
import '../screens/ai/ai_main_screen.dart';
import '../screens/vr/vr_main_screen.dart';
import '../screens/analytics/analytics_main_screen.dart';
import '../screens/gamification/gamification_main_screen.dart';
import '../screens/social/social_main_screen.dart';
import '../screens/iot/iot_main_screen.dart';
import '../screens/crypto/crypto_main_screen.dart';
import '../screens/finance/finance_main_screen.dart';
import '../screens/ar/ar_main_screen.dart';
import '../screens/delivery/delivery_main_screen.dart';
import '../screens/space/space_main_screen.dart';
import '../screens/quantum/quantum_main_screen.dart';
import '../screens/parts/parts_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authProvider = Provider.of<FirebaseAuthProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final user = authProvider.currentUser;

    return Drawer(
      child: Column(
        children: [
          // Header
          _buildDrawerHeader(context, user, languageProvider),

          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // الصفحة الرئيسية
                ListTile(
                  leading: const Icon(Icons.home),
                  title: Text(l10n.home),
                  onTap: () => Navigator.pop(context),
                ),

                if (user != null) ...[
                  const Divider(),

                  // المفضلة
                  ListTile(
                    leading: const Icon(Icons.favorite),
                    title: Text(
                        languageProvider.isArabic ? 'المفضلة' : 'Favorites'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FavoritesScreen(),
                        ),
                      );
                    },
                  ),

                  // قطع الغيار
                  ListTile(
                    leading:
                        const Icon(Icons.build_circle, color: Colors.orange),
                    title: Text(languageProvider.isArabic
                        ? 'قطع الغيار'
                        : 'Spare Parts'),
                    subtitle: Text(languageProvider.isArabic
                        ? 'تصفح قطع الغيار المتاحة'
                        : 'Browse available spare parts'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        languageProvider.isArabic ? 'جديد' : 'New',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PartsScreen(),
                        ),
                      );
                    },
                  ),

                  // الإشعارات
                  ListTile(
                    leading: const Icon(Icons.notifications),
                    title: Text(languageProvider.isArabic
                        ? 'الإشعارات'
                        : 'Notifications'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationsScreen(),
                        ),
                      );
                    },
                  ),

                  // الإحصائيات (للإدارة فقط)
                  if (user.phoneNumber == '0508423246')
                    ListTile(
                      leading: const Icon(Icons.analytics),
                      title: Text(languageProvider.isArabic
                          ? 'الإحصائيات المتقدمة'
                          : 'Advanced Analytics'),
                      trailing: Text(
                          languageProvider.isArabic ? 'قريباً' : 'Soon',
                          style: const TextStyle(color: Colors.grey)),
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(languageProvider.isArabic
                                  ? 'الإحصائيات المتقدمة ستكون متاحة قريباً'
                                  : 'Advanced Analytics will be available soon')),
                        );
                      },
                    ),

                  // لوحة الإدارة (للإدارة فقط)
                  if (user.phoneNumber == '0508423246')
                    ListTile(
                      leading: const Icon(Icons.admin_panel_settings),
                      title: Text(languageProvider.isArabic
                          ? 'لوحة الإدارة'
                          : 'Admin Panel'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AdminPanelScreen(),
                          ),
                        );
                      },
                    ),
                ],

                const Divider(),

                // الإعدادات
                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(l10n.language),
                  trailing: Text(
                    languageProvider.isArabic ? 'العربية' : 'English',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LanguageSettingsScreen(),
                      ),
                    );
                  },
                ),

                const Divider(),

                // الميزات المتقدمة الجديدة
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    languageProvider.isArabic
                        ? 'الميزات المتقدمة'
                        : 'Advanced Features',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                ),

                ListTile(
                  leading: const Icon(Icons.psychology, color: Colors.purple),
                  title: Text(languageProvider.isArabic
                      ? 'الذكاء الاصطناعي'
                      : 'Artificial Intelligence'),
                  subtitle: Text(languageProvider.isArabic
                      ? 'تقييم وتوصيات ذكية'
                      : 'Smart evaluation and recommendations'),
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.purple,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      languageProvider.isArabic ? 'جديد' : 'New',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AIMainScreen(),
                      ),
                    );
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.mic, color: Colors.deepPurple),
                  title: Text(languageProvider.isArabic
                      ? 'المساعد الصوتي'
                      : 'Voice Assistant'),
                  subtitle: Text(languageProvider.isArabic
                      ? 'تفاعل صوتي ذكي'
                      : 'Smart voice interaction'),
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'AI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/voice_assistant');
                  },
                ),

                ListTile(
                  leading:
                      const Icon(Icons.view_in_ar_outlined, color: Colors.teal),
                  title: Text(languageProvider.isArabic
                      ? 'الواقع الافتراضي'
                      : 'Virtual Reality'),
                  subtitle: Text(languageProvider.isArabic
                      ? 'جولات VR وميتافيرس'
                      : 'VR tours and metaverse'),
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.teal,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'VR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const VRMainScreen(),
                      ),
                    );
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.analytics, color: Colors.blue),
                  title: const Text('التحليلات المتقدمة'),
                  subtitle: const Text('بيانات ضخمة وذكاء أعمال'),
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'BigData',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AnalyticsMainScreen(),
                      ),
                    );
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.games, color: Colors.pink),
                  title: const Text('الألعاب والمكافآت'),
                  subtitle: const Text('نقاط ولاء وتحديات'),
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.pink,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Game',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GamificationMainScreen(),
                      ),
                    );
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.people, color: Colors.cyan),
                  title: const Text('المجتمع الاجتماعي'),
                  subtitle: const Text('منتديات ومشاركة تجارب'),
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.cyan,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Social',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SocialMainScreen(),
                      ),
                    );
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.router, color: Colors.brown),
                  title: const Text('إنترنت الأشياء'),
                  subtitle: const Text('سيارات ذكية وتشخيص عن بُعد'),
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.brown,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'IoT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => IoTMainScreen(
                          carId: 'demo_car_id',
                          userId: 'demo_user_id',
                        ),
                      ),
                    );
                  },
                ),

                const Divider(),

                // لوحة الإدارة
                ListTile(
                  leading: const Icon(Icons.admin_panel_settings,
                      color: Colors.purple),
                  title: const Text('لوحة الإدارة'),
                  subtitle: const Text('إدارة السيارات والموافقات'),
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.purple,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Admin',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/admin_login');
                  },
                ),
                const Divider(),

                // الميزات المستقبلية المتطورة
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'الميزات المستقبلية',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                ),

                // الذكاء الاصطناعي الكمي
                ListTile(
                  leading: const Icon(Icons.psychology, color: Colors.indigo),
                  title: const Text('الذكاء الاصطناعي الكمي'),
                  subtitle: const Text('حوسبة كمية وذكاء فائق'),
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.indigo,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Quantum',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const QuantumMainScreen(),
                      ),
                    );
                  },
                ),

                // تقنيات الفضاء
                ListTile(
                  leading:
                      const Icon(Icons.rocket_launch, color: Colors.deepOrange),
                  title: const Text('تقنيات الفضاء'),
                  subtitle: const Text('السيارات الفضائية والاستكشاف الكوني'),
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.deepOrange,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Space',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SpaceMainScreen(),
                      ),
                    );
                  },
                ),

                // السفر عبر الزمن
                ListTile(
                  leading: const Icon(Icons.access_time, color: Colors.amber),
                  title: const Text('السفر عبر الزمن'),
                  subtitle: const Text('آلات الزمن والمفارقات الزمنية'),
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Time',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('السفر عبر الزمن - قريباً في v5.0...'),
                        backgroundColor: Colors.amber,
                      ),
                    );
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.gavel, color: Colors.red),
                  title: const Text('المزادات المباشرة'),
                  subtitle: const Text('مزادات حية مع بث مباشر'),
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'مباشر',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('المزادات المباشرة ستكون متاحة قريباً'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.view_in_ar, color: Colors.orange),
                  title: const Text('الواقع المعزز'),
                  subtitle: const Text('فحص السيارات بالكاميرا'),
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'AR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ARMainScreen(),
                      ),
                    );
                  },
                ),

                ListTile(
                  leading:
                      const Icon(Icons.account_balance, color: Colors.green),
                  title: const Text('التمويل والتقسيط'),
                  subtitle: const Text('حلول تمويل متنوعة'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FinanceMainScreen(),
                      ),
                    );
                  },
                ),

                ListTile(
                  leading:
                      const Icon(Icons.currency_bitcoin, color: Colors.amber),
                  title: const Text('العملات الرقمية'),
                  subtitle: const Text('دفع بالبلوك تشين'),
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Web3',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CryptoMainScreen(),
                      ),
                    );
                  },
                ),

                ListTile(
                  leading:
                      const Icon(Icons.local_shipping, color: Colors.indigo),
                  title: const Text('التوصيل والشحن'),
                  subtitle: const Text('خدمات لوجستية متكاملة'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DeliveryMainScreen(),
                      ),
                    );
                  },
                ),

                const Divider(),

                // البلاغات والاقتراحات
                ListTile(
                  leading: const Icon(Icons.report),
                  title: const Text('بلاغ أو اقتراح'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ReportScreen(),
                      ),
                    );
                  },
                ),

                // معلومات التطبيق
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('حول التطبيق'),
                  onTap: () => _showAboutDialog(context),
                ),

                if (user != null) ...[
                  const Divider(),

                  // تسجيل الخروج
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      'تسجيل الخروج',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () => _showLogoutDialog(context, authProvider),
                  ),
                ] else ...[
                  const Divider(),

                  // تسجيل الدخول
                  ListTile(
                    leading: const Icon(Icons.login, color: Colors.green),
                    title: const Text(
                      'تسجيل الدخول',
                      style: TextStyle(color: Colors.green),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),

          // Footer
          _buildDrawerFooter(context),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(
    BuildContext context,
    UserModel? user,
    LanguageProvider languageProvider,
  ) {
    return UserAccountsDrawerHeader(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
        ),
      ),
      accountName: Text(
        user?.username ?? 'زائر',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      accountEmail: Text(
        user?.phoneNumber ?? 'غير مسجل',
        style: const TextStyle(fontSize: 14),
      ),
      currentAccountPicture: CircleAvatar(
        backgroundColor: Colors.white,
        child: Icon(
          user != null ? Icons.person : Icons.person_outline,
          size: 40,
          color: Theme.of(context).primaryColor,
        ),
      ),
      otherAccountsPictures: [
        IconButton(
          icon: Icon(
            languageProvider.isArabic ? Icons.translate : Icons.g_translate,
            color: Colors.white,
          ),
          onPressed: () {
            languageProvider.toggleLanguage();
          },
        ),
      ],
    );
  }

  Widget _buildDrawerFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Text(
            'تطبيق تشليحكم',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'الإصدار 2.0.0',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.phone,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                '0508423246',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'تشليحكم',
      applicationVersion: '4.0.0 - Ultimate Experience',
      applicationIcon: const Icon(
        Icons.directions_car,
        size: 48,
      ),
      children: [
        const Text(
          'تطبيق تشليحكم هو منصة شاملة لبيع وشراء السيارات وقطع الغيار المستعملة في المملكة العربية السعودية.',
        ),
        const SizedBox(height: 16),
        const Text('الميزات الجديدة في الإصدار 2.0:'),
        const SizedBox(height: 8),
        const Text('• نظام الإشعارات المتقدم'),
        const Text('• المفضلة والبحوث المحفوظة'),
        const Text('• مقارنة السيارات'),
        const Text('• الإحصائيات المتقدمة'),
        const Text('• نظام التقارير والشكاوى'),
        const Text('• تحسينات في الأداء والأمان'),
      ],
    );
  }

  void _showLogoutDialog(
      BuildContext context, FirebaseAuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل تريد تسجيل الخروج من التطبيق؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // إغلاق الحوار
              Navigator.pop(context); // إغلاق الدرج
              authProvider.logout();
            },
            child: const Text(
              'تسجيل الخروج',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
