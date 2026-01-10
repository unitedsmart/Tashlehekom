/// نماذج تقنيات الفضاء

/// بيانات القمر الصناعي
class SatelliteData {
  final String id;
  final String name;
  final SatelliteType type;
  final SatelliteStatus status;
  final double altitude; // km
  final double speed; // km/h
  final double latitude;
  final double longitude;
  final double signalStrength; // 0.0 to 1.0
  final double batteryLevel; // 0.0 to 1.0
  final DateTime lastUpdate;
  final CoverageArea coverage;

  const SatelliteData({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.altitude,
    required this.speed,
    required this.latitude,
    required this.longitude,
    required this.signalStrength,
    required this.batteryLevel,
    required this.lastUpdate,
    required this.coverage,
  });

  factory SatelliteData.fromMap(Map<String, dynamic> map) {
    return SatelliteData(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      type: SatelliteType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => SatelliteType.navigation,
      ),
      status: SatelliteStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => SatelliteStatus.offline,
      ),
      altitude: (map['altitude'] ?? 0.0).toDouble(),
      speed: (map['speed'] ?? 0.0).toDouble(),
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      signalStrength: (map['signalStrength'] ?? 0.0).toDouble(),
      batteryLevel: (map['batteryLevel'] ?? 0.0).toDouble(),
      lastUpdate: DateTime.parse(map['lastUpdate']),
      coverage: CoverageArea.fromMap(map['coverage'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'status': status.name,
      'altitude': altitude,
      'speed': speed,
      'latitude': latitude,
      'longitude': longitude,
      'signalStrength': signalStrength,
      'batteryLevel': batteryLevel,
      'lastUpdate': lastUpdate.toIso8601String(),
      'coverage': coverage.toMap(),
    };
  }

  bool get isOperational => status == SatelliteStatus.operational;
  String get statusText => status.displayName;
  String get typeText => type.displayName;
}

/// نوع القمر الصناعي
enum SatelliteType {
  navigation('ملاحة'),
  communication('اتصالات'),
  observation('مراقبة'),
  weather('طقس'),
  military('عسكري');

  const SatelliteType(this.displayName);
  final String displayName;
}

/// حالة القمر الصناعي
enum SatelliteStatus {
  operational('تشغيلي'),
  maintenance('صيانة'),
  offline('غير متصل'),
  error('خطأ');

  const SatelliteStatus(this.displayName);
  final String displayName;
}

/// منطقة التغطية
class CoverageArea {
  final double centerLat;
  final double centerLng;
  final double radius; // km

  const CoverageArea({
    required this.centerLat,
    required this.centerLng,
    required this.radius,
  });

  factory CoverageArea.fromMap(Map<String, dynamic> map) {
    return CoverageArea(
      centerLat: (map['centerLat'] ?? 0.0).toDouble(),
      centerLng: (map['centerLng'] ?? 0.0).toDouble(),
      radius: (map['radius'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'centerLat': centerLat,
      'centerLng': centerLng,
      'radius': radius,
    };
  }
}

/// تتبع الأقمار الصناعية
class SatelliteTracking {
  final String vehicleId;
  final GeoPosition currentPosition;
  final List<TrackingPoint> trackingHistory;
  final List<String> activeSatellites;
  final double signalQuality; // 0.0 to 1.0
  final double trackingAccuracy; // 0.0 to 1.0
  final DateTime lastUpdate;
  final double estimatedSpeed; // km/h
  final double heading; // degrees
  final bool isMoving;

  const SatelliteTracking({
    required this.vehicleId,
    required this.currentPosition,
    required this.trackingHistory,
    required this.activeSatellites,
    required this.signalQuality,
    required this.trackingAccuracy,
    required this.lastUpdate,
    required this.estimatedSpeed,
    required this.heading,
    required this.isMoving,
  });

  factory SatelliteTracking.empty() {
    return SatelliteTracking(
      vehicleId: '',
      currentPosition: GeoPosition.empty(),
      trackingHistory: [],
      activeSatellites: [],
      signalQuality: 0.0,
      trackingAccuracy: 0.0,
      lastUpdate: DateTime.now(),
      estimatedSpeed: 0.0,
      heading: 0.0,
      isMoving: false,
    );
  }

  factory SatelliteTracking.fromMap(Map<String, dynamic> map) {
    return SatelliteTracking(
      vehicleId: map['vehicleId'] ?? '',
      currentPosition: GeoPosition.fromMap(map['currentPosition'] ?? {}),
      trackingHistory: (map['trackingHistory'] as List<dynamic>?)
              ?.map((item) => TrackingPoint.fromMap(item))
              .toList() ??
          [],
      activeSatellites: List<String>.from(map['activeSatellites'] ?? []),
      signalQuality: (map['signalQuality'] ?? 0.0).toDouble(),
      trackingAccuracy: (map['trackingAccuracy'] ?? 0.0).toDouble(),
      lastUpdate: DateTime.parse(map['lastUpdate']),
      estimatedSpeed: (map['estimatedSpeed'] ?? 0.0).toDouble(),
      heading: (map['heading'] ?? 0.0).toDouble(),
      isMoving: map['isMoving'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vehicleId': vehicleId,
      'currentPosition': currentPosition.toMap(),
      'trackingHistory': trackingHistory.map((point) => point.toMap()).toList(),
      'activeSatellites': activeSatellites,
      'signalQuality': signalQuality,
      'trackingAccuracy': trackingAccuracy,
      'lastUpdate': lastUpdate.toIso8601String(),
      'estimatedSpeed': estimatedSpeed,
      'heading': heading,
      'isMoving': isMoving,
    };
  }

  String get signalQualityText {
    if (signalQuality > 0.8) return 'ممتاز';
    if (signalQuality > 0.6) return 'جيد';
    if (signalQuality > 0.4) return 'متوسط';
    return 'ضعيف';
  }

  String get trackingAccuracyText {
    if (trackingAccuracy > 0.9) return 'دقة عالية';
    if (trackingAccuracy > 0.7) return 'دقة جيدة';
    if (trackingAccuracy > 0.5) return 'دقة متوسطة';
    return 'دقة منخفضة';
  }
}

/// الموقع الجغرافي
class GeoPosition {
  final double latitude;
  final double longitude;
  final double altitude; // meters
  final double accuracy; // meters

  const GeoPosition({
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.accuracy,
  });

  factory GeoPosition.empty() {
    return const GeoPosition(
      latitude: 0.0,
      longitude: 0.0,
      altitude: 0.0,
      accuracy: 0.0,
    );
  }

  factory GeoPosition.fromMap(Map<String, dynamic> map) {
    return GeoPosition(
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      altitude: (map['altitude'] ?? 0.0).toDouble(),
      accuracy: (map['accuracy'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'accuracy': accuracy,
    };
  }

  String get coordinatesText =>
      '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
  String get altitudeText => '${altitude.toStringAsFixed(1)} م';
  String get accuracyText => '±${accuracy.toStringAsFixed(1)} م';
}

/// نقطة التتبع
class TrackingPoint {
  final GeoPosition position;
  final DateTime timestamp;
  final double speed; // km/h
  final double heading; // degrees

  const TrackingPoint({
    required this.position,
    required this.timestamp,
    required this.speed,
    required this.heading,
  });

  factory TrackingPoint.fromMap(Map<String, dynamic> map) {
    return TrackingPoint(
      position: GeoPosition.fromMap(map['position'] ?? {}),
      timestamp: DateTime.parse(map['timestamp']),
      speed: (map['speed'] ?? 0.0).toDouble(),
      heading: (map['heading'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'position': position.toMap(),
      'timestamp': timestamp.toIso8601String(),
      'speed': speed,
      'heading': heading,
    };
  }
}

/// بيانات الطقس الفضائي
class SpaceWeatherData {
  final SolarActivityLevel solarActivity;
  final bool geomagneticStorm;
  final RadiationLevel radiationLevel;
  final double solarWindSpeed; // km/s
  final double kpIndex; // 0-9
  final int sunspotNumber;
  final List<SpaceWeatherForecast> forecast;
  final String impactOnSatellites;
  final DateTime lastUpdate;

  const SpaceWeatherData({
    required this.solarActivity,
    required this.geomagneticStorm,
    required this.radiationLevel,
    required this.solarWindSpeed,
    required this.kpIndex,
    required this.sunspotNumber,
    required this.forecast,
    required this.impactOnSatellites,
    required this.lastUpdate,
  });

  factory SpaceWeatherData.empty() {
    return SpaceWeatherData(
      solarActivity: SolarActivityLevel.low,
      geomagneticStorm: false,
      radiationLevel: RadiationLevel.low,
      solarWindSpeed: 0.0,
      kpIndex: 0.0,
      sunspotNumber: 0,
      forecast: [],
      impactOnSatellites: '',
      lastUpdate: DateTime.now(),
    );
  }

  factory SpaceWeatherData.fromMap(Map<String, dynamic> map) {
    return SpaceWeatherData(
      solarActivity: SolarActivityLevel.values.firstWhere(
        (e) => e.name == map['solarActivity'],
        orElse: () => SolarActivityLevel.low,
      ),
      geomagneticStorm: map['geomagneticStorm'] ?? false,
      radiationLevel: RadiationLevel.values.firstWhere(
        (e) => e.name == map['radiationLevel'],
        orElse: () => RadiationLevel.low,
      ),
      solarWindSpeed: (map['solarWindSpeed'] ?? 0.0).toDouble(),
      kpIndex: (map['kpIndex'] ?? 0.0).toDouble(),
      sunspotNumber: map['sunspotNumber'] ?? 0,
      forecast: (map['forecast'] as List<dynamic>?)
              ?.map((item) => SpaceWeatherForecast.fromMap(item))
              .toList() ??
          [],
      impactOnSatellites: map['impactOnSatellites'] ?? '',
      lastUpdate: DateTime.parse(map['lastUpdate']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'solarActivity': solarActivity.name,
      'geomagneticStorm': geomagneticStorm,
      'radiationLevel': radiationLevel.name,
      'solarWindSpeed': solarWindSpeed,
      'kpIndex': kpIndex,
      'sunspotNumber': sunspotNumber,
      'forecast': forecast.map((f) => f.toMap()).toList(),
      'impactOnSatellites': impactOnSatellites,
      'lastUpdate': lastUpdate.toIso8601String(),
    };
  }

  String get overallCondition {
    if (geomagneticStorm || solarActivity == SolarActivityLevel.extreme)
      return 'خطير';
    if (solarActivity == SolarActivityLevel.high || kpIndex > 6) return 'نشط';
    if (solarActivity == SolarActivityLevel.moderate || kpIndex > 3)
      return 'متوسط';
    return 'هادئ';
  }

  String get riskLevel {
    if (geomagneticStorm && radiationLevel == RadiationLevel.high)
      return 'عالي';
    if (solarActivity == SolarActivityLevel.high) return 'متوسط';
    return 'منخفض';
  }
}

/// مستوى النشاط الشمسي
enum SolarActivityLevel {
  low('منخفض'),
  moderate('متوسط'),
  high('عالي'),
  extreme('شديد');

  const SolarActivityLevel(this.displayName);
  final String displayName;
}

/// مستوى الإشعاع
enum RadiationLevel {
  low('منخفض'),
  moderate('متوسط'),
  high('عالي');

  const RadiationLevel(this.displayName);
  final String displayName;
}

/// توقعات الطقس الفضائي
class SpaceWeatherForecast {
  final DateTime date;
  final SolarActivityLevel activity;
  final double confidence; // 0.0 to 1.0
  final String description;

  const SpaceWeatherForecast({
    required this.date,
    required this.activity,
    required this.confidence,
    required this.description,
  });

  factory SpaceWeatherForecast.fromMap(Map<String, dynamic> map) {
    return SpaceWeatherForecast(
      date: DateTime.parse(map['date']),
      activity: SolarActivityLevel.values.firstWhere(
        (e) => e.name == map['activity'],
        orElse: () => SolarActivityLevel.low,
      ),
      confidence: (map['confidence'] ?? 0.0).toDouble(),
      description: map['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'activity': activity.name,
      'confidence': confidence,
      'description': description,
    };
  }
}

/// مسار الملاحة الفضائية
class SpaceNavigationRoute {
  final GeoPosition startPosition;
  final GeoPosition endPosition;
  final List<GeoPosition> waypoints;
  final double totalDistance; // km
  final Duration estimatedTime;
  final RouteOptimization optimization;
  final double satelliteCoverage; // 0.0 to 1.0
  final RouteQuality routeQuality;
  final List<AlternativeRoute> alternativeRoutes;
  final Map<String, TrafficLevel> trafficConditions;
  final DateTime lastCalculated;

  const SpaceNavigationRoute({
    required this.startPosition,
    required this.endPosition,
    required this.waypoints,
    required this.totalDistance,
    required this.estimatedTime,
    required this.optimization,
    required this.satelliteCoverage,
    required this.routeQuality,
    required this.alternativeRoutes,
    required this.trafficConditions,
    required this.lastCalculated,
  });

  factory SpaceNavigationRoute.empty() {
    return SpaceNavigationRoute(
      startPosition: GeoPosition.empty(),
      endPosition: GeoPosition.empty(),
      waypoints: [],
      totalDistance: 0.0,
      estimatedTime: Duration.zero,
      optimization: RouteOptimization.fastest,
      satelliteCoverage: 0.0,
      routeQuality: RouteQuality.poor,
      alternativeRoutes: [],
      trafficConditions: {},
      lastCalculated: DateTime.now(),
    );
  }

  factory SpaceNavigationRoute.fromMap(Map<String, dynamic> map) {
    return SpaceNavigationRoute(
      startPosition: GeoPosition.fromMap(map['startPosition'] ?? {}),
      endPosition: GeoPosition.fromMap(map['endPosition'] ?? {}),
      waypoints: (map['waypoints'] as List<dynamic>?)
              ?.map((item) => GeoPosition.fromMap(item))
              .toList() ??
          [],
      totalDistance: (map['totalDistance'] ?? 0.0).toDouble(),
      estimatedTime: Duration(minutes: map['estimatedTime'] ?? 0),
      optimization: RouteOptimization.values.firstWhere(
        (e) => e.name == map['optimization'],
        orElse: () => RouteOptimization.fastest,
      ),
      satelliteCoverage: (map['satelliteCoverage'] ?? 0.0).toDouble(),
      routeQuality: RouteQuality.values.firstWhere(
        (e) => e.name == map['routeQuality'],
        orElse: () => RouteQuality.poor,
      ),
      alternativeRoutes: (map['alternativeRoutes'] as List<dynamic>?)
              ?.map((item) => AlternativeRoute.fromMap(item))
              .toList() ??
          [],
      trafficConditions: Map<String, TrafficLevel>.from(
        (map['trafficConditions'] as Map<String, dynamic>?)?.map(
              (key, value) => MapEntry(
                  key,
                  TrafficLevel.values.firstWhere(
                    (e) => e.name == value,
                    orElse: () => TrafficLevel.light,
                  )),
            ) ??
            {},
      ),
      lastCalculated: DateTime.parse(map['lastCalculated']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'startPosition': startPosition.toMap(),
      'endPosition': endPosition.toMap(),
      'waypoints': waypoints.map((wp) => wp.toMap()).toList(),
      'totalDistance': totalDistance,
      'estimatedTime': estimatedTime.inMinutes,
      'optimization': optimization.name,
      'satelliteCoverage': satelliteCoverage,
      'routeQuality': routeQuality.name,
      'alternativeRoutes':
          alternativeRoutes.map((route) => route.toMap()).toList(),
      'trafficConditions':
          trafficConditions.map((key, value) => MapEntry(key, value.name)),
      'lastCalculated': lastCalculated.toIso8601String(),
    };
  }

  String get distanceText => '${totalDistance.toStringAsFixed(1)} كم';
  String get timeText =>
      '${estimatedTime.inHours}س ${estimatedTime.inMinutes % 60}د';
  String get coverageText => '${(satelliteCoverage * 100).toInt()}%';
  String get qualityText => routeQuality.displayName;
}

/// تحسين المسار
enum RouteOptimization {
  fastest('الأسرع'),
  shortest('الأقصر'),
  economical('الاقتصادي'),
  scenic('المناظر الطبيعية');

  const RouteOptimization(this.displayName);
  final String displayName;
}

/// جودة المسار
enum RouteQuality {
  excellent('ممتاز'),
  good('جيد'),
  fair('مقبول'),
  poor('ضعيف');

  const RouteQuality(this.displayName);
  final String displayName;
}

/// مسار بديل
class AlternativeRoute {
  final String name;
  final double distance; // km
  final Duration estimatedTime;
  final TrafficLevel trafficLevel;
  final String advantages;

  const AlternativeRoute({
    required this.name,
    required this.distance,
    required this.estimatedTime,
    required this.trafficLevel,
    required this.advantages,
  });

  factory AlternativeRoute.fromMap(Map<String, dynamic> map) {
    return AlternativeRoute(
      name: map['name'] ?? '',
      distance: (map['distance'] ?? 0.0).toDouble(),
      estimatedTime: Duration(minutes: map['estimatedTime'] ?? 0),
      trafficLevel: TrafficLevel.values.firstWhere(
        (e) => e.name == map['trafficLevel'],
        orElse: () => TrafficLevel.light,
      ),
      advantages: map['advantages'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'distance': distance,
      'estimatedTime': estimatedTime.inMinutes,
      'trafficLevel': trafficLevel.name,
      'advantages': advantages,
    };
  }
}

/// مستوى الازدحام
enum TrafficLevel {
  light('خفيف'),
  moderate('متوسط'),
  heavy('كثيف'),
  severe('شديد');

  const TrafficLevel(this.displayName);
  final String displayName;
}

/// مراقبة الأسطول
class FleetMonitoring {
  final String region;
  final int totalVehicles;
  final int activeVehicles;
  final List<VehicleStatus> vehicles;
  final CoverageArea coverageArea;
  final double monitoringQuality; // 0.0 to 1.0
  final List<FleetAlert> alerts;
  final DateTime lastUpdate;

  const FleetMonitoring({
    required this.region,
    required this.totalVehicles,
    required this.activeVehicles,
    required this.vehicles,
    required this.coverageArea,
    required this.monitoringQuality,
    required this.alerts,
    required this.lastUpdate,
  });

  factory FleetMonitoring.empty() {
    return FleetMonitoring(
      region: '',
      totalVehicles: 0,
      activeVehicles: 0,
      vehicles: [],
      coverageArea: const CoverageArea(centerLat: 0, centerLng: 0, radius: 0),
      monitoringQuality: 0.0,
      alerts: [],
      lastUpdate: DateTime.now(),
    );
  }

  factory FleetMonitoring.fromMap(Map<String, dynamic> map) {
    return FleetMonitoring(
      region: map['region'] ?? '',
      totalVehicles: map['totalVehicles'] ?? 0,
      activeVehicles: map['activeVehicles'] ?? 0,
      vehicles: (map['vehicles'] as List<dynamic>?)
              ?.map((item) => VehicleStatus.fromMap(item))
              .toList() ??
          [],
      coverageArea: CoverageArea.fromMap(map['coverageArea'] ?? {}),
      monitoringQuality: (map['monitoringQuality'] ?? 0.0).toDouble(),
      alerts: (map['alerts'] as List<dynamic>?)
              ?.map((item) => FleetAlert.fromMap(item))
              .toList() ??
          [],
      lastUpdate: DateTime.parse(map['lastUpdate']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'region': region,
      'totalVehicles': totalVehicles,
      'activeVehicles': activeVehicles,
      'vehicles': vehicles.map((v) => v.toMap()).toList(),
      'coverageArea': coverageArea.toMap(),
      'monitoringQuality': monitoringQuality,
      'alerts': alerts.map((a) => a.toMap()).toList(),
      'lastUpdate': lastUpdate.toIso8601String(),
    };
  }

  int get inactiveVehicles => totalVehicles - activeVehicles;
  double get activePercentage =>
      totalVehicles > 0 ? (activeVehicles / totalVehicles) * 100 : 0.0;
  int get criticalAlerts =>
      alerts.where((a) => a.severity == AlertSeverity.critical).length;
  String get monitoringQualityText {
    if (monitoringQuality > 0.9) return 'ممتاز';
    if (monitoringQuality > 0.7) return 'جيد';
    if (monitoringQuality > 0.5) return 'متوسط';
    return 'ضعيف';
  }
}

/// حالة المركبة
class VehicleStatus {
  final String vehicleId;
  final GeoPosition position;
  final VehicleOperationalStatus status;
  final double speed; // km/h
  final double heading; // degrees
  final double fuel; // 0.0 to 1.0
  final DateTime lastUpdate;

  const VehicleStatus({
    required this.vehicleId,
    required this.position,
    required this.status,
    required this.speed,
    required this.heading,
    required this.fuel,
    required this.lastUpdate,
  });

  factory VehicleStatus.fromMap(Map<String, dynamic> map) {
    return VehicleStatus(
      vehicleId: map['vehicleId'] ?? '',
      position: GeoPosition.fromMap(map['position'] ?? {}),
      status: VehicleOperationalStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => VehicleOperationalStatus.inactive,
      ),
      speed: (map['speed'] ?? 0.0).toDouble(),
      heading: (map['heading'] ?? 0.0).toDouble(),
      fuel: (map['fuel'] ?? 0.0).toDouble(),
      lastUpdate: DateTime.parse(map['lastUpdate']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vehicleId': vehicleId,
      'position': position.toMap(),
      'status': status.name,
      'speed': speed,
      'heading': heading,
      'fuel': fuel,
      'lastUpdate': lastUpdate.toIso8601String(),
    };
  }

  String get statusText => status.displayName;
  String get speedText => '${speed.toStringAsFixed(1)} كم/س';
  String get fuelText => '${(fuel * 100).toInt()}%';
  bool get isActive => status == VehicleOperationalStatus.active;
  bool get needsAttention =>
      fuel < 0.2 || status == VehicleOperationalStatus.maintenance;
}

/// حالة تشغيل المركبة
enum VehicleOperationalStatus {
  active('نشط'),
  inactive('غير نشط'),
  maintenance('صيانة'),
  emergency('طوارئ');

  const VehicleOperationalStatus(this.displayName);
  final String displayName;
}

/// تنبيه الأسطول
class FleetAlert {
  final String id;
  final FleetAlertType type;
  final String vehicleId;
  final String message;
  final AlertSeverity severity;
  final DateTime timestamp;

  const FleetAlert({
    required this.id,
    required this.type,
    required this.vehicleId,
    required this.message,
    required this.severity,
    required this.timestamp,
  });

  factory FleetAlert.fromMap(Map<String, dynamic> map) {
    return FleetAlert(
      id: map['id'] ?? '',
      type: FleetAlertType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => FleetAlertType.general,
      ),
      vehicleId: map['vehicleId'] ?? '',
      message: map['message'] ?? '',
      severity: AlertSeverity.values.firstWhere(
        (e) => e.name == map['severity'],
        orElse: () => AlertSeverity.low,
      ),
      timestamp: DateTime.parse(map['timestamp']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'vehicleId': vehicleId,
      'message': message,
      'severity': severity.name,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  String get typeText => type.displayName;
  String get severityText => severity.displayName;
  bool get isCritical => severity == AlertSeverity.critical;
}

/// نوع تنبيه الأسطول
enum FleetAlertType {
  general('عام'),
  fuel('وقود'),
  maintenance('صيانة'),
  security('أمان'),
  location('موقع');

  const FleetAlertType(this.displayName);
  final String displayName;
}

/// شدة التنبيه
enum AlertSeverity {
  low('منخفض'),
  medium('متوسط'),
  high('عالي'),
  critical('حرج');

  const AlertSeverity(this.displayName);
  final String displayName;
}

/// تحليل التضاريس
class TerrainAnalysis {
  final GeoPosition centerPosition;
  final double analysisRadius; // km
  final TerrainType terrainType;
  final ElevationData elevation;
  final SlopeData slope;
  final VegetationData vegetation;
  final AccessibilityData accessibility;
  final WeatherImpact weatherImpact;
  final DateTime analysisDate;
  final String imageResolution;
  final String dataSource;

  const TerrainAnalysis({
    required this.centerPosition,
    required this.analysisRadius,
    required this.terrainType,
    required this.elevation,
    required this.slope,
    required this.vegetation,
    required this.accessibility,
    required this.weatherImpact,
    required this.analysisDate,
    required this.imageResolution,
    required this.dataSource,
  });

  factory TerrainAnalysis.empty() {
    return TerrainAnalysis(
      centerPosition: GeoPosition.empty(),
      analysisRadius: 0.0,
      terrainType: TerrainType.flat,
      elevation:
          const ElevationData(minimum: 0, maximum: 0, average: 0, variance: 0),
      slope:
          const SlopeData(averageSlope: 0, maximumSlope: 0, slopeVariation: 0),
      vegetation: const VegetationData(
          coverage: 0,
          type: VegetationType.none,
          density: VegetationDensity.none),
      accessibility: const AccessibilityData(
          roadAccess: false,
          difficulty: AccessibilityLevel.impossible,
          recommendedVehicleType: RecommendedVehicleType.none),
      weatherImpact: const WeatherImpact(
          rainEffect: ImpactLevel.none,
          windEffect: ImpactLevel.none,
          temperatureEffect: ImpactLevel.none),
      analysisDate: DateTime.now(),
      imageResolution: '',
      dataSource: '',
    );
  }

  factory TerrainAnalysis.fromMap(Map<String, dynamic> map) {
    return TerrainAnalysis(
      centerPosition: GeoPosition.fromMap(map['centerPosition'] ?? {}),
      analysisRadius: (map['analysisRadius'] ?? 0.0).toDouble(),
      terrainType: TerrainType.values.firstWhere(
        (e) => e.name == map['terrainType'],
        orElse: () => TerrainType.flat,
      ),
      elevation: ElevationData.fromMap(map['elevation'] ?? {}),
      slope: SlopeData.fromMap(map['slope'] ?? {}),
      vegetation: VegetationData.fromMap(map['vegetation'] ?? {}),
      accessibility: AccessibilityData.fromMap(map['accessibility'] ?? {}),
      weatherImpact: WeatherImpact.fromMap(map['weatherImpact'] ?? {}),
      analysisDate: DateTime.parse(map['analysisDate']),
      imageResolution: map['imageResolution'] ?? '',
      dataSource: map['dataSource'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'centerPosition': centerPosition.toMap(),
      'analysisRadius': analysisRadius,
      'terrainType': terrainType.name,
      'elevation': elevation.toMap(),
      'slope': slope.toMap(),
      'vegetation': vegetation.toMap(),
      'accessibility': accessibility.toMap(),
      'weatherImpact': weatherImpact.toMap(),
      'analysisDate': analysisDate.toIso8601String(),
      'imageResolution': imageResolution,
      'dataSource': dataSource,
    };
  }

  String get terrainTypeText => terrainType.displayName;
  String get accessibilityText => accessibility.difficulty.displayName;
  String get vegetationText => vegetation.type.displayName;
  bool get isAccessible => accessibility.roadAccess;
  String get recommendedVehicle =>
      accessibility.recommendedVehicleType.displayName;
}
