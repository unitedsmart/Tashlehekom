import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tashlehekomv2/models/iot_models.dart';
import 'package:tashlehekomv2/models/delivery_logistics_models.dart'
    as logistics;
import 'package:tashlehekomv2/services/logging_service.dart';
import 'package:tashlehekomv2/services/enhanced_error_handler.dart';
import 'package:tashlehekomv2/services/performance_service.dart';
import 'package:tashlehekomv2/services/enhanced_cache_service.dart';

/// خدمة إنترنت الأشياء (IoT)
class IoTService {
  static final IoTService _instance = IoTService._internal();
  factory IoTService() => _instance;
  IoTService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final EnhancedCacheService _cache = EnhancedCacheService();

  // محاكاة اتصال IoT
  final Map<String, StreamController<IoTDeviceData>> _deviceStreams = {};
  final Map<String, Timer> _simulationTimers = {};

  /// تسجيل جهاز IoT جديد
  Future<String?> registerIoTDevice({
    required String carId,
    required String deviceType,
    required String deviceModel,
    required String serialNumber,
    Map<String, dynamic>? configuration,
  }) async {
    return EnhancedErrorHandler.executeWithErrorHandling(
      () async {
        return PerformanceService.measureAsync('register_iot_device', () async {
          final deviceData = {
            'carId': carId,
            'deviceType': deviceType,
            'deviceModel': deviceModel,
            'serialNumber': serialNumber,
            'configuration': configuration ?? {},
            'status': IoTDeviceStatus.offline.name,
            'lastSeen': null,
            'batteryLevel': 100,
            'signalStrength': 0,
            'firmwareVersion': '1.0.0',
            'registeredAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          };

          final docRef =
              await _firestore.collection('iot_devices').add(deviceData);

          LoggingService.success('تم تسجيل جهاز IoT جديد: $deviceType');
          return docRef.id;
        });
      },
      'تسجيل جهاز IoT',
    );
  }

  /// الحصول على أجهزة IoT للسيارة
  Future<List<IoTDevice>> getCarIoTDevices(String carId) async {
    try {
      final result =
          await EnhancedErrorHandler.executeWithErrorHandling<List<IoTDevice>>(
        () async {
          return PerformanceService.measureAsync('get_car_iot_devices',
              () async {
            final cacheKey = 'iot_devices_$carId';

            // التحقق من التخزين المؤقت
            final cachedDevices = await _cache.get<List<dynamic>>(cacheKey);
            if (cachedDevices != null) {
              return cachedDevices
                  .map((item) => IoTDevice.fromMap(item))
                  .toList();
            }

            // جلب من قاعدة البيانات
            final snapshot = await _firestore
                .collection('iot_devices')
                .where('carId', isEqualTo: carId)
                .get();

            final devices = snapshot.docs.map((doc) {
              return IoTDevice.fromMap({...doc.data(), 'id': doc.id});
            }).toList();

            // حفظ في التخزين المؤقت
            await _cache.set(
              cacheKey,
              devices.map((device) => device.toMap()).toList(),
              expiration: const Duration(minutes: 5),
            );

            return devices;
          });
        },
        'جلب أجهزة IoT للسيارة',
      );

      return result ?? [];
    } catch (e) {
      LoggingService.error('خطأ في جلب أجهزة IoT للسيارة', error: e);
      return [];
    }
  }

  /// بدء مراقبة جهاز IoT
  Stream<IoTDeviceData> monitorDevice(String deviceId) {
    if (_deviceStreams.containsKey(deviceId)) {
      return _deviceStreams[deviceId]!.stream;
    }

    final controller = StreamController<IoTDeviceData>.broadcast();
    _deviceStreams[deviceId] = controller;

    // بدء محاكاة البيانات
    _startDeviceSimulation(deviceId, controller);

    return controller.stream;
  }

  /// إيقاف مراقبة جهاز IoT
  void stopMonitoring(String deviceId) {
    _simulationTimers[deviceId]?.cancel();
    _simulationTimers.remove(deviceId);

    _deviceStreams[deviceId]?.close();
    _deviceStreams.remove(deviceId);
  }

  /// إرسال أمر إلى جهاز IoT
  Future<bool> sendDeviceCommand({
    required String deviceId,
    required IoTCommand command,
    Map<String, dynamic>? parameters,
  }) async {
    final result = await EnhancedErrorHandler.executeWithErrorHandling<bool>(
      () async {
        return PerformanceService.measureAsync('send_device_command', () async {
          // تسجيل الأمر
          await _firestore.collection('iot_commands').add({
            'deviceId': deviceId,
            'command': command.name,
            'parameters': parameters ?? {},
            'status': CommandStatus.pending.name,
            'sentAt': FieldValue.serverTimestamp(),
          });

          // محاكاة إرسال الأمر
          await Future.delayed(const Duration(seconds: 1));

          LoggingService.success(
              'تم إرسال أمر ${command.name} إلى الجهاز $deviceId');
          return true;
        });
      },
      'إرسال أمر IoT',
    );
    return result ?? false;
  }

  /// الحصول على بيانات التشخيص الذكي
  Future<SmartDiagnostics> getSmartDiagnostics(String carId) async {
    final result =
        await EnhancedErrorHandler.executeWithErrorHandling<SmartDiagnostics>(
      () async {
        return PerformanceService.measureAsync('get_smart_diagnostics',
            () async {
          final cacheKey = 'smart_diagnostics_$carId';

          // التحقق من التخزين المؤقت
          final cachedDiagnostics =
              await _cache.get<Map<String, dynamic>>(cacheKey);
          if (cachedDiagnostics != null) {
            return SmartDiagnostics.fromMap(cachedDiagnostics);
          }

          // محاكاة بيانات التشخيص
          final diagnostics = _generateMockDiagnostics(carId);

          // حفظ في التخزين المؤقت
          await _cache.set(
            cacheKey,
            diagnostics.toMap(),
            expiration: const Duration(minutes: 10),
          );

          return diagnostics;
        });
      },
      'جلب التشخيص الذكي',
    );
    return result ?? SmartDiagnostics.empty(carId);
  }

  /// الحصول على توقعات الصيانة التنبؤية
  Future<PredictiveMaintenance> getPredictiveMaintenance(String carId) async {
    final result = await EnhancedErrorHandler.executeWithErrorHandling<
        PredictiveMaintenance>(
      () async {
        return PerformanceService.measureAsync('get_predictive_maintenance',
            () async {
          final cacheKey = 'predictive_maintenance_$carId';

          // التحقق من التخزين المؤقت
          final cachedMaintenance =
              await _cache.get<Map<String, dynamic>>(cacheKey);
          if (cachedMaintenance != null) {
            return PredictiveMaintenance.fromMap(cachedMaintenance);
          }

          // محاكاة بيانات الصيانة التنبؤية
          final maintenance = _generateMockPredictiveMaintenance(carId);

          // حفظ في التخزين المؤقت
          await _cache.set(
            cacheKey,
            maintenance.toMap(),
            expiration: const Duration(hours: 1),
          );

          return maintenance;
        });
      },
      'جلب الصيانة التنبؤية',
    );
    return result ?? PredictiveMaintenance.empty(carId);
  }

  /// الحصول على إحصائيات الاستخدام
  Future<UsageStatistics> getUsageStatistics(
    String carId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final result =
        await EnhancedErrorHandler.executeWithErrorHandling<UsageStatistics>(
      () async {
        return PerformanceService.measureAsync('get_usage_statistics',
            () async {
          final start =
              startDate ?? DateTime.now().subtract(const Duration(days: 30));
          final end = endDate ?? DateTime.now();

          final cacheKey =
              'usage_statistics_${carId}_${start.millisecondsSinceEpoch}_${end.millisecondsSinceEpoch}';

          // التحقق من التخزين المؤقت
          final cachedStats = await _cache.get<Map<String, dynamic>>(cacheKey);
          if (cachedStats != null) {
            return UsageStatistics.fromMap(cachedStats);
          }

          // محاكاة إحصائيات الاستخدام
          final statistics = _generateMockUsageStatistics(carId, start, end);

          // حفظ في التخزين المؤقت
          await _cache.set(
            cacheKey,
            statistics.toMap(),
            expiration: const Duration(minutes: 30),
          );

          return statistics;
        });
      },
      'جلب إحصائيات الاستخدام',
    );
    return result ?? UsageStatistics.empty(carId);
  }

  /// تحديث إعدادات الجهاز
  Future<bool> updateDeviceSettings({
    required String deviceId,
    required Map<String, dynamic> settings,
  }) async {
    final result = await EnhancedErrorHandler.executeWithErrorHandling<bool>(
      () async {
        return PerformanceService.measureAsync('update_device_settings',
            () async {
          await _firestore.collection('iot_devices').doc(deviceId).update({
            'configuration': settings,
            'updatedAt': FieldValue.serverTimestamp(),
          });

          // إزالة من التخزين المؤقت
          await _cache.removePattern('iot_devices_');

          LoggingService.success('تم تحديث إعدادات الجهاز $deviceId');
          return true;
        });
      },
      'تحديث إعدادات الجهاز',
    );
    return result ?? false;
  }

  /// الحصول على تاريخ البيانات
  Future<List<IoTDataHistory>> getDeviceDataHistory({
    required String deviceId,
    required DateTime startDate,
    required DateTime endDate,
    String? dataType,
  }) async {
    final result = await EnhancedErrorHandler.executeWithErrorHandling<
        List<IoTDataHistory>>(
      () async {
        return PerformanceService.measureAsync('get_device_data_history',
            () async {
          // محاكاة تاريخ البيانات
          final history =
              _generateMockDataHistory(deviceId, startDate, endDate, dataType);
          return history;
        });
      },
      'جلب تاريخ البيانات',
    );
    return result ?? [];
  }

  // الطرق المساعدة
  void _startDeviceSimulation(
      String deviceId, StreamController<IoTDeviceData> controller) {
    _simulationTimers[deviceId] =
        Timer.periodic(const Duration(seconds: 5), (timer) {
      if (controller.isClosed) {
        timer.cancel();
        return;
      }

      final data = _generateMockDeviceData(deviceId);
      controller.add(data);
    });
  }

  IoTDeviceData _generateMockDeviceData(String deviceId) {
    final random = Random();

    return IoTDeviceData(
      deviceId: deviceId,
      timestamp: DateTime.now(),
      data: {
        'engineTemperature': 85 + random.nextDouble() * 20,
        'oilPressure': 30 + random.nextDouble() * 20,
        'fuelLevel': 20 + random.nextDouble() * 60,
        'batteryVoltage': 12.0 + random.nextDouble() * 2,
        'speed': random.nextDouble() * 120,
        'rpm': 800 + random.nextDouble() * 5000,
        'location': {
          'latitude': 24.7136 + (random.nextDouble() - 0.5) * 0.1,
          'longitude': 46.6753 + (random.nextDouble() - 0.5) * 0.1,
        },
      },
      status: IoTDeviceStatus.online,
      batteryLevel: 80 + random.nextInt(20),
      signalStrength: 70 + random.nextInt(30),
    );
  }

  SmartDiagnostics _generateMockDiagnostics(String carId) {
    final random = Random();

    final issues = [
      DiagnosticIssue(
        code: 'P0171',
        description: 'نظام الوقود ضعيف جداً (البنك 1)',
        severity: IssueSeverity.medium,
        category: IssueCategory.engine,
        recommendation: 'فحص مرشح الهواء وحساس الأكسجين',
        estimatedCost: 150 + random.nextDouble() * 300,
      ),
      DiagnosticIssue(
        code: 'B1001',
        description: 'انخفاض ضغط الإطارات',
        severity: IssueSeverity.low,
        category: IssueCategory.tires,
        recommendation: 'فحص ضغط الإطارات وإعادة ملئها',
        estimatedCost: 20 + random.nextDouble() * 50,
      ),
    ];

    return SmartDiagnostics(
      carId: carId,
      overallHealth: 85 + random.nextInt(10),
      lastScanDate:
          DateTime.now().subtract(Duration(hours: random.nextInt(24))),
      issues: issues,
      recommendations: [
        'تغيير زيت المحرك خلال 1000 كم',
        'فحص الفرامل خلال شهر',
        'تنظيف مرشح الهواء',
      ],
      nextMaintenanceDate:
          DateTime.now().add(Duration(days: 30 + random.nextInt(60))),
    );
  }

  PredictiveMaintenance _generateMockPredictiveMaintenance(String carId) {
    final random = Random();

    final predictions = [
      MaintenancePrediction(
        component: 'زيت المحرك',
        currentCondition: 75 + random.nextInt(20),
        predictedFailureDate:
            DateTime.now().add(Duration(days: 20 + random.nextInt(40))),
        confidence: 85 + random.nextInt(10),
        recommendedAction: 'تغيير الزيت والفلتر',
        estimatedCost: 80 + random.nextDouble() * 50,
        priority: MaintenancePriority.medium,
      ),
      MaintenancePrediction(
        component: 'بطارية السيارة',
        currentCondition: 60 + random.nextInt(30),
        predictedFailureDate:
            DateTime.now().add(Duration(days: 90 + random.nextInt(180))),
        confidence: 70 + random.nextInt(20),
        recommendedAction: 'فحص البطارية واستبدالها إذا لزم الأمر',
        estimatedCost: 200 + random.nextDouble() * 100,
        priority: MaintenancePriority.low,
      ),
    ];

    return PredictiveMaintenance(
      carId: carId,
      predictions: predictions,
      totalEstimatedCost:
          predictions.fold(0.0, (sum, p) => sum + p.estimatedCost),
      nextCriticalMaintenance: predictions
          .where((p) => p.priority == MaintenancePriority.high)
          .map((p) => p.predictedFailureDate)
          .fold<DateTime?>(
              null,
              (earliest, date) => earliest == null || date.isBefore(earliest)
                  ? date
                  : earliest),
      lastUpdated: DateTime.now(),
    );
  }

  UsageStatistics _generateMockUsageStatistics(
      String carId, DateTime start, DateTime end) {
    final random = Random();
    final days = end.difference(start).inDays;

    return UsageStatistics(
      carId: carId,
      period: DateRange(start: start, end: end),
      totalDistance: (days * 50) + random.nextDouble() * (days * 100),
      totalDrivingTime: Duration(hours: days * 2 + random.nextInt(days)),
      averageSpeed: 45 + random.nextDouble() * 30,
      fuelConsumption: (days * 8) + random.nextDouble() * (days * 5),
      fuelEfficiency: 8 + random.nextDouble() * 4,
      tripCount: days ~/ 2 + random.nextInt(days),
      harshBrakingEvents: random.nextInt(days ~/ 5),
      harshAccelerationEvents: random.nextInt(days ~/ 7),
      speedingEvents: random.nextInt(days ~/ 3),
      idleTime: Duration(hours: days ~/ 2 + random.nextInt(days ~/ 2)),
      carbonFootprint: ((days * 8) + random.nextDouble() * (days * 5)) * 2.3,
      lastUpdated: DateTime.now(),
    );
  }

  List<IoTDataHistory> _generateMockDataHistory(
    String deviceId,
    DateTime start,
    DateTime end,
    String? dataType,
  ) {
    final random = Random();
    final history = <IoTDataHistory>[];
    final duration = end.difference(start);
    final intervals = duration.inHours;

    for (int i = 0; i < intervals; i++) {
      final timestamp = start.add(Duration(hours: i));

      history.add(IoTDataHistory(
        deviceId: deviceId,
        timestamp: timestamp,
        dataType: dataType ?? 'engineTemperature',
        value: 80 + random.nextDouble() * 40,
        unit: dataType == 'speed' ? 'km/h' : '°C',
      ));
    }

    return history;
  }

  /// تنظيف الموارد
  void dispose() {
    for (final timer in _simulationTimers.values) {
      timer.cancel();
    }
    _simulationTimers.clear();

    for (final controller in _deviceStreams.values) {
      controller.close();
    }
    _deviceStreams.clear();
  }
}
