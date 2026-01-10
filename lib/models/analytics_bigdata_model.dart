import 'package:flutter/foundation.dart';

/// نموذج التحليلات المتقدمة
class AdvancedAnalytics {
  final String id;
  final String userId;
  final AnalyticsType type;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final String sessionId;
  final Map<String, dynamic> userContext;
  final List<String> tags;
  final double confidence;
  final AnalyticsStatus status;

  const AdvancedAnalytics({
    required this.id,
    required this.userId,
    required this.type,
    required this.data,
    required this.timestamp,
    required this.sessionId,
    required this.userContext,
    required this.tags,
    required this.confidence,
    required this.status,
  });

  factory AdvancedAnalytics.fromJson(Map<String, dynamic> json) {
    return AdvancedAnalytics(
      id: json['id'],
      userId: json['userId'],
      type: AnalyticsType.values[json['type']],
      data: json['data'],
      timestamp: DateTime.parse(json['timestamp']),
      sessionId: json['sessionId'],
      userContext: json['userContext'],
      tags: List<String>.from(json['tags']),
      confidence: json['confidence'],
      status: AnalyticsStatus.values[json['status']],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.index,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'sessionId': sessionId,
      'userContext': userContext,
      'tags': tags,
      'confidence': confidence,
      'status': status.index,
    };
  }
}

/// أنواع التحليلات
enum AnalyticsType {
  userBehavior,
  marketTrend,
  priceAnalysis,
  searchPattern,
  conversionRate,
  engagement,
  retention,
  churn,
  recommendation,
  fraud
}

/// حالة التحليل
enum AnalyticsStatus {
  processing,
  completed,
  failed,
  pending
}

/// نموذج سلوك المستخدم
class UserBehaviorAnalysis {
  final String id;
  final String userId;
  final List<UserAction> actions;
  final Map<String, int> preferences;
  final List<String> interests;
  final Map<String, double> scores;
  final DateTime analysisDate;
  final BehaviorPattern pattern;
  final List<String> recommendations;
  final double engagementScore;

  const UserBehaviorAnalysis({
    required this.id,
    required this.userId,
    required this.actions,
    required this.preferences,
    required this.interests,
    required this.scores,
    required this.analysisDate,
    required this.pattern,
    required this.recommendations,
    required this.engagementScore,
  });

  factory UserBehaviorAnalysis.fromJson(Map<String, dynamic> json) {
    return UserBehaviorAnalysis(
      id: json['id'],
      userId: json['userId'],
      actions: (json['actions'] as List)
          .map((action) => UserAction.fromJson(action))
          .toList(),
      preferences: Map<String, int>.from(json['preferences']),
      interests: List<String>.from(json['interests']),
      scores: Map<String, double>.from(json['scores']),
      analysisDate: DateTime.parse(json['analysisDate']),
      pattern: BehaviorPattern.values[json['pattern']],
      recommendations: List<String>.from(json['recommendations']),
      engagementScore: json['engagementScore'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'actions': actions.map((action) => action.toJson()).toList(),
      'preferences': preferences,
      'interests': interests,
      'scores': scores,
      'analysisDate': analysisDate.toIso8601String(),
      'pattern': pattern.index,
      'recommendations': recommendations,
      'engagementScore': engagementScore,
    };
  }
}

/// نموذج إجراء المستخدم
class UserAction {
  final String id;
  final ActionType type;
  final String target;
  final Map<String, dynamic> parameters;
  final DateTime timestamp;
  final int duration;
  final String source;

  const UserAction({
    required this.id,
    required this.type,
    required this.target,
    required this.parameters,
    required this.timestamp,
    required this.duration,
    required this.source,
  });

  factory UserAction.fromJson(Map<String, dynamic> json) {
    return UserAction(
      id: json['id'],
      type: ActionType.values[json['type']],
      target: json['target'],
      parameters: json['parameters'],
      timestamp: DateTime.parse(json['timestamp']),
      duration: json['duration'],
      source: json['source'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.index,
      'target': target,
      'parameters': parameters,
      'timestamp': timestamp.toIso8601String(),
      'duration': duration,
      'source': source,
    };
  }
}

/// أنواع الإجراءات
enum ActionType {
  view,
  click,
  search,
  filter,
  bookmark,
  share,
  contact,
  purchase,
  compare,
  rate
}

/// أنماط السلوك
enum BehaviorPattern {
  browser,
  researcher,
  buyer,
  seller,
  casual,
  professional,
  frequent,
  occasional
}

/// نموذج توقعات السوق
class MarketPrediction {
  final String id;
  final String market;
  final PredictionType type;
  final Map<String, double> predictions;
  final double confidence;
  final DateTime predictionDate;
  final DateTime validUntil;
  final List<String> factors;
  final Map<String, dynamic> historicalData;
  final PredictionAccuracy accuracy;

  const MarketPrediction({
    required this.id,
    required this.market,
    required this.type,
    required this.predictions,
    required this.confidence,
    required this.predictionDate,
    required this.validUntil,
    required this.factors,
    required this.historicalData,
    required this.accuracy,
  });

  factory MarketPrediction.fromJson(Map<String, dynamic> json) {
    return MarketPrediction(
      id: json['id'],
      market: json['market'],
      type: PredictionType.values[json['type']],
      predictions: Map<String, double>.from(json['predictions']),
      confidence: json['confidence'],
      predictionDate: DateTime.parse(json['predictionDate']),
      validUntil: DateTime.parse(json['validUntil']),
      factors: List<String>.from(json['factors']),
      historicalData: json['historicalData'],
      accuracy: PredictionAccuracy.values[json['accuracy']],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'market': market,
      'type': type.index,
      'predictions': predictions,
      'confidence': confidence,
      'predictionDate': predictionDate.toIso8601String(),
      'validUntil': validUntil.toIso8601String(),
      'factors': factors,
      'historicalData': historicalData,
      'accuracy': accuracy.index,
    };
  }
}

/// أنواع التنبؤات
enum PredictionType {
  price,
  demand,
  supply,
  trend,
  seasonal,
  economic,
  regional,
  brand
}

/// دقة التنبؤ
enum PredictionAccuracy {
  low,
  medium,
  high,
  veryHigh,
  excellent
}

/// نموذج ذكاء الأعمال
class BusinessIntelligence {
  final String id;
  final String reportName;
  final BIType type;
  final Map<String, dynamic> metrics;
  final List<String> insights;
  final List<String> recommendations;
  final DateTime generatedAt;
  final String period;
  final Map<String, dynamic> comparisons;
  final double score;

  const BusinessIntelligence({
    required this.id,
    required this.reportName,
    required this.type,
    required this.metrics,
    required this.insights,
    required this.recommendations,
    required this.generatedAt,
    required this.period,
    required this.comparisons,
    required this.score,
  });

  factory BusinessIntelligence.fromJson(Map<String, dynamic> json) {
    return BusinessIntelligence(
      id: json['id'],
      reportName: json['reportName'],
      type: BIType.values[json['type']],
      metrics: json['metrics'],
      insights: List<String>.from(json['insights']),
      recommendations: List<String>.from(json['recommendations']),
      generatedAt: DateTime.parse(json['generatedAt']),
      period: json['period'],
      comparisons: json['comparisons'],
      score: json['score'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reportName': reportName,
      'type': type.index,
      'metrics': metrics,
      'insights': insights,
      'recommendations': recommendations,
      'generatedAt': generatedAt.toIso8601String(),
      'period': period,
      'comparisons': comparisons,
      'score': score,
    };
  }
}

/// أنواع ذكاء الأعمال
enum BIType {
  sales,
  marketing,
  operations,
  finance,
  customer,
  inventory,
  performance,
  competitive
}

/// نموذج البيانات الضخمة
class BigDataProcessor {
  final String id;
  final String datasetName;
  final DataType dataType;
  final int recordCount;
  final Map<String, dynamic> schema;
  final ProcessingStatus status;
  final DateTime startTime;
  final DateTime? endTime;
  final Map<String, dynamic> results;
  final List<String> errors;

  const BigDataProcessor({
    required this.id,
    required this.datasetName,
    required this.dataType,
    required this.recordCount,
    required this.schema,
    required this.status,
    required this.startTime,
    this.endTime,
    required this.results,
    required this.errors,
  });

  factory BigDataProcessor.fromJson(Map<String, dynamic> json) {
    return BigDataProcessor(
      id: json['id'],
      datasetName: json['datasetName'],
      dataType: DataType.values[json['dataType']],
      recordCount: json['recordCount'],
      schema: json['schema'],
      status: ProcessingStatus.values[json['status']],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      results: json['results'],
      errors: List<String>.from(json['errors']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'datasetName': datasetName,
      'dataType': dataType.index,
      'recordCount': recordCount,
      'schema': schema,
      'status': status.index,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'results': results,
      'errors': errors,
    };
  }
}

/// أنواع البيانات
enum DataType {
  userActivity,
  transactions,
  inventory,
  market,
  social,
  sensor,
  logs,
  images
}

/// حالة المعالجة
enum ProcessingStatus {
  queued,
  processing,
  completed,
  failed,
  cancelled
}
