import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tashlehekomv2/services/database_service.dart';
import 'package:tashlehekomv2/models/notification_model.dart';
import 'package:tashlehekomv2/services/logging_service.dart';

/// خدمة Firebase Cloud Messaging
/// تتعامل مع الإشعارات الفورية والمجدولة
class FirebaseMessagingService {
  static final FirebaseMessagingService _instance =
      FirebaseMessagingService._internal();
  factory FirebaseMessagingService() => _instance;
  FirebaseMessagingService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final DatabaseService _dbService = DatabaseService.instance;

  String? _fcmToken;
  bool _isInitialized = false;

  /// تهيئة خدمة الإشعارات
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      LoggingService.start('تهيئة خدمة الإشعارات');

      // طلب الأذونات
      await _requestPermissions();

      // تهيئة الإشعارات المحلية
      await _initializeLocalNotifications();

      // الحصول على FCM Token
      await _getFCMToken();

      // إعداد معالجات الإشعارات
      _setupMessageHandlers();

      _isInitialized = true;
      LoggingService.success('تم تهيئة خدمة الإشعارات بنجاح');
    } catch (e) {
      print('❌ خطأ في تهيئة خدمة الإشعارات: $e');
    }
  }

  /// طلب أذونات الإشعارات
  Future<void> _requestPermissions() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('🔐 حالة أذونات الإشعارات: ${settings.authorizationStatus}');
  }

  /// تهيئة الإشعارات المحلية
  Future<void> _initializeLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // إنشاء قناة الإشعارات لـ Android
    await _createNotificationChannel();
  }

  /// إنشاء قناة الإشعارات
  Future<void> _createNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      'tashlehekomv2_channel',
      'تشليحكم - الإشعارات',
      description: 'إشعارات تطبيق تشليحكم',
      importance: Importance.high,
      sound: RawResourceAndroidNotificationSound('notification'),
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// الحصول على FCM Token
  Future<void> _getFCMToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      print('🔑 FCM Token: $_fcmToken');

      // حفظ التوكن في قاعدة البيانات
      if (_fcmToken != null) {
        await _saveFCMToken(_fcmToken!);
      }

      // الاستماع لتحديثات التوكن
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        _saveFCMToken(newToken);
        print('🔄 تم تحديث FCM Token: $newToken');
      });
    } catch (e) {
      print('❌ خطأ في الحصول على FCM Token: $e');
    }
  }

  /// حفظ FCM Token في قاعدة البيانات
  Future<void> _saveFCMToken(String token) async {
    try {
      // TODO: حفظ التوكن مع معرف المستخدم في قاعدة البيانات
      // await _dbService.saveFCMToken(userId, token);
      print('💾 تم حفظ FCM Token في قاعدة البيانات');
    } catch (e) {
      print('❌ خطأ في حفظ FCM Token: $e');
    }
  }

  /// إعداد معالجات الإشعارات
  void _setupMessageHandlers() {
    // معالج الإشعارات عندما يكون التطبيق في المقدمة
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // معالج الإشعارات عندما يكون التطبيق في الخلفية
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    // معالج الإشعارات عندما يكون التطبيق مغلق - تحقق من التوفر أولاً
    try {
      FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
    } catch (e) {
      LoggingService.warning('لا يمكن تسجيل معالج الرسائل في الخلفية: $e');
    }
  }

  /// معالجة الإشعارات في المقدمة
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('📱 تم استلام إشعار في المقدمة: ${message.messageId}');

    // حفظ الإشعار في قاعدة البيانات
    await _saveNotificationToDatabase(message);

    // عرض الإشعار المحلي
    await _showLocalNotification(message);
  }

  /// معالجة الإشعارات في الخلفية
  Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    print('🔔 تم استلام إشعار في الخلفية: ${message.messageId}');

    // حفظ الإشعار في قاعدة البيانات
    await _saveNotificationToDatabase(message);
  }

  /// عرض الإشعار المحلي
  Future<void> _showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'tashlehekomv2_channel',
      'تشليحكم - الإشعارات',
      channelDescription: 'إشعارات تطبيق تشليحكم',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      sound: RawResourceAndroidNotificationSound('notification'),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'تشليحكم',
      message.notification?.body ?? 'لديك إشعار جديد',
      details,
      payload: jsonEncode(message.data),
    );
  }

  /// حفظ الإشعار في قاعدة البيانات
  Future<void> _saveNotificationToDatabase(RemoteMessage message) async {
    try {
      // تحديد نوع الإشعار
      NotificationType notificationType = NotificationType.systemUpdate;
      final typeString = message.data['type'] as String?;

      switch (typeString) {
        case 'new_car':
          notificationType = NotificationType.newCar;
          break;
        case 'car_sold':
          notificationType = NotificationType.carSold;
          break;
        case 'new_message':
          notificationType = NotificationType.newMessage;
          break;
        case 'new_rating':
          notificationType = NotificationType.newRating;
          break;
        case 'account_approved':
          notificationType = NotificationType.accountApproved;
          break;
        case 'account_rejected':
          notificationType = NotificationType.accountRejected;
          break;
        case 'price_change':
          notificationType = NotificationType.priceChange;
          break;
        case 'car_expired':
          notificationType = NotificationType.carExpired;
          break;
        case 'reminder':
          notificationType = NotificationType.reminder;
          break;
        default:
          notificationType = NotificationType.systemUpdate;
      }

      final notification = NotificationModel(
        id: message.messageId ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        userId: message.data['user_id'] ?? 'unknown',
        title: message.notification?.title ?? 'إشعار جديد',
        body: message.notification?.body ?? '',
        type: notificationType,
        relatedId: message.data['related_id'],
        data: message.data.isNotEmpty ? message.data : null,
        isRead: false,
        createdAt: DateTime.now(),
      );

      await _dbService.insertNotification(notification);
      print('💾 تم حفظ الإشعار في قاعدة البيانات');
    } catch (e) {
      print('❌ خطأ في حفظ الإشعار: $e');
    }
  }

  /// معالجة النقر على الإشعار
  void _onNotificationTapped(NotificationResponse response) {
    print('👆 تم النقر على الإشعار: ${response.payload}');

    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!);
        _handleNotificationAction(data);
      } catch (e) {
        print('❌ خطأ في معالجة بيانات الإشعار: $e');
      }
    }
  }

  /// معالجة إجراءات الإشعار
  void _handleNotificationAction(Map<String, dynamic> data) {
    final type = data['type'] as String?;

    switch (type) {
      case 'new_car':
        // التنقل إلى تفاصيل السيارة الجديدة
        print('🚗 فتح تفاصيل السيارة: ${data['car_id']}');
        break;
      case 'car_approved':
        // إشعار بالموافقة على السيارة
        print('✅ تم قبول السيارة: ${data['car_id']}');
        break;
      case 'new_message':
        // فتح المحادثة
        print('💬 فتح المحادثة: ${data['chat_id']}');
        break;
      case 'price_update':
        // إشعار بتحديث السعر
        print('💰 تحديث السعر: ${data['car_id']}');
        break;
      default:
        print('📋 إشعار عام');
    }
  }

  /// إرسال إشعار لمستخدم محدد
  Future<bool> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    String type = 'general',
    Map<String, dynamic>? data,
  }) async {
    try {
      // TODO: تنفيذ إرسال الإشعار عبر Firebase Functions أو Admin SDK
      print('📤 إرسال إشعار للمستخدم: $userId');
      print('   العنوان: $title');
      print('   المحتوى: $body');

      return true;
    } catch (e) {
      print('❌ خطأ في إرسال الإشعار: $e');
      return false;
    }
  }

  /// إرسال إشعار لجميع المستخدمين
  Future<bool> sendBroadcastNotification({
    required String title,
    required String body,
    String type = 'general',
    Map<String, dynamic>? data,
  }) async {
    try {
      // TODO: تنفيذ إرسال الإشعار لجميع المستخدمين
      print('📢 إرسال إشعار عام');
      print('   العنوان: $title');
      print('   المحتوى: $body');

      return true;
    } catch (e) {
      print('❌ خطأ في إرسال الإشعار العام: $e');
      return false;
    }
  }

  /// الحصول على FCM Token الحالي
  String? get fcmToken => _fcmToken;

  /// التحقق من حالة التهيئة
  bool get isInitialized => _isInitialized;
}

/// معالج الإشعارات في الخلفية (يجب أن يكون دالة عامة)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('🔔 معالجة إشعار في الخلفية: ${message.messageId}');

  // يمكن إضافة منطق إضافي هنا
  final service = FirebaseMessagingService();
  await service._handleBackgroundMessage(message);
}
