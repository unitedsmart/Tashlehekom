import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/car_model.dart';
import '../models/report_model.dart';
import '../models/notification_model.dart';
import '../models/favorite_model.dart';
import '../models/rating_model.dart';
import 'database_service.dart';
import 'firebase_firestore_service.dart';

/// خدمة نقل البيانات من SQLite إلى Firestore
class DataMigrationService {
  static final DataMigrationService _instance = DataMigrationService._internal();
  factory DataMigrationService() => _instance;
  DataMigrationService._internal();

  final DatabaseService _localDb = DatabaseService.instance;
  final FirebaseFirestoreService _firestore = FirebaseFirestoreService();

  /// نقل جميع البيانات من SQLite إلى Firestore
  Future<void> migrateAllData() async {
    try {
      print('🚀 بدء نقل البيانات من SQLite إلى Firestore...');
      
      // نقل البيانات الأساسية أولاً
      await _migrateCarBrands();
      await _migrateCities();
      
      // نقل بيانات المستخدمين
      await _migrateUsers();
      
      // نقل بيانات السيارات
      await _migrateCars();
      
      // نقل البيانات المرتبطة
      await _migrateFavorites();
      await _migrateRatings();
      await _migrateReports();
      await _migrateNotifications();
      
      print('✅ تم نقل جميع البيانات بنجاح!');
    } catch (e) {
      print('❌ خطأ في نقل البيانات: $e');
      rethrow;
    }
  }

  /// نقل ماركات السيارات
  Future<void> _migrateCarBrands() async {
    try {
      print('📦 نقل ماركات السيارات...');
      
      List<Map<String, dynamic>> brands = await _localDb.getAllCarBrands();
      
      WriteBatch batch = FirebaseFirestore.instance.batch();
      
      for (Map<String, dynamic> brand in brands) {
        DocumentReference ref = _firestore.carBrands.doc(brand['id'].toString());
        batch.set(ref, {
          'id': brand['id'].toString(),
          'name': brand['name'],
          'createdAt': DateTime.now(),
        });
      }
      
      await batch.commit();
      print('✅ تم نقل ${brands.length} ماركة سيارة');
    } catch (e) {
      print('❌ خطأ في نقل ماركات السيارات: $e');
    }
  }

  /// نقل المدن
  Future<void> _migrateCities() async {
    try {
      print('🏙️ نقل المدن...');
      
      List<Map<String, dynamic>> cities = await _localDb.getAllCities();
      
      WriteBatch batch = FirebaseFirestore.instance.batch();
      
      for (Map<String, dynamic> city in cities) {
        DocumentReference ref = _firestore.cities.doc(city['id'].toString());
        batch.set(ref, {
          'id': city['id'].toString(),
          'name': city['name'],
          'createdAt': DateTime.now(),
        });
      }
      
      await batch.commit();
      print('✅ تم نقل ${cities.length} مدينة');
    } catch (e) {
      print('❌ خطأ في نقل المدن: $e');
    }
  }

  /// نقل المستخدمين
  Future<void> _migrateUsers() async {
    try {
      print('👥 نقل المستخدمين...');
      
      List<UserModel> users = await _localDb.getAllUsers();
      
      WriteBatch batch = FirebaseFirestore.instance.batch();
      int batchCount = 0;
      
      for (UserModel user in users) {
        DocumentReference ref = _firestore.users.doc(user.id);
        batch.set(ref, user.toMap());
        
        batchCount++;
        
        // Firestore يدعم حتى 500 عملية في الـ batch الواحد
        if (batchCount >= 500) {
          await batch.commit();
          batch = FirebaseFirestore.instance.batch();
          batchCount = 0;
        }
      }
      
      if (batchCount > 0) {
        await batch.commit();
      }
      
      print('✅ تم نقل ${users.length} مستخدم');
    } catch (e) {
      print('❌ خطأ في نقل المستخدمين: $e');
    }
  }

  /// نقل السيارات
  Future<void> _migrateCars() async {
    try {
      print('🚗 نقل السيارات...');
      
      List<CarModel> cars = await _localDb.getAllCars();
      
      WriteBatch batch = FirebaseFirestore.instance.batch();
      int batchCount = 0;
      
      for (CarModel car in cars) {
        DocumentReference ref = _firestore.cars.doc(car.id);
        batch.set(ref, car.toMap());
        
        batchCount++;
        
        if (batchCount >= 500) {
          await batch.commit();
          batch = FirebaseFirestore.instance.batch();
          batchCount = 0;
        }
      }
      
      if (batchCount > 0) {
        await batch.commit();
      }
      
      print('✅ تم نقل ${cars.length} سيارة');
    } catch (e) {
      print('❌ خطأ في نقل السيارات: $e');
    }
  }

  /// نقل المفضلة
  Future<void> _migrateFavorites() async {
    try {
      print('❤️ نقل المفضلة...');
      
      List<FavoriteModel> favorites = await _localDb.getAllFavorites();
      
      WriteBatch batch = FirebaseFirestore.instance.batch();
      int batchCount = 0;
      
      for (FavoriteModel favorite in favorites) {
        DocumentReference ref = _firestore.favorites.doc(favorite.id);
        batch.set(ref, favorite.toMap());
        
        batchCount++;
        
        if (batchCount >= 500) {
          await batch.commit();
          batch = FirebaseFirestore.instance.batch();
          batchCount = 0;
        }
      }
      
      if (batchCount > 0) {
        await batch.commit();
      }
      
      print('✅ تم نقل ${favorites.length} عنصر مفضل');
    } catch (e) {
      print('❌ خطأ في نقل المفضلة: $e');
    }
  }

  /// نقل التقييمات
  Future<void> _migrateRatings() async {
    try {
      print('⭐ نقل التقييمات...');
      
      List<RatingModel> ratings = await _localDb.getAllRatings();
      
      WriteBatch batch = FirebaseFirestore.instance.batch();
      int batchCount = 0;
      
      for (RatingModel rating in ratings) {
        DocumentReference ref = _firestore.ratings.doc(rating.id);
        batch.set(ref, rating.toMap());
        
        batchCount++;
        
        if (batchCount >= 500) {
          await batch.commit();
          batch = FirebaseFirestore.instance.batch();
          batchCount = 0;
        }
      }
      
      if (batchCount > 0) {
        await batch.commit();
      }
      
      print('✅ تم نقل ${ratings.length} تقييم');
    } catch (e) {
      print('❌ خطأ في نقل التقييمات: $e');
    }
  }

  /// نقل البلاغات
  Future<void> _migrateReports() async {
    try {
      print('📝 نقل البلاغات...');
      
      List<ReportModel> reports = await _localDb.getAllReports();
      
      WriteBatch batch = FirebaseFirestore.instance.batch();
      int batchCount = 0;
      
      for (ReportModel report in reports) {
        DocumentReference ref = _firestore.reports.doc(report.id);
        batch.set(ref, report.toMap());
        
        batchCount++;
        
        if (batchCount >= 500) {
          await batch.commit();
          batch = FirebaseFirestore.instance.batch();
          batchCount = 0;
        }
      }
      
      if (batchCount > 0) {
        await batch.commit();
      }
      
      print('✅ تم نقل ${reports.length} بلاغ');
    } catch (e) {
      print('❌ خطأ في نقل البلاغات: $e');
    }
  }

  /// نقل الإشعارات
  Future<void> _migrateNotifications() async {
    try {
      print('🔔 نقل الإشعارات...');
      
      List<NotificationModel> notifications = await _localDb.getAllNotifications();
      
      WriteBatch batch = FirebaseFirestore.instance.batch();
      int batchCount = 0;
      
      for (NotificationModel notification in notifications) {
        DocumentReference ref = _firestore.notifications.doc(notification.id);
        batch.set(ref, notification.toMap());
        
        batchCount++;
        
        if (batchCount >= 500) {
          await batch.commit();
          batch = FirebaseFirestore.instance.batch();
          batchCount = 0;
        }
      }
      
      if (batchCount > 0) {
        await batch.commit();
      }
      
      print('✅ تم نقل ${notifications.length} إشعار');
    } catch (e) {
      print('❌ خطأ في نقل الإشعارات: $e');
    }
  }

  /// التحقق من نجاح النقل
  Future<Map<String, int>> verifyMigration() async {
    try {
      print('🔍 التحقق من نجاح النقل...');
      
      Map<String, int> counts = {};
      
      // عد البيانات في Firestore
      counts['users'] = (await _firestore.users.get()).docs.length;
      counts['cars'] = (await _firestore.cars.get()).docs.length;
      counts['favorites'] = (await _firestore.favorites.get()).docs.length;
      counts['ratings'] = (await _firestore.ratings.get()).docs.length;
      counts['reports'] = (await _firestore.reports.get()).docs.length;
      counts['notifications'] = (await _firestore.notifications.get()).docs.length;
      counts['carBrands'] = (await _firestore.carBrands.get()).docs.length;
      counts['cities'] = (await _firestore.cities.get()).docs.length;
      
      print('📊 إحصائيات البيانات المنقولة:');
      counts.forEach((key, value) {
        print('   $key: $value');
      });
      
      return counts;
    } catch (e) {
      print('❌ خطأ في التحقق من النقل: $e');
      return {};
    }
  }

  /// مسح البيانات من Firestore (للاختبار)
  Future<void> clearFirestoreData() async {
    try {
      print('🗑️ مسح البيانات من Firestore...');
      
      // مسح كل مجموعة
      await _clearCollection('users');
      await _clearCollection('cars');
      await _clearCollection('favorites');
      await _clearCollection('ratings');
      await _clearCollection('reports');
      await _clearCollection('notifications');
      await _clearCollection('car_brands');
      await _clearCollection('cities');
      
      print('✅ تم مسح جميع البيانات من Firestore');
    } catch (e) {
      print('❌ خطأ في مسح البيانات: $e');
    }
  }

  /// مسح مجموعة معينة
  Future<void> _clearCollection(String collectionName) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(collectionName)
          .get();
      
      WriteBatch batch = FirebaseFirestore.instance.batch();
      int batchCount = 0;
      
      for (DocumentSnapshot doc in snapshot.docs) {
        batch.delete(doc.reference);
        batchCount++;
        
        if (batchCount >= 500) {
          await batch.commit();
          batch = FirebaseFirestore.instance.batch();
          batchCount = 0;
        }
      }
      
      if (batchCount > 0) {
        await batch.commit();
      }
      
      print('✅ تم مسح مجموعة $collectionName (${snapshot.docs.length} عنصر)');
    } catch (e) {
      print('❌ خطأ في مسح مجموعة $collectionName: $e');
    }
  }
}
