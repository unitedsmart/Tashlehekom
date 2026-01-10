import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tashlehekomv2/services/logging_service.dart';
import 'package:tashlehekomv2/services/performance_service.dart';

/// خدمة التخزين المؤقت المحسنة
class EnhancedCacheService {
  static final EnhancedCacheService _instance =
      EnhancedCacheService._internal();
  factory EnhancedCacheService() => _instance;
  EnhancedCacheService._internal();

  SharedPreferences? _prefs;
  final Map<String, CacheItem> _memoryCache = {};
  final Map<String, Timer> _expirationTimers = {};

  static const String _cachePrefix = 'cache_';
  static const String _expirationPrefix = 'exp_';
  static const Duration _defaultExpiration = Duration(hours: 24);
  static const int _maxMemoryCacheSize = 100;

  /// تهيئة الخدمة
  Future<void> initialize() async {
    return PerformanceService.measureAsync('cache_initialize', () async {
      _prefs = await SharedPreferences.getInstance();
      await _cleanExpiredItems();
      LoggingService.success('تم تهيئة خدمة التخزين المؤقت المحسنة');
    });
  }

  /// حفظ بيانات في التخزين المؤقت
  Future<void> set<T>(
    String key,
    T value, {
    Duration? expiration,
    bool memoryOnly = false,
  }) async {
    return PerformanceService.measureAsync('cache_set', () async {
      final exp = expiration ?? _defaultExpiration;
      final expirationTime = DateTime.now().add(exp);

      final cacheItem = CacheItem<T>(
        value: value,
        expirationTime: expirationTime,
        createdAt: DateTime.now(),
      );

      // حفظ في الذاكرة
      _memoryCache[key] = cacheItem;
      _manageMemoryCacheSize();

      // إعداد مؤقت انتهاء الصلاحية
      _setExpirationTimer(key, exp);

      // حفظ في التخزين الدائم إذا لم يكن للذاكرة فقط
      if (!memoryOnly && _prefs != null) {
        final jsonString = jsonEncode({
          'value': _serializeValue(value),
          'type': value.runtimeType.toString(),
          'expirationTime': expirationTime.millisecondsSinceEpoch,
          'createdAt': cacheItem.createdAt.millisecondsSinceEpoch,
        });

        await _prefs!.setString('$_cachePrefix$key', jsonString);
        await _prefs!.setInt(
            '$_expirationPrefix$key', expirationTime.millisecondsSinceEpoch);
      }

      LoggingService.info('تم حفظ البيانات في التخزين المؤقت: $key');
    });
  }

  /// استرجاع بيانات من التخزين المؤقت
  Future<T?> get<T>(String key) async {
    return PerformanceService.measureAsync('cache_get', () async {
      // البحث في الذاكرة أولاً
      final memoryCacheItem = _memoryCache[key];
      if (memoryCacheItem != null) {
        if (memoryCacheItem.isExpired) {
          await remove(key);
          return null;
        }
        LoggingService.info(
            'تم استرجاع البيانات من ذاكرة التخزين المؤقت: $key');
        return memoryCacheItem.value as T?;
      }

      // البحث في التخزين الدائم
      if (_prefs == null) return null;

      final jsonString = _prefs!.getString('$_cachePrefix$key');
      if (jsonString == null) return null;

      try {
        final data = jsonDecode(jsonString) as Map<String, dynamic>;
        final expirationTime =
            DateTime.fromMillisecondsSinceEpoch(data['expirationTime']);

        if (DateTime.now().isAfter(expirationTime)) {
          await remove(key);
          return null;
        }

        final value = _deserializeValue<T>(data['value'], data['type']);

        // إضافة إلى ذاكرة التخزين المؤقت
        if (value != null) {
          final cacheItem = CacheItem<T>(
            value: value,
            expirationTime: expirationTime,
            createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt']),
          );
          _memoryCache[key] = cacheItem;
        }

        _manageMemoryCacheSize();

        LoggingService.info('تم استرجاع البيانات من التخزين الدائم: $key');
        return value;
      } catch (e) {
        LoggingService.error('خطأ في استرجاع البيانات من التخزين المؤقت: $key',
            error: e);
        await remove(key);
        return null;
      }
    });
  }

  /// حذف بيانات من التخزين المؤقت
  Future<void> remove(String key) async {
    return PerformanceService.measureAsync('cache_remove', () async {
      // حذف من الذاكرة
      _memoryCache.remove(key);

      // إلغاء مؤقت انتهاء الصلاحية
      _expirationTimers[key]?.cancel();
      _expirationTimers.remove(key);

      // حذف من التخزين الدائم
      if (_prefs != null) {
        await _prefs!.remove('$_cachePrefix$key');
        await _prefs!.remove('$_expirationPrefix$key');
      }

      LoggingService.info('تم حذف البيانات من التخزين المؤقت: $key');
    });
  }

  /// مسح جميع البيانات المؤقتة
  Future<void> clear() async {
    return PerformanceService.measureAsync('cache_clear', () async {
      // مسح الذاكرة
      _memoryCache.clear();

      // إلغاء جميع المؤقتات
      for (final timer in _expirationTimers.values) {
        timer.cancel();
      }
      _expirationTimers.clear();

      // مسح التخزين الدائم
      if (_prefs != null) {
        final keys = _prefs!
            .getKeys()
            .where((key) =>
                key.startsWith(_cachePrefix) ||
                key.startsWith(_expirationPrefix))
            .toList();

        for (final key in keys) {
          await _prefs!.remove(key);
        }
      }

      LoggingService.success('تم مسح جميع البيانات المؤقتة');
    });
  }

  /// مسح البيانات بناءً على نمط معين
  Future<void> removePattern(String pattern) async {
    return PerformanceService.measureAsync('cache_remove_pattern', () async {
      // مسح من الذاكرة
      final keysToRemove =
          _memoryCache.keys.where((key) => key.contains(pattern)).toList();
      for (final key in keysToRemove) {
        _memoryCache.remove(key);
        // إلغاء المؤقت إذا كان موجوداً
        _expirationTimers[key]?.cancel();
        _expirationTimers.remove(key);
      }

      // مسح من التخزين الدائم
      if (_prefs != null) {
        final allKeys = _prefs!
            .getKeys()
            .where((key) =>
                (key.startsWith(_cachePrefix) ||
                    key.startsWith(_expirationPrefix)) &&
                key.contains(pattern))
            .toList();

        for (final key in allKeys) {
          await _prefs!.remove(key);
        }
      }

      LoggingService.info('تم مسح البيانات بالنمط: $pattern');
    });
  }

  /// التحقق من وجود مفتاح
  Future<bool> containsKey(String key) async {
    final value = await get(key);
    return value != null;
  }

  /// الحصول على حجم التخزين المؤقت
  int get memoryCacheSize => _memoryCache.length;

  /// الحصول على إحصائيات التخزين المؤقت
  CacheStats getStats() {
    final now = DateTime.now();
    int expiredCount = 0;
    int validCount = 0;

    for (final item in _memoryCache.values) {
      if (item.isExpired) {
        expiredCount++;
      } else {
        validCount++;
      }
    }

    return CacheStats(
      totalItems: _memoryCache.length,
      validItems: validCount,
      expiredItems: expiredCount,
      memoryUsage: _memoryCache.length,
    );
  }

  /// تنظيف العناصر منتهية الصلاحية
  Future<void> _cleanExpiredItems() async {
    final expiredKeys = <String>[];

    for (final entry in _memoryCache.entries) {
      if (entry.value.isExpired) {
        expiredKeys.add(entry.key);
      }
    }

    for (final key in expiredKeys) {
      await remove(key);
    }

    if (expiredKeys.isNotEmpty) {
      LoggingService.info('تم تنظيف ${expiredKeys.length} عنصر منتهي الصلاحية');
    }
  }

  /// إدارة حجم ذاكرة التخزين المؤقت
  void _manageMemoryCacheSize() {
    if (_memoryCache.length <= _maxMemoryCacheSize) return;

    // حذف أقدم العناصر
    final sortedEntries = _memoryCache.entries.toList()
      ..sort((a, b) => a.value.createdAt.compareTo(b.value.createdAt));

    final itemsToRemove = _memoryCache.length - _maxMemoryCacheSize;
    for (int i = 0; i < itemsToRemove; i++) {
      _memoryCache.remove(sortedEntries[i].key);
    }

    LoggingService.info('تم تنظيف $itemsToRemove عنصر من ذاكرة التخزين المؤقت');
  }

  /// إعداد مؤقت انتهاء الصلاحية
  void _setExpirationTimer(String key, Duration duration) {
    _expirationTimers[key]?.cancel();
    _expirationTimers[key] = Timer(duration, () async {
      await remove(key);
    });
  }

  /// تسلسل القيمة للحفظ
  dynamic _serializeValue<T>(T value) {
    if (value is String || value is num || value is bool) {
      return value;
    } else if (value is List || value is Map) {
      return value;
    } else {
      return value.toString();
    }
  }

  /// إلغاء تسلسل القيمة
  T? _deserializeValue<T>(dynamic value, String type) {
    try {
      if (type.contains('String')) return value as T;
      if (type.contains('int')) return int.parse(value.toString()) as T;
      if (type.contains('double')) return double.parse(value.toString()) as T;
      if (type.contains('bool'))
        return (value.toString().toLowerCase() == 'true') as T;
      if (type.contains('List')) return value as T;
      if (type.contains('Map')) return value as T;
      return value as T;
    } catch (e) {
      LoggingService.error('خطأ في إلغاء تسلسل القيمة', error: e);
      return null;
    }
  }
}

/// عنصر في التخزين المؤقت
class CacheItem<T> {
  final T value;
  final DateTime expirationTime;
  final DateTime createdAt;

  const CacheItem({
    required this.value,
    required this.expirationTime,
    required this.createdAt,
  });

  bool get isExpired => DateTime.now().isAfter(expirationTime);

  Duration get timeToExpire => expirationTime.difference(DateTime.now());

  Duration get age => DateTime.now().difference(createdAt);
}

/// إحصائيات التخزين المؤقت
class CacheStats {
  final int totalItems;
  final int validItems;
  final int expiredItems;
  final int memoryUsage;

  const CacheStats({
    required this.totalItems,
    required this.validItems,
    required this.expiredItems,
    required this.memoryUsage,
  });

  double get hitRate => totalItems > 0 ? validItems / totalItems : 0.0;
}
