import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tashlehekomv2/models/part_request_model.dart';
import 'package:tashlehekomv2/models/offer_model.dart';
import 'package:tashlehekomv2/services/notification_service.dart';

/// خدمة إدارة طلبات قطع الغيار والعروض
class PartRequestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();

  // ============ طلبات قطع الغيار ============

  /// إنشاء طلب جديد
  Future<String> createRequest(PartRequest request) async {
    final docRef =
        await _firestore.collection('part_requests').add(request.toMap());
    return docRef.id;
  }

  /// جلب طلبات المستخدم
  Stream<List<PartRequest>> getUserRequests(String userId) {
    return _firestore
        .collection('part_requests')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PartRequest.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// جلب الطلبات النشطة (للتشاليح)
  Stream<List<PartRequest>> getActiveRequests({String? city}) {
    Query<Map<String, dynamic>> query = _firestore
        .collection('part_requests')
        .where('status', isEqualTo: PartRequestStatus.active.name);

    if (city != null && city.isNotEmpty) {
      query = query.where('city', isEqualTo: city);
    }

    return query.orderBy('createdAt', descending: true).snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => PartRequest.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// تحديث حالة الطلب
  Future<void> updateRequestStatus(
      String requestId, PartRequestStatus status) async {
    await _firestore.collection('part_requests').doc(requestId).update({
      'status': status.name,
      'updatedAt': Timestamp.now(),
    });
  }

  /// تحديث الطلب
  Future<void> updateRequest(
      String requestId, Map<String, dynamic> data) async {
    data['updatedAt'] = Timestamp.now();
    await _firestore.collection('part_requests').doc(requestId).update(data);
  }

  /// حذف الطلب
  Future<void> deleteRequest(String requestId) async {
    // حذف جميع العروض المرتبطة أولاً
    final offers = await _firestore
        .collection('offers')
        .where('requestId', isEqualTo: requestId)
        .get();

    for (var doc in offers.docs) {
      await doc.reference.delete();
    }

    await _firestore.collection('part_requests').doc(requestId).delete();
  }

  // ============ العروض ============

  /// إرسال عرض جديد
  Future<String> createOffer(Offer offer) async {
    final docRef = await _firestore.collection('offers').add(offer.toMap());

    // زيادة عدد العروض في الطلب
    await _firestore.collection('part_requests').doc(offer.requestId).update({
      'offersCount': FieldValue.increment(1),
    });

    // إرسال إشعار لصاحب الطلب
    try {
      final requestDoc = await _firestore
          .collection('part_requests')
          .doc(offer.requestId)
          .get();
      if (requestDoc.exists) {
        final requestData = requestDoc.data()!;
        await _notificationService.notifyNewOffer(
          userId: requestData['userId'],
          partName: requestData['partName'],
          shopName: offer.shopName,
          price: offer.price,
          requestId: offer.requestId,
        );
      }
    } catch (e) {
      print('❌ خطأ في إرسال إشعار العرض: $e');
    }

    return docRef.id;
  }

  /// جلب عروض طلب معين
  Stream<List<Offer>> getRequestOffers(String requestId) {
    return _firestore
        .collection('offers')
        .where('requestId', isEqualTo: requestId)
        .orderBy('price', descending: false) // الأقل سعراً أولاً
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Offer.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// جلب عروض التشليح
  Stream<List<Offer>> getShopOffers(String shopId) {
    return _firestore
        .collection('offers')
        .where('shopId', isEqualTo: shopId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Offer.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// قبول عرض
  Future<void> acceptOffer(String offerId, String requestId,
      {String? customerName}) async {
    // جلب بيانات العرض
    final offerDoc = await _firestore.collection('offers').doc(offerId).get();
    final offerData = offerDoc.data();

    // تحديث حالة العرض إلى مقبول
    await _firestore.collection('offers').doc(offerId).update({
      'status': OfferStatus.accepted.name,
      'updatedAt': Timestamp.now(),
    });

    // إغلاق الطلب
    await updateRequestStatus(requestId, PartRequestStatus.closed);

    // إرسال إشعار لصاحب العرض المقبول
    if (offerData != null) {
      final requestDoc =
          await _firestore.collection('part_requests').doc(requestId).get();
      final requestData = requestDoc.data();
      await _notificationService.notifyOfferAccepted(
        shopId: offerData['shopId'],
        partName: requestData?['partName'] ?? 'قطعة غيار',
        customerName: customerName ?? 'العميل',
        offerId: offerId,
      );
    }

    // رفض باقي العروض وإرسال إشعارات
    final otherOffers = await _firestore
        .collection('offers')
        .where('requestId', isEqualTo: requestId)
        .where(FieldPath.documentId, isNotEqualTo: offerId)
        .get();

    final requestDoc =
        await _firestore.collection('part_requests').doc(requestId).get();
    final partName = requestDoc.data()?['partName'] ?? 'قطعة غيار';

    for (final doc in otherOffers.docs) {
      await doc.reference.update({
        'status': OfferStatus.rejected.name,
        'updatedAt': Timestamp.now(),
      });

      // إرسال إشعار رفض
      final data = doc.data();
      await _notificationService.notifyOfferRejected(
        shopId: data['shopId'],
        partName: partName,
        offerId: doc.id,
      );
    }
  }

  /// رفض عرض
  Future<void> rejectOffer(String offerId, {String? partName}) async {
    final offerDoc = await _firestore.collection('offers').doc(offerId).get();
    final offerData = offerDoc.data();

    await _firestore.collection('offers').doc(offerId).update({
      'status': OfferStatus.rejected.name,
      'updatedAt': Timestamp.now(),
    });

    // إرسال إشعار للتشليح
    if (offerData != null) {
      await _notificationService.notifyOfferRejected(
        shopId: offerData['shopId'],
        partName: partName ?? 'قطعة غيار',
        offerId: offerId,
      );
    }
  }

  /// حذف عرض
  Future<void> deleteOffer(String offerId, String requestId) async {
    await _firestore.collection('offers').doc(offerId).delete();

    // تقليل عدد العروض
    await _firestore.collection('part_requests').doc(requestId).update({
      'offersCount': FieldValue.increment(-1),
    });
  }
}
