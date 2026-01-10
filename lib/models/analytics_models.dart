/// نماذج التحليلات المتقدمة

/// إحصائيات التطبيق العامة
class AppStatistics {
  final int totalUsers;
  final int totalCars;
  final int totalTransactions;
  final int activeUsers;
  final List<BrandStatistic> popularBrands;
  final Map<String, double> averagePrices;
  final DateTime lastUpdated;

  const AppStatistics({
    required this.totalUsers,
    required this.totalCars,
    required this.totalTransactions,
    required this.activeUsers,
    required this.popularBrands,
    required this.averagePrices,
    required this.lastUpdated,
  });

  factory AppStatistics.empty() {
    return AppStatistics(
      totalUsers: 0,
      totalCars: 0,
      totalTransactions: 0,
      activeUsers: 0,
      popularBrands: [],
      averagePrices: {},
      lastUpdated: DateTime.now(),
    );
  }

  factory AppStatistics.fromMap(Map<String, dynamic> map) {
    return AppStatistics(
      totalUsers: map['totalUsers'] ?? 0,
      totalCars: map['totalCars'] ?? 0,
      totalTransactions: map['totalTransactions'] ?? 0,
      activeUsers: map['activeUsers'] ?? 0,
      popularBrands: (map['popularBrands'] as List<dynamic>?)
          ?.map((item) => BrandStatistic.fromMap(item))
          .toList() ?? [],
      averagePrices: Map<String, double>.from(map['averagePrices'] ?? {}),
      lastUpdated: DateTime.parse(map['lastUpdated']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalUsers': totalUsers,
      'totalCars': totalCars,
      'totalTransactions': totalTransactions,
      'activeUsers': activeUsers,
      'popularBrands': popularBrands.map((brand) => brand.toMap()).toList(),
      'averagePrices': averagePrices,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}

/// إحصائية الماركة
class BrandStatistic {
  final String brand;
  final int count;
  final double percentage;

  const BrandStatistic({
    required this.brand,
    required this.count,
    required this.percentage,
  });

  factory BrandStatistic.fromMap(Map<String, dynamic> map) {
    return BrandStatistic(
      brand: map['brand'],
      count: map['count'],
      percentage: map['percentage'].toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'brand': brand,
      'count': count,
      'percentage': percentage,
    };
  }
}

/// تحليلات المبيعات
class SalesAnalytics {
  final int totalSales;
  final double totalRevenue;
  final double averagePrice;
  final List<DataPoint> dailyTrends;
  final List<BrandStatistic> topSellingBrands;
  final double conversionRate;
  final DateTime lastUpdated;

  const SalesAnalytics({
    required this.totalSales,
    required this.totalRevenue,
    required this.averagePrice,
    required this.dailyTrends,
    required this.topSellingBrands,
    required this.conversionRate,
    required this.lastUpdated,
  });

  factory SalesAnalytics.empty() {
    return SalesAnalytics(
      totalSales: 0,
      totalRevenue: 0.0,
      averagePrice: 0.0,
      dailyTrends: [],
      topSellingBrands: [],
      conversionRate: 0.0,
      lastUpdated: DateTime.now(),
    );
  }

  factory SalesAnalytics.fromMap(Map<String, dynamic> map) {
    return SalesAnalytics(
      totalSales: map['totalSales'] ?? 0,
      totalRevenue: (map['totalRevenue'] ?? 0.0).toDouble(),
      averagePrice: (map['averagePrice'] ?? 0.0).toDouble(),
      dailyTrends: (map['dailyTrends'] as List<dynamic>?)
          ?.map((item) => DataPoint.fromMap(item))
          .toList() ?? [],
      topSellingBrands: (map['topSellingBrands'] as List<dynamic>?)
          ?.map((item) => BrandStatistic.fromMap(item))
          .toList() ?? [],
      conversionRate: (map['conversionRate'] ?? 0.0).toDouble(),
      lastUpdated: DateTime.parse(map['lastUpdated']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalSales': totalSales,
      'totalRevenue': totalRevenue,
      'averagePrice': averagePrice,
      'dailyTrends': dailyTrends.map((point) => point.toMap()).toList(),
      'topSellingBrands': topSellingBrands.map((brand) => brand.toMap()).toList(),
      'conversionRate': conversionRate,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}

/// تحليلات المستخدمين
class UserAnalytics {
  final List<DataPoint> registrationTrends;
  final List<DataPoint> activityData;
  final Map<String, int> demographics;
  final Map<String, double> retentionData;
  final DateTime lastUpdated;

  const UserAnalytics({
    required this.registrationTrends,
    required this.activityData,
    required this.demographics,
    required this.retentionData,
    required this.lastUpdated,
  });

  factory UserAnalytics.empty() {
    return UserAnalytics(
      registrationTrends: [],
      activityData: [],
      demographics: {},
      retentionData: {},
      lastUpdated: DateTime.now(),
    );
  }

  factory UserAnalytics.fromMap(Map<String, dynamic> map) {
    return UserAnalytics(
      registrationTrends: (map['registrationTrends'] as List<dynamic>?)
          ?.map((item) => DataPoint.fromMap(item))
          .toList() ?? [],
      activityData: (map['activityData'] as List<dynamic>?)
          ?.map((item) => DataPoint.fromMap(item))
          .toList() ?? [],
      demographics: Map<String, int>.from(map['demographics'] ?? {}),
      retentionData: Map<String, double>.from(map['retentionData'] ?? {}),
      lastUpdated: DateTime.parse(map['lastUpdated']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'registrationTrends': registrationTrends.map((point) => point.toMap()).toList(),
      'activityData': activityData.map((point) => point.toMap()).toList(),
      'demographics': demographics,
      'retentionData': retentionData,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}

/// تقرير السوق
class MarketReport {
  final List<PriceTrend> priceTrends;
  final List<ModelPopularity> popularModels;
  final List<CityAnalytic> cityAnalytics;
  final List<SeasonalTrend> seasonalTrends;
  final DateTime generatedAt;

  const MarketReport({
    required this.priceTrends,
    required this.popularModels,
    required this.cityAnalytics,
    required this.seasonalTrends,
    required this.generatedAt,
  });

  factory MarketReport.empty() {
    return MarketReport(
      priceTrends: [],
      popularModels: [],
      cityAnalytics: [],
      seasonalTrends: [],
      generatedAt: DateTime.now(),
    );
  }

  factory MarketReport.fromMap(Map<String, dynamic> map) {
    return MarketReport(
      priceTrends: (map['priceTrends'] as List<dynamic>?)
          ?.map((item) => PriceTrend.fromMap(item))
          .toList() ?? [],
      popularModels: (map['popularModels'] as List<dynamic>?)
          ?.map((item) => ModelPopularity.fromMap(item))
          .toList() ?? [],
      cityAnalytics: (map['cityAnalytics'] as List<dynamic>?)
          ?.map((item) => CityAnalytic.fromMap(item))
          .toList() ?? [],
      seasonalTrends: (map['seasonalTrends'] as List<dynamic>?)
          ?.map((item) => SeasonalTrend.fromMap(item))
          .toList() ?? [],
      generatedAt: DateTime.parse(map['generatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'priceTrends': priceTrends.map((trend) => trend.toMap()).toList(),
      'popularModels': popularModels.map((model) => model.toMap()).toList(),
      'cityAnalytics': cityAnalytics.map((city) => city.toMap()).toList(),
      'seasonalTrends': seasonalTrends.map((trend) => trend.toMap()).toList(),
      'generatedAt': generatedAt.toIso8601String(),
    };
  }
}

/// نقطة بيانات للرسوم البيانية
class DataPoint {
  final String label;
  final double value;

  const DataPoint({
    required this.label,
    required this.value,
  });

  factory DataPoint.fromMap(Map<String, dynamic> map) {
    return DataPoint(
      label: map['label'],
      value: (map['value'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'value': value,
    };
  }
}

/// اتجاه السعر
class PriceTrend {
  final String brand;
  final double currentPrice;
  final double previousPrice;
  final double changePercent;

  const PriceTrend({
    required this.brand,
    required this.currentPrice,
    required this.previousPrice,
    required this.changePercent,
  });

  bool get isIncreasing => changePercent > 0;
  bool get isDecreasing => changePercent < 0;
  bool get isStable => changePercent == 0;

  factory PriceTrend.fromMap(Map<String, dynamic> map) {
    return PriceTrend(
      brand: map['brand'],
      currentPrice: (map['currentPrice'] ?? 0.0).toDouble(),
      previousPrice: (map['previousPrice'] ?? 0.0).toDouble(),
      changePercent: (map['changePercent'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'brand': brand,
      'currentPrice': currentPrice,
      'previousPrice': previousPrice,
      'changePercent': changePercent,
    };
  }
}

/// شعبية الموديل
class ModelPopularity {
  final String brand;
  final String model;
  final int searchCount;
  final int viewCount;

  const ModelPopularity({
    required this.brand,
    required this.model,
    required this.searchCount,
    required this.viewCount,
  });

  double get engagementRate => viewCount > 0 ? (searchCount / viewCount) * 100 : 0;

  factory ModelPopularity.fromMap(Map<String, dynamic> map) {
    return ModelPopularity(
      brand: map['brand'],
      model: map['model'],
      searchCount: map['searchCount'] ?? 0,
      viewCount: map['viewCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'brand': brand,
      'model': model,
      'searchCount': searchCount,
      'viewCount': viewCount,
    };
  }
}

/// تحليل المدينة
class CityAnalytic {
  final String city;
  final int totalCars;
  final double averagePrice;
  final String popularBrand;

  const CityAnalytic({
    required this.city,
    required this.totalCars,
    required this.averagePrice,
    required this.popularBrand,
  });

  factory CityAnalytic.fromMap(Map<String, dynamic> map) {
    return CityAnalytic(
      city: map['city'],
      totalCars: map['totalCars'] ?? 0,
      averagePrice: (map['averagePrice'] ?? 0.0).toDouble(),
      popularBrand: map['popularBrand'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'city': city,
      'totalCars': totalCars,
      'averagePrice': averagePrice,
      'popularBrand': popularBrand,
    };
  }
}

/// الاتجاه الموسمي
class SeasonalTrend {
  final String month;
  final int salesCount;
  final double averagePrice;

  const SeasonalTrend({
    required this.month,
    required this.salesCount,
    required this.averagePrice,
  });

  factory SeasonalTrend.fromMap(Map<String, dynamic> map) {
    return SeasonalTrend(
      month: map['month'],
      salesCount: map['salesCount'] ?? 0,
      averagePrice: (map['averagePrice'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'month': month,
      'salesCount': salesCount,
      'averagePrice': averagePrice,
    };
  }
}

/// مقاييس الأداء
class PerformanceMetrics {
  final double averageLoadTime;
  final double errorRate;
  final double crashRate;
  final double userSatisfaction;
  final Map<String, double> apiResponseTimes;
  final DateTime lastUpdated;

  const PerformanceMetrics({
    required this.averageLoadTime,
    required this.errorRate,
    required this.crashRate,
    required this.userSatisfaction,
    required this.apiResponseTimes,
    required this.lastUpdated,
  });

  factory PerformanceMetrics.empty() {
    return PerformanceMetrics(
      averageLoadTime: 0.0,
      errorRate: 0.0,
      crashRate: 0.0,
      userSatisfaction: 0.0,
      apiResponseTimes: {},
      lastUpdated: DateTime.now(),
    );
  }

  factory PerformanceMetrics.fromMap(Map<String, dynamic> map) {
    return PerformanceMetrics(
      averageLoadTime: (map['averageLoadTime'] ?? 0.0).toDouble(),
      errorRate: (map['errorRate'] ?? 0.0).toDouble(),
      crashRate: (map['crashRate'] ?? 0.0).toDouble(),
      userSatisfaction: (map['userSatisfaction'] ?? 0.0).toDouble(),
      apiResponseTimes: Map<String, double>.from(map['apiResponseTimes'] ?? {}),
      lastUpdated: DateTime.parse(map['lastUpdated']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'averageLoadTime': averageLoadTime,
      'errorRate': errorRate,
      'crashRate': crashRate,
      'userSatisfaction': userSatisfaction,
      'apiResponseTimes': apiResponseTimes,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}
