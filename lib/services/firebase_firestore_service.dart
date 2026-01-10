import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/car_model.dart';
import '../models/report_model.dart';
import '../models/notification_model.dart';
import '../models/favorite_model.dart';
import '../models/rating_model.dart';

/// خدمة Firestore لإدارة البيانات السحابية
class FirebaseFirestoreService {
  static final FirebaseFirestoreService _instance =
      FirebaseFirestoreService._internal();
  factory FirebaseFirestoreService() => _instance;
  FirebaseFirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // مراجع المجموعات
  CollectionReference get users => _firestore.collection('users');
  CollectionReference get cars => _firestore.collection('cars');
  CollectionReference get reports => _firestore.collection('reports');
  CollectionReference get notifications =>
      _firestore.collection('notifications');
  CollectionReference get favorites => _firestore.collection('favorites');
  CollectionReference get ratings => _firestore.collection('ratings');
  CollectionReference get carBrands => _firestore.collection('car_brands');
  CollectionReference get cities => _firestore.collection('cities');

  // ==================== المستخدمين ====================

  /// إنشاء مستخدم جديد
  Future<void> createUser(UserModel user) async {
    try {
      await users.doc(user.id).set(user.toMap());
      print('✅ تم إنشاء المستخدم: ${user.name}');
    } catch (e) {
      print('❌ خطأ في إنشاء المستخدم: $e');
      rethrow;
    }
  }

  /// الحصول على مستخدم بالمعرف
  Future<UserModel?> getUser(String userId) async {
    try {
      DocumentSnapshot doc = await users.doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('❌ خطأ في جلب المستخدم: $e');
      return null;
    }
  }

  /// الحصول على مستخدم برقم الهاتف
  Future<UserModel?> getUserByPhone(String phoneNumber) async {
    try {
      QuerySnapshot query = await users
          .where('phoneNumber', isEqualTo: phoneNumber)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return UserModel.fromMap(
            query.docs.first.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('❌ خطأ في البحث عن المستخدم برقم الهاتف: $e');
      return null;
    }
  }

  /// تحديث بيانات المستخدم
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      await users.doc(userId).update(data);
      print('✅ تم تحديث المستخدم: $userId');
    } catch (e) {
      print('❌ خطأ في تحديث المستخدم: $e');
      rethrow;
    }
  }

  /// تحديث بيانات المستخدم بالكامل
  Future<void> updateUserModel(UserModel user) async {
    try {
      await users.doc(user.id).update(user.toMap());
      print('✅ تم تحديث المستخدم: ${user.name}');
    } catch (e) {
      print('❌ خطأ في تحديث المستخدم: $e');
      rethrow;
    }
  }

  /// حذف مستخدم
  Future<void> deleteUser(String userId) async {
    try {
      await users.doc(userId).delete();
      print('✅ تم حذف المستخدم: $userId');
    } catch (e) {
      print('❌ خطأ في حذف المستخدم: $e');
      rethrow;
    }
  }

  /// الحصول على جميع المستخدمين
  Future<List<UserModel>> getAllUsers() async {
    try {
      QuerySnapshot query = await users.get();
      return query.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ خطأ في جلب المستخدمين: $e');
      return [];
    }
  }

  // ==================== السيارات ====================

  /// إضافة سيارة جديدة
  Future<void> createCar(CarModel car) async {
    try {
      await cars.doc(car.id).set(car.toMap());
      print('✅ تم إضافة السيارة: ${car.brand} ${car.model}');
    } catch (e) {
      print('❌ خطأ في إضافة السيارة: $e');
      rethrow;
    }
  }

  /// الحصول على سيارة بالمعرف
  Future<CarModel?> getCar(String carId) async {
    try {
      DocumentSnapshot doc = await cars.doc(carId).get();
      if (doc.exists) {
        return CarModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('❌ خطأ في جلب السيارة: $e');
      return null;
    }
  }

  /// الحصول على جميع السيارات
  Future<List<CarModel>> getAllCars() async {
    try {
      QuerySnapshot query = await cars
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs
          .map((doc) => CarModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ خطأ في جلب السيارات: $e');
      return [];
    }
  }

  /// البحث في السيارات
  Future<List<CarModel>> searchCars({
    String? brand,
    String? model,
    String? city,
    double? minPrice,
    double? maxPrice,
    int? minYear,
    int? maxYear,
  }) async {
    try {
      Query query = cars.where('isActive', isEqualTo: true);

      if (brand != null && brand.isNotEmpty) {
        query = query.where('brand', isEqualTo: brand);
      }

      if (city != null && city.isNotEmpty) {
        query = query.where('city', isEqualTo: city);
      }

      QuerySnapshot snapshot = await query.get();
      List<CarModel> results = snapshot.docs
          .map((doc) => CarModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      // تطبيق فلاتر إضافية
      if (model != null && model.isNotEmpty) {
        results = results
            .where(
                (car) => car.model.toLowerCase().contains(model.toLowerCase()))
            .toList();
      }

      if (minPrice != null) {
        results = results.where((car) => car.price >= minPrice).toList();
      }

      if (maxPrice != null) {
        results = results.where((car) => car.price <= maxPrice).toList();
      }

      if (minYear != null) {
        results = results.where((car) => car.year >= minYear).toList();
      }

      if (maxYear != null) {
        results = results.where((car) => car.year <= maxYear).toList();
      }

      return results;
    } catch (e) {
      print('❌ خطأ في البحث في السيارات: $e');
      return [];
    }
  }

  /// تحديث بيانات السيارة
  Future<void> updateCar(CarModel car) async {
    try {
      await cars.doc(car.id).update(car.toMap());
      print('✅ تم تحديث السيارة: ${car.brand} ${car.model}');
    } catch (e) {
      print('❌ خطأ في تحديث السيارة: $e');
      rethrow;
    }
  }

  /// حذف سيارة
  Future<void> deleteCar(String carId) async {
    try {
      await cars.doc(carId).delete();
      print('✅ تم حذف السيارة: $carId');
    } catch (e) {
      print('❌ خطأ في حذف السيارة: $e');
      rethrow;
    }
  }

  /// الحصول على سيارات المستخدم
  Future<List<CarModel>> getUserCars(String userId) async {
    try {
      QuerySnapshot query = await cars
          .where('sellerId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs
          .map((doc) => CarModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ خطأ في جلب سيارات المستخدم: $e');
      return [];
    }
  }

  // ==================== المفضلة ====================

  /// إضافة سيارة للمفضلة
  Future<void> addToFavorites(String userId, String carId) async {
    try {
      String favoriteId = '${userId}_$carId';
      FavoriteModel favorite = FavoriteModel(
        id: favoriteId,
        userId: userId,
        carId: carId,
        createdAt: DateTime.now(),
      );

      await favorites.doc(favoriteId).set(favorite.toMap());
      print('✅ تم إضافة السيارة للمفضلة');
    } catch (e) {
      print('❌ خطأ في إضافة السيارة للمفضلة: $e');
      rethrow;
    }
  }

  /// إزالة سيارة من المفضلة
  Future<void> removeFromFavorites(String userId, String carId) async {
    try {
      String favoriteId = '${userId}_$carId';
      await favorites.doc(favoriteId).delete();
      print('✅ تم إزالة السيارة من المفضلة');
    } catch (e) {
      print('❌ خطأ في إزالة السيارة من المفضلة: $e');
      rethrow;
    }
  }

  /// التحقق من وجود السيارة في المفضلة
  Future<bool> isCarInFavorites(String userId, String carId) async {
    try {
      String favoriteId = '${userId}_$carId';
      DocumentSnapshot doc = await favorites.doc(favoriteId).get();
      return doc.exists;
    } catch (e) {
      print('❌ خطأ في التحقق من المفضلة: $e');
      return false;
    }
  }

  /// الحصول على السيارات المفضلة للمستخدم
  Future<List<CarModel>> getUserFavorites(String userId) async {
    try {
      QuerySnapshot favQuery =
          await favorites.where('userId', isEqualTo: userId).get();

      List<String> carIds = favQuery.docs
          .map((doc) => (doc.data() as Map<String, dynamic>)['carId'] as String)
          .toList();

      if (carIds.isEmpty) return [];

      List<CarModel> favoriteCars = [];
      for (String carId in carIds) {
        CarModel? car = await getCar(carId);
        if (car != null && car.isActive) {
          favoriteCars.add(car);
        }
      }

      return favoriteCars;
    } catch (e) {
      print('❌ خطأ في جلب السيارات المفضلة: $e');
      return [];
    }
  }

  // ==================== الميزات المتقدمة ====================

  /// الاستماع للتغييرات في الوقت الفعلي - السيارات
  Stream<List<CarModel>> getCarsStream({
    String? sellerId,
    String? city,
    String? brand,
    bool? isActive,
    int limit = 50,
  }) {
    try {
      Query query = cars.orderBy('createdAt', descending: true);

      if (sellerId != null) {
        query = query.where('sellerId', isEqualTo: sellerId);
      }
      if (city != null) {
        query = query.where('city', isEqualTo: city);
      }
      if (brand != null) {
        query = query.where('brand', isEqualTo: brand);
      }
      if (isActive != null) {
        query = query.where('isActive', isEqualTo: isActive);
      }

      query = query.limit(limit);

      return query.snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => CarModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList();
      });
    } catch (e) {
      print('❌ خطأ في stream السيارات: $e');
      return Stream.value([]);
    }
  }

  /// الاستماع للتغييرات في الوقت الفعلي - المستخدمين
  Stream<List<UserModel>> getUsersStream({
    UserType? userType,
    String? city,
    bool? isActive,
    int limit = 50,
  }) {
    try {
      Query query = users.orderBy('createdAt', descending: true);

      if (userType != null) {
        query = query.where('userType', isEqualTo: userType.index);
      }
      if (city != null) {
        query = query.where('city', isEqualTo: city);
      }
      if (isActive != null) {
        query = query.where('isActive', isEqualTo: isActive);
      }

      query = query.limit(limit);

      return query.snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList();
      });
    } catch (e) {
      print('❌ خطأ في stream المستخدمين: $e');
      return Stream.value([]);
    }
  }

  /// البحث المتقدم مع التصفية والترتيب
  Future<List<CarModel>> advancedCarSearch({
    String? searchText,
    String? brand,
    String? model,
    String? city,
    double? minPrice,
    double? maxPrice,
    int? minYear,
    int? maxYear,
    String? condition,
    String? fuelType,
    String? transmission,
    String? sortBy = 'createdAt',
    bool descending = true,
    int limit = 50,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query = this.cars.where('isActive', isEqualTo: true);

      // تطبيق الفلاتر
      if (brand != null && brand.isNotEmpty) {
        query = query.where('brand', isEqualTo: brand);
      }
      if (model != null && model.isNotEmpty) {
        query = query.where('model', isEqualTo: model);
      }
      if (city != null && city.isNotEmpty) {
        query = query.where('city', isEqualTo: city);
      }
      if (condition != null && condition.isNotEmpty) {
        query = query.where('condition', isEqualTo: condition);
      }
      if (fuelType != null && fuelType.isNotEmpty) {
        query = query.where('fuelType', isEqualTo: fuelType);
      }
      if (transmission != null && transmission.isNotEmpty) {
        query = query.where('transmission', isEqualTo: transmission);
      }

      // الترتيب
      query = query.orderBy(sortBy ?? 'createdAt', descending: descending);

      // التصفح (Pagination)
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      query = query.limit(limit);

      QuerySnapshot snapshot = await query.get();
      List<CarModel> carsList = snapshot.docs
          .map((doc) => CarModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      // تطبيق فلاتر إضافية (لا يمكن تطبيقها في Firestore)
      if (minPrice != null) {
        carsList = carsList.where((car) => car.price >= minPrice).toList();
      }
      if (maxPrice != null) {
        carsList = carsList.where((car) => car.price <= maxPrice).toList();
      }
      if (minYear != null) {
        carsList = carsList.where((car) => car.year >= minYear).toList();
      }
      if (maxYear != null) {
        carsList = carsList.where((car) => car.year <= maxYear).toList();
      }

      // البحث النصي
      if (searchText != null && searchText.isNotEmpty) {
        String searchLower = searchText.toLowerCase();
        carsList = carsList.where((car) {
          return car.brand.toLowerCase().contains(searchLower) ||
              car.model.toLowerCase().contains(searchLower);
        }).toList();
      }

      return carsList;
    } catch (e) {
      print('❌ خطأ في البحث المتقدم: $e');
      return [];
    }
  }

  /// إحصائيات شاملة
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      // عدد السيارات النشطة
      QuerySnapshot activeCarsQuery =
          await cars.where('isActive', isEqualTo: true).get();
      int activeCarsCount = activeCarsQuery.docs.length;

      // عدد المستخدمين النشطين
      QuerySnapshot activeUsersQuery =
          await users.where('isActive', isEqualTo: true).get();
      int activeUsersCount = activeUsersQuery.docs.length;

      // عدد السيارات المباعة
      QuerySnapshot soldCarsQuery =
          await this.cars.where('isSold', isEqualTo: true).get();
      int soldCarsCount = soldCarsQuery.docs.length;

      // إحصائيات الماركات
      Map<String, int> brandStats = {};
      for (var doc in activeCarsQuery.docs) {
        CarModel car = CarModel.fromMap(doc.data() as Map<String, dynamic>);
        brandStats[car.brand] = (brandStats[car.brand] ?? 0) + 1;
      }

      // إحصائيات المدن
      Map<String, int> cityStats = {};
      for (var doc in activeCarsQuery.docs) {
        CarModel car = CarModel.fromMap(doc.data() as Map<String, dynamic>);
        cityStats[car.city] = (cityStats[car.city] ?? 0) + 1;
      }

      return {
        'activeCars': activeCarsCount,
        'activeUsers': activeUsersCount,
        'soldCars': soldCarsCount,
        'totalCars': activeCarsCount + soldCarsCount,
        'brandStats': brandStats,
        'cityStats': cityStats,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('❌ خطأ في جلب الإحصائيات: $e');
      return {};
    }
  }

  /// الحصول على جميع التقارير
  Future<List<ReportModel>> getAllReports() async {
    try {
      final querySnapshot =
          await reports.orderBy('createdAt', descending: true).get();
      return querySnapshot.docs
          .map((doc) => ReportModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ خطأ في جلب التقارير: $e');
      return [];
    }
  }

  /// تحديث تقرير
  Future<void> updateReport(String reportId, Map<String, dynamic> data) async {
    try {
      await reports.doc(reportId).update(data);
      print('✅ تم تحديث التقرير: $reportId');
    } catch (e) {
      print('❌ خطأ في تحديث التقرير: $e');
      rethrow;
    }
  }

  /// الحصول على سجلات الأمان
  Future<List<Map<String, dynamic>>> getSecurityLogs() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('security_logs')
          .orderBy('timestamp', descending: true)
          .limit(100)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('❌ خطأ في جلب سجلات الأمان: $e');
      return [];
    }
  }

  /// حذف سجل أمان
  Future<void> deleteSecurityLog(String logId) async {
    try {
      await FirebaseFirestore.instance
          .collection('security_logs')
          .doc(logId)
          .delete();
      print('✅ تم حذف سجل الأمان: $logId');
    } catch (e) {
      print('❌ خطأ في حذف سجل الأمان: $e');
      rethrow;
    }
  }

  /// مسح جميع سجلات الأمان
  Future<void> clearSecurityLogs() async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      final querySnapshot =
          await FirebaseFirestore.instance.collection('security_logs').get();

      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('✅ تم مسح جميع سجلات الأمان');
    } catch (e) {
      print('❌ خطأ في مسح سجلات الأمان: $e');
      rethrow;
    }
  }
}
