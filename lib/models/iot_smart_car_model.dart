import 'package:flutter/foundation.dart';

/// نموذج السيارة الذكية
class SmartCar {
  final String id;
  final String carId;
  final String vin;
  final SmartCarBrand brand;
  final String model;
  final int year;
  final List<IoTSensor> sensors;
  final ConnectivityStatus connectivity;
  final Map<String, dynamic> currentData;
  final DateTime lastUpdate;
  final List<String> supportedFeatures;
  final SmartCarSettings settings;

  const SmartCar({
    required this.id,
    required this.carId,
    required this.vin,
    required this.brand,
    required this.model,
    required this.year,
    required this.sensors,
    required this.connectivity,
    required this.currentData,
    required this.lastUpdate,
    required this.supportedFeatures,
    required this.settings,
  });

  factory SmartCar.fromJson(Map<String, dynamic> json) {
    return SmartCar(
      id: json['id'],
      carId: json['carId'],
      vin: json['vin'],
      brand: SmartCarBrand.values[json['brand']],
      model: json['model'],
      year: json['year'],
      sensors: (json['sensors'] as List)
          .map((s) => IoTSensor.fromJson(s))
          .toList(),
      connectivity: ConnectivityStatus.values[json['connectivity']],
      currentData: json['currentData'],
      lastUpdate: DateTime.parse(json['lastUpdate']),
      supportedFeatures: List<String>.from(json['supportedFeatures']),
      settings: SmartCarSettings.fromJson(json['settings']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'carId': carId,
      'vin': vin,
      'brand': brand.index,
      'model': model,
      'year': year,
      'sensors': sensors.map((s) => s.toJson()).toList(),
      'connectivity': connectivity.index,
      'currentData': currentData,
      'lastUpdate': lastUpdate.toIso8601String(),
      'supportedFeatures': supportedFeatures,
      'settings': settings.toJson(),
    };
  }
}

/// ماركات السيارات الذكية
enum SmartCarBrand {
  tesla,
  bmw,
  mercedes,
  audi,
  volvo,
  toyota,
  nissan,
  hyundai,
  kia,
  ford,
  chevrolet,
  lucid
}

/// حالة الاتصال
enum ConnectivityStatus {
  connected,
  disconnected,
  connecting,
  error,
  maintenance
}

/// مستشعر إنترنت الأشياء
class IoTSensor {
  final String id;
  final String name;
  final SensorType type;
  final String unit;
  final dynamic currentValue;
  final dynamic minValue;
  final dynamic maxValue;
  final SensorStatus status;
  final DateTime lastReading;
  final List<SensorReading> history;
  final Map<String, dynamic> calibration;

  const IoTSensor({
    required this.id,
    required this.name,
    required this.type,
    required this.unit,
    required this.currentValue,
    required this.minValue,
    required this.maxValue,
    required this.status,
    required this.lastReading,
    required this.history,
    required this.calibration,
  });

  factory IoTSensor.fromJson(Map<String, dynamic> json) {
    return IoTSensor(
      id: json['id'],
      name: json['name'],
      type: SensorType.values[json['type']],
      unit: json['unit'],
      currentValue: json['currentValue'],
      minValue: json['minValue'],
      maxValue: json['maxValue'],
      status: SensorStatus.values[json['status']],
      lastReading: DateTime.parse(json['lastReading']),
      history: (json['history'] as List)
          .map((r) => SensorReading.fromJson(r))
          .toList(),
      calibration: json['calibration'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.index,
      'unit': unit,
      'currentValue': currentValue,
      'minValue': minValue,
      'maxValue': maxValue,
      'status': status.index,
      'lastReading': lastReading.toIso8601String(),
      'history': history.map((r) => r.toJson()).toList(),
      'calibration': calibration,
    };
  }
}

/// أنواع المستشعرات
enum SensorType {
  temperature,
  pressure,
  speed,
  rpm,
  fuel,
  battery,
  oil,
  brake,
  tire,
  engine,
  transmission,
  gps,
  accelerometer,
  gyroscope
}

/// حالة المستشعر
enum SensorStatus {
  active,
  inactive,
  error,
  calibrating,
  maintenance
}

/// قراءة المستشعر
class SensorReading {
  final String id;
  final String sensorId;
  final dynamic value;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;
  final ReadingQuality quality;

  const SensorReading({
    required this.id,
    required this.sensorId,
    required this.value,
    required this.timestamp,
    required this.metadata,
    required this.quality,
  });

  factory SensorReading.fromJson(Map<String, dynamic> json) {
    return SensorReading(
      id: json['id'],
      sensorId: json['sensorId'],
      value: json['value'],
      timestamp: DateTime.parse(json['timestamp']),
      metadata: json['metadata'],
      quality: ReadingQuality.values[json['quality']],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sensorId': sensorId,
      'value': value,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
      'quality': quality.index,
    };
  }
}

/// جودة القراءة
enum ReadingQuality {
  excellent,
  good,
  fair,
  poor,
  invalid
}

/// التشخيص عن بُعد
class RemoteDiagnostics {
  final String id;
  final String smartCarId;
  final DiagnosticType type;
  final Map<String, dynamic> results;
  final List<DiagnosticCode> codes;
  final DiagnosticSeverity severity;
  final DateTime performedAt;
  final String? technician;
  final List<String> recommendations;
  final bool requiresService;

  const RemoteDiagnostics({
    required this.id,
    required this.smartCarId,
    required this.type,
    required this.results,
    required this.codes,
    required this.severity,
    required this.performedAt,
    this.technician,
    required this.recommendations,
    required this.requiresService,
  });

  factory RemoteDiagnostics.fromJson(Map<String, dynamic> json) {
    return RemoteDiagnostics(
      id: json['id'],
      smartCarId: json['smartCarId'],
      type: DiagnosticType.values[json['type']],
      results: json['results'],
      codes: (json['codes'] as List)
          .map((c) => DiagnosticCode.fromJson(c))
          .toList(),
      severity: DiagnosticSeverity.values[json['severity']],
      performedAt: DateTime.parse(json['performedAt']),
      technician: json['technician'],
      recommendations: List<String>.from(json['recommendations']),
      requiresService: json['requiresService'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'smartCarId': smartCarId,
      'type': type.index,
      'results': results,
      'codes': codes.map((c) => c.toJson()).toList(),
      'severity': severity.index,
      'performedAt': performedAt.toIso8601String(),
      'technician': technician,
      'recommendations': recommendations,
      'requiresService': requiresService,
    };
  }
}

/// أنواع التشخيص
enum DiagnosticType {
  engine,
  transmission,
  brakes,
  electrical,
  emissions,
  safety,
  performance,
  full
}

/// شدة التشخيص
enum DiagnosticSeverity {
  info,
  warning,
  error,
  critical,
  emergency
}

/// كود التشخيص
class DiagnosticCode {
  final String code;
  final String description;
  final DiagnosticCategory category;
  final DiagnosticSeverity severity;
  final List<String> possibleCauses;
  final List<String> solutions;
  final bool isActive;

  const DiagnosticCode({
    required this.code,
    required this.description,
    required this.category,
    required this.severity,
    required this.possibleCauses,
    required this.solutions,
    required this.isActive,
  });

  factory DiagnosticCode.fromJson(Map<String, dynamic> json) {
    return DiagnosticCode(
      code: json['code'],
      description: json['description'],
      category: DiagnosticCategory.values[json['category']],
      severity: DiagnosticSeverity.values[json['severity']],
      possibleCauses: List<String>.from(json['possibleCauses']),
      solutions: List<String>.from(json['solutions']),
      isActive: json['isActive'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'description': description,
      'category': category.index,
      'severity': severity.index,
      'possibleCauses': possibleCauses,
      'solutions': solutions,
      'isActive': isActive,
    };
  }
}

/// فئة التشخيص
enum DiagnosticCategory {
  powertrain,
  chassis,
  body,
  network,
  hybrid,
  electric,
  manufacturer,
  generic
}

/// الصيانة التنبؤية
class PredictiveMaintenance {
  final String id;
  final String smartCarId;
  final MaintenanceType type;
  final DateTime predictedDate;
  final double confidence;
  final List<String> indicators;
  final Map<String, dynamic> analysis;
  final MaintenancePriority priority;
  final double estimatedCost;
  final int estimatedDuration;

  const PredictiveMaintenance({
    required this.id,
    required this.smartCarId,
    required this.type,
    required this.predictedDate,
    required this.confidence,
    required this.indicators,
    required this.analysis,
    required this.priority,
    required this.estimatedCost,
    required this.estimatedDuration,
  });

  factory PredictiveMaintenance.fromJson(Map<String, dynamic> json) {
    return PredictiveMaintenance(
      id: json['id'],
      smartCarId: json['smartCarId'],
      type: MaintenanceType.values[json['type']],
      predictedDate: DateTime.parse(json['predictedDate']),
      confidence: json['confidence'],
      indicators: List<String>.from(json['indicators']),
      analysis: json['analysis'],
      priority: MaintenancePriority.values[json['priority']],
      estimatedCost: json['estimatedCost'],
      estimatedDuration: json['estimatedDuration'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'smartCarId': smartCarId,
      'type': type.index,
      'predictedDate': predictedDate.toIso8601String(),
      'confidence': confidence,
      'indicators': indicators,
      'analysis': analysis,
      'priority': priority.index,
      'estimatedCost': estimatedCost,
      'estimatedDuration': estimatedDuration,
    };
  }
}

/// أنواع الصيانة
enum MaintenanceType {
  oilChange,
  brakeService,
  tireRotation,
  batteryCheck,
  engineTune,
  transmission,
  cooling,
  electrical,
  suspension,
  exhaust
}

/// أولوية الصيانة
enum MaintenancePriority {
  low,
  medium,
  high,
  urgent,
  critical
}

/// إعدادات السيارة الذكية
class SmartCarSettings {
  final bool autoUpdates;
  final bool dataSharing;
  final bool remoteDiagnostics;
  final bool predictiveMaintenance;
  final int dataRetentionDays;
  final List<String> allowedUsers;
  final Map<String, bool> notifications;
  final Map<String, dynamic> preferences;

  const SmartCarSettings({
    required this.autoUpdates,
    required this.dataSharing,
    required this.remoteDiagnostics,
    required this.predictiveMaintenance,
    required this.dataRetentionDays,
    required this.allowedUsers,
    required this.notifications,
    required this.preferences,
  });

  factory SmartCarSettings.fromJson(Map<String, dynamic> json) {
    return SmartCarSettings(
      autoUpdates: json['autoUpdates'],
      dataSharing: json['dataSharing'],
      remoteDiagnostics: json['remoteDiagnostics'],
      predictiveMaintenance: json['predictiveMaintenance'],
      dataRetentionDays: json['dataRetentionDays'],
      allowedUsers: List<String>.from(json['allowedUsers']),
      notifications: Map<String, bool>.from(json['notifications']),
      preferences: json['preferences'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'autoUpdates': autoUpdates,
      'dataSharing': dataSharing,
      'remoteDiagnostics': remoteDiagnostics,
      'predictiveMaintenance': predictiveMaintenance,
      'dataRetentionDays': dataRetentionDays,
      'allowedUsers': allowedUsers,
      'notifications': notifications,
      'preferences': preferences,
    };
  }
}
