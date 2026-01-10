import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tashlehekomv2/services/logging_service.dart';
import 'package:tashlehekomv2/services/enhanced_error_handler.dart';
import 'package:tashlehekomv2/services/performance_service.dart';
import 'package:tashlehekomv2/services/enhanced_cache_service.dart';
import 'package:tashlehekomv2/models/analytics_models.dart';

/// خدمة التحليلات المتقدمة
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final EnhancedCacheService _cache = EnhancedCacheService();

  /// الحصول على إحصائيات عامة للتطبيق
  Future<AppStatistics> getAppStatistics() async {
    final result =
        await EnhancedErrorHandler.executeWithErrorHandling<AppStatistics>(
      () async {
        return PerformanceService.measureAsync('app_statistics', () async {
          const cacheKey = 'app_statistics';

          // التحقق من التخزين المؤقت
          final cachedStats = await _cache.get<Map<String, dynamic>>(cacheKey);
          if (cachedStats != null) {
            LoggingService.info(
                'تم العثور على إحصائيات التطبيق في التخزين المؤقت');
            return AppStatistics.fromMap(cachedStats);
          }

          // جمع الإحصائيات من قاعدة البيانات
          final futures = await Future.wait([
            _getTotalUsers(),
            _getTotalCars(),
            _getTotalTransactions(),
            _getActiveUsers(),
            _getPopularBrands(),
            _getAveragePrices(),
          ]);

          final stats = AppStatistics(
            totalUsers: futures[0] as int,
            totalCars: futures[1] as int,
            totalTransactions: futures[2] as int,
            activeUsers: futures[3] as int,
            popularBrands: futures[4] as List<BrandStatistic>,
            averagePrices: futures[5] as Map<String, double>,
            lastUpdated: DateTime.now(),
          );

          // حفظ في التخزين المؤقت
          await _cache.set(
            cacheKey,
            stats.toMap(),
            expiration: const Duration(hours: 1),
          );

          LoggingService.success('تم جمع إحصائيات التطبيق بنجاح');
          return stats;
        });
      },
      'جمع إحصائيات التطبيق',
    );
    return result ?? AppStatistics.empty();
  }

  /// الحصول على تحليلات المبيعات
  Future<SalesAnalytics> getSalesAnalytics({
    DateTime? startDate,
    DateTime? endDate,
    String? city,
    String? brand,
  }) async {
    final result =
        await EnhancedErrorHandler.executeWithErrorHandling<SalesAnalytics>(
      () async {
        return PerformanceService.measureAsync('sales_analytics', () async {
          final start =
              startDate ?? DateTime.now().subtract(const Duration(days: 30));
          final end = endDate ?? DateTime.now();

          final cacheKey =
              'sales_analytics_${start.millisecondsSinceEpoch}_${end.millisecondsSinceEpoch}_${city ?? 'all'}_${brand ?? 'all'}';

          // التحقق من التخزين المؤقت
          final cachedAnalytics =
              await _cache.get<Map<String, dynamic>>(cacheKey);
          if (cachedAnalytics != null) {
            return SalesAnalytics.fromMap(cachedAnalytics);
          }

          // بناء الاستعلام
          Query query = _firestore
              .collection('transactions')
              .where('createdAt', isGreaterThanOrEqualTo: start)
              .where('createdAt', isLessThanOrEqualTo: end);

          if (city != null) {
            query = query.where('city', isEqualTo: city);
          }

          final snapshot = await query.get();
          final transactions = snapshot.docs;

          // تحليل البيانات
          final analytics = _analyzeSalesData(transactions, brand);

          // حفظ في التخزين المؤقت
          await _cache.set(
            cacheKey,
            analytics.toMap(),
            expiration: const Duration(minutes: 30),
          );

          return analytics;
        });
      },
      'تحليل المبيعات',
    );
    return result ?? SalesAnalytics.empty();
  }

  /// الحصول على تحليلات المستخدمين
  Future<UserAnalytics> getUserAnalytics() async {
    final result =
        await EnhancedErrorHandler.executeWithErrorHandling<UserAnalytics>(
      () async {
        return PerformanceService.measureAsync('user_analytics', () async {
          const cacheKey = 'user_analytics';

          final cachedAnalytics =
              await _cache.get<Map<String, dynamic>>(cacheKey);
          if (cachedAnalytics != null) {
            return UserAnalytics.fromMap(cachedAnalytics);
          }

          final futures = await Future.wait([
            _getUserRegistrationTrends(),
            _getUserActivityData(),
            _getUserDemographics(),
            _getUserRetentionData(),
          ]);

          final analytics = UserAnalytics(
            registrationTrends: futures[0] as List<DataPoint>,
            activityData: futures[1] as List<DataPoint>,
            demographics: futures[2] as Map<String, int>,
            retentionData: futures[3] as Map<String, double>,
            lastUpdated: DateTime.now(),
          );

          await _cache.set(
            cacheKey,
            analytics.toMap(),
            expiration: const Duration(hours: 2),
          );

          return analytics;
        });
      },
      'تحليل المستخدمين',
    );
    return result ?? UserAnalytics.empty();
  }

  /// الحصول على تقرير السوق
  Future<MarketReport> getMarketReport() async {
    final result =
        await EnhancedErrorHandler.executeWithErrorHandling<MarketReport>(
      () async {
        return PerformanceService.measureAsync('market_report', () async {
          const cacheKey = 'market_report';

          final cachedReport = await _cache.get<Map<String, dynamic>>(cacheKey);
          if (cachedReport != null) {
            return MarketReport.fromMap(cachedReport);
          }

          final futures = await Future.wait([
            _getPriceTrends(),
            _getPopularModels(),
            _getCityAnalytics(),
            _getSeasonalTrends(),
          ]);

          final report = MarketReport(
            priceTrends: futures[0] as List<PriceTrend>,
            popularModels: futures[1] as List<ModelPopularity>,
            cityAnalytics: futures[2] as List<CityAnalytic>,
            seasonalTrends: futures[3] as List<SeasonalTrend>,
            generatedAt: DateTime.now(),
          );

          await _cache.set(
            cacheKey,
            report.toMap(),
            expiration: const Duration(hours: 6),
          );

          return report;
        });
      },
      'تقرير السوق',
    );
    return result ?? MarketReport.empty();
  }

  /// تسجيل حدث تحليلي
  Future<void> trackEvent({
    required String eventName,
    required String userId,
    Map<String, dynamic>? parameters,
  }) async {
    return EnhancedErrorHandler.executeWithErrorHandling(
      () async {
        await _firestore.collection('analytics_events').add({
          'eventName': eventName,
          'userId': userId,
          'parameters': parameters ?? {},
          'timestamp': FieldValue.serverTimestamp(),
          'platform': 'mobile',
        });

        LoggingService.info('تم تسجيل الحدث التحليلي: $eventName');
      },
      'تسجيل حدث تحليلي',
    );
  }

  /// الحصول على إحصائيات الأداء
  Future<PerformanceMetrics> getPerformanceMetrics() async {
    final result =
        await EnhancedErrorHandler.executeWithErrorHandling<PerformanceMetrics>(
      () async {
        return PerformanceService.measureAsync('performance_metrics', () async {
          const cacheKey = 'performance_metrics';

          final cachedMetrics =
              await _cache.get<Map<String, dynamic>>(cacheKey);
          if (cachedMetrics != null) {
            return PerformanceMetrics.fromMap(cachedMetrics);
          }

          // جمع مقاييس الأداء
          final metrics = PerformanceMetrics(
            averageLoadTime: await _getAverageLoadTime(),
            errorRate: await _getErrorRate(),
            crashRate: await _getCrashRate(),
            userSatisfaction: await _getUserSatisfactionScore(),
            apiResponseTimes: await _getApiResponseTimes(),
            lastUpdated: DateTime.now(),
          );

          await _cache.set(
            cacheKey,
            metrics.toMap(),
            expiration: const Duration(minutes: 15),
          );

          return metrics;
        });
      },
      'مقاييس الأداء',
    );
    return result ?? PerformanceMetrics.empty();
  }

  // الطرق المساعدة
  Future<int> _getTotalUsers() async {
    final snapshot = await _firestore.collection('users').count().get();
    return snapshot.count ?? 0;
  }

  Future<int> _getTotalCars() async {
    final snapshot = await _firestore.collection('cars').count().get();
    return snapshot.count ?? 0;
  }

  Future<int> _getTotalTransactions() async {
    final snapshot = await _firestore.collection('transactions').count().get();
    return snapshot.count ?? 0;
  }

  Future<int> _getActiveUsers() async {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final snapshot = await _firestore
        .collection('users')
        .where('lastActive', isGreaterThan: thirtyDaysAgo)
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  Future<List<BrandStatistic>> _getPopularBrands() async {
    final snapshot = await _firestore.collection('cars').get();
    final brandCounts = <String, int>{};

    for (final doc in snapshot.docs) {
      final brand = doc.data()['brand'] as String?;
      if (brand != null) {
        brandCounts[brand] = (brandCounts[brand] ?? 0) + 1;
      }
    }

    return brandCounts.entries
        .map((entry) => BrandStatistic(
              brand: entry.key,
              count: entry.value,
              percentage: (entry.value / snapshot.docs.length) * 100,
            ))
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));
  }

  Future<Map<String, double>> _getAveragePrices() async {
    final snapshot = await _firestore.collection('cars').get();
    final brandPrices = <String, List<double>>{};

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final brand = data['brand'] as String?;
      final price = (data['price'] as num?)?.toDouble();

      if (brand != null && price != null) {
        brandPrices.putIfAbsent(brand, () => []).add(price);
      }
    }

    return brandPrices.map((brand, prices) {
      final average = prices.reduce((a, b) => a + b) / prices.length;
      return MapEntry(brand, average);
    });
  }

  SalesAnalytics _analyzeSalesData(
      List<QueryDocumentSnapshot> transactions, String? brandFilter) {
    var filteredTransactions = transactions;

    if (brandFilter != null) {
      filteredTransactions = transactions.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['carBrand'] == brandFilter;
      }).toList();
    }

    final totalSales = filteredTransactions.length;
    final totalRevenue = filteredTransactions.fold<double>(0, (sum, doc) {
      final data = doc.data() as Map<String, dynamic>;
      return sum + ((data['amount'] as num?)?.toDouble() ?? 0);
    });

    final averagePrice = totalSales > 0 ? totalRevenue / totalSales : 0.0;

    // تحليل الاتجاهات اليومية
    final dailyTrends = <DataPoint>[];
    final dailyData = <String, int>{};

    for (final doc in filteredTransactions) {
      final data = doc.data() as Map<String, dynamic>;
      final timestamp = (data['createdAt'] as Timestamp).toDate();
      final dateKey =
          '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}';
      dailyData[dateKey] = (dailyData[dateKey] ?? 0) + 1;
    }

    dailyData.forEach((date, count) {
      dailyTrends.add(DataPoint(label: date, value: count.toDouble()));
    });

    return SalesAnalytics(
      totalSales: totalSales,
      totalRevenue: totalRevenue,
      averagePrice: averagePrice,
      dailyTrends: dailyTrends,
      topSellingBrands: [],
      conversionRate: 0.0,
      lastUpdated: DateTime.now(),
    );
  }

  Future<List<DataPoint>> _getUserRegistrationTrends() async {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final snapshot = await _firestore
        .collection('users')
        .where('createdAt', isGreaterThan: thirtyDaysAgo)
        .get();

    final dailyRegistrations = <String, int>{};

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final timestamp = (data['createdAt'] as Timestamp).toDate();
      final dateKey = '${timestamp.month}/${timestamp.day}';
      dailyRegistrations[dateKey] = (dailyRegistrations[dateKey] ?? 0) + 1;
    }

    return dailyRegistrations.entries
        .map((entry) =>
            DataPoint(label: entry.key, value: entry.value.toDouble()))
        .toList();
  }

  Future<List<DataPoint>> _getUserActivityData() async {
    // محاكاة بيانات النشاط
    return [
      DataPoint(label: 'البحث', value: 45.0),
      DataPoint(label: 'المشاهدة', value: 30.0),
      DataPoint(label: 'التواصل', value: 15.0),
      DataPoint(label: 'الشراء', value: 10.0),
    ];
  }

  Future<Map<String, int>> _getUserDemographics() async {
    // محاكاة البيانات الديموغرافية
    return {
      'الرياض': 35,
      'جدة': 25,
      'الدمام': 20,
      'مكة': 15,
      'أخرى': 5,
    };
  }

  Future<Map<String, double>> _getUserRetentionData() async {
    // محاكاة بيانات الاحتفاظ
    return {
      'اليوم الأول': 100.0,
      'الأسبوع الأول': 75.0,
      'الشهر الأول': 50.0,
      'الشهر الثالث': 30.0,
      'الشهر السادس': 20.0,
    };
  }

  Future<List<PriceTrend>> _getPriceTrends() async {
    // محاكاة اتجاهات الأسعار
    return [
      PriceTrend(
          brand: 'تويوتا',
          currentPrice: 85000,
          previousPrice: 82000,
          changePercent: 3.7),
      PriceTrend(
          brand: 'هوندا',
          currentPrice: 78000,
          previousPrice: 80000,
          changePercent: -2.5),
      PriceTrend(
          brand: 'نيسان',
          currentPrice: 72000,
          previousPrice: 71000,
          changePercent: 1.4),
    ];
  }

  Future<List<ModelPopularity>> _getPopularModels() async {
    // محاكاة شعبية الموديلات
    return [
      ModelPopularity(
          brand: 'تويوتا', model: 'كامري', searchCount: 1250, viewCount: 3500),
      ModelPopularity(
          brand: 'هوندا', model: 'أكورد', searchCount: 980, viewCount: 2800),
      ModelPopularity(
          brand: 'نيسان', model: 'التيما', searchCount: 750, viewCount: 2100),
    ];
  }

  Future<List<CityAnalytic>> _getCityAnalytics() async {
    // محاكاة تحليلات المدن
    return [
      CityAnalytic(
          city: 'الرياض',
          totalCars: 1500,
          averagePrice: 85000,
          popularBrand: 'تويوتا'),
      CityAnalytic(
          city: 'جدة',
          totalCars: 1200,
          averagePrice: 78000,
          popularBrand: 'هوندا'),
      CityAnalytic(
          city: 'الدمام',
          totalCars: 800,
          averagePrice: 72000,
          popularBrand: 'نيسان'),
    ];
  }

  Future<List<SeasonalTrend>> _getSeasonalTrends() async {
    // محاكاة الاتجاهات الموسمية
    return [
      SeasonalTrend(month: 'يناير', salesCount: 450, averagePrice: 82000),
      SeasonalTrend(month: 'فبراير', salesCount: 520, averagePrice: 84000),
      SeasonalTrend(month: 'مارس', salesCount: 680, averagePrice: 86000),
    ];
  }

  Future<double> _getAverageLoadTime() async {
    // محاكاة متوسط وقت التحميل
    return 2.3;
  }

  Future<double> _getErrorRate() async {
    // محاكاة معدل الأخطاء
    return 0.05;
  }

  Future<double> _getCrashRate() async {
    // محاكاة معدل التعطل
    return 0.01;
  }

  Future<double> _getUserSatisfactionScore() async {
    // محاكاة نقاط رضا المستخدمين
    return 4.2;
  }

  Future<Map<String, double>> _getApiResponseTimes() async {
    // محاكاة أوقات استجابة API
    return {
      'البحث': 150.0,
      'تحميل السيارات': 300.0,
      'المراسلة': 100.0,
      'التحليلات': 500.0,
    };
  }
}
