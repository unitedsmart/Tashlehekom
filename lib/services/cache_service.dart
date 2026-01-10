import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tashlehekomv2/models/car_model.dart';
import 'package:tashlehekomv2/models/user_model.dart';

/// خدمة التخزين المؤقت المتقدمة
class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  SharedPreferences? _prefs;
  final Map<String, Timer> _expirationTimers = {};
  final Map<String, dynamic> _memoryCache = {};

  /// تهيئة الخدمة
  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      print('✅ تم تهيئة خدمة التخزين المؤقت');
    } catch (e) {
      print('❌ خطأ في تهيئة خدمة التخزين المؤقت: $e');
    }
  }

  /// حفظ البيانات في الذاكرة المؤقتة
  Future<void> set<T>(
    String key,
    T value, {
    Duration? expiration,
    bool memoryOnly = false,
  }) async {
    try {
      // حفظ في الذاكرة
      _memoryCache[key] = value;

      // إعداد انتهاء الصلاحية
      if (expiration != null) {
        _expirationTimers[key]?.cancel();
        _expirationTimers[key] = Timer(expiration, () {
          _memoryCache.remove(key);
          if (!memoryOnly) {
            _prefs?.remove(key);
            _prefs?.remove('${key}_expiry');
          }
        });
      }

      // حفظ في التخزين الدائم إذا لم يكن memoryOnly
      if (!memoryOnly && _prefs != null) {
        String jsonString = jsonEncode(_serializeValue(value));
        await _prefs!.setString(key, jsonString);

        if (expiration != null) {
          int expiryTime = DateTime.now().add(expiration).millisecondsSinceEpoch;
          await _prefs!.setInt('${key}_expiry', expiryTime);
        }
      }
    } catch (e) {
      print('❌ خطأ في حفظ البيانات في الذاكرة المؤقتة: $e');
    }
  }

  /// استرجاع البيانات من الذاكرة المؤقتة
  Future<T?> get<T>(String key, {T Function(Map<String, dynamic>)? fromJson}) async {
    try {
      // البحث في الذاكرة أولاً
      if (_memoryCache.containsKey(key)) {
        return _memoryCache[key] as T?;
      }

      // البحث في التخزين الدائم
      if (_prefs != null) {
        // التحقق من انتهاء الصلاحية
        int? expiryTime = _prefs!.getInt('${key}_expiry');
        if (expiryTime != null && DateTime.now().millisecondsSinceEpoch > expiryTime) {
          await remove(key);
          return null;
        }

        String? jsonString = _prefs!.getString(key);
        if (jsonString != null) {
          dynamic value = _deserializeValue(jsonDecode(jsonString), fromJson);
          _memoryCache[key] = value; // حفظ في الذاكرة للوصول السريع
          return value as T?;
        }
      }

      return null;
    } catch (e) {
      print('❌ خطأ في استرجاع البيانات من الذاكرة المؤقتة: $e');
      return null;
    }
  }

  /// حذف البيانات من الذاكرة المؤقتة
  Future<void> remove(String key) async {
    try {
      _memoryCache.remove(key);
      _expirationTimers[key]?.cancel();
      _expirationTimers.remove(key);
      
      if (_prefs != null) {
        await _prefs!.remove(key);
        await _prefs!.remove('${key}_expiry');
      }
    } catch (e) {
      print('❌ خطأ في حذف البيانات من الذاكرة المؤقتة: $e');
    }
  }

  /// مسح جميع البيانات المؤقتة
  Future<void> clear() async {
    try {
      _memoryCache.clear();
      for (Timer timer in _expirationTimers.values) {
        timer.cancel();
      }
      _expirationTimers.clear();
      
      if (_prefs != null) {
        await _prefs!.clear();
      }
      
      print('✅ تم مسح جميع البيانات المؤقتة');
    } catch (e) {
      print('❌ خطأ في مسح البيانات المؤقتة: $e');
    }
  }

  /// التحقق من وجود البيانات
  Future<bool> contains(String key) async {
    if (_memoryCache.containsKey(key)) {
      return true;
    }
    
    if (_prefs != null) {
      // التحقق من انتهاء الصلاحية
      int? expiryTime = _prefs!.getInt('${key}_expiry');
      if (expiryTime != null && DateTime.now().millisecondsSinceEpoch > expiryTime) {
        await remove(key);
        return false;
      }
      
      return _prefs!.containsKey(key);
    }
    
    return false;
  }

  /// حفظ قائمة السيارات
  Future<void> setCars(List<CarModel> cars, {Duration? expiration}) async {
    await set('cars_list', cars.map((car) => car.toMap()).toList(), expiration: expiration);
  }

  /// استرجاع قائمة السيارات
  Future<List<CarModel>?> getCars() async {
    List<dynamic>? carsData = await get<List<dynamic>>('cars_list');
    if (carsData != null) {
      return carsData.map((data) => CarModel.fromMap(data as Map<String, dynamic>)).toList();
    }
    return null;
  }

  /// حفظ بيانات المستخدم
  Future<void> setUser(UserModel user, {Duration? expiration}) async {
    await set('current_user', user.toMap(), expiration: expiration);
  }

  /// استرجاع بيانات المستخدم
  Future<UserModel?> getUser() async {
    Map<String, dynamic>? userData = await get<Map<String, dynamic>>('current_user');
    if (userData != null) {
      return UserModel.fromMap(userData);
    }
    return null;
  }

  /// حفظ نتائج البحث
  Future<void> setSearchResults(String query, List<CarModel> results) async {
    String key = 'search_${query.hashCode}';
    await set(key, results.map((car) => car.toMap()).toList(), 
        expiration: const Duration(minutes: 15));
  }

  /// استرجاع نتائج البحث
  Future<List<CarModel>?> getSearchResults(String query) async {
    String key = 'search_${query.hashCode}';
    List<dynamic>? resultsData = await get<List<dynamic>>(key);
    if (resultsData != null) {
      return resultsData.map((data) => CarModel.fromMap(data as Map<String, dynamic>)).toList();
    }
    return null;
  }

  /// حفظ الإحصائيات
  Future<void> setStatistics(Map<String, dynamic> stats) async {
    await set('app_statistics', stats, expiration: const Duration(hours: 1));
  }

  /// استرجاع الإحصائيات
  Future<Map<String, dynamic>?> getStatistics() async {
    return await get<Map<String, dynamic>>('app_statistics');
  }

  /// حفظ إعدادات التطبيق
  Future<void> setAppSettings(Map<String, dynamic> settings) async {
    await set('app_settings', settings); // بدون انتهاء صلاحية
  }

  /// استرجاع إعدادات التطبيق
  Future<Map<String, dynamic>?> getAppSettings() async {
    return await get<Map<String, dynamic>>('app_settings');
  }

  /// تسلسل القيم للحفظ
  dynamic _serializeValue(dynamic value) {
    if (value is List) {
      return value.map((item) => _serializeValue(item)).toList();
    } else if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), _serializeValue(val)));
    } else {
      return value;
    }
  }

  /// إلغاء تسلسل القيم عند الاسترجاع
  dynamic _deserializeValue(dynamic value, Function? fromJson) {
    if (value is List) {
      return value.map((item) => _deserializeValue(item, fromJson)).toList();
    } else if (value is Map<String, dynamic> && fromJson != null) {
      return fromJson(value);
    } else {
      return value;
    }
  }

  /// الحصول على حجم الذاكرة المؤقتة
  int get memoryCacheSize => _memoryCache.length;

  /// الحصول على عدد المؤقتات النشطة
  int get activeTimersCount => _expirationTimers.length;

  /// تنظيف البيانات المنتهية الصلاحية
  Future<void> cleanupExpired() async {
    try {
      if (_prefs == null) return;

      Set<String> keysToRemove = {};
      Set<String> allKeys = _prefs!.getKeys();
      
      for (String key in allKeys) {
        if (key.endsWith('_expiry')) {
          int? expiryTime = _prefs!.getInt(key);
          if (expiryTime != null && DateTime.now().millisecondsSinceEpoch > expiryTime) {
            String dataKey = key.replaceAll('_expiry', '');
            keysToRemove.add(key);
            keysToRemove.add(dataKey);
            _memoryCache.remove(dataKey);
          }
        }
      }

      for (String key in keysToRemove) {
        await _prefs!.remove(key);
      }

      print('✅ تم تنظيف ${keysToRemove.length ~/ 2} عنصر منتهي الصلاحية');
    } catch (e) {
      print('❌ خطأ في تنظيف البيانات المنتهية الصلاحية: $e');
    }
  }
}
