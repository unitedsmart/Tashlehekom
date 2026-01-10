import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/user_model.dart';
import '../models/car_model.dart';
import '../models/report_model.dart';
import '../models/notification_model.dart';
import '../models/favorite_model.dart';
import '../models/rating_model.dart';
import 'database_service.dart';
import 'firebase_firestore_service.dart';

/// خدمة قاعدة البيانات الهجينة التي تجمع بين SQLite و Firestore
/// تعمل offline مع SQLite وتتزامن مع Firestore عند توفر الإنترنت
class HybridDatabaseService {
  static final HybridDatabaseService _instance =
      HybridDatabaseService._internal();
  factory HybridDatabaseService() => _instance;
  HybridDatabaseService._internal();

  final DatabaseService _localDb = DatabaseService.instance;
  final FirebaseFirestoreService _firestore = FirebaseFirestoreService();
  final Connectivity _connectivity = Connectivity();

  bool _isOnline = false;
  bool _isSyncing = false;

  /// تهيئة الخدمة
  Future<void> initialize() async {
    // التحقق من حالة الاتصال
    await _checkConnectivity();

    // الاستماع لتغييرات الاتصال
    _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);

    // محاولة المزامنة إذا كان متصل
    if (_isOnline) {
      _syncData();
    }
  }

  /// التحقق من حالة الاتصال
  Future<void> _checkConnectivity() async {
    try {
      ConnectivityResult result = await _connectivity.checkConnectivity();
      _isOnline = result != ConnectivityResult.none;
      print('🌐 حالة الاتصال: ${_isOnline ? "متصل" : "غير متصل"}');
    } catch (e) {
      _isOnline = false;
      print('❌ خطأ في التحقق من الاتصال: $e');
    }
  }

  /// معالج تغيير حالة الاتصال
  void _onConnectivityChanged(ConnectivityResult result) {
    bool wasOnline = _isOnline;
    _isOnline = result != ConnectivityResult.none;

    print('🌐 تغيرت حالة الاتصال: ${_isOnline ? "متصل" : "غير متصل"}');

    // إذا أصبح متصل بعد انقطاع، ابدأ المزامنة
    if (!wasOnline && _isOnline) {
      _syncData();
    }
  }

  /// مزامنة البيانات مع Firestore
  Future<void> _syncData() async {
    if (_isSyncing || !_isOnline) return;

    try {
      _isSyncing = true;
      print('🔄 بدء مزامنة البيانات...');

      // مزامنة البيانات المحلية إلى Firestore
      await _syncLocalToFirestore();

      // مزامنة البيانات من Firestore إلى المحلي
      await _syncFirestoreToLocal();

      print('✅ تمت المزامنة بنجاح');
    } catch (e) {
      print('❌ خطأ في المزامنة: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// مزامنة البيانات المحلية إلى Firestore
  Future<void> _syncLocalToFirestore() async {
    // هذا سيتم تنفيذه لاحقاً حسب الحاجة
    print('📤 مزامنة البيانات المحلية إلى Firestore...');
  }

  /// مزامنة البيانات من Firestore إلى المحلي
  Future<void> _syncFirestoreToLocal() async {
    // هذا سيتم تنفيذه لاحقاً حسب الحاجة
    print('📥 مزامنة البيانات من Firestore إلى المحلي...');
  }

  // ==================== المستخدمين ====================

  /// الحصول على مستخدم
  Future<UserModel?> getUser(String userId) async {
    try {
      if (_isOnline) {
        // محاولة الحصول من Firestore أولاً
        UserModel? user = await _firestore.getUser(userId);
        if (user != null) {
          // حفظ في قاعدة البيانات المحلية
          await _localDb.insertUser(user);
          return user;
        }
      }

      // الحصول من قاعدة البيانات المحلية
      return await _localDb.getUserById(userId);
    } catch (e) {
      print('❌ خطأ في الحصول على المستخدم: $e');
      // في حالة الخطأ، محاولة الحصول من المحلي
      return await _localDb.getUserById(userId);
    }
  }

  /// إنشاء مستخدم جديد
  Future<void> createUser(UserModel user) async {
    try {
      // حفظ في قاعدة البيانات المحلية أولاً
      await _localDb.insertUser(user);

      // إذا كان متصل، حفظ في Firestore
      if (_isOnline) {
        await _firestore.createUser(user);
      }
    } catch (e) {
      print('❌ خطأ في إنشاء المستخدم: $e');
      rethrow;
    }
  }

  /// تحديث مستخدم
  Future<void> updateUser(UserModel user) async {
    try {
      // تحديث في قاعدة البيانات المحلية أولاً
      await _localDb.updateUser(user);

      // إذا كان متصل، تحديث في Firestore
      if (_isOnline) {
        await _firestore.updateUserModel(user);
      }
    } catch (e) {
      print('❌ خطأ في تحديث المستخدم: $e');
      rethrow;
    }
  }

  // ==================== السيارات ====================

  /// الحصول على جميع السيارات
  Future<List<CarModel>> getAllCars() async {
    try {
      if (_isOnline) {
        // محاولة الحصول من Firestore أولاً
        List<CarModel> cars = await _firestore.getAllCars();
        if (cars.isNotEmpty) {
          // حفظ في قاعدة البيانات المحلية
          for (CarModel car in cars) {
            await _localDb.insertCar(car);
          }
          return cars;
        }
      }

      // الحصول من قاعدة البيانات المحلية
      return await _localDb.getAllCars();
    } catch (e) {
      print('❌ خطأ في الحصول على السيارات: $e');
      // في حالة الخطأ، الحصول من المحلي
      return await _localDb.getAllCars();
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
      if (_isOnline) {
        // البحث في Firestore أولاً
        return await _firestore.searchCars(
          brand: brand,
          model: model,
          city: city,
          minPrice: minPrice,
          maxPrice: maxPrice,
          minYear: minYear,
          maxYear: maxYear,
        );
      }

      // البحث في قاعدة البيانات المحلية
      return await _localDb.searchCars(
        brand: brand,
        model: model,
        city: city,
        minPrice: minPrice,
        maxPrice: maxPrice,
        minYear: minYear,
        maxYear: maxYear,
      );
    } catch (e) {
      print('❌ خطأ في البحث في السيارات: $e');
      // في حالة الخطأ، البحث في المحلي
      return await _localDb.searchCars(
        brand: brand,
        model: model,
        city: city,
        minPrice: minPrice,
        maxPrice: maxPrice,
        minYear: minYear,
        maxYear: maxYear,
      );
    }
  }

  /// إضافة سيارة جديدة
  Future<void> createCar(CarModel car) async {
    try {
      // حفظ في قاعدة البيانات المحلية أولاً
      await _localDb.insertCar(car);

      // إذا كان متصل، حفظ في Firestore
      if (_isOnline) {
        await _firestore.createCar(car);
      }
    } catch (e) {
      print('❌ خطأ في إضافة السيارة: $e');
      rethrow;
    }
  }

  // ==================== المفضلة ====================

  /// إضافة للمفضلة
  Future<void> addToFavorites(String userId, String carId) async {
    try {
      // إضافة في قاعدة البيانات المحلية أولاً
      await _localDb.addToFavorites(userId, carId);

      // إذا كان متصل، إضافة في Firestore
      if (_isOnline) {
        await _firestore.addToFavorites(userId, carId);
      }
    } catch (e) {
      print('❌ خطأ في إضافة للمفضلة: $e');
      rethrow;
    }
  }

  /// إزالة من المفضلة
  Future<void> removeFromFavorites(String userId, String carId) async {
    try {
      // إزالة من قاعدة البيانات المحلية أولاً
      await _localDb.removeFromFavorites(userId, carId);

      // إذا كان متصل، إزالة من Firestore
      if (_isOnline) {
        await _firestore.removeFromFavorites(userId, carId);
      }
    } catch (e) {
      print('❌ خطأ في إزالة من المفضلة: $e');
      rethrow;
    }
  }

  /// الحصول على المفضلة
  Future<List<CarModel>> getUserFavorites(String userId) async {
    try {
      if (_isOnline) {
        // محاولة الحصول من Firestore أولاً
        List<CarModel> favorites = await _firestore.getUserFavorites(userId);
        if (favorites.isNotEmpty) {
          return favorites;
        }
      }

      // الحصول من قاعدة البيانات المحلية
      return await _localDb.getUserFavorites(userId);
    } catch (e) {
      print('❌ خطأ في الحصول على المفضلة: $e');
      // في حالة الخطأ، الحصول من المحلي
      return await _localDb.getUserFavorites(userId);
    }
  }

  /// التحقق من حالة الاتصال
  bool get isOnline => _isOnline;

  /// التحقق من حالة المزامنة
  bool get isSyncing => _isSyncing;

  /// فرض المزامنة
  Future<void> forcSync() async {
    if (_isOnline) {
      await _syncData();
    }
  }
}
