import 'package:uuid/uuid.dart';

/// نموذج تقييم الذكاء الاصطناعي للسيارات
class AICarEvaluation {
  final String id;
  final String carId;
  final double predictedPrice;
  final double confidenceScore;
  final List<String> strengths;
  final List<String> weaknesses;
  final Map<String, double> componentScores;
  final DateTime evaluatedAt;
  final String aiModelVersion;

  AICarEvaluation({
    required this.id,
    required this.carId,
    required this.predictedPrice,
    required this.confidenceScore,
    required this.strengths,
    required this.weaknesses,
    required this.componentScores,
    required this.evaluatedAt,
    required this.aiModelVersion,
  });

  factory AICarEvaluation.fromJson(Map<String, dynamic> json) {
    return AICarEvaluation(
      id: json['id'],
      carId: json['carId'],
      predictedPrice: json['predictedPrice'].toDouble(),
      confidenceScore: json['confidenceScore'].toDouble(),
      strengths: List<String>.from(json['strengths']),
      weaknesses: List<String>.from(json['weaknesses']),
      componentScores: Map<String, double>.from(json['componentScores']),
      evaluatedAt: DateTime.parse(json['evaluatedAt']),
      aiModelVersion: json['aiModelVersion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'carId': carId,
      'predictedPrice': predictedPrice,
      'confidenceScore': confidenceScore,
      'strengths': strengths,
      'weaknesses': weaknesses,
      'componentScores': componentScores,
      'evaluatedAt': evaluatedAt.toIso8601String(),
      'aiModelVersion': aiModelVersion,
    };
  }
}

/// نموذج التوصيات الذكية
class SmartRecommendation {
  final String id;
  final String userId;
  final String carId;
  final RecommendationType type;
  final String title;
  final String description;
  final double relevanceScore;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final bool isViewed;

  SmartRecommendation({
    required this.id,
    required this.userId,
    required this.carId,
    required this.type,
    required this.title,
    required this.description,
    required this.relevanceScore,
    required this.metadata,
    required this.createdAt,
    required this.isViewed,
  });

  factory SmartRecommendation.fromJson(Map<String, dynamic> json) {
    return SmartRecommendation(
      id: json['id'],
      userId: json['userId'],
      carId: json['carId'],
      type: RecommendationType.values[json['type']],
      title: json['title'],
      description: json['description'],
      relevanceScore: json['relevanceScore'].toDouble(),
      metadata: Map<String, dynamic>.from(json['metadata']),
      createdAt: DateTime.parse(json['createdAt']),
      isViewed: json['isViewed'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'carId': carId,
      'type': type.index,
      'title': title,
      'description': description,
      'relevanceScore': relevanceScore,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'isViewed': isViewed,
    };
  }
}

enum RecommendationType {
  similarCar,
  priceAlert,
  maintenanceTip,
  upgradeOpportunity,
  marketTrend,
  personalizedOffer,
}

/// نموذج تحليل السوق بالذكاء الاصطناعي
class MarketAnalysis {
  final String id;
  final String brand;
  final String model;
  final int year;
  final double averagePrice;
  final double priceVariation;
  final List<PriceTrend> trends;
  final Map<String, double> factorImpacts;
  final DateTime analyzedAt;

  MarketAnalysis({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.averagePrice,
    required this.priceVariation,
    required this.trends,
    required this.factorImpacts,
    required this.analyzedAt,
  });
}

class PriceTrend {
  final DateTime date;
  final double price;
  final int volume;

  PriceTrend({
    required this.date,
    required this.price,
    required this.volume,
  });
}

/// نموذج فحص الصور بالذكاء الاصطناعي
class AIImageAnalysis {
  final String id;
  final String carId;
  final String imageUrl;
  final List<DetectedDamage> damages;
  final double overallConditionScore;
  final List<String> identifiedFeatures;
  final Map<String, double> partConditions;
  final DateTime analyzedAt;

  AIImageAnalysis({
    required this.id,
    required this.carId,
    required this.imageUrl,
    required this.damages,
    required this.overallConditionScore,
    required this.identifiedFeatures,
    required this.partConditions,
    required this.analyzedAt,
  });
}

class DetectedDamage {
  final String type;
  final String location;
  final double severity;
  final String description;
  final List<double> boundingBox;

  DetectedDamage({
    required this.type,
    required this.location,
    required this.severity,
    required this.description,
    required this.boundingBox,
  });
}

/// نموذج التنبؤ بالأسعار
class PricePrediction {
  final String id;
  final String carId;
  final double currentPrice;
  final double predictedPrice30Days;
  final double predictedPrice90Days;
  final double predictedPrice180Days;
  final List<PriceFactor> factors;
  final double accuracy;
  final DateTime predictedAt;

  PricePrediction({
    required this.id,
    required this.carId,
    required this.currentPrice,
    required this.predictedPrice30Days,
    required this.predictedPrice90Days,
    required this.predictedPrice180Days,
    required this.factors,
    required this.accuracy,
    required this.predictedAt,
  });
}

class PriceFactor {
  final String name;
  final double impact;
  final String description;

  PriceFactor({
    required this.name,
    required this.impact,
    required this.description,
  });
}
