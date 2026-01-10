import 'dart:async';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tashlehekomv2/models/user_model.dart';
import 'package:tashlehekomv2/services/firebase_firestore_service.dart';
import 'package:tashlehekomv2/services/security_service.dart';

/// خدمة مراقبة الأنشطة والسلوكيات المشبوهة
class ActivityMonitorService {
  static final ActivityMonitorService _instance =
      ActivityMonitorService._internal();
  factory ActivityMonitorService() => _instance;
  ActivityMonitorService._internal();

  final FirebaseFirestoreService _firestoreService = FirebaseFirestoreService();
  final SecurityService _securityService = SecurityService();

  // عدادات الأنشطة
  final Map<String, int> _activityCounts = {};
  final Map<String, DateTime> _lastActivityTime = {};

  // حدود الأنشطة المشبوهة
  static const int maxCarUploadsPerHour = 10;
  static const int maxSearchesPerMinute = 30;
  static const int maxFavoriteActionsPerMinute = 20;
  static const int maxReportsPerDay = 5;

  Timer? _cleanupTimer;

  /// تهيئة خدمة المراقبة
  Future<void> initialize() async {
    // تنظيف البيانات القديمة كل ساعة
    _cleanupTimer = Timer.periodic(const Duration(hours: 1), (_) {
      _cleanupOldData();
    });

    print('✅ تم تهيئة خدمة مراقبة الأنشطة');
  }

  /// تنظيف البيانات القديمة
  void _cleanupOldData() {
    final now = DateTime.now();
    final keysToRemove = <String>[];

    _lastActivityTime.forEach((key, time) {
      if (now.difference(time).inHours > 24) {
        keysToRemove.add(key);
      }
    });

    for (final key in keysToRemove) {
      _activityCounts.remove(key);
      _lastActivityTime.remove(key);
    }
  }

  /// تسجيل نشاط المستخدم
  Future<void> logUserActivity(
    String userId,
    String activityType, {
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final now = DateTime.now();
      final deviceInfo = await _getDeviceInfo();

      // تسجيل النشاط في Firebase
      await _firestoreService.users.add({
        'type': 'user_activity',
        'userId': userId,
        'activityType': activityType,
        'timestamp': now.toIso8601String(),
        'deviceInfo': deviceInfo,
        'metadata': metadata ?? {},
      });

      // فحص الأنشطة المشبوهة
      await _checkSuspiciousActivity(userId, activityType);
    } catch (e) {
      print('❌ خطأ في تسجيل نشاط المستخدم: $e');
    }
  }

  /// فحص الأنشطة المشبوهة
  Future<void> _checkSuspiciousActivity(
      String userId, String activityType) async {
    final key = '${userId}_$activityType';
    final now = DateTime.now();

    // تحديث العدادات
    _activityCounts[key] = (_activityCounts[key] ?? 0) + 1;
    _lastActivityTime[key] = now;

    bool isSuspicious = false;
    String reason = '';

    switch (activityType) {
      case 'car_upload':
        if (_getActivityCountInTimeFrame(key, const Duration(hours: 1)) >
            maxCarUploadsPerHour) {
          isSuspicious = true;
          reason = 'رفع عدد كبير من السيارات في وقت قصير';
        }
        break;

      case 'search':
        if (_getActivityCountInTimeFrame(key, const Duration(minutes: 1)) >
            maxSearchesPerMinute) {
          isSuspicious = true;
          reason = 'عدد كبير من عمليات البحث في دقيقة واحدة';
        }
        break;

      case 'favorite_add':
      case 'favorite_remove':
        if (_getActivityCountInTimeFrame(key, const Duration(minutes: 1)) >
            maxFavoriteActionsPerMinute) {
          isSuspicious = true;
          reason = 'عدد كبير من إجراءات المفضلة في دقيقة واحدة';
        }
        break;

      case 'report_submit':
        if (_getActivityCountInTimeFrame(key, const Duration(days: 1)) >
            maxReportsPerDay) {
          isSuspicious = true;
          reason = 'عدد كبير من البلاغات في يوم واحد';
        }
        break;
    }

    if (isSuspicious) {
      await _handleSuspiciousActivity(userId, activityType, reason);
    }
  }

  /// الحصول على عدد الأنشطة في إطار زمني محدد
  int _getActivityCountInTimeFrame(String key, Duration timeFrame) {
    final lastTime = _lastActivityTime[key];
    if (lastTime == null) return 0;

    final now = DateTime.now();
    if (now.difference(lastTime) <= timeFrame) {
      return _activityCounts[key] ?? 0;
    }

    return 0;
  }

  /// التعامل مع النشاط المشبوه
  Future<void> _handleSuspiciousActivity(
      String userId, String activityType, String reason) async {
    try {
      // تسجيل النشاط المشبوه
      await _securityService.logSuspiciousActivity(userId, activityType, {
        'reason': reason,
        'timestamp': DateTime.now().toIso8601String(),
        'activityCount': _activityCounts['${userId}_$activityType'] ?? 0,
      });

      // إرسال تنبيه للإداريين
      await _sendAdminAlert(userId, activityType, reason);

      // تطبيق إجراءات وقائية حسب نوع النشاط
      await _applyPreventiveMeasures(userId, activityType);
    } catch (e) {
      print('❌ خطأ في التعامل مع النشاط المشبوه: $e');
    }
  }

  /// إرسال تنبيه للإداريين
  Future<void> _sendAdminAlert(
      String userId, String activityType, String reason) async {
    try {
      // الحصول على قائمة الإداريين
      final admins = await _firestoreService.getAllUsers().then((users) => users
          .where((user) =>
              user.userType == UserType.admin ||
              user.userType == UserType.superAdmin)
          .toList());

      for (final admin in admins) {
        await _firestoreService.users.add({
          'type': 'admin_notification',
          'userId': admin.id,
          'title': 'تنبيه أمني',
          'body': 'تم رصد نشاط مشبوه من المستخدم $userId',
          'data': {
            'suspiciousUserId': userId,
            'activityType': activityType,
            'reason': reason,
            'timestamp': DateTime.now().toIso8601String(),
          },
          'isRead': false,
          'createdAt': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      print('❌ خطأ في إرسال تنبيه الإداريين: $e');
    }
  }

  /// تطبيق إجراءات وقائية
  Future<void> _applyPreventiveMeasures(
      String userId, String activityType) async {
    try {
      switch (activityType) {
        case 'car_upload':
          // تقييد رفع السيارات لمدة ساعة
          await _setUserRestriction(
              userId, 'car_upload', const Duration(hours: 1));
          break;

        case 'search':
          // تقييد البحث لمدة 10 دقائق
          await _setUserRestriction(
              userId, 'search', const Duration(minutes: 10));
          break;

        case 'favorite_add':
        case 'favorite_remove':
          // تقييد إجراءات المفضلة لمدة 5 دقائق
          await _setUserRestriction(
              userId, 'favorite_actions', const Duration(minutes: 5));
          break;

        case 'report_submit':
          // تقييد تقديم البلاغات لمدة 24 ساعة
          await _setUserRestriction(
              userId, 'report_submit', const Duration(hours: 24));
          break;
      }
    } catch (e) {
      print('❌ خطأ في تطبيق الإجراءات الوقائية: $e');
    }
  }

  /// تعيين قيود على المستخدم
  Future<void> _setUserRestriction(
      String userId, String restrictionType, Duration duration) async {
    try {
      final expiryTime = DateTime.now().add(duration);

      await _firestoreService.users.add({
        'type': 'user_restriction',
        'userId': userId,
        'restrictionType': restrictionType,
        'expiryTime': expiryTime.toIso8601String(),
        'createdAt': DateTime.now().toIso8601String(),
        'isActive': true,
      });

      print(
          '🔒 تم تطبيق قيد $restrictionType على المستخدم $userId حتى $expiryTime');
    } catch (e) {
      print('❌ خطأ في تعيين قيود المستخدم: $e');
    }
  }

  /// التحقق من وجود قيود على المستخدم
  Future<bool> isUserRestricted(String userId, String restrictionType) async {
    try {
      final restrictions = await _firestoreService.users
          .where('type', isEqualTo: 'user_restriction')
          .where('userId', isEqualTo: userId)
          .where('restrictionType', isEqualTo: restrictionType)
          .where('isActive', isEqualTo: true)
          .get();

      for (final doc in restrictions.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final expiryTime = DateTime.parse(data['expiryTime']);

        if (DateTime.now().isBefore(expiryTime)) {
          return true; // المستخدم مقيد
        } else {
          // انتهت صلاحية القيد، إلغاؤه
          await doc.reference.update({'isActive': false});
        }
      }

      return false;
    } catch (e) {
      print('❌ خطأ في التحقق من قيود المستخدم: $e');
      return false;
    }
  }

  /// الحصول على معلومات الجهاز
  Future<Map<String, dynamic>> _getDeviceInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final packageInfo = await PackageInfo.fromPlatform();

      Map<String, dynamic> info = {
        'appVersion': packageInfo.version,
        'buildNumber': packageInfo.buildNumber,
        'platform': Platform.operatingSystem,
      };

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        info.addAll({
          'deviceModel': androidInfo.model,
          'deviceBrand': androidInfo.brand,
          'androidVersion': androidInfo.version.release,
          'sdkVersion': androidInfo.version.sdkInt,
        });
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        info.addAll({
          'deviceModel': iosInfo.model,
          'deviceName': iosInfo.name,
          'systemVersion': iosInfo.systemVersion,
        });
      }

      return info;
    } catch (e) {
      return {'error': 'فشل في الحصول على معلومات الجهاز'};
    }
  }

  /// تسجيل محاولة وصول غير مصرح بها
  Future<void> logUnauthorizedAccess(
    String userId,
    String attemptedAction, {
    Map<String, dynamic>? context,
  }) async {
    try {
      await _securityService
          .logSuspiciousActivity(userId, 'unauthorized_access', {
        'attemptedAction': attemptedAction,
        'context': context ?? {},
        'severity': 'high',
      });

      // إرسال تنبيه فوري للإداريين
      await _sendAdminAlert(userId, 'unauthorized_access',
          'محاولة وصول غير مصرح بها: $attemptedAction');
    } catch (e) {
      print('❌ خطأ في تسجيل محاولة الوصول غير المصرح بها: $e');
    }
  }

  /// إنهاء الخدمة
  void dispose() {
    _cleanupTimer?.cancel();
    _activityCounts.clear();
    _lastActivityTime.clear();
  }
}
