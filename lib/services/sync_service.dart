import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:tashlehekomv2/services/database_service.dart';
import 'package:tashlehekomv2/services/firebase_firestore_service.dart';
import 'package:tashlehekomv2/services/error_handling_service.dart';
import 'package:tashlehekomv2/models/car_model.dart';
import 'package:tashlehekomv2/models/user_model.dart';
import 'package:tashlehekomv2/models/favorite_model.dart';

/// خدمة المزامنة بين قاعدة البيانات المحلية و Firebase
class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final DatabaseService _localDb = DatabaseService.instance;
  final FirebaseFirestoreService _cloudDb = FirebaseFirestoreService();
  final ErrorHandlingService _errorHandler = ErrorHandlingService();
  final Connectivity _connectivity = Connectivity();

  bool _isSyncing = false;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  Timer? _periodicSyncTimer;

  /// تهيئة خدمة المزامنة
  Future<void> initialize() async {
    try {
      print('🔄 تهيئة خدمة المزامنة...');

      // مراقبة حالة الاتصال
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        _onConnectivityChanged,
      );

      // مزامنة دورية كل 5 دقائق
      _periodicSyncTimer = Timer.periodic(
        const Duration(minutes: 5),
        (_) => syncAll(),
      );

      // مزامنة أولية
      await syncAll();

      print('✅ تم تهيئة خدمة المزامنة بنجاح');
    } catch (e) {
      _errorHandler.logError('تهيئة خدمة المزامنة', e);
    }
  }

  /// معالجة تغيير حالة الاتصال
  void _onConnectivityChanged(ConnectivityResult result) {
    if (result != ConnectivityResult.none && !_isSyncing) {
      print('🌐 تم استعادة الاتصال - بدء المزامنة...');
      syncAll();
    }
  }

  /// مزامنة جميع البيانات
  Future<bool> syncAll() async {
    if (_isSyncing) {
      print('⏳ المزامنة قيد التشغيل بالفعل');
      return false;
    }

    _isSyncing = true;
    bool success = true;

    try {
      print('🔄 بدء المزامنة الشاملة...');

      // التحقق من الاتصال
      bool isConnected = await _errorHandler.checkConnectivity();
      if (!isConnected) {
        print('❌ لا يوجد اتصال بالإنترنت');
        return false;
      }

      // مزامنة السيارات
      bool carsSync = await syncCars();
      if (!carsSync) success = false;

      // مزامنة المستخدمين
      bool usersSync = await syncUsers();
      if (!usersSync) success = false;

      // مزامنة المفضلة
      bool favoritesSync = await syncFavorites();
      if (!favoritesSync) success = false;

      print(
          success ? '✅ تمت المزامنة بنجاح' : '⚠️ تمت المزامنة مع بعض الأخطاء');
      return success;
    } catch (e) {
      _errorHandler.logError('المزامنة الشاملة', e);
      return false;
    } finally {
      _isSyncing = false;
    }
  }

  /// مزامنة السيارات
  Future<bool> syncCars() async {
    try {
      print('🚗 مزامنة السيارات...');

      // جلب السيارات المحلية المحدثة
      List<CarModel> localCars = await _localDb.getAllCars();
      List<CarModel> cloudCars = await _cloudDb.getAllCars();

      // إنشاء خرائط للمقارنة السريعة
      Map<String, CarModel> localCarsMap = {
        for (var car in localCars) car.id: car
      };
      Map<String, CarModel> cloudCarsMap = {
        for (var car in cloudCars) car.id: car
      };

      int uploaded = 0, downloaded = 0, updated = 0;

      // رفع السيارات الجديدة والمحدثة إلى السحابة
      for (CarModel localCar in localCars) {
        try {
          if (!cloudCarsMap.containsKey(localCar.id)) {
            // سيارة جديدة - رفع إلى السحابة
            await _cloudDb.createCar(localCar);
            uploaded++;
          } else {
            CarModel cloudCar = cloudCarsMap[localCar.id]!;
            if (localCar.updatedAt
                    ?.isAfter(cloudCar.updatedAt ?? DateTime.now()) ??
                false) {
              // السيارة المحلية أحدث - تحديث السحابة
              await _cloudDb.updateCar(localCar);
              updated++;
            }
          }
        } catch (e) {
          _errorHandler.logError('رفع السيارة ${localCar.id}', e);
        }
      }

      // تحميل السيارات الجديدة والمحدثة من السحابة
      for (CarModel cloudCar in cloudCars) {
        try {
          if (!localCarsMap.containsKey(cloudCar.id)) {
            // سيارة جديدة - تحميل إلى المحلي
            await _localDb.insertCar(cloudCar);
            downloaded++;
          } else {
            CarModel localCar = localCarsMap[cloudCar.id]!;
            if (cloudCar.updatedAt
                    ?.isAfter(localCar.updatedAt ?? DateTime.now()) ??
                false) {
              // السيارة السحابية أحدث - تحديث المحلي
              // استخدام insertCar بدلاً من updateCar
              await _localDb.insertCar(cloudCar);
              updated++;
            }
          }
        } catch (e) {
          _errorHandler.logError('تحميل السيارة ${cloudCar.id}', e);
        }
      }

      print(
          '✅ مزامنة السيارات: رفع $uploaded، تحميل $downloaded، تحديث $updated');
      return true;
    } catch (e) {
      _errorHandler.logError('مزامنة السيارات', e);
      return false;
    }
  }

  /// مزامنة المستخدمين
  Future<bool> syncUsers() async {
    try {
      print('👥 مزامنة المستخدمين...');

      List<UserModel> localUsers = await _localDb.getAllUsers();
      List<UserModel> cloudUsers = await _cloudDb.getAllUsers();

      Map<String, UserModel> localUsersMap = {
        for (var user in localUsers) user.id: user
      };
      Map<String, UserModel> cloudUsersMap = {
        for (var user in cloudUsers) user.id: user
      };

      int uploaded = 0, downloaded = 0, updated = 0;

      // رفع المستخدمين الجدد والمحدثين
      for (UserModel localUser in localUsers) {
        try {
          if (!cloudUsersMap.containsKey(localUser.id)) {
            await _cloudDb.createUser(localUser);
            uploaded++;
          } else {
            UserModel cloudUser = cloudUsersMap[localUser.id]!;
            if (localUser.updatedAt
                    ?.isAfter(cloudUser.updatedAt ?? DateTime.now()) ??
                false) {
              await _cloudDb.updateUserModel(localUser);
              updated++;
            }
          }
        } catch (e) {
          _errorHandler.logError('رفع المستخدم ${localUser.id}', e);
        }
      }

      // تحميل المستخدمين الجدد والمحدثين
      for (UserModel cloudUser in cloudUsers) {
        try {
          if (!localUsersMap.containsKey(cloudUser.id)) {
            await _localDb.insertUser(cloudUser);
            downloaded++;
          } else {
            UserModel localUser = localUsersMap[cloudUser.id]!;
            if (cloudUser.updatedAt
                    ?.isAfter(localUser.updatedAt ?? DateTime.now()) ??
                false) {
              await _localDb.updateUser(cloudUser);
              updated++;
            }
          }
        } catch (e) {
          _errorHandler.logError('تحميل المستخدم ${cloudUser.id}', e);
        }
      }

      print(
          '✅ مزامنة المستخدمين: رفع $uploaded، تحميل $downloaded، تحديث $updated');
      return true;
    } catch (e) {
      _errorHandler.logError('مزامنة المستخدمين', e);
      return false;
    }
  }

  /// مزامنة المفضلة
  Future<bool> syncFavorites() async {
    try {
      print('⭐ مزامنة المفضلة...');

      List<FavoriteModel> localFavorites = await _localDb.getAllFavorites();

      int uploaded = 0;

      // رفع المفضلة المحلية إلى السحابة
      for (FavoriteModel favorite in localFavorites) {
        try {
          bool existsInCloud = await _cloudDb.isCarInFavorites(
            favorite.userId,
            favorite.carId,
          );

          if (!existsInCloud) {
            await _cloudDb.addToFavorites(favorite.userId, favorite.carId);
            uploaded++;
          }
        } catch (e) {
          _errorHandler.logError('رفع المفضلة ${favorite.id}', e);
        }
      }

      print('✅ مزامنة المفضلة: رفع $uploaded');
      return true;
    } catch (e) {
      _errorHandler.logError('مزامنة المفضلة', e);
      return false;
    }
  }

  /// مزامنة سيارة واحدة فوراً
  Future<bool> syncSingleCar(CarModel car) async {
    try {
      bool isConnected = await _errorHandler.checkConnectivity();
      if (!isConnected) return false;

      await _cloudDb.createCar(car);
      print('✅ تم رفع السيارة ${car.id} إلى السحابة');
      return true;
    } catch (e) {
      _errorHandler.logError('رفع السيارة ${car.id}', e);
      return false;
    }
  }

  /// مزامنة مستخدم واحد فوراً
  Future<bool> syncSingleUser(UserModel user) async {
    try {
      bool isConnected = await _errorHandler.checkConnectivity();
      if (!isConnected) return false;

      await _cloudDb.createUser(user);
      print('✅ تم رفع المستخدم ${user.id} إلى السحابة');
      return true;
    } catch (e) {
      _errorHandler.logError('رفع المستخدم ${user.id}', e);
      return false;
    }
  }

  /// الحصول على حالة المزامنة
  bool get isSyncing => _isSyncing;

  /// إيقاف خدمة المزامنة
  void dispose() {
    _connectivitySubscription?.cancel();
    _periodicSyncTimer?.cancel();
    print('🛑 تم إيقاف خدمة المزامنة');
  }
}
