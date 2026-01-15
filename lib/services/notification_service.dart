import 'package:uuid/uuid.dart';
import '../models/notification_model.dart';
import 'database_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final DatabaseService _db = DatabaseService.instance;

  // إرسال إشعار لمستخدم معين (محلي فقط)
  Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    required NotificationType type,
    String? relatedId,
    Map<String, dynamic>? data,
  }) async {
    try {
      // حفظ الإشعار في قاعدة البيانات المحلية
      final notification = NotificationModel(
        id: const Uuid().v4(),
        userId: userId,
        title: title,
        body: body,
        type: type,
        relatedId: relatedId,
        data: data,
        createdAt: DateTime.now(),
      );

      await _insertNotification(notification);
      print('✅ تم إرسال إشعار محلي: $title');
    } catch (e) {
      print('❌ خطأ في إرسال الإشعار: $e');
    }
  }

  // إدراج إشعار في قاعدة البيانات
  Future<void> _insertNotification(NotificationModel notification) async {
    try {
      await _db.insertNotification(notification);
      print('📝 تم حفظ إشعار: ${notification.title}');
    } catch (e) {
      print('❌ خطأ في حفظ الإشعار: $e');
    }
  }

  // الحصول على الإشعارات غير المقروءة
  Future<List<NotificationModel>> getUnreadNotifications(String userId) async {
    try {
      final notifications = await _db.getUnreadNotifications(userId);
      print(
          '📬 تم جلب ${notifications.length} إشعار غير مقروء للمستخدم: $userId');
      return notifications;
    } catch (e) {
      print('❌ خطأ في جلب الإشعارات: $e');
      return [];
    }
  }

  // الحصول على جميع الإشعارات
  Future<List<NotificationModel>> getAllNotifications(String userId) async {
    try {
      final notifications = await _db.getAllUserNotifications(userId);
      print('📬 تم جلب ${notifications.length} إشعار للمستخدم: $userId');
      return notifications;
    } catch (e) {
      print('❌ خطأ في جلب الإشعارات: $e');
      return [];
    }
  }

  // تحديد إشعار كمقروء
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _db.markNotificationAsRead(notificationId);
      print('✅ تم تحديد الإشعار كمقروء: $notificationId');
    } catch (e) {
      print('❌ خطأ في تحديث الإشعار: $e');
    }
  }

  // حذف إشعار
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _db.deleteNotification(notificationId);
      print('🗑️ تم حذف الإشعار: $notificationId');
    } catch (e) {
      print('❌ خطأ في حذف الإشعار: $e');
    }
  }

  // مسح جميع الإشعارات لمستخدم
  Future<void> clearAllNotifications(String userId) async {
    try {
      await _db.clearAllNotifications(userId);
      print('🧹 تم مسح جميع الإشعارات للمستخدم: $userId');
    } catch (e) {
      print('❌ خطأ في مسح الإشعارات: $e');
    }
  }

  // إرسال إشعار عند إضافة سيارة جديدة
  Future<void> notifyNewCarAdded(String carId, String carTitle) async {
    // إشعار للمدراء فقط
    await sendNotificationToUser(
      userId: 'admin_001', // ID المدير
      title: 'سيارة جديدة تحتاج موافقة',
      body: 'تم إضافة سيارة جديدة: $carTitle',
      type: NotificationType.newCar,
      relatedId: carId,
    );
  }

  // إرسال إشعار عند الموافقة على الحساب
  Future<void> notifyAccountApproved(String userId) async {
    await sendNotificationToUser(
      userId: userId,
      title: 'تم الموافقة على حسابك',
      body:
          'مرحباً بك في تشليحكم! يمكنك الآن إضافة السيارات والتفاعل مع المجتمع',
      type: NotificationType.accountApproved,
    );
  }

  // إرسال إشعار عند رفض الحساب
  Future<void> notifyAccountRejected(String userId, String reason) async {
    await sendNotificationToUser(
      userId: userId,
      title: 'تم رفض طلب الحساب',
      body: 'نأسف، تم رفض طلب إنشاء الحساب. السبب: $reason',
      type: NotificationType.accountRejected,
    );
  }

  // إرسال إشعار عند بيع السيارة
  Future<void> notifyCarSold(String sellerId, String carTitle) async {
    await sendNotificationToUser(
      userId: sellerId,
      title: 'تم بيع سيارتك',
      body: 'تهانينا! تم بيع سيارة $carTitle بنجاح',
      type: NotificationType.carSold,
    );
  }

  // إرسال إشعار عند تلقي تقييم جديد
  Future<void> notifyNewRating(String sellerId, double rating) async {
    await sendNotificationToUser(
      userId: sellerId,
      title: 'تقييم جديد',
      body: 'تم تقييمك بـ ${rating.toStringAsFixed(1)} نجوم',
      type: NotificationType.newRating,
    );
  }

  // ==================== إشعارات قطع الغيار ====================

  /// إرسال إشعار عند استلام عرض جديد على طلب قطعة غيار
  Future<void> notifyNewOffer({
    required String userId,
    required String partName,
    required String shopName,
    required double price,
    required String requestId,
  }) async {
    await sendNotificationToUser(
      userId: userId,
      title: 'عرض جديد على طلبك',
      body:
          'استلمت عرضاً من $shopName بسعر ${price.toStringAsFixed(0)} ريال على طلب $partName',
      type: NotificationType.newOffer,
      relatedId: requestId,
      data: {
        'request_id': requestId,
        'shop_name': shopName,
        'price': price,
      },
    );
  }

  /// إرسال إشعار عند قبول العرض
  Future<void> notifyOfferAccepted({
    required String shopId,
    required String partName,
    required String customerName,
    required String offerId,
  }) async {
    await sendNotificationToUser(
      userId: shopId,
      title: 'تم قبول عرضك!',
      body: 'قام $customerName بقبول عرضك على $partName',
      type: NotificationType.offerAccepted,
      relatedId: offerId,
      data: {
        'offer_id': offerId,
        'customer_name': customerName,
      },
    );
  }

  /// إرسال إشعار عند رفض العرض
  Future<void> notifyOfferRejected({
    required String shopId,
    required String partName,
    required String offerId,
  }) async {
    await sendNotificationToUser(
      userId: shopId,
      title: 'تم رفض عرضك',
      body: 'نأسف، تم رفض عرضك على $partName',
      type: NotificationType.offerRejected,
      relatedId: offerId,
    );
  }

  /// إرسال إشعار للتشاليح عند وجود طلب جديد في مدينتهم
  Future<void> notifyNewPartRequest({
    required String shopId,
    required String partName,
    required String carInfo,
    required String city,
    required String requestId,
  }) async {
    await sendNotificationToUser(
      userId: shopId,
      title: 'طلب قطعة غيار جديد',
      body: 'طلب جديد: $partName لـ $carInfo في $city',
      type: NotificationType.newPartRequest,
      relatedId: requestId,
      data: {
        'request_id': requestId,
        'part_name': partName,
        'city': city,
      },
    );
  }
}
