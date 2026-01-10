import 'package:cloud_firestore/cloud_firestore.dart';

/// نماذج إنترنت الأشياء (IoT)

/// جهاز IoT
class IoTDevice {
  final String id;
  final String carId;
  final String deviceType;
  final String deviceModel;
  final String serialNumber;
  final Map<String, dynamic> configuration;
  final IoTDeviceStatus status;
  final DateTime? lastSeen;
  final int batteryLevel;
  final int signalStrength;
  final String firmwareVersion;
  final DateTime registeredAt;
  final DateTime updatedAt;

  const IoTDevice({
    required this.id,
    required this.carId,
    required this.deviceType,
    required this.deviceModel,
    required this.serialNumber,
    required this.configuration,
    required this.status,
    this.lastSeen,
    required this.batteryLevel,
    required this.signalStrength,
    required this.firmwareVersion,
    required this.registeredAt,
    required this.updatedAt,
  });

  factory IoTDevice.fromMap(Map<String, dynamic> map) {
    return IoTDevice(
      id: map['id'],
      carId: map['carId'],
      deviceType: map['deviceType'],
      deviceModel: map['deviceModel'],
      serialNumber: map['serialNumber'],
      configuration: Map<String, dynamic>.from(map['configuration'] ?? {}),
      status: IoTDeviceStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => IoTDeviceStatus.offline,
      ),
      lastSeen: map['lastSeen'] != null ? (map['lastSeen'] as Timestamp).toDate() : null,
      batteryLevel: map['batteryLevel'] ?? 0,
      signalStrength: map['signalStrength'] ?? 0,
      firmwareVersion: map['firmwareVersion'] ?? '1.0.0',
      registeredAt: (map['registeredAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'carId': carId,
      'deviceType': deviceType,
      'deviceModel': deviceModel,
      'serialNumber': serialNumber,
      'configuration': configuration,
      'status': status.name,
      'lastSeen': lastSeen,
      'batteryLevel': batteryLevel,
      'signalStrength': signalStrength,
      'firmwareVersion': firmwareVersion,
      'registeredAt': registeredAt,
      'updatedAt': updatedAt,
    };
  }

  bool get isOnline => status == IoTDeviceStatus.online;
  bool get isLowBattery => batteryLevel < 20;
  bool get isWeakSignal => signalStrength < 30;
}

/// حالة جهاز IoT
enum IoTDeviceStatus {
  online('متصل'),
  offline('غير متصل'),
  maintenance('صيانة'),
  error('خطأ');

  const IoTDeviceStatus(this.displayName);
  final String displayName;
}

/// بيانات جهاز IoT
class IoTDeviceData {
  final String deviceId;
  final DateTime timestamp;
  final Map<String, dynamic> data;
  final IoTDeviceStatus status;
  final int batteryLevel;
  final int signalStrength;

  const IoTDeviceData({
    required this.deviceId,
    required this.timestamp,
    required this.data,
    required this.status,
    required this.batteryLevel,
    required this.signalStrength,
  });

  factory IoTDeviceData.fromMap(Map<String, dynamic> map) {
    return IoTDeviceData(
      deviceId: map['deviceId'],
      timestamp: DateTime.parse(map['timestamp']),
      data: Map<String, dynamic>.from(map['data'] ?? {}),
      status: IoTDeviceStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => IoTDeviceStatus.offline,
      ),
      batteryLevel: map['batteryLevel'] ?? 0,
      signalStrength: map['signalStrength'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'deviceId': deviceId,
      'timestamp': timestamp.toIso8601String(),
      'data': data,
      'status': status.name,
      'batteryLevel': batteryLevel,
      'signalStrength': signalStrength,
    };
  }
}

/// أمر IoT
enum IoTCommand {
  startEngine('تشغيل المحرك'),
  stopEngine('إيقاف المحرك'),
  lockDoors('قفل الأبواب'),
  unlockDoors('فتح الأبواب'),
  turnOnLights('تشغيل الأضواء'),
  turnOffLights('إطفاء الأضواء'),
  startAC('تشغيل التكييف'),
  stopAC('إيقاف التكييف'),
  honkHorn('تشغيل الزمور'),
  locateCar('تحديد موقع السيارة'),
  enableAlarm('تفعيل الإنذار'),
  disableAlarm('إلغاء الإنذار');

  const IoTCommand(this.displayName);
  final String displayName;
}

/// حالة الأمر
enum CommandStatus {
  pending('في الانتظار'),
  executing('قيد التنفيذ'),
  completed('مكتمل'),
  failed('فشل'),
  timeout('انتهت المهلة');

  const CommandStatus(this.displayName);
  final String displayName;
}

/// التشخيص الذكي
class SmartDiagnostics {
  final String carId;
  final int overallHealth;
  final DateTime lastScanDate;
  final List<DiagnosticIssue> issues;
  final List<String> recommendations;
  final DateTime? nextMaintenanceDate;

  const SmartDiagnostics({
    required this.carId,
    required this.overallHealth,
    required this.lastScanDate,
    required this.issues,
    required this.recommendations,
    this.nextMaintenanceDate,
  });

  factory SmartDiagnostics.empty(String carId) {
    return SmartDiagnostics(
      carId: carId,
      overallHealth: 100,
      lastScanDate: DateTime.now(),
      issues: [],
      recommendations: [],
    );
  }

  factory SmartDiagnostics.fromMap(Map<String, dynamic> map) {
    return SmartDiagnostics(
      carId: map['carId'],
      overallHealth: map['overallHealth'] ?? 100,
      lastScanDate: DateTime.parse(map['lastScanDate']),
      issues: (map['issues'] as List<dynamic>?)
          ?.map((item) => DiagnosticIssue.fromMap(item))
          .toList() ?? [],
      recommendations: List<String>.from(map['recommendations'] ?? []),
      nextMaintenanceDate: map['nextMaintenanceDate'] != null
          ? DateTime.parse(map['nextMaintenanceDate'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'carId': carId,
      'overallHealth': overallHealth,
      'lastScanDate': lastScanDate.toIso8601String(),
      'issues': issues.map((issue) => issue.toMap()).toList(),
      'recommendations': recommendations,
      'nextMaintenanceDate': nextMaintenanceDate?.toIso8601String(),
    };
  }

  bool get hasIssues => issues.isNotEmpty;
  bool get hasCriticalIssues => issues.any((issue) => issue.severity == IssueSeverity.high);
  String get healthStatus {
    if (overallHealth >= 90) return 'ممتاز';
    if (overallHealth >= 75) return 'جيد';
    if (overallHealth >= 50) return 'متوسط';
    return 'يحتاج صيانة';
  }
}

/// مشكلة تشخيصية
class DiagnosticIssue {
  final String code;
  final String description;
  final IssueSeverity severity;
  final IssueCategory category;
  final String recommendation;
  final double estimatedCost;

  const DiagnosticIssue({
    required this.code,
    required this.description,
    required this.severity,
    required this.category,
    required this.recommendation,
    required this.estimatedCost,
  });

  factory DiagnosticIssue.fromMap(Map<String, dynamic> map) {
    return DiagnosticIssue(
      code: map['code'],
      description: map['description'],
      severity: IssueSeverity.values.firstWhere(
        (e) => e.name == map['severity'],
        orElse: () => IssueSeverity.low,
      ),
      category: IssueCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => IssueCategory.general,
      ),
      recommendation: map['recommendation'],
      estimatedCost: (map['estimatedCost'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'description': description,
      'severity': severity.name,
      'category': category.name,
      'recommendation': recommendation,
      'estimatedCost': estimatedCost,
    };
  }
}

/// شدة المشكلة
enum IssueSeverity {
  low('منخفضة'),
  medium('متوسطة'),
  high('عالية'),
  critical('حرجة');

  const IssueSeverity(this.displayName);
  final String displayName;
}

/// فئة المشكلة
enum IssueCategory {
  general('عام'),
  engine('المحرك'),
  transmission('ناقل الحركة'),
  brakes('الفرامل'),
  suspension('التعليق'),
  electrical('الكهرباء'),
  cooling('التبريد'),
  fuel('الوقود'),
  exhaust('العادم'),
  tires('الإطارات');

  const IssueCategory(this.displayName);
  final String displayName;
}

/// الصيانة التنبؤية
class PredictiveMaintenance {
  final String carId;
  final List<MaintenancePrediction> predictions;
  final double totalEstimatedCost;
  final DateTime? nextCriticalMaintenance;
  final DateTime lastUpdated;

  const PredictiveMaintenance({
    required this.carId,
    required this.predictions,
    required this.totalEstimatedCost,
    this.nextCriticalMaintenance,
    required this.lastUpdated,
  });

  factory PredictiveMaintenance.empty(String carId) {
    return PredictiveMaintenance(
      carId: carId,
      predictions: [],
      totalEstimatedCost: 0.0,
      lastUpdated: DateTime.now(),
    );
  }

  factory PredictiveMaintenance.fromMap(Map<String, dynamic> map) {
    return PredictiveMaintenance(
      carId: map['carId'],
      predictions: (map['predictions'] as List<dynamic>?)
          ?.map((item) => MaintenancePrediction.fromMap(item))
          .toList() ?? [],
      totalEstimatedCost: (map['totalEstimatedCost'] ?? 0.0).toDouble(),
      nextCriticalMaintenance: map['nextCriticalMaintenance'] != null
          ? DateTime.parse(map['nextCriticalMaintenance'])
          : null,
      lastUpdated: DateTime.parse(map['lastUpdated']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'carId': carId,
      'predictions': predictions.map((p) => p.toMap()).toList(),
      'totalEstimatedCost': totalEstimatedCost,
      'nextCriticalMaintenance': nextCriticalMaintenance?.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  bool get hasCriticalMaintenance => predictions.any((p) => p.priority == MaintenancePriority.high);
  int get daysUntilNextMaintenance {
    if (nextCriticalMaintenance == null) return -1;
    return nextCriticalMaintenance!.difference(DateTime.now()).inDays;
  }
}

/// توقع الصيانة
class MaintenancePrediction {
  final String component;
  final int currentCondition;
  final DateTime predictedFailureDate;
  final int confidence;
  final String recommendedAction;
  final double estimatedCost;
  final MaintenancePriority priority;

  const MaintenancePrediction({
    required this.component,
    required this.currentCondition,
    required this.predictedFailureDate,
    required this.confidence,
    required this.recommendedAction,
    required this.estimatedCost,
    required this.priority,
  });

  factory MaintenancePrediction.fromMap(Map<String, dynamic> map) {
    return MaintenancePrediction(
      component: map['component'],
      currentCondition: map['currentCondition'] ?? 100,
      predictedFailureDate: DateTime.parse(map['predictedFailureDate']),
      confidence: map['confidence'] ?? 0,
      recommendedAction: map['recommendedAction'],
      estimatedCost: (map['estimatedCost'] ?? 0.0).toDouble(),
      priority: MaintenancePriority.values.firstWhere(
        (e) => e.name == map['priority'],
        orElse: () => MaintenancePriority.low,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'component': component,
      'currentCondition': currentCondition,
      'predictedFailureDate': predictedFailureDate.toIso8601String(),
      'confidence': confidence,
      'recommendedAction': recommendedAction,
      'estimatedCost': estimatedCost,
      'priority': priority.name,
    };
  }

  int get daysUntilFailure => predictedFailureDate.difference(DateTime.now()).inDays;
  bool get isUrgent => daysUntilFailure <= 7;
}

/// أولوية الصيانة
enum MaintenancePriority {
  low('منخفضة'),
  medium('متوسطة'),
  high('عالية');

  const MaintenancePriority(this.displayName);
  final String displayName;
}

/// إحصائيات الاستخدام
class UsageStatistics {
  final String carId;
  final DateRange period;
  final double totalDistance;
  final Duration totalDrivingTime;
  final double averageSpeed;
  final double fuelConsumption;
  final double fuelEfficiency;
  final int tripCount;
  final int harshBrakingEvents;
  final int harshAccelerationEvents;
  final int speedingEvents;
  final Duration idleTime;
  final double carbonFootprint;
  final DateTime lastUpdated;

  const UsageStatistics({
    required this.carId,
    required this.period,
    required this.totalDistance,
    required this.totalDrivingTime,
    required this.averageSpeed,
    required this.fuelConsumption,
    required this.fuelEfficiency,
    required this.tripCount,
    required this.harshBrakingEvents,
    required this.harshAccelerationEvents,
    required this.speedingEvents,
    required this.idleTime,
    required this.carbonFootprint,
    required this.lastUpdated,
  });

  factory UsageStatistics.empty(String carId) {
    return UsageStatistics(
      carId: carId,
      period: DateRange(start: DateTime.now(), end: DateTime.now()),
      totalDistance: 0.0,
      totalDrivingTime: Duration.zero,
      averageSpeed: 0.0,
      fuelConsumption: 0.0,
      fuelEfficiency: 0.0,
      tripCount: 0,
      harshBrakingEvents: 0,
      harshAccelerationEvents: 0,
      speedingEvents: 0,
      idleTime: Duration.zero,
      carbonFootprint: 0.0,
      lastUpdated: DateTime.now(),
    );
  }

  factory UsageStatistics.fromMap(Map<String, dynamic> map) {
    return UsageStatistics(
      carId: map['carId'],
      period: DateRange.fromMap(map['period']),
      totalDistance: (map['totalDistance'] ?? 0.0).toDouble(),
      totalDrivingTime: Duration(milliseconds: map['totalDrivingTime'] ?? 0),
      averageSpeed: (map['averageSpeed'] ?? 0.0).toDouble(),
      fuelConsumption: (map['fuelConsumption'] ?? 0.0).toDouble(),
      fuelEfficiency: (map['fuelEfficiency'] ?? 0.0).toDouble(),
      tripCount: map['tripCount'] ?? 0,
      harshBrakingEvents: map['harshBrakingEvents'] ?? 0,
      harshAccelerationEvents: map['harshAccelerationEvents'] ?? 0,
      speedingEvents: map['speedingEvents'] ?? 0,
      idleTime: Duration(milliseconds: map['idleTime'] ?? 0),
      carbonFootprint: (map['carbonFootprint'] ?? 0.0).toDouble(),
      lastUpdated: DateTime.parse(map['lastUpdated']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'carId': carId,
      'period': period.toMap(),
      'totalDistance': totalDistance,
      'totalDrivingTime': totalDrivingTime.inMilliseconds,
      'averageSpeed': averageSpeed,
      'fuelConsumption': fuelConsumption,
      'fuelEfficiency': fuelEfficiency,
      'tripCount': tripCount,
      'harshBrakingEvents': harshBrakingEvents,
      'harshAccelerationEvents': harshAccelerationEvents,
      'speedingEvents': speedingEvents,
      'idleTime': idleTime.inMilliseconds,
      'carbonFootprint': carbonFootprint,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  double get averageTripDistance => tripCount > 0 ? totalDistance / tripCount : 0.0;
  Duration get averageTripDuration => tripCount > 0 
      ? Duration(milliseconds: totalDrivingTime.inMilliseconds ~/ tripCount)
      : Duration.zero;
  double get idleTimePercentage => totalDrivingTime.inMilliseconds > 0
      ? (idleTime.inMilliseconds / totalDrivingTime.inMilliseconds) * 100
      : 0.0;
}

/// نطاق التاريخ
class DateRange {
  final DateTime start;
  final DateTime end;

  const DateRange({
    required this.start,
    required this.end,
  });

  factory DateRange.fromMap(Map<String, dynamic> map) {
    return DateRange(
      start: DateTime.parse(map['start']),
      end: DateTime.parse(map['end']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
    };
  }

  Duration get duration => end.difference(start);
  int get days => duration.inDays;
}

/// تاريخ بيانات IoT
class IoTDataHistory {
  final String deviceId;
  final DateTime timestamp;
  final String dataType;
  final double value;
  final String unit;

  const IoTDataHistory({
    required this.deviceId,
    required this.timestamp,
    required this.dataType,
    required this.value,
    required this.unit,
  });

  factory IoTDataHistory.fromMap(Map<String, dynamic> map) {
    return IoTDataHistory(
      deviceId: map['deviceId'],
      timestamp: DateTime.parse(map['timestamp']),
      dataType: map['dataType'],
      value: (map['value'] ?? 0.0).toDouble(),
      unit: map['unit'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'deviceId': deviceId,
      'timestamp': timestamp.toIso8601String(),
      'dataType': dataType,
      'value': value,
      'unit': unit,
    };
  }
}
