import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tashlehekomv2/models/car_model.dart';
import 'package:tashlehekomv2/services/logging_service.dart';
import 'package:tashlehekomv2/services/enhanced_error_handler.dart';
import 'package:tashlehekomv2/services/performance_service.dart';
import 'package:tashlehekomv2/services/enhanced_cache_service.dart';

/// نتيجة البحث
class SearchResult {
  final List<CarModel> cars;
  final int totalCount;
  final bool hasMore;
  final DocumentSnapshot? lastDocument;
  final String? searchQuery;
  final SearchFilters? appliedFilters;
  final SortOption sortOption;

  const SearchResult({
    required this.cars,
    required this.totalCount,
    required this.hasMore,
    required this.sortOption,
    this.lastDocument,
    this.searchQuery,
    this.appliedFilters,
  });

  factory SearchResult.empty() {
    return const SearchResult(
      cars: [],
      totalCount: 0,
      hasMore: false,
      sortOption: SortOption.newest,
    );
  }

  factory SearchResult.fromMap(Map<String, dynamic> map) {
    return SearchResult(
      cars: (map['cars'] as List<dynamic>?)
              ?.map((carData) => CarModel.fromMap(carData))
              .toList() ??
          [],
      totalCount: map['totalCount'] ?? 0,
      hasMore: map['hasMore'] ?? false,
      searchQuery: map['searchQuery'],
      appliedFilters: map['appliedFilters'] != null
          ? SearchFilters.fromMap(map['appliedFilters'])
          : null,
      sortOption: SortOption.values.firstWhere(
        (option) => option.name == map['sortOption'],
        orElse: () => SortOption.newest,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cars': cars.map((car) => car.toMap()).toList(),
      'totalCount': totalCount,
      'hasMore': hasMore,
      'searchQuery': searchQuery,
      'appliedFilters': appliedFilters?.toMap(),
      'sortOption': sortOption.name,
    };
  }
}

/// فلاتر البحث
class SearchFilters {
  final String? status;
  final String? brand;
  final String? type;
  final double? minPrice;
  final double? maxPrice;
  final int? minYear;
  final int? maxYear;
  final int? maxMileage;
  final String? city;
  final String? fuelType;
  final String? transmission;
  final String? condition;

  const SearchFilters({
    this.status,
    this.brand,
    this.type,
    this.minPrice,
    this.maxPrice,
    this.minYear,
    this.maxYear,
    this.maxMileage,
    this.city,
    this.fuelType,
    this.transmission,
    this.condition,
  });

  factory SearchFilters.fromMap(Map<String, dynamic> map) {
    return SearchFilters(
      status: map['status'],
      brand: map['brand'],
      type: map['type'],
      minPrice: map['minPrice']?.toDouble(),
      maxPrice: map['maxPrice']?.toDouble(),
      minYear: map['minYear'],
      maxYear: map['maxYear'],
      maxMileage: map['maxMileage'],
      city: map['city'],
      fuelType: map['fuelType'],
      transmission: map['transmission'],
      condition: map['condition'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'brand': brand,
      'type': type,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'minYear': minYear,
      'maxYear': maxYear,
      'maxMileage': maxMileage,
      'city': city,
      'fuelType': fuelType,
      'transmission': transmission,
      'condition': condition,
    };
  }

  SearchFilters copyWith({
    String? status,
    String? brand,
    String? type,
    double? minPrice,
    double? maxPrice,
    int? minYear,
    int? maxYear,
    int? maxMileage,
    String? city,
    String? fuelType,
    String? transmission,
    String? condition,
  }) {
    return SearchFilters(
      status: status ?? this.status,
      brand: brand ?? this.brand,
      type: type ?? this.type,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minYear: minYear ?? this.minYear,
      maxYear: maxYear ?? this.maxYear,
      maxMileage: maxMileage ?? this.maxMileage,
      city: city ?? this.city,
      fuelType: fuelType ?? this.fuelType,
      transmission: transmission ?? this.transmission,
      condition: condition ?? this.condition,
    );
  }

  bool get isEmpty {
    return status == null &&
        brand == null &&
        type == null &&
        minPrice == null &&
        maxPrice == null &&
        minYear == null &&
        maxYear == null &&
        maxMileage == null &&
        city == null &&
        fuelType == null &&
        transmission == null &&
        condition == null;
  }
}

/// خيارات الترتيب
enum SortOption {
  newest('الأحدث'),
  oldest('الأقدم'),
  priceLowToHigh('السعر: من الأقل للأعلى'),
  priceHighToLow('السعر: من الأعلى للأقل'),
  mileageLowToHigh('المسافة: من الأقل للأعلى'),
  yearNewest('سنة الصنع: الأحدث'),
  yearOldest('سنة الصنع: الأقدم');

  const SortOption(this.displayName);
  final String displayName;
}

/// خدمة البحث المحسنة
class EnhancedSearchService {
  static final EnhancedSearchService _instance =
      EnhancedSearchService._internal();
  factory EnhancedSearchService() => _instance;
  EnhancedSearchService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final EnhancedCacheService _cache = EnhancedCacheService();

  static const String _carsCollection = 'cars';
  static const String _searchHistoryCollection = 'search_history';
  static const String _popularSearchesCollection = 'popular_searches';

  /// البحث المتقدم في السيارات
  Future<SearchResult> searchCars({
    String? query,
    SearchFilters? filters,
    SortOption sortBy = SortOption.newest,
    int limit = 20,
    DocumentSnapshot? lastDocument,
    bool useCache = true,
  }) async {
    return EnhancedErrorHandler.executeWithErrorHandling(
          () async {
            return PerformanceService.measureAsync('advanced_search', () async {
              // إنشاء مفتاح التخزين المؤقت
              final cacheKey = _generateCacheKey(query, filters, sortBy, limit);

              // التحقق من التخزين المؤقت
              if (useCache && lastDocument == null) {
                final cachedResult =
                    await _cache.get<Map<String, dynamic>>(cacheKey);
                if (cachedResult != null) {
                  LoggingService.info(
                      'تم العثور على نتائج البحث في التخزين المؤقت');
                  return SearchResult.fromMap(cachedResult);
                }
              }

              // بناء الاستعلام
              Query<Map<String, dynamic>> queryBuilder =
                  _firestore.collection(_carsCollection);

              // تطبيق الفلاتر
              queryBuilder = _applyFilters(queryBuilder, filters);

              // تطبيق البحث النصي
              if (query != null && query.isNotEmpty) {
                queryBuilder = _applyTextSearch(queryBuilder, query);
              }

              // تطبيق الترتيب
              queryBuilder = _applySorting(queryBuilder, sortBy);

              // تطبيق التصفح
              if (lastDocument != null) {
                queryBuilder = queryBuilder.startAfterDocument(lastDocument);
              }

              queryBuilder = queryBuilder.limit(limit);

              // تنفيذ الاستعلام
              final querySnapshot = await queryBuilder.get();

              // تحويل النتائج
              final cars = querySnapshot.docs
                  .map((doc) {
                    try {
                      return CarModel.fromMap({...doc.data(), 'id': doc.id});
                    } catch (e) {
                      LoggingService.error('خطأ في تحويل بيانات السيارة',
                          error: e);
                      return null;
                    }
                  })
                  .where((car) => car != null)
                  .cast<CarModel>()
                  .toList();

              final result = SearchResult(
                cars: cars,
                totalCount: cars.length,
                hasMore: cars.length == limit,
                lastDocument: querySnapshot.docs.isNotEmpty
                    ? querySnapshot.docs.last
                    : null,
                searchQuery: query,
                appliedFilters: filters,
                sortOption: sortBy,
              );

              // حفظ في التخزين المؤقت
              if (useCache && lastDocument == null) {
                await _cache.set(
                  cacheKey,
                  result.toMap(),
                  expiration: const Duration(minutes: 15),
                );
              }

              // حفظ في تاريخ البحث
              if (query != null && query.isNotEmpty) {
                _saveSearchHistory(query);
              }

              LoggingService.success('تم البحث بنجاح: ${cars.length} نتيجة');
              return result;
            });
          },
          'البحث المتقدم في السيارات',
        ) ??
        SearchResult.empty();
  }

  /// البحث السريع
  Future<List<CarModel>> quickSearch(String query, {int limit = 10}) async {
    return EnhancedErrorHandler.executeWithErrorHandling(
          () async {
            return PerformanceService.measureAsync('quick_search', () async {
              final cacheKey = 'quick_search_$query';

              // التحقق من التخزين المؤقت
              final cachedResults = await _cache.get<List<dynamic>>(cacheKey);
              if (cachedResults != null) {
                return cachedResults
                    .map((data) => CarModel.fromMap(data))
                    .toList();
              }

              final querySnapshot = await _firestore
                  .collection(_carsCollection)
                  .where('status', isEqualTo: 'available')
                  .where('searchKeywords',
                      arrayContainsAny: _generateSearchKeywords(query))
                  .limit(limit)
                  .get();

              final cars = querySnapshot.docs
                  .map((doc) {
                    try {
                      return CarModel.fromMap({...doc.data(), 'id': doc.id});
                    } catch (e) {
                      LoggingService.error('خطأ في تحويل بيانات السيارة',
                          error: e);
                      return null;
                    }
                  })
                  .where((car) => car != null)
                  .cast<CarModel>()
                  .toList();

              // حفظ في التخزين المؤقت
              await _cache.set(
                cacheKey,
                cars.map((car) => car.toMap()).toList(),
                expiration: const Duration(minutes: 5),
              );

              return cars;
            });
          },
          'البحث السريع',
        ) ??
        [];
  }

  /// البحث بالموقع الجغرافي
  Future<List<CarModel>> searchByLocation({
    required double latitude,
    required double longitude,
    required double radiusKm,
    int limit = 20,
  }) async {
    return EnhancedErrorHandler.executeWithErrorHandling(
          () async {
            return PerformanceService.measureAsync('location_search', () async {
              // حساب النطاق الجغرافي
              final bounds = _calculateGeoBounds(latitude, longitude, radiusKm);

              final querySnapshot = await _firestore
                  .collection(_carsCollection)
                  .where('status', isEqualTo: 'available')
                  .where('location.latitude',
                      isGreaterThanOrEqualTo: bounds['minLat'])
                  .where('location.latitude',
                      isLessThanOrEqualTo: bounds['maxLat'])
                  .limit(limit * 2) // جلب عدد أكبر للفلترة
                  .get();

              final cars = querySnapshot.docs
                  .map((doc) {
                    try {
                      final car =
                          CarModel.fromMap({...doc.data(), 'id': doc.id});

                      // التحقق من المسافة الدقيقة
                      if (car.latitude != null && car.longitude != null) {
                        final distance = _calculateDistance(
                          latitude,
                          longitude,
                          car.latitude!,
                          car.longitude!,
                        );

                        if (distance <= radiusKm) {
                          return car;
                        }
                      }

                      return null;
                    } catch (e) {
                      LoggingService.error('خطأ في تحويل بيانات السيارة',
                          error: e);
                      return null;
                    }
                  })
                  .where((car) => car != null)
                  .cast<CarModel>()
                  .take(limit)
                  .toList();

              LoggingService.success('تم البحث بالموقع: ${cars.length} نتيجة');
              return cars;
            });
          },
          'البحث بالموقع الجغرافي',
        ) ??
        [];
  }

  /// الحصول على الاقتراحات
  Future<List<String>> getSuggestions(String query) async {
    return EnhancedErrorHandler.executeWithErrorHandling(
          () async {
            return PerformanceService.measureAsync('get_suggestions', () async {
              if (query.length < 2) return [];

              final cacheKey = 'suggestions_$query';
              final cachedSuggestions =
                  await _cache.get<List<dynamic>>(cacheKey);
              if (cachedSuggestions != null) {
                return cachedSuggestions.cast<String>();
              }

              final suggestions = <String>[];

              // اقتراحات من تاريخ البحث
              final historySnapshot = await _firestore
                  .collection(_searchHistoryCollection)
                  .where('query', isGreaterThanOrEqualTo: query)
                  .where('query', isLessThan: query + 'z')
                  .orderBy('count', descending: true)
                  .limit(5)
                  .get();

              suggestions.addAll(
                historySnapshot.docs
                    .map((doc) => doc.data()['query'] as String),
              );

              // اقتراحات من أسماء السيارات
              final carsSnapshot = await _firestore
                  .collection(_carsCollection)
                  .where('searchKeywords',
                      arrayContainsAny: _generateSearchKeywords(query))
                  .limit(10)
                  .get();

              for (final doc in carsSnapshot.docs) {
                final data = doc.data();
                final title = data['title'] as String?;
                final brand = data['brand'] as String?;
                final model = data['model'] as String?;

                if (title != null &&
                    title.toLowerCase().contains(query.toLowerCase())) {
                  suggestions.add(title);
                }
                if (brand != null &&
                    brand.toLowerCase().contains(query.toLowerCase())) {
                  suggestions.add(brand);
                }
                if (model != null &&
                    model.toLowerCase().contains(query.toLowerCase())) {
                  suggestions.add(model);
                }
              }

              // إزالة التكرارات وترتيب النتائج
              final uniqueSuggestions = suggestions.toSet().take(10).toList();

              // حفظ في التخزين المؤقت
              await _cache.set(
                cacheKey,
                uniqueSuggestions,
                expiration: const Duration(minutes: 30),
              );

              return uniqueSuggestions;
            });
          },
          'الحصول على الاقتراحات',
        ) ??
        [];
  }

  /// تطبيق الفلاتر على الاستعلام
  Query<Map<String, dynamic>> _applyFilters(
    Query<Map<String, dynamic>> query,
    SearchFilters? filters,
  ) {
    if (filters == null) return query;

    // فلتر الحالة
    if (filters.status != null) {
      query = query.where('status', isEqualTo: filters.status);
    }

    // فلتر الماركة
    if (filters.brand != null && filters.brand!.isNotEmpty) {
      query = query.where('brand', isEqualTo: filters.brand);
    }

    // فلتر النوع
    if (filters.type != null && filters.type!.isNotEmpty) {
      query = query.where('type', isEqualTo: filters.type);
    }

    // فلتر السعر
    if (filters.minPrice != null) {
      query = query.where('price', isGreaterThanOrEqualTo: filters.minPrice);
    }
    if (filters.maxPrice != null) {
      query = query.where('price', isLessThanOrEqualTo: filters.maxPrice);
    }

    // فلتر سنة الصنع
    if (filters.minYear != null) {
      query = query.where('year', isGreaterThanOrEqualTo: filters.minYear);
    }
    if (filters.maxYear != null) {
      query = query.where('year', isLessThanOrEqualTo: filters.maxYear);
    }

    // فلتر المسافة المقطوعة
    if (filters.maxMileage != null) {
      query = query.where('mileage', isLessThanOrEqualTo: filters.maxMileage);
    }

    // فلتر المدينة
    if (filters.city != null && filters.city!.isNotEmpty) {
      query = query.where('city', isEqualTo: filters.city);
    }

    return query;
  }

  /// تطبيق البحث النصي
  Query<Map<String, dynamic>> _applyTextSearch(
    Query<Map<String, dynamic>> query,
    String searchText,
  ) {
    final keywords = _generateSearchKeywords(searchText);
    return query.where('searchKeywords', arrayContainsAny: keywords);
  }

  /// تطبيق الترتيب
  Query<Map<String, dynamic>> _applySorting(
    Query<Map<String, dynamic>> query,
    SortOption sortBy,
  ) {
    switch (sortBy) {
      case SortOption.newest:
        return query.orderBy('createdAt', descending: true);
      case SortOption.oldest:
        return query.orderBy('createdAt', descending: false);
      case SortOption.priceLowToHigh:
        return query.orderBy('price', descending: false);
      case SortOption.priceHighToLow:
        return query.orderBy('price', descending: true);
      case SortOption.mileageLowToHigh:
        return query.orderBy('mileage', descending: false);
      case SortOption.yearNewest:
        return query.orderBy('year', descending: true);
      case SortOption.yearOldest:
        return query.orderBy('year', descending: false);
      default:
        return query.orderBy('createdAt', descending: true);
    }
  }

  /// إنشاء كلمات مفتاحية للبحث
  List<String> _generateSearchKeywords(String text) {
    final keywords = <String>[];
    final words = text.toLowerCase().split(' ');

    for (final word in words) {
      if (word.length >= 2) {
        keywords.add(word);
        // إضافة أجزاء من الكلمة للبحث الجزئي
        for (int i = 2; i <= word.length; i++) {
          keywords.add(word.substring(0, i));
        }
      }
    }

    return keywords.toSet().toList();
  }

  /// إنشاء مفتاح التخزين المؤقت
  String _generateCacheKey(
    String? query,
    SearchFilters? filters,
    SortOption sortBy,
    int limit,
  ) {
    final parts = [
      'search',
      query ?? 'all',
      filters?.toMap().toString() ?? 'no_filters',
      sortBy.name,
      limit.toString(),
    ];
    return parts.join('_');
  }

  /// حفظ في تاريخ البحث
  void _saveSearchHistory(String query) {
    // تنفيذ غير متزامن لعدم إبطاء البحث
    Future.microtask(() async {
      try {
        final docRef =
            _firestore.collection(_searchHistoryCollection).doc(query);
        await docRef.set({
          'query': query,
          'count': FieldValue.increment(1),
          'lastSearched': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e) {
        LoggingService.error('خطأ في حفظ تاريخ البحث', error: e);
      }
    });
  }

  /// حساب النطاق الجغرافي
  Map<String, double> _calculateGeoBounds(
    double latitude,
    double longitude,
    double radiusKm,
  ) {
    const double earthRadiusKm = 6371.0;
    final double latRadian = latitude * (3.14159 / 180);

    final double deltaLat = radiusKm / earthRadiusKm * (180 / 3.14159);
    final double deltaLng = radiusKm /
        (earthRadiusKm * (3.14159 / 180) * cos(latitude * 3.14159 / 180)) *
        (180 / 3.14159);

    return {
      'minLat': latitude - deltaLat,
      'maxLat': latitude + deltaLat,
      'minLng': longitude - deltaLng,
      'maxLng': longitude + deltaLng,
    };
  }

  /// حساب المسافة بين نقطتين
  double _calculateDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const double earthRadiusKm = 6371.0;
    final double dLat = (lat2 - lat1) * (3.14159 / 180);
    final double dLng = (lng2 - lng1) * (3.14159 / 180);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * 3.14159 / 180) *
            cos(lat2 * 3.14159 / 180) *
            sin(dLng / 2) *
            sin(dLng / 2);

    final double c = 2 * asin(sqrt(a));
    return earthRadiusKm * c;
  }
}
