import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tashlehekomv2/services/logging_service.dart';
import 'package:tashlehekomv2/services/enhanced_error_handler.dart';
import 'package:tashlehekomv2/services/performance_service.dart';
import 'package:tashlehekomv2/services/enhanced_cache_service.dart';
import 'package:tashlehekomv2/models/delivery_logistics_models.dart';

/// خدمة التوصيل واللوجستيات
class DeliveryLogisticsService {
  static final DeliveryLogisticsService _instance = DeliveryLogisticsService._internal();
  factory DeliveryLogisticsService() => _instance;
  DeliveryLogisticsService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final EnhancedCacheService _cache = EnhancedCacheService();

  /// إنشاء طلب توصيل جديد
  Future<DeliveryOrder> createDeliveryOrder({
    required String carId,
    required String buyerId,
    required String sellerId,
    required DeliveryAddress pickupAddress,
    required DeliveryAddress deliveryAddress,
    required DeliveryType deliveryType,
    String? specialInstructions,
  }) async {
    return EnhancedErrorHandler.executeWithErrorHandling(
      () async {
        return PerformanceService.measureAsync('create_delivery_order', () async {
          final orderId = 'DEL_${DateTime.now().millisecondsSinceEpoch}';
          
          final order = DeliveryOrder(
            id: orderId,
            carId: carId,
            buyerId: buyerId,
            sellerId: sellerId,
            pickupAddress: pickupAddress,
            deliveryAddress: deliveryAddress,
            deliveryType: deliveryType,
            status: DeliveryStatus.pending,
            specialInstructions: specialInstructions,
            estimatedCost: await _calculateDeliveryCost(pickupAddress, deliveryAddress, deliveryType),
            estimatedTime: await _calculateDeliveryTime(pickupAddress, deliveryAddress, deliveryType),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          // حفظ في Firestore
          await _firestore.collection('delivery_orders').doc(orderId).set(order.toMap());

          LoggingService.success('تم إنشاء طلب التوصيل: $orderId');
          return order;
        });
      },
      'إنشاء طلب التوصيل',
    ) ?? DeliveryOrder.empty();
  }

  /// تتبع طلب التوصيل
  Future<DeliveryTracking> trackDelivery(String orderId) async {
    return EnhancedErrorHandler.executeWithErrorHandling(
      () async {
        return PerformanceService.measureAsync('track_delivery', () async {
          final cacheKey = 'delivery_tracking_$orderId';
          
          // التحقق من التخزين المؤقت
          final cachedTracking = await _cache.get<Map<String, dynamic>>(cacheKey);
          if (cachedTracking != null) {
            return DeliveryTracking.fromMap(cachedTracking);
          }

          // محاكاة بيانات التتبع
          final tracking = await _generateDeliveryTracking(orderId);

          // حفظ في التخزين المؤقت
          await _cache.set(
            cacheKey,
            tracking.toMap(),
            expiration: const Duration(minutes: 5),
          );

          LoggingService.success('تم تتبع طلب التوصيل: $orderId');
          return tracking;
        });
      },
      'تتبع التوصيل',
    ) ?? DeliveryTracking.empty();
  }

  /// الحصول على السائقين المتاحين
  Future<List<DeliveryDriver>> getAvailableDrivers({
    required double latitude,
    required double longitude,
    required double radiusKm,
    DeliveryType? preferredType,
  }) async {
    return EnhancedErrorHandler.executeWithErrorHandling(
      () async {
        return PerformanceService.measureAsync('get_available_drivers', () async {
          final cacheKey = 'available_drivers_${latitude}_${longitude}_$radiusKm';
          
          // التحقق من التخزين المؤقت
          final cachedDrivers = await _cache.get<List<dynamic>>(cacheKey);
          if (cachedDrivers != null) {
            return cachedDrivers.map((item) => DeliveryDriver.fromMap(item)).toList();
          }

          // محاكاة السائقين المتاحين
          final drivers = await _generateAvailableDrivers(latitude, longitude, radiusKm, preferredType);

          // حفظ في التخزين المؤقت
          await _cache.set(
            cacheKey,
            drivers.map((d) => d.toMap()).toList(),
            expiration: const Duration(minutes: 10),
          );

          LoggingService.success('تم العثور على ${drivers.length} سائق متاح');
          return drivers;
        });
      },
      'البحث عن السائقين',
    ) ?? [];
  }

  /// تعيين سائق لطلب التوصيل
  Future<bool> assignDriverToOrder({
    required String orderId,
    required String driverId,
  }) async {
    return EnhancedErrorHandler.executeWithErrorHandling(
      () async {
        return PerformanceService.measureAsync('assign_driver', () async {
          // تحديث طلب التوصيل
          await _firestore.collection('delivery_orders').doc(orderId).update({
            'driverId': driverId,
            'status': DeliveryStatus.assigned.name,
            'updatedAt': DateTime.now().toIso8601String(),
          });

          // تحديث حالة السائق
          await _firestore.collection('delivery_drivers').doc(driverId).update({
            'status': DriverStatus.busy.name,
            'currentOrderId': orderId,
            'updatedAt': DateTime.now().toIso8601String(),
          });

          LoggingService.success('تم تعيين السائق $driverId للطلب $orderId');
          return true;
        });
      },
      'تعيين السائق',
    ) ?? false;
  }

  /// حساب تكلفة التوصيل
  Future<DeliveryCostBreakdown> calculateDeliveryCost({
    required DeliveryAddress pickupAddress,
    required DeliveryAddress deliveryAddress,
    required DeliveryType deliveryType,
    bool includeInsurance = false,
  }) async {
    return EnhancedErrorHandler.executeWithErrorHandling(
      () async {
        return PerformanceService.measureAsync('calculate_delivery_cost', () async {
          final distance = _calculateDistance(
            pickupAddress.latitude,
            pickupAddress.longitude,
            deliveryAddress.latitude,
            deliveryAddress.longitude,
          );

          final baseCost = _getBaseCostForType(deliveryType);
          final distanceCost = distance * _getDistanceRate(deliveryType);
          final insuranceCost = includeInsurance ? baseCost * 0.1 : 0.0;
          final serviceFee = (baseCost + distanceCost) * 0.15;
          final vat = (baseCost + distanceCost + serviceFee) * 0.15;

          return DeliveryCostBreakdown(
            baseCost: baseCost,
            distanceCost: distanceCost,
            insuranceCost: insuranceCost,
            serviceFee: serviceFee,
            vat: vat,
            totalCost: baseCost + distanceCost + insuranceCost + serviceFee + vat,
            distance: distance,
            deliveryType: deliveryType,
          );
        });
      },
      'حساب تكلفة التوصيل',
    ) ?? DeliveryCostBreakdown.empty();
  }

  /// الحصول على إحصائيات التوصيل
  Future<DeliveryStatistics> getDeliveryStatistics({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return EnhancedErrorHandler.executeWithErrorHandling(
      () async {
        return PerformanceService.measureAsync('delivery_statistics', () async {
          final cacheKey = 'delivery_stats_${userId}_${startDate.day}_${endDate.day}';
          
          // التحقق من التخزين المؤقت
          final cachedStats = await _cache.get<Map<String, dynamic>>(cacheKey);
          if (cachedStats != null) {
            return DeliveryStatistics.fromMap(cachedStats);
          }

          // محاكاة الإحصائيات
          final stats = await _generateDeliveryStatistics(userId, startDate, endDate);

          // حفظ في التخزين المؤقت
          await _cache.set(
            cacheKey,
            stats.toMap(),
            expiration: const Duration(hours: 6),
          );

          LoggingService.success('تم تحميل إحصائيات التوصيل للمستخدم: $userId');
          return stats;
        });
      },
      'إحصائيات التوصيل',
    ) ?? DeliveryStatistics.empty();
  }

  /// إدارة شبكة السائقين
  Future<DriverNetworkStatus> getDriverNetworkStatus({
    required String region,
  }) async {
    return EnhancedErrorHandler.executeWithErrorHandling(
      () async {
        return PerformanceService.measureAsync('driver_network_status', () async {
          final cacheKey = 'driver_network_$region';
          
          // التحقق من التخزين المؤقت
          final cachedStatus = await _cache.get<Map<String, dynamic>>(cacheKey);
          if (cachedStatus != null) {
            return DriverNetworkStatus.fromMap(cachedStatus);
          }

          // محاكاة حالة الشبكة
          final status = await _generateDriverNetworkStatus(region);

          // حفظ في التخزين المؤقت
          await _cache.set(
            cacheKey,
            status.toMap(),
            expiration: const Duration(minutes: 15),
          );

          LoggingService.success('تم تحميل حالة شبكة السائقين للمنطقة: $region');
          return status;
        });
      },
      'حالة شبكة السائقين',
    ) ?? DriverNetworkStatus.empty();
  }

  /// تحديث موقع السائق
  Future<bool> updateDriverLocation({
    required String driverId,
    required double latitude,
    required double longitude,
  }) async {
    return EnhancedErrorHandler.executeWithErrorHandling(
      () async {
        return PerformanceService.measureAsync('update_driver_location', () async {
          await _firestore.collection('delivery_drivers').doc(driverId).update({
            'currentLocation': {
              'latitude': latitude,
              'longitude': longitude,
              'timestamp': DateTime.now().toIso8601String(),
            },
            'updatedAt': DateTime.now().toIso8601String(),
          });

          // إزالة من التخزين المؤقت لإجبار التحديث
          await _cache.remove('available_drivers_${latitude}_${longitude}_10');

          LoggingService.success('تم تحديث موقع السائق: $driverId');
          return true;
        });
      },
      'تحديث موقع السائق',
    ) ?? false;
  }

  // الطرق المساعدة
  Future<double> _calculateDeliveryCost(
    DeliveryAddress pickup, DeliveryAddress delivery, DeliveryType type
  ) async {
    final distance = _calculateDistance(
      pickup.latitude, pickup.longitude,
      delivery.latitude, delivery.longitude,
    );
    
    final baseCost = _getBaseCostForType(type);
    final distanceCost = distance * _getDistanceRate(type);
    
    return baseCost + distanceCost;
  }

  Future<Duration> _calculateDeliveryTime(
    DeliveryAddress pickup, DeliveryAddress delivery, DeliveryType type
  ) async {
    final distance = _calculateDistance(
      pickup.latitude, pickup.longitude,
      delivery.latitude, delivery.longitude,
    );
    
    final baseTime = _getBaseTimeForType(type);
    final travelTime = (distance / _getAverageSpeed(type) * 60).round();
    
    return Duration(minutes: baseTime + travelTime);
  }

  double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6371; // km
    final double dLat = (lat2 - lat1) * (pi / 180);
    final double dLng = (lng2 - lng1) * (pi / 180);
    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * (pi / 180)) * cos(lat2 * (pi / 180)) * sin(dLng / 2) * sin(dLng / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _getBaseCostForType(DeliveryType type) {
    switch (type) {
      case DeliveryType.standard:
        return 50.0;
      case DeliveryType.express:
        return 100.0;
      case DeliveryType.premium:
        return 200.0;
      case DeliveryType.overnight:
        return 300.0;
    }
  }

  double _getDistanceRate(DeliveryType type) {
    switch (type) {
      case DeliveryType.standard:
        return 2.0; // ريال/كم
      case DeliveryType.express:
        return 3.0;
      case DeliveryType.premium:
        return 5.0;
      case DeliveryType.overnight:
        return 8.0;
    }
  }

  int _getBaseTimeForType(DeliveryType type) {
    switch (type) {
      case DeliveryType.standard:
        return 60; // دقيقة
      case DeliveryType.express:
        return 30;
      case DeliveryType.premium:
        return 15;
      case DeliveryType.overnight:
        return 720; // 12 ساعة
    }
  }

  double _getAverageSpeed(DeliveryType type) {
    switch (type) {
      case DeliveryType.standard:
        return 40.0; // كم/س
      case DeliveryType.express:
        return 60.0;
      case DeliveryType.premium:
        return 80.0;
      case DeliveryType.overnight:
        return 50.0;
    }
  }

  Future<DeliveryTracking> _generateDeliveryTracking(String orderId) async {
    await Future.delayed(const Duration(seconds: 1));
    
    final random = Random();
    final statuses = [
      DeliveryStatus.pending,
      DeliveryStatus.assigned,
      DeliveryStatus.pickedUp,
      DeliveryStatus.inTransit,
      DeliveryStatus.delivered,
    ];
    
    final currentStatusIndex = random.nextInt(statuses.length);
    final currentStatus = statuses[currentStatusIndex];
    
    final trackingEvents = <TrackingEvent>[];
    for (int i = 0; i <= currentStatusIndex; i++) {
      trackingEvents.add(TrackingEvent(
        status: statuses[i],
        timestamp: DateTime.now().subtract(Duration(hours: (currentStatusIndex - i) * 2)),
        location: 'موقع ${i + 1}',
        description: 'تم ${statuses[i].displayName}',
      ));
    }
    
    return DeliveryTracking(
      orderId: orderId,
      currentStatus: currentStatus,
      trackingEvents: trackingEvents,
      estimatedDeliveryTime: DateTime.now().add(Duration(hours: 2 + random.nextInt(6))),
      currentLocation: DeliveryLocation(
        latitude: 24.0 + random.nextDouble() * 6,
        longitude: 45.0 + random.nextDouble() * 10,
        address: 'الموقع الحالي',
        timestamp: DateTime.now(),
      ),
      driverInfo: random.nextBool() ? DriverInfo(
        id: 'DRIVER_${random.nextInt(100)}',
        name: 'السائق ${random.nextInt(100)}',
        phone: '05${random.nextInt(100000000).toString().padLeft(8, '0')}',
        rating: 3.5 + random.nextDouble() * 1.5,
        vehicleInfo: 'تويوتا كامري ${2015 + random.nextInt(8)}',
      ) : null,
      lastUpdated: DateTime.now(),
    );
  }

  Future<List<DeliveryDriver>> _generateAvailableDrivers(
    double latitude, double longitude, double radiusKm, DeliveryType? preferredType
  ) async {
    await Future.delayed(const Duration(seconds: 1));
    
    final random = Random();
    final drivers = <DeliveryDriver>[];
    final count = 3 + random.nextInt(8);
    
    for (int i = 0; i < count; i++) {
      drivers.add(DeliveryDriver(
        id: 'DRIVER_${i + 1}',
        name: 'السائق ${i + 1}',
        phone: '05${random.nextInt(100000000).toString().padLeft(8, '0')}',
        rating: 3.0 + random.nextDouble() * 2.0,
        status: DriverStatus.available,
        currentLocation: DeliveryLocation(
          latitude: latitude + (random.nextDouble() - 0.5) * 0.1,
          longitude: longitude + (random.nextDouble() - 0.5) * 0.1,
          address: 'موقع السائق ${i + 1}',
          timestamp: DateTime.now(),
        ),
        vehicleInfo: VehicleInfo(
          type: VehicleType.values[random.nextInt(VehicleType.values.length)],
          model: 'تويوتا كامري ${2015 + random.nextInt(8)}',
          plateNumber: '${random.nextInt(9999).toString().padLeft(4, '0')} ${String.fromCharCode(65 + random.nextInt(26))}${String.fromCharCode(65 + random.nextInt(26))}${String.fromCharCode(65 + random.nextInt(26))}',
          color: ['أبيض', 'أسود', 'فضي', 'أزرق', 'أحمر'][random.nextInt(5)],
        ),
        specializations: _generateDriverSpecializations(random),
        completedDeliveries: random.nextInt(500),
        joinDate: DateTime.now().subtract(Duration(days: random.nextInt(365))),
        isVerified: random.nextDouble() > 0.2,
        lastActive: DateTime.now().subtract(Duration(minutes: random.nextInt(30))),
      ));
    }
    
    return drivers;
  }

  List<DeliveryType> _generateDriverSpecializations(Random random) {
    final specializations = <DeliveryType>[];
    for (final type in DeliveryType.values) {
      if (random.nextDouble() > 0.3) {
        specializations.add(type);
      }
    }
    return specializations.isEmpty ? [DeliveryType.standard] : specializations;
  }

  Future<DeliveryStatistics> _generateDeliveryStatistics(
    String userId, DateTime startDate, DateTime endDate
  ) async {
    await Future.delayed(const Duration(seconds: 1));
    
    final random = Random();
    final days = endDate.difference(startDate).inDays;
    
    return DeliveryStatistics(
      userId: userId,
      period: DateRange(start: startDate, end: endDate),
      totalOrders: random.nextInt(50) + days,
      completedOrders: random.nextInt(45) + (days * 0.8).round(),
      cancelledOrders: random.nextInt(5),
      totalCost: 1000 + random.nextDouble() * 5000,
      averageDeliveryTime: Duration(hours: 2 + random.nextInt(4)),
      onTimeDeliveryRate: 0.8 + random.nextDouble() * 0.15,
      customerSatisfactionRate: 0.85 + random.nextDouble() * 0.1,
      mostUsedDeliveryType: DeliveryType.values[random.nextInt(DeliveryType.values.length)],
      deliveryTypeBreakdown: _generateDeliveryTypeBreakdown(random),
      monthlyTrend: _generateMonthlyTrend(random, days),
      topDrivers: _generateTopDrivers(random),
      lastUpdated: DateTime.now(),
    );
  }

  Map<DeliveryType, int> _generateDeliveryTypeBreakdown(Random random) {
    return {
      DeliveryType.standard: random.nextInt(20),
      DeliveryType.express: random.nextInt(15),
      DeliveryType.premium: random.nextInt(10),
      DeliveryType.overnight: random.nextInt(5),
    };
  }

  List<MonthlyDeliveryData> _generateMonthlyTrend(Random random, int days) {
    final trend = <MonthlyDeliveryData>[];
    final months = (days / 30).ceil();
    
    for (int i = 0; i < months; i++) {
      trend.add(MonthlyDeliveryData(
        month: DateTime.now().subtract(Duration(days: (months - i - 1) * 30)),
        orders: random.nextInt(30) + 10,
        cost: 500 + random.nextDouble() * 2000,
      ));
    }
    
    return trend;
  }

  List<DriverPerformance> _generateTopDrivers(Random random) {
    return List.generate(5, (i) => DriverPerformance(
      driverId: 'DRIVER_${i + 1}',
      name: 'السائق ${i + 1}',
      deliveries: random.nextInt(50) + 20,
      rating: 4.0 + random.nextDouble(),
      onTimeRate: 0.8 + random.nextDouble() * 0.15,
    ));
  }

  Future<DriverNetworkStatus> _generateDriverNetworkStatus(String region) async {
    await Future.delayed(const Duration(seconds: 1));
    
    final random = Random();
    
    return DriverNetworkStatus(
      region: region,
      totalDrivers: 50 + random.nextInt(200),
      activeDrivers: 30 + random.nextInt(100),
      busyDrivers: 10 + random.nextInt(50),
      averageRating: 4.0 + random.nextDouble(),
      coverageAreas: _generateCoverageAreas(random),
      peakHours: _generatePeakHours(random),
      networkEfficiency: 0.8 + random.nextDouble() * 0.15,
      lastUpdated: DateTime.now(),
    );
  }

  List<CoverageArea> _generateCoverageAreas(Random random) {
    return List.generate(3 + random.nextInt(5), (i) => CoverageArea(
      name: 'منطقة ${i + 1}',
      driversCount: random.nextInt(20) + 5,
      averageResponseTime: Duration(minutes: 10 + random.nextInt(20)),
      demandLevel: DemandLevel.values[random.nextInt(DemandLevel.values.length)],
    ));
  }

  Map<int, int> _generatePeakHours(Random random) {
    final peakHours = <int, int>{};
    for (int hour = 0; hour < 24; hour++) {
      peakHours[hour] = random.nextInt(20);
    }
    return peakHours;
  }
}
