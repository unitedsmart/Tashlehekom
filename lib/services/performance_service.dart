import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:tashlehekomv2/services/logging_service.dart';

/// خدمة تحسين الأداء
class PerformanceService {
  static final PerformanceService _instance = PerformanceService._internal();
  factory PerformanceService() => _instance;
  PerformanceService._internal();
  
  final Map<String, DateTime> _operationStartTimes = {};
  final Queue<PerformanceMetric> _metrics = Queue();
  static const int _maxMetrics = 100;
  
  /// بدء قياس أداء عملية
  void startOperation(String operationName) {
    _operationStartTimes[operationName] = DateTime.now();
    LoggingService.performance('بدء قياس: $operationName');
  }
  
  /// انتهاء قياس أداء عملية
  void endOperation(String operationName) {
    final startTime = _operationStartTimes[operationName];
    if (startTime == null) {
      LoggingService.warning('لم يتم العثور على بداية العملية: $operationName');
      return;
    }
    
    final endTime = DateTime.now();
    final duration = endTime.difference(startTime);
    
    final metric = PerformanceMetric(
      operationName: operationName,
      duration: duration,
      timestamp: endTime,
    );
    
    _addMetric(metric);
    _operationStartTimes.remove(operationName);
    
    LoggingService.performance(
      'انتهاء قياس: $operationName - المدة: ${duration.inMilliseconds}ms'
    );
  }
  
  /// إضافة مقياس أداء
  void _addMetric(PerformanceMetric metric) {
    _metrics.add(metric);
    
    // الحفاظ على حد أقصى من المقاييس
    while (_metrics.length > _maxMetrics) {
      _metrics.removeFirst();
    }
  }
  
  /// الحصول على متوسط أداء عملية
  Duration? getAveragePerformance(String operationName) {
    final operationMetrics = _metrics
        .where((metric) => metric.operationName == operationName)
        .toList();
    
    if (operationMetrics.isEmpty) return null;
    
    final totalMilliseconds = operationMetrics
        .map((metric) => metric.duration.inMilliseconds)
        .reduce((a, b) => a + b);
    
    final averageMilliseconds = totalMilliseconds / operationMetrics.length;
    return Duration(milliseconds: averageMilliseconds.round());
  }
  
  /// الحصول على أبطأ العمليات
  List<PerformanceMetric> getSlowestOperations({int limit = 10}) {
    final sortedMetrics = _metrics.toList()
      ..sort((a, b) => b.duration.compareTo(a.duration));
    
    return sortedMetrics.take(limit).toList();
  }
  
  /// الحصول على أسرع العمليات
  List<PerformanceMetric> getFastestOperations({int limit = 10}) {
    final sortedMetrics = _metrics.toList()
      ..sort((a, b) => a.duration.compareTo(b.duration));
    
    return sortedMetrics.take(limit).toList();
  }
  
  /// الحصول على إحصائيات الأداء
  PerformanceStats getPerformanceStats() {
    if (_metrics.isEmpty) {
      return PerformanceStats(
        totalOperations: 0,
        averageDuration: Duration.zero,
        minDuration: Duration.zero,
        maxDuration: Duration.zero,
        operationCounts: {},
      );
    }
    
    final durations = _metrics.map((m) => m.duration).toList();
    final totalMilliseconds = durations
        .map((d) => d.inMilliseconds)
        .reduce((a, b) => a + b);
    
    final operationCounts = <String, int>{};
    for (final metric in _metrics) {
      operationCounts[metric.operationName] = 
          (operationCounts[metric.operationName] ?? 0) + 1;
    }
    
    return PerformanceStats(
      totalOperations: _metrics.length,
      averageDuration: Duration(
        milliseconds: (totalMilliseconds / _metrics.length).round()
      ),
      minDuration: durations.reduce((a, b) => a < b ? a : b),
      maxDuration: durations.reduce((a, b) => a > b ? a : b),
      operationCounts: operationCounts,
    );
  }
  
  /// مسح جميع المقاييس
  void clearMetrics() {
    _metrics.clear();
    _operationStartTimes.clear();
    LoggingService.performance('تم مسح جميع مقاييس الأداء');
  }
  
  /// تسجيل تقرير الأداء
  void logPerformanceReport() {
    final stats = getPerformanceStats();
    
    LoggingService.performance('''
تقرير الأداء:
- إجمالي العمليات: ${stats.totalOperations}
- متوسط المدة: ${stats.averageDuration.inMilliseconds}ms
- أقل مدة: ${stats.minDuration.inMilliseconds}ms
- أكبر مدة: ${stats.maxDuration.inMilliseconds}ms
- أكثر العمليات استخداماً: ${stats.operationCounts.entries.map((e) => '${e.key}: ${e.value}').join(', ')}
    ''');
  }
  
  /// تنفيذ عملية مع قياس الأداء
  static Future<T> measureAsync<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    final service = PerformanceService();
    service.startOperation(operationName);
    
    try {
      final result = await operation();
      service.endOperation(operationName);
      return result;
    } catch (e) {
      service.endOperation(operationName);
      rethrow;
    }
  }
  
  /// تنفيذ عملية متزامنة مع قياس الأداء
  static T measureSync<T>(
    String operationName,
    T Function() operation,
  ) {
    final service = PerformanceService();
    service.startOperation(operationName);
    
    try {
      final result = operation();
      service.endOperation(operationName);
      return result;
    } catch (e) {
      service.endOperation(operationName);
      rethrow;
    }
  }
}

/// مقياس أداء واحد
class PerformanceMetric {
  final String operationName;
  final Duration duration;
  final DateTime timestamp;
  
  const PerformanceMetric({
    required this.operationName,
    required this.duration,
    required this.timestamp,
  });
  
  @override
  String toString() {
    return 'PerformanceMetric(operation: $operationName, duration: ${duration.inMilliseconds}ms, time: $timestamp)';
  }
}

/// إحصائيات الأداء
class PerformanceStats {
  final int totalOperations;
  final Duration averageDuration;
  final Duration minDuration;
  final Duration maxDuration;
  final Map<String, int> operationCounts;
  
  const PerformanceStats({
    required this.totalOperations,
    required this.averageDuration,
    required this.minDuration,
    required this.maxDuration,
    required this.operationCounts,
  });
}
