import 'dart:math' as math;

/// نماذج الذكاء الاصطناعي الكمي

/// تحليل السوق الكمي
class QuantumMarketAnalysis {
  final String region;
  final String carType;
  final int timeHorizon;
  final List<double> quantumStates;
  final List<MarketTrend> marketTrends;
  final double priceVolatility;
  final double demandProbability;
  final double supplyProbability;
  final double quantumAdvantage;
  final double confidenceLevel;
  final Duration computationTime;
  final DateTime lastUpdated;

  const QuantumMarketAnalysis({
    required this.region,
    required this.carType,
    required this.timeHorizon,
    required this.quantumStates,
    required this.marketTrends,
    required this.priceVolatility,
    required this.demandProbability,
    required this.supplyProbability,
    required this.quantumAdvantage,
    required this.confidenceLevel,
    required this.computationTime,
    required this.lastUpdated,
  });

  factory QuantumMarketAnalysis.empty() {
    return QuantumMarketAnalysis(
      region: '',
      carType: '',
      timeHorizon: 0,
      quantumStates: [],
      marketTrends: [],
      priceVolatility: 0.0,
      demandProbability: 0.0,
      supplyProbability: 0.0,
      quantumAdvantage: 0.0,
      confidenceLevel: 0.0,
      computationTime: Duration.zero,
      lastUpdated: DateTime.now(),
    );
  }

  factory QuantumMarketAnalysis.fromMap(Map<String, dynamic> map) {
    return QuantumMarketAnalysis(
      region: map['region'] ?? '',
      carType: map['carType'] ?? '',
      timeHorizon: map['timeHorizon'] ?? 0,
      quantumStates: List<double>.from(map['quantumStates'] ?? []),
      marketTrends: (map['marketTrends'] as List<dynamic>?)
          ?.map((item) => MarketTrend.fromMap(item))
          .toList() ?? [],
      priceVolatility: (map['priceVolatility'] ?? 0.0).toDouble(),
      demandProbability: (map['demandProbability'] ?? 0.0).toDouble(),
      supplyProbability: (map['supplyProbability'] ?? 0.0).toDouble(),
      quantumAdvantage: (map['quantumAdvantage'] ?? 0.0).toDouble(),
      confidenceLevel: (map['confidenceLevel'] ?? 0.0).toDouble(),
      computationTime: Duration(milliseconds: map['computationTime'] ?? 0),
      lastUpdated: DateTime.parse(map['lastUpdated']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'region': region,
      'carType': carType,
      'timeHorizon': timeHorizon,
      'quantumStates': quantumStates,
      'marketTrends': marketTrends.map((trend) => trend.toMap()).toList(),
      'priceVolatility': priceVolatility,
      'demandProbability': demandProbability,
      'supplyProbability': supplyProbability,
      'quantumAdvantage': quantumAdvantage,
      'confidenceLevel': confidenceLevel,
      'computationTime': computationTime.inMilliseconds,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  String get marketOutlook {
    if (demandProbability > 0.8) return 'إيجابي جداً';
    if (demandProbability > 0.6) return 'إيجابي';
    if (demandProbability > 0.4) return 'محايد';
    return 'سلبي';
  }

  String get volatilityLevel {
    if (priceVolatility > 0.3) return 'عالي';
    if (priceVolatility > 0.15) return 'متوسط';
    return 'منخفض';
  }
}

/// اتجاه السوق
class MarketTrend {
  final String factor;
  final double impact;
  final double confidence;

  const MarketTrend({
    required this.factor,
    required this.impact,
    required this.confidence,
  });

  factory MarketTrend.fromMap(Map<String, dynamic> map) {
    return MarketTrend(
      factor: map['factor'] ?? '',
      impact: (map['impact'] ?? 0.0).toDouble(),
      confidence: (map['confidence'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'factor': factor,
      'impact': impact,
      'confidence': confidence,
    };
  }

  String get impactDirection {
    if (impact > 0.1) return 'إيجابي';
    if (impact < -0.1) return 'سلبي';
    return 'محايد';
  }
}

/// التنبؤ بالأسعار الكمي
class QuantumPricePrediction {
  final String carId;
  final double currentPrice;
  final List<PricePredictionPoint> predictions;
  final double quantumAdvantage;
  final double algorithmAccuracy;
  final List<String> marketFactors;
  final String riskAssessment;
  final DateTime lastUpdated;

  const QuantumPricePrediction({
    required this.carId,
    required this.currentPrice,
    required this.predictions,
    required this.quantumAdvantage,
    required this.algorithmAccuracy,
    required this.marketFactors,
    required this.riskAssessment,
    required this.lastUpdated,
  });

  factory QuantumPricePrediction.empty() {
    return QuantumPricePrediction(
      carId: '',
      currentPrice: 0.0,
      predictions: [],
      quantumAdvantage: 0.0,
      algorithmAccuracy: 0.0,
      marketFactors: [],
      riskAssessment: '',
      lastUpdated: DateTime.now(),
    );
  }

  factory QuantumPricePrediction.fromMap(Map<String, dynamic> map) {
    return QuantumPricePrediction(
      carId: map['carId'] ?? '',
      currentPrice: (map['currentPrice'] ?? 0.0).toDouble(),
      predictions: (map['predictions'] as List<dynamic>?)
          ?.map((item) => PricePredictionPoint.fromMap(item))
          .toList() ?? [],
      quantumAdvantage: (map['quantumAdvantage'] ?? 0.0).toDouble(),
      algorithmAccuracy: (map['algorithmAccuracy'] ?? 0.0).toDouble(),
      marketFactors: List<String>.from(map['marketFactors'] ?? []),
      riskAssessment: map['riskAssessment'] ?? '',
      lastUpdated: DateTime.parse(map['lastUpdated']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'carId': carId,
      'currentPrice': currentPrice,
      'predictions': predictions.map((p) => p.toMap()).toList(),
      'quantumAdvantage': quantumAdvantage,
      'algorithmAccuracy': algorithmAccuracy,
      'marketFactors': marketFactors,
      'riskAssessment': riskAssessment,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  double get averagePredictedPrice {
    if (predictions.isEmpty) return currentPrice;
    return predictions.map((p) => p.predictedPrice).reduce((a, b) => a + b) / predictions.length;
  }

  double get priceChangePercentage {
    if (predictions.isEmpty) return 0.0;
    final finalPrice = predictions.last.predictedPrice;
    return ((finalPrice - currentPrice) / currentPrice) * 100;
  }

  String get priceDirection {
    final change = priceChangePercentage;
    if (change > 5) return 'صاعد';
    if (change < -5) return 'هابط';
    return 'مستقر';
  }
}

/// نقطة التنبؤ بالسعر
class PricePredictionPoint {
  final DateTime date;
  final double predictedPrice;
  final double confidence;
  final double quantumUncertainty;

  const PricePredictionPoint({
    required this.date,
    required this.predictedPrice,
    required this.confidence,
    required this.quantumUncertainty,
  });

  factory PricePredictionPoint.fromMap(Map<String, dynamic> map) {
    return PricePredictionPoint(
      date: DateTime.parse(map['date']),
      predictedPrice: (map['predictedPrice'] ?? 0.0).toDouble(),
      confidence: (map['confidence'] ?? 0.0).toDouble(),
      quantumUncertainty: (map['quantumUncertainty'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'predictedPrice': predictedPrice,
      'confidence': confidence,
      'quantumUncertainty': quantumUncertainty,
    };
  }
}

/// تحليل سلوك المستخدم الكمي
class QuantumUserBehaviorAnalysis {
  final String userId;
  final int analysisDepth;
  final List<String> behaviorPatterns;
  final double purchaseProbability;
  final List<String> preferredCategories;
  final PriceRange priceRange;
  final double activityScore;
  final double loyaltyIndex;
  final Map<String, double> quantumPersonality;
  final List<String> predictedActions;
  final DateTime lastUpdated;

  const QuantumUserBehaviorAnalysis({
    required this.userId,
    required this.analysisDepth,
    required this.behaviorPatterns,
    required this.purchaseProbability,
    required this.preferredCategories,
    required this.priceRange,
    required this.activityScore,
    required this.loyaltyIndex,
    required this.quantumPersonality,
    required this.predictedActions,
    required this.lastUpdated,
  });

  factory QuantumUserBehaviorAnalysis.empty() {
    return QuantumUserBehaviorAnalysis(
      userId: '',
      analysisDepth: 0,
      behaviorPatterns: [],
      purchaseProbability: 0.0,
      preferredCategories: [],
      priceRange: PriceRange(min: 0.0, max: 0.0),
      activityScore: 0.0,
      loyaltyIndex: 0.0,
      quantumPersonality: {},
      predictedActions: [],
      lastUpdated: DateTime.now(),
    );
  }

  factory QuantumUserBehaviorAnalysis.fromMap(Map<String, dynamic> map) {
    return QuantumUserBehaviorAnalysis(
      userId: map['userId'] ?? '',
      analysisDepth: map['analysisDepth'] ?? 0,
      behaviorPatterns: List<String>.from(map['behaviorPatterns'] ?? []),
      purchaseProbability: (map['purchaseProbability'] ?? 0.0).toDouble(),
      preferredCategories: List<String>.from(map['preferredCategories'] ?? []),
      priceRange: PriceRange.fromMap(map['priceRange'] ?? {}),
      activityScore: (map['activityScore'] ?? 0.0).toDouble(),
      loyaltyIndex: (map['loyaltyIndex'] ?? 0.0).toDouble(),
      quantumPersonality: Map<String, double>.from(map['quantumPersonality'] ?? {}),
      predictedActions: List<String>.from(map['predictedActions'] ?? []),
      lastUpdated: DateTime.parse(map['lastUpdated']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'analysisDepth': analysisDepth,
      'behaviorPatterns': behaviorPatterns,
      'purchaseProbability': purchaseProbability,
      'preferredCategories': preferredCategories,
      'priceRange': priceRange.toMap(),
      'activityScore': activityScore,
      'loyaltyIndex': loyaltyIndex,
      'quantumPersonality': quantumPersonality,
      'predictedActions': predictedActions,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  String get userSegment {
    if (purchaseProbability > 0.8 && loyaltyIndex > 0.7) return 'عميل مميز';
    if (purchaseProbability > 0.6) return 'مشتري محتمل';
    if (activityScore > 0.5) return 'متصفح نشط';
    return 'زائر عادي';
  }

  String get personalityType {
    final traits = quantumPersonality.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return traits.isNotEmpty ? traits.first.key : 'غير محدد';
  }
}

/// نطاق الأسعار
class PriceRange {
  final double min;
  final double max;

  const PriceRange({
    required this.min,
    required this.max,
  });

  factory PriceRange.fromMap(Map<String, dynamic> map) {
    return PriceRange(
      min: (map['min'] ?? 0.0).toDouble(),
      max: (map['max'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'min': min,
      'max': max,
    };
  }

  double get average => (min + max) / 2;
  double get range => max - min;
}

/// تحسين المحفظة الكمي
class QuantumPortfolioOptimization {
  final String userId;
  final double budget;
  final String riskProfile;
  final List<OptimizedCarRecommendation> optimizedCars;
  final double expectedReturn;
  final double riskScore;
  final double diversificationIndex;
  final double quantumEfficiency;
  final bool rebalanceRecommendation;
  final DateTime lastUpdated;

  const QuantumPortfolioOptimization({
    required this.userId,
    required this.budget,
    required this.riskProfile,
    required this.optimizedCars,
    required this.expectedReturn,
    required this.riskScore,
    required this.diversificationIndex,
    required this.quantumEfficiency,
    required this.rebalanceRecommendation,
    required this.lastUpdated,
  });

  factory QuantumPortfolioOptimization.empty() {
    return QuantumPortfolioOptimization(
      userId: '',
      budget: 0.0,
      riskProfile: '',
      optimizedCars: [],
      expectedReturn: 0.0,
      riskScore: 0.0,
      diversificationIndex: 0.0,
      quantumEfficiency: 0.0,
      rebalanceRecommendation: false,
      lastUpdated: DateTime.now(),
    );
  }

  factory QuantumPortfolioOptimization.fromMap(Map<String, dynamic> map) {
    return QuantumPortfolioOptimization(
      userId: map['userId'] ?? '',
      budget: (map['budget'] ?? 0.0).toDouble(),
      riskProfile: map['riskProfile'] ?? '',
      optimizedCars: (map['optimizedCars'] as List<dynamic>?)
          ?.map((item) => OptimizedCarRecommendation.fromMap(item))
          .toList() ?? [],
      expectedReturn: (map['expectedReturn'] ?? 0.0).toDouble(),
      riskScore: (map['riskScore'] ?? 0.0).toDouble(),
      diversificationIndex: (map['diversificationIndex'] ?? 0.0).toDouble(),
      quantumEfficiency: (map['quantumEfficiency'] ?? 0.0).toDouble(),
      rebalanceRecommendation: map['rebalanceRecommendation'] ?? false,
      lastUpdated: DateTime.parse(map['lastUpdated']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'budget': budget,
      'riskProfile': riskProfile,
      'optimizedCars': optimizedCars.map((car) => car.toMap()).toList(),
      'expectedReturn': expectedReturn,
      'riskScore': riskScore,
      'diversificationIndex': diversificationIndex,
      'quantumEfficiency': quantumEfficiency,
      'rebalanceRecommendation': rebalanceRecommendation,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  double get totalAllocation => optimizedCars.fold(0.0, (sum, car) => sum + car.allocationPercentage);
  
  String get riskLevel {
    if (riskScore > 0.7) return 'عالي';
    if (riskScore > 0.4) return 'متوسط';
    return 'منخفض';
  }

  String get diversificationLevel {
    if (diversificationIndex > 0.8) return 'ممتاز';
    if (diversificationIndex > 0.6) return 'جيد';
    if (diversificationIndex > 0.4) return 'متوسط';
    return 'ضعيف';
  }
}

/// توصية السيارة المحسنة
class OptimizedCarRecommendation {
  final String carId;
  final double allocationPercentage;
  final double expectedReturn;
  final double riskLevel;
  final double quantumScore;
  final String reasoning;

  const OptimizedCarRecommendation({
    required this.carId,
    required this.allocationPercentage,
    required this.expectedReturn,
    required this.riskLevel,
    required this.quantumScore,
    required this.reasoning,
  });

  factory OptimizedCarRecommendation.fromMap(Map<String, dynamic> map) {
    return OptimizedCarRecommendation(
      carId: map['carId'] ?? '',
      allocationPercentage: (map['allocationPercentage'] ?? 0.0).toDouble(),
      expectedReturn: (map['expectedReturn'] ?? 0.0).toDouble(),
      riskLevel: (map['riskLevel'] ?? 0.0).toDouble(),
      quantumScore: (map['quantumScore'] ?? 0.0).toDouble(),
      reasoning: map['reasoning'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'carId': carId,
      'allocationPercentage': allocationPercentage,
      'expectedReturn': expectedReturn,
      'riskLevel': riskLevel,
      'quantumScore': quantumScore,
      'reasoning': reasoning,
    };
  }

  String get riskCategory {
    if (riskLevel > 0.7) return 'عالي المخاطر';
    if (riskLevel > 0.4) return 'متوسط المخاطر';
    return 'منخفض المخاطر';
  }
}

/// كشف الاحتيال الكمي
class QuantumFraudDetection {
  final String transactionId;
  final double fraudProbability;
  final FraudRiskLevel riskLevel;
  final List<String> detectedPatterns;
  final List<double> quantumSignatures;
  final FraudAction recommendedAction;
  final double confidenceLevel;
  final Duration processingTime;
  final DateTime lastUpdated;

  const QuantumFraudDetection({
    required this.transactionId,
    required this.fraudProbability,
    required this.riskLevel,
    required this.detectedPatterns,
    required this.quantumSignatures,
    required this.recommendedAction,
    required this.confidenceLevel,
    required this.processingTime,
    required this.lastUpdated,
  });

  factory QuantumFraudDetection.empty() {
    return QuantumFraudDetection(
      transactionId: '',
      fraudProbability: 0.0,
      riskLevel: FraudRiskLevel.low,
      detectedPatterns: [],
      quantumSignatures: [],
      recommendedAction: FraudAction.approve,
      confidenceLevel: 0.0,
      processingTime: Duration.zero,
      lastUpdated: DateTime.now(),
    );
  }

  factory QuantumFraudDetection.fromMap(Map<String, dynamic> map) {
    return QuantumFraudDetection(
      transactionId: map['transactionId'] ?? '',
      fraudProbability: (map['fraudProbability'] ?? 0.0).toDouble(),
      riskLevel: FraudRiskLevel.values.firstWhere(
        (e) => e.name == map['riskLevel'],
        orElse: () => FraudRiskLevel.low,
      ),
      detectedPatterns: List<String>.from(map['detectedPatterns'] ?? []),
      quantumSignatures: List<double>.from(map['quantumSignatures'] ?? []),
      recommendedAction: FraudAction.values.firstWhere(
        (e) => e.name == map['recommendedAction'],
        orElse: () => FraudAction.approve,
      ),
      confidenceLevel: (map['confidenceLevel'] ?? 0.0).toDouble(),
      processingTime: Duration(milliseconds: map['processingTime'] ?? 0),
      lastUpdated: DateTime.parse(map['lastUpdated']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'transactionId': transactionId,
      'fraudProbability': fraudProbability,
      'riskLevel': riskLevel.name,
      'detectedPatterns': detectedPatterns,
      'quantumSignatures': quantumSignatures,
      'recommendedAction': recommendedAction.name,
      'confidenceLevel': confidenceLevel,
      'processingTime': processingTime.inMilliseconds,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  bool get isSuspicious => fraudProbability > 0.5;
  bool get requiresReview => riskLevel == FraudRiskLevel.medium || riskLevel == FraudRiskLevel.high;
}

/// مستوى مخاطر الاحتيال
enum FraudRiskLevel {
  low('منخفض'),
  medium('متوسط'),
  high('عالي');

  const FraudRiskLevel(this.displayName);
  final String displayName;
}

/// إجراء الاحتيال
enum FraudAction {
  approve('موافقة'),
  review('مراجعة'),
  block('حظر');

  const FraudAction(this.displayName);
  final String displayName;
}

/// التنبؤ بالطلب الكمي
class QuantumDemandForecast {
  final String carCategory;
  final String region;
  final int forecastPeriod;
  final List<DemandForecastPoint> forecasts;
  final DemandTrend overallTrend;
  final double seasonalityFactor;
  final double quantumAccuracy;
  final DateTime lastUpdated;

  const QuantumDemandForecast({
    required this.carCategory,
    required this.region,
    required this.forecastPeriod,
    required this.forecasts,
    required this.overallTrend,
    required this.seasonalityFactor,
    required this.quantumAccuracy,
    required this.lastUpdated,
  });

  factory QuantumDemandForecast.empty() {
    return QuantumDemandForecast(
      carCategory: '',
      region: '',
      forecastPeriod: 0,
      forecasts: [],
      overallTrend: DemandTrend.stable,
      seasonalityFactor: 0.0,
      quantumAccuracy: 0.0,
      lastUpdated: DateTime.now(),
    );
  }

  factory QuantumDemandForecast.fromMap(Map<String, dynamic> map) {
    return QuantumDemandForecast(
      carCategory: map['carCategory'] ?? '',
      region: map['region'] ?? '',
      forecastPeriod: map['forecastPeriod'] ?? 0,
      forecasts: (map['forecasts'] as List<dynamic>?)
          ?.map((item) => DemandForecastPoint.fromMap(item))
          .toList() ?? [],
      overallTrend: DemandTrend.values.firstWhere(
        (e) => e.name == map['overallTrend'],
        orElse: () => DemandTrend.stable,
      ),
      seasonalityFactor: (map['seasonalityFactor'] ?? 0.0).toDouble(),
      quantumAccuracy: (map['quantumAccuracy'] ?? 0.0).toDouble(),
      lastUpdated: DateTime.parse(map['lastUpdated']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'carCategory': carCategory,
      'region': region,
      'forecastPeriod': forecastPeriod,
      'forecasts': forecasts.map((f) => f.toMap()).toList(),
      'overallTrend': overallTrend.name,
      'seasonalityFactor': seasonalityFactor,
      'quantumAccuracy': quantumAccuracy,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  double get averageDemand {
    if (forecasts.isEmpty) return 0.0;
    return forecasts.map((f) => f.demandLevel).reduce((a, b) => a + b) / forecasts.length;
  }

  double get peakDemand => forecasts.isEmpty ? 0.0 : forecasts.map((f) => f.demandLevel).reduce(math.max);
  double get minDemand => forecasts.isEmpty ? 0.0 : forecasts.map((f) => f.demandLevel).reduce(math.min);
}

/// نقطة التنبؤ بالطلب
class DemandForecastPoint {
  final DateTime date;
  final double demandLevel;
  final double confidence;
  final List<String> influencingFactors;

  const DemandForecastPoint({
    required this.date,
    required this.demandLevel,
    required this.confidence,
    required this.influencingFactors,
  });

  factory DemandForecastPoint.fromMap(Map<String, dynamic> map) {
    return DemandForecastPoint(
      date: DateTime.parse(map['date']),
      demandLevel: (map['demandLevel'] ?? 0.0).toDouble(),
      confidence: (map['confidence'] ?? 0.0).toDouble(),
      influencingFactors: List<String>.from(map['influencingFactors'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'demandLevel': demandLevel,
      'confidence': confidence,
      'influencingFactors': influencingFactors,
    };
  }

  String get demandCategory {
    if (demandLevel > 0.8) return 'طلب عالي';
    if (demandLevel > 0.6) return 'طلب متوسط';
    if (demandLevel > 0.4) return 'طلب منخفض';
    return 'طلب ضعيف';
  }
}

/// اتجاه الطلب
enum DemandTrend {
  increasing('متزايد'),
  stable('مستقر'),
  decreasing('متناقص');

  const DemandTrend(this.displayName);
  final String displayName;
}

/// حالة النظام الكمي
class QuantumSystemStatus {
  final bool isOnline;
  final List<QuantumProcessor> quantumProcessors;
  final int totalComputations;
  final Duration averageProcessingTime;
  final double systemLoad;
  final int quantumVolume;
  final DateTime lastMaintenance;
  final DateTime nextMaintenance;
  final DateTime lastUpdated;

  const QuantumSystemStatus({
    required this.isOnline,
    required this.quantumProcessors,
    required this.totalComputations,
    required this.averageProcessingTime,
    required this.systemLoad,
    required this.quantumVolume,
    required this.lastMaintenance,
    required this.nextMaintenance,
    required this.lastUpdated,
  });

  factory QuantumSystemStatus.empty() {
    return QuantumSystemStatus(
      isOnline: false,
      quantumProcessors: [],
      totalComputations: 0,
      averageProcessingTime: Duration.zero,
      systemLoad: 0.0,
      quantumVolume: 0,
      lastMaintenance: DateTime.now(),
      nextMaintenance: DateTime.now(),
      lastUpdated: DateTime.now(),
    );
  }

  factory QuantumSystemStatus.fromMap(Map<String, dynamic> map) {
    return QuantumSystemStatus(
      isOnline: map['isOnline'] ?? false,
      quantumProcessors: (map['quantumProcessors'] as List<dynamic>?)
          ?.map((item) => QuantumProcessor.fromMap(item))
          .toList() ?? [],
      totalComputations: map['totalComputations'] ?? 0,
      averageProcessingTime: Duration(milliseconds: map['averageProcessingTime'] ?? 0),
      systemLoad: (map['systemLoad'] ?? 0.0).toDouble(),
      quantumVolume: map['quantumVolume'] ?? 0,
      lastMaintenance: DateTime.parse(map['lastMaintenance']),
      nextMaintenance: DateTime.parse(map['nextMaintenance']),
      lastUpdated: DateTime.parse(map['lastUpdated']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isOnline': isOnline,
      'quantumProcessors': quantumProcessors.map((p) => p.toMap()).toList(),
      'totalComputations': totalComputations,
      'averageProcessingTime': averageProcessingTime.inMilliseconds,
      'systemLoad': systemLoad,
      'quantumVolume': quantumVolume,
      'lastMaintenance': lastMaintenance.toIso8601String(),
      'nextMaintenance': nextMaintenance.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  int get activeProcessors => quantumProcessors.where((p) => p.status == ProcessorStatus.active).length;
  int get totalQubits => quantumProcessors.fold(0, (sum, p) => sum + p.qubits);
  
  String get systemHealth {
    if (!isOnline) return 'غير متصل';
    if (systemLoad > 0.9) return 'محمل بشدة';
    if (systemLoad > 0.7) return 'محمل';
    if (systemLoad > 0.5) return 'نشط';
    return 'مستقر';
  }

  Duration get timeUntilMaintenance => nextMaintenance.difference(DateTime.now());
}

/// معالج كمي
class QuantumProcessor {
  final String id;
  final ProcessorStatus status;
  final int qubits;
  final Duration coherenceTime;
  final double errorRate;
  final double temperature; // Kelvin

  const QuantumProcessor({
    required this.id,
    required this.status,
    required this.qubits,
    required this.coherenceTime,
    required this.errorRate,
    required this.temperature,
  });

  factory QuantumProcessor.fromMap(Map<String, dynamic> map) {
    return QuantumProcessor(
      id: map['id'] ?? '',
      status: ProcessorStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ProcessorStatus.offline,
      ),
      qubits: map['qubits'] ?? 0,
      coherenceTime: Duration(microseconds: map['coherenceTime'] ?? 0),
      errorRate: (map['errorRate'] ?? 0.0).toDouble(),
      temperature: (map['temperature'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'status': status.name,
      'qubits': qubits,
      'coherenceTime': coherenceTime.inMicroseconds,
      'errorRate': errorRate,
      'temperature': temperature,
    };
  }

  bool get isOperational => status == ProcessorStatus.active;
  
  String get performanceLevel {
    if (errorRate > 0.01) return 'منخفض';
    if (errorRate > 0.005) return 'متوسط';
    if (errorRate > 0.001) return 'جيد';
    return 'ممتاز';
  }
}

/// حالة المعالج
enum ProcessorStatus {
  active('نشط'),
  maintenance('صيانة'),
  offline('غير متصل'),
  error('خطأ');

  const ProcessorStatus(this.displayName);
  final String displayName;
}
