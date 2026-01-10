import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tashlehekomv2/services/logging_service.dart';
import 'package:tashlehekomv2/services/enhanced_error_handler.dart';
import 'package:tashlehekomv2/services/performance_service.dart';
import 'package:tashlehekomv2/services/enhanced_cache_service.dart';
import 'package:tashlehekomv2/models/space_technology_models.dart';

/// خدمة تقنيات الفضاء
class SpaceTechnologyService {
  static final SpaceTechnologyService _instance =
      SpaceTechnologyService._internal();
  factory SpaceTechnologyService() => _instance;
  SpaceTechnologyService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final EnhancedCacheService _cache = EnhancedCacheService();

  /// الحصول على بيانات الأقمار الصناعية
  Future<List<SatelliteData>> getSatelliteData({
    required String region,
    SatelliteType? type,
  }) async {
    return EnhancedErrorHandler.executeWithErrorHandling(
          () async {
            return PerformanceService.measureAsync('satellite_data', () async {
              final cacheKey =
                  'satellite_data_${region}_${type?.name ?? 'all'}';

              // التحقق من التخزين المؤقت
              final cachedData = await _cache.get<List<dynamic>>(cacheKey);
              if (cachedData != null) {
                return cachedData
                    .map((item) => SatelliteData.fromMap(item))
                    .toList();
              }

              // محاكاة بيانات الأقمار الصناعية
              final satellites = await _generateSatelliteData(region, type);

              // حفظ في التخزين المؤقت
              await _cache.set(
                cacheKey,
                satellites.map((s) => s.toMap()).toList(),
                expiration: const Duration(minutes: 15),
              );

              LoggingService.success(
                  'تم تحميل بيانات الأقمار الصناعية للمنطقة: $region');
              return satellites;
            });
          },
          'بيانات الأقمار الصناعية',
        ) ??
        [];
  }

  /// تتبع السيارة باستخدام الأقمار الصناعية
  Future<SatelliteTracking> trackVehicleWithSatellite({
    required String vehicleId,
    required double latitude,
    required double longitude,
  }) async {
    return EnhancedErrorHandler.executeWithErrorHandling(
          () async {
            return PerformanceService.measureAsync('satellite_tracking',
                () async {
              final cacheKey = 'satellite_tracking_$vehicleId';

              // محاكاة التتبع الفضائي
              final tracking = await _performSatelliteTracking(
                  vehicleId, latitude, longitude);

              // حفظ في التخزين المؤقت
              await _cache.set(
                cacheKey,
                tracking.toMap(),
                expiration: const Duration(minutes: 5),
              );

              LoggingService.success(
                  'تم تتبع السيارة بالأقمار الصناعية: $vehicleId');
              return tracking;
            });
          },
          'التتبع الفضائي',
        ) ??
        SatelliteTracking.empty();
  }

  /// الحصول على بيانات الطقس الفضائي
  Future<SpaceWeatherData> getSpaceWeatherData() async {
    return EnhancedErrorHandler.executeWithErrorHandling(
          () async {
            return PerformanceService.measureAsync('space_weather', () async {
              const cacheKey = 'space_weather_data';

              // التحقق من التخزين المؤقت
              final cachedWeather =
                  await _cache.get<Map<String, dynamic>>(cacheKey);
              if (cachedWeather != null) {
                return SpaceWeatherData.fromMap(cachedWeather);
              }

              // محاكاة بيانات الطقس الفضائي
              final weather = _generateSpaceWeatherData();

              // حفظ في التخزين المؤقت
              await _cache.set(
                cacheKey,
                weather.toMap(),
                expiration: const Duration(hours: 1),
              );

              LoggingService.success('تم تحميل بيانات الطقس الفضائي');
              return weather;
            });
          },
          'الطقس الفضائي',
        ) ??
        SpaceWeatherData.empty();
  }

  /// تحليل المسار الأمثل باستخدام الملاحة الفضائية
  Future<SpaceNavigationRoute> calculateOptimalRoute({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    RouteOptimization optimization = RouteOptimization.fastest,
  }) async {
    return EnhancedErrorHandler.executeWithErrorHandling(
          () async {
            return PerformanceService.measureAsync('space_navigation',
                () async {
              final cacheKey =
                  'space_route_${startLat}_${startLng}_${endLat}_${endLng}_${optimization.name}';

              // التحقق من التخزين المؤقت
              final cachedRoute =
                  await _cache.get<Map<String, dynamic>>(cacheKey);
              if (cachedRoute != null) {
                return SpaceNavigationRoute.fromMap(cachedRoute);
              }

              // محاكاة حساب المسار الفضائي
              final route = await _calculateSpaceRoute(
                  startLat, startLng, endLat, endLng, optimization);

              // حفظ في التخزين المؤقت
              await _cache.set(
                cacheKey,
                route.toMap(),
                expiration: const Duration(hours: 2),
              );

              LoggingService.success('تم حساب المسار الأمثل بالملاحة الفضائية');
              return route;
            });
          },
          'الملاحة الفضائية',
        ) ??
        SpaceNavigationRoute.empty();
  }

  /// مراقبة الأسطول باستخدام الأقمار الصناعية
  Future<FleetMonitoring> monitorFleetFromSpace({
    required List<String> vehicleIds,
    required String region,
  }) async {
    return EnhancedErrorHandler.executeWithErrorHandling(
          () async {
            return PerformanceService.measureAsync('fleet_monitoring',
                () async {
              final cacheKey =
                  'fleet_monitoring_${region}_${vehicleIds.length}';

              // التحقق من التخزين المؤقت
              final cachedMonitoring =
                  await _cache.get<Map<String, dynamic>>(cacheKey);
              if (cachedMonitoring != null) {
                return FleetMonitoring.fromMap(cachedMonitoring);
              }

              // محاكاة مراقبة الأسطول
              final monitoring =
                  await _performFleetMonitoring(vehicleIds, region);

              // حفظ في التخزين المؤقت
              await _cache.set(
                cacheKey,
                monitoring.toMap(),
                expiration: const Duration(minutes: 10),
              );

              LoggingService.success(
                  'تم مراقبة الأسطول من الفضاء: ${vehicleIds.length} مركبة');
              return monitoring;
            });
          },
          'مراقبة الأسطول',
        ) ??
        FleetMonitoring.empty();
  }

  /// تحليل التضاريس باستخدام صور الأقمار الصناعية
  Future<TerrainAnalysis> analyzeTerrainFromSatellite({
    required double latitude,
    required double longitude,
    required double radius, // بالكيلومتر
  }) async {
    return EnhancedErrorHandler.executeWithErrorHandling(
          () async {
            return PerformanceService.measureAsync('terrain_analysis',
                () async {
              final cacheKey =
                  'terrain_analysis_${latitude}_${longitude}_$radius';

              // التحقق من التخزين المؤقت
              final cachedAnalysis =
                  await _cache.get<Map<String, dynamic>>(cacheKey);
              if (cachedAnalysis != null) {
                return TerrainAnalysis.fromMap(cachedAnalysis);
              }

              // محاكاة تحليل التضاريس
              final analysis =
                  await _performTerrainAnalysis(latitude, longitude, radius);

              // حفظ في التخزين المؤقت
              await _cache.set(
                cacheKey,
                analysis.toMap(),
                expiration: const Duration(hours: 24),
              );

              LoggingService.success('تم تحليل التضاريس من الأقمار الصناعية');
              return analysis;
            });
          },
          'تحليل التضاريس',
        ) ??
        TerrainAnalysis.empty();
  }

  /// الحصول على حالة الشبكة الفضائية
  Future<SpaceNetworkStatus> getSpaceNetworkStatus() async {
    return EnhancedErrorHandler.executeWithErrorHandling(
          () async {
            return PerformanceService.measureAsync('space_network_status',
                () async {
              const cacheKey = 'space_network_status';

              // التحقق من التخزين المؤقت
              final cachedStatus =
                  await _cache.get<Map<String, dynamic>>(cacheKey);
              if (cachedStatus != null) {
                return SpaceNetworkStatus.fromMap(cachedStatus);
              }

              // محاكاة حالة الشبكة الفضائية
              final status = _generateSpaceNetworkStatus();

              // حفظ في التخزين المؤقت
              await _cache.set(
                cacheKey,
                status.toMap(),
                expiration: const Duration(minutes: 5),
              );

              return status;
            });
          },
          'حالة الشبكة الفضائية',
        ) ??
        SpaceNetworkStatus.empty();
  }

  /// البحث عن السيارات المفقودة باستخدام الأقمار الصناعية
  Future<SatelliteSearchResult> searchLostVehicles({
    required String searchArea,
    required DateTime lastKnownTime,
    required double lastKnownLat,
    required double lastKnownLng,
  }) async {
    return EnhancedErrorHandler.executeWithErrorHandling(
          () async {
            return PerformanceService.measureAsync('satellite_search',
                () async {
              // محاكاة البحث بالأقمار الصناعية
              final searchResult = await _performSatelliteSearch(
                  searchArea, lastKnownTime, lastKnownLat, lastKnownLng);

              LoggingService.success(
                  'تم إجراء البحث بالأقمار الصناعية في المنطقة: $searchArea');
              return searchResult;
            });
          },
          'البحث بالأقمار الصناعية',
        ) ??
        SatelliteSearchResult.empty();
  }

  // الطرق المساعدة
  Future<List<SatelliteData>> _generateSatelliteData(
      String region, SatelliteType? type) async {
    await Future.delayed(const Duration(seconds: 1));

    final random = Random();
    final satellites = <SatelliteData>[];

    final satelliteTypes = type != null ? [type] : SatelliteType.values;

    for (final satType in satelliteTypes) {
      final count = 2 + random.nextInt(4);
      for (int i = 0; i < count; i++) {
        satellites.add(SatelliteData(
          id: '${satType.name.toUpperCase()}-${i + 1}',
          name: '${satType.displayName} ${i + 1}',
          type: satType,
          status: random.nextDouble() > 0.1
              ? SatelliteStatus.operational
              : SatelliteStatus.maintenance,
          altitude: 200 + random.nextInt(35000).toDouble(), // km
          speed: 7000 + random.nextInt(3000).toDouble(), // km/h
          latitude: 21.0 + random.nextDouble() * 10, // السعودية تقريباً
          longitude: 39.0 + random.nextDouble() * 15,
          signalStrength: 0.7 + random.nextDouble() * 0.25,
          batteryLevel: 0.6 + random.nextDouble() * 0.35,
          lastUpdate:
              DateTime.now().subtract(Duration(minutes: random.nextInt(30))),
          coverage: CoverageArea(
            centerLat: 24.0 + random.nextDouble() * 6,
            centerLng: 45.0 + random.nextDouble() * 10,
            radius: 500 + random.nextInt(1500).toDouble(),
          ),
        ));
      }
    }

    return satellites;
  }

  Future<SatelliteTracking> _performSatelliteTracking(
      String vehicleId, double latitude, double longitude) async {
    await Future.delayed(const Duration(seconds: 2));

    final random = Random();

    return SatelliteTracking(
      vehicleId: vehicleId,
      currentPosition: GeoPosition(
        latitude: latitude + (random.nextDouble() - 0.5) * 0.001,
        longitude: longitude + (random.nextDouble() - 0.5) * 0.001,
        altitude: random.nextInt(1000).toDouble(),
        accuracy: 1.0 + random.nextDouble() * 3.0,
      ),
      trackingHistory: _generateTrackingHistory(latitude, longitude, random),
      activeSatellites:
          List.generate(3 + random.nextInt(3), (i) => 'SAT-${i + 1}'),
      signalQuality: 0.8 + random.nextDouble() * 0.15,
      trackingAccuracy: 0.9 + random.nextDouble() * 0.08,
      lastUpdate: DateTime.now(),
      estimatedSpeed: random.nextInt(120).toDouble(),
      heading: random.nextInt(360).toDouble(),
      isMoving: random.nextBool(),
    );
  }

  List<TrackingPoint> _generateTrackingHistory(
      double baseLat, double baseLng, Random random) {
    final history = <TrackingPoint>[];
    var currentLat = baseLat;
    var currentLng = baseLng;

    for (int i = 0; i < 10; i++) {
      currentLat += (random.nextDouble() - 0.5) * 0.01;
      currentLng += (random.nextDouble() - 0.5) * 0.01;

      history.add(TrackingPoint(
        position: GeoPosition(
          latitude: currentLat,
          longitude: currentLng,
          altitude: random.nextInt(1000).toDouble(),
          accuracy: 1.0 + random.nextDouble() * 2.0,
        ),
        timestamp: DateTime.now().subtract(Duration(minutes: (10 - i) * 5)),
        speed: random.nextInt(80).toDouble(),
        heading: random.nextInt(360).toDouble(),
      ));
    }

    return history;
  }

  SpaceWeatherData _generateSpaceWeatherData() {
    final random = Random();

    return SpaceWeatherData(
      solarActivity: SolarActivityLevel
          .values[random.nextInt(SolarActivityLevel.values.length)],
      geomagneticStorm: random.nextDouble() > 0.8,
      radiationLevel:
          RadiationLevel.values[random.nextInt(RadiationLevel.values.length)],
      solarWindSpeed: 300 + random.nextInt(400).toDouble(), // km/s
      kpIndex: random.nextDouble() * 9,
      sunspotNumber: random.nextInt(200),
      forecast: _generateSpaceWeatherForecast(random),
      impactOnSatellites: random.nextDouble() > 0.7
          ? 'تأثير محتمل على الإشارات'
          : 'لا يوجد تأثير متوقع',
      lastUpdate: DateTime.now(),
    );
  }

  List<SpaceWeatherForecast> _generateSpaceWeatherForecast(Random random) {
    return List.generate(
        7,
        (i) => SpaceWeatherForecast(
              date: DateTime.now().add(Duration(days: i + 1)),
              activity: SolarActivityLevel
                  .values[random.nextInt(SolarActivityLevel.values.length)],
              confidence: 0.6 + random.nextDouble() * 0.3,
              description: 'توقعات الطقس الفضائي لليوم ${i + 1}',
            ));
  }

  Future<SpaceNavigationRoute> _calculateSpaceRoute(
      double startLat,
      double startLng,
      double endLat,
      double endLng,
      RouteOptimization optimization) async {
    await Future.delayed(const Duration(seconds: 3));

    final random = Random();
    final distance = _calculateDistance(startLat, startLng, endLat, endLng);

    return SpaceNavigationRoute(
      startPosition: GeoPosition(
        latitude: startLat,
        longitude: startLng,
        altitude: 0,
        accuracy: 1.0,
      ),
      endPosition: GeoPosition(
        latitude: endLat,
        longitude: endLng,
        altitude: 0,
        accuracy: 1.0,
      ),
      waypoints: _generateWaypoints(startLat, startLng, endLat, endLng, random),
      totalDistance: distance,
      estimatedTime: Duration(
          minutes: (distance / 60 * (1 + random.nextDouble() * 0.5)).round()),
      optimization: optimization,
      satelliteCoverage: 0.85 + random.nextDouble() * 0.1,
      routeQuality:
          RouteQuality.values[random.nextInt(RouteQuality.values.length)],
      alternativeRoutes: _generateAlternativeRoutes(random),
      trafficConditions: _generateTrafficConditions(random),
      lastCalculated: DateTime.now(),
    );
  }

  double _calculateDistance(
      double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6371; // km
    final double dLat = (lat2 - lat1) * (pi / 180);
    final double dLng = (lng2 - lng1) * (pi / 180);
    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * (pi / 180)) *
            cos(lat2 * (pi / 180)) *
            sin(dLng / 2) *
            sin(dLng / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  List<GeoPosition> _generateWaypoints(double startLat, double startLng,
      double endLat, double endLng, Random random) {
    final waypoints = <GeoPosition>[];
    final steps = 3 + random.nextInt(5);

    for (int i = 1; i < steps; i++) {
      final ratio = i / steps;
      final lat = startLat +
          (endLat - startLat) * ratio +
          (random.nextDouble() - 0.5) * 0.01;
      final lng = startLng +
          (endLng - startLng) * ratio +
          (random.nextDouble() - 0.5) * 0.01;

      waypoints.add(GeoPosition(
        latitude: lat,
        longitude: lng,
        altitude: random.nextInt(500).toDouble(),
        accuracy: 1.0 + random.nextDouble() * 2.0,
      ));
    }

    return waypoints;
  }

  List<AlternativeRoute> _generateAlternativeRoutes(Random random) {
    return List.generate(
        2 + random.nextInt(2),
        (i) => AlternativeRoute(
              name: 'مسار بديل ${i + 1}',
              distance: 50 + random.nextInt(200).toDouble(),
              estimatedTime: Duration(minutes: 30 + random.nextInt(120)),
              trafficLevel: TrafficLevel
                  .values[random.nextInt(TrafficLevel.values.length)],
              advantages: [
                'أقل ازدحاماً',
                'طريق أسرع',
                'مناظر أفضل'
              ][random.nextInt(3)],
            ));
  }

  Map<String, TrafficLevel> _generateTrafficConditions(Random random) {
    return {
      'الطريق الرئيسي':
          TrafficLevel.values[random.nextInt(TrafficLevel.values.length)],
      'الطرق الفرعية':
          TrafficLevel.values[random.nextInt(TrafficLevel.values.length)],
      'المناطق الحضرية':
          TrafficLevel.values[random.nextInt(TrafficLevel.values.length)],
    };
  }

  Future<FleetMonitoring> _performFleetMonitoring(
      List<String> vehicleIds, String region) async {
    await Future.delayed(const Duration(seconds: 2));

    final random = Random();
    final vehicles = vehicleIds
        .map((id) => VehicleStatus(
              vehicleId: id,
              position: GeoPosition(
                latitude: 24.0 + random.nextDouble() * 6,
                longitude: 45.0 + random.nextDouble() * 10,
                altitude: random.nextInt(1000).toDouble(),
                accuracy: 1.0 + random.nextDouble() * 3.0,
              ),
              status: VehicleOperationalStatus.values[
                  random.nextInt(VehicleOperationalStatus.values.length)],
              speed: random.nextInt(120).toDouble(),
              heading: random.nextInt(360).toDouble(),
              fuel: 0.2 + random.nextDouble() * 0.7,
              lastUpdate: DateTime.now()
                  .subtract(Duration(minutes: random.nextInt(30))),
            ))
        .toList();

    return FleetMonitoring(
      region: region,
      totalVehicles: vehicleIds.length,
      activeVehicles: vehicles
          .where((v) => v.status == VehicleOperationalStatus.active)
          .length,
      vehicles: vehicles,
      coverageArea: CoverageArea(
        centerLat: 24.0 + random.nextDouble() * 6,
        centerLng: 45.0 + random.nextDouble() * 10,
        radius: 100 + random.nextInt(500).toDouble(),
      ),
      monitoringQuality: 0.8 + random.nextDouble() * 0.15,
      alerts: _generateFleetAlerts(random),
      lastUpdate: DateTime.now(),
    );
  }

  List<FleetAlert> _generateFleetAlerts(Random random) {
    if (random.nextDouble() > 0.3) return [];

    return List.generate(
        1 + random.nextInt(3),
        (i) => FleetAlert(
              id: 'ALERT-${i + 1}',
              type: FleetAlertType
                  .values[random.nextInt(FleetAlertType.values.length)],
              vehicleId: 'VEH-${random.nextInt(100)}',
              message: 'تنبيه الأسطول ${i + 1}',
              severity: AlertSeverity
                  .values[random.nextInt(AlertSeverity.values.length)],
              timestamp: DateTime.now()
                  .subtract(Duration(minutes: random.nextInt(60))),
            ));
  }

  Future<TerrainAnalysis> _performTerrainAnalysis(
      double latitude, double longitude, double radius) async {
    await Future.delayed(const Duration(seconds: 3));

    final random = Random();

    return TerrainAnalysis(
      centerPosition: GeoPosition(
        latitude: latitude,
        longitude: longitude,
        altitude: 500 + random.nextInt(1500).toDouble(),
        accuracy: 1.0,
      ),
      analysisRadius: radius,
      terrainType:
          TerrainType.values[random.nextInt(TerrainType.values.length)],
      elevation: ElevationData(
        minimum: random.nextInt(500).toDouble(),
        maximum: 500 + random.nextInt(2000).toDouble(),
        average: 250 + random.nextInt(750).toDouble(),
        variance: random.nextDouble() * 200,
      ),
      slope: SlopeData(
        averageSlope: random.nextDouble() * 30,
        maximumSlope: 20 + random.nextDouble() * 40,
        slopeVariation: random.nextDouble() * 15,
      ),
      vegetation: VegetationData(
        coverage: random.nextDouble(),
        type:
            VegetationType.values[random.nextInt(VegetationType.values.length)],
        density: VegetationDensity
            .values[random.nextInt(VegetationDensity.values.length)],
      ),
      accessibility: AccessibilityData(
        roadAccess: random.nextDouble() > 0.3,
        difficulty: AccessibilityLevel
            .values[random.nextInt(AccessibilityLevel.values.length)],
        recommendedVehicleType: RecommendedVehicleType
            .values[random.nextInt(RecommendedVehicleType.values.length)],
      ),
      weatherImpact: WeatherImpact(
        rainEffect:
            ImpactLevel.values[random.nextInt(ImpactLevel.values.length)],
        windEffect:
            ImpactLevel.values[random.nextInt(ImpactLevel.values.length)],
        temperatureEffect:
            ImpactLevel.values[random.nextInt(ImpactLevel.values.length)],
      ),
      analysisDate: DateTime.now(),
      imageResolution: '${1 + random.nextInt(5)}m/pixel',
      dataSource: 'Satellite Imagery ${DateTime.now().year}',
    );
  }

  SpaceNetworkStatus _generateSpaceNetworkStatus() {
    final random = Random();

    return SpaceNetworkStatus(
      isOnline: true,
      activeSatellites: 8 + random.nextInt(12),
      totalSatellites: 15 + random.nextInt(10),
      networkCoverage: 0.85 + random.nextDouble() * 0.1,
      signalQuality: 0.8 + random.nextDouble() * 0.15,
      latency: Duration(milliseconds: 100 + random.nextInt(200)),
      bandwidth: 50 + random.nextInt(150).toDouble(), // Mbps
      groundStations: List.generate(
          3 + random.nextInt(3),
          (i) => GroundStation(
                id: 'GS-${i + 1}',
                name: 'محطة أرضية ${i + 1}',
                location: 'المنطقة ${i + 1}',
                status: random.nextDouble() > 0.1
                    ? StationStatus.operational
                    : StationStatus.maintenance,
                signalStrength: 0.7 + random.nextDouble() * 0.25,
              )),
      lastUpdate: DateTime.now(),
    );
  }

  Future<SatelliteSearchResult> _performSatelliteSearch(String searchArea,
      DateTime lastKnownTime, double lastKnownLat, double lastKnownLng) async {
    await Future.delayed(const Duration(seconds: 4));

    final random = Random();
    final foundVehicles = <FoundVehicle>[];

    // محاكاة العثور على بعض السيارات
    if (random.nextDouble() > 0.3) {
      final count = 1 + random.nextInt(3);
      for (int i = 0; i < count; i++) {
        foundVehicles.add(FoundVehicle(
          vehicleId: 'FOUND-${i + 1}',
          position: GeoPosition(
            latitude: lastKnownLat + (random.nextDouble() - 0.5) * 0.1,
            longitude: lastKnownLng + (random.nextDouble() - 0.5) * 0.1,
            altitude: random.nextInt(1000).toDouble(),
            accuracy: 5.0 + random.nextDouble() * 10.0,
          ),
          confidence: 0.6 + random.nextDouble() * 0.3,
          detectionTime:
              DateTime.now().subtract(Duration(minutes: random.nextInt(120))),
          imageQuality:
              ImageQuality.values[random.nextInt(ImageQuality.values.length)],
          additionalInfo: 'تم اكتشافها في صورة القمر الصناعي',
        ));
      }
    }

    return SatelliteSearchResult(
      searchArea: searchArea,
      searchRadius: 10 + random.nextInt(40).toDouble(),
      foundVehicles: foundVehicles,
      searchDuration: Duration(minutes: 15 + random.nextInt(45)),
      satellitesUsed:
          List.generate(2 + random.nextInt(4), (i) => 'SAT-SEARCH-${i + 1}'),
      imagesCaptured: 5 + random.nextInt(15),
      searchAccuracy: 0.8 + random.nextDouble() * 0.15,
      weatherConditions: 'صافي',
      searchStatus:
          foundVehicles.isNotEmpty ? SearchStatus.found : SearchStatus.notFound,
      lastUpdate: DateTime.now(),
    );
  }
}
