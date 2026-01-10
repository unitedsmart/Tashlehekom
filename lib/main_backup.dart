import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tashlehekomv2/firebase_options.dart';
import 'package:tashlehekomv2/providers/firebase_auth_provider.dart';
import 'package:tashlehekomv2/providers/car_provider.dart';
import 'package:tashlehekomv2/providers/user_provider.dart';
import 'package:tashlehekomv2/providers/language_provider.dart';
import 'package:tashlehekomv2/screens/home_screen.dart';
import 'package:tashlehekomv2/screens/voice_ai/voice_assistant_screen.dart';
import 'package:tashlehekomv2/screens/admin/admin_login_screen.dart';
import 'package:tashlehekomv2/services/database_service.dart';
import 'package:tashlehekomv2/services/firebase_service.dart';
import 'package:tashlehekomv2/services/firebase_messaging_service.dart';
import 'package:tashlehekomv2/services/cache_service.dart';
import 'package:tashlehekomv2/services/sync_service.dart';
import 'package:tashlehekomv2/services/error_handling_service.dart';
import 'package:tashlehekomv2/services/security_service.dart';
import 'package:tashlehekomv2/services/activity_monitor_service.dart';
import 'package:tashlehekomv2/services/enhanced_error_handler.dart';
import 'package:tashlehekomv2/services/performance_service.dart';
import 'package:tashlehekomv2/services/enhanced_cache_service.dart';
import 'package:tashlehekomv2/services/logging_service.dart';
import 'package:tashlehekomv2/utils/app_theme.dart';
import 'package:tashlehekomv2/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Enhanced Error Handler
    await EnhancedErrorHandler.initialize();

    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    LoggingService.firebase('Firebase initialized successfully');

    // Initialize Firebase services
    await FirebaseService.initialize();
    LoggingService.firebase('Firestore configured successfully');

    // Initialize Enhanced Cache Service
    await EnhancedCacheService().initialize();

    // Initialize Firebase Messaging
    await FirebaseMessagingService().initialize();

    // Initialize Cache Service (for compatibility)
    await CacheService().initialize();

    // Initialize Sync Service
    await SyncService().initialize();

    // Initialize Security Services
    await ActivityMonitorService().initialize();

    // Initialize database (keeping for migration purposes)
    await DatabaseService.instance.database;

    LoggingService.success('تم تهيئة جميع خدمات التطبيق بنجاح');
    runApp(const TashlehekomApp());
  } catch (e, stackTrace) {
    LoggingService.error('خطأ في تهيئة التطبيق',
        error: e, stackTrace: stackTrace);
    // Run app anyway with basic functionality
    runApp(const TashlehekomApp());
  }
}

class TashlehekomApp extends StatelessWidget {
  const TashlehekomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => FirebaseAuthProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => CarProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
          return MaterialApp(
            title: context.watch<LanguageProvider>().isArabic
                ? 'تشليحكم'
                : 'Tashlehekom',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            locale: languageProvider.currentLocale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const HomeScreen(),
            routes: {
              '/voice_assistant': (context) => const VoiceAssistantScreen(),
              '/admin_login': (context) => const AdminLoginScreen(),
            },
          );
        },
      ),
    );
  }
}
