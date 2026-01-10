import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

/// خدمة Firebase الأساسية لإدارة جميع خدمات Firebase
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  // Firebase instances
  FirebaseAuth get auth => FirebaseAuth.instance;
  FirebaseFirestore get firestore => FirebaseFirestore.instance;
  FirebaseStorage get storage => FirebaseStorage.instance;
  FirebaseMessaging get messaging => FirebaseMessaging.instance;
  FirebaseAnalytics get analytics => FirebaseAnalytics.instance;

  /// تهيئة Firebase
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
      print('✅ Firebase initialized successfully');
      
      // تكوين Firestore للعمل في وضع offline
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
      
      print('✅ Firestore configured successfully');
    } catch (e) {
      print('❌ Firebase initialization failed: $e');
      rethrow;
    }
  }

  /// تهيئة Firebase Cloud Messaging
  Future<void> initializeMessaging() async {
    try {
      // طلب إذن الإشعارات
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('✅ User granted permission for notifications');
        
        // الحصول على FCM token
        String? token = await messaging.getToken();
        print('📱 FCM Token: $token');
        
        // الاستماع لتحديثات الـ token
        messaging.onTokenRefresh.listen((newToken) {
          print('🔄 FCM Token refreshed: $newToken');
          // يمكن حفظ الـ token الجديد في قاعدة البيانات هنا
        });
        
      } else {
        print('❌ User declined or has not accepted permission for notifications');
      }
    } catch (e) {
      print('❌ FCM initialization failed: $e');
    }
  }

  /// تسجيل حدث في Firebase Analytics
  Future<void> logEvent(String eventName, Map<String, Object>? parameters) async {
    try {
      await analytics.logEvent(
        name: eventName,
        parameters: parameters,
      );
      print('📊 Analytics event logged: $eventName');
    } catch (e) {
      print('❌ Analytics event failed: $e');
    }
  }

  /// تسجيل تسجيل دخول المستخدم في Analytics
  Future<void> logLogin(String method) async {
    await logEvent('login', {'login_method': method});
  }

  /// تسجيل تسجيل خروج المستخدم في Analytics
  Future<void> logSignUp(String method) async {
    await logEvent('sign_up', {'sign_up_method': method});
  }

  /// تسجيل عرض شاشة في Analytics
  Future<void> logScreenView(String screenName) async {
    await analytics.logScreenView(screenName: screenName);
  }

  /// التحقق من حالة الاتصال بالإنترنت
  Future<bool> isConnected() async {
    try {
      // محاولة الوصول إلى Firestore للتحقق من الاتصال
      await firestore.doc('test/connection').get();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// تنظيف الموارد
  void dispose() {
    // تنظيف أي موارد إذا لزم الأمر
  }
}

/// معالج الرسائل في الخلفية لـ FCM
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('📱 Background message received: ${message.messageId}');
  print('📱 Title: ${message.notification?.title}');
  print('📱 Body: ${message.notification?.body}');
}
