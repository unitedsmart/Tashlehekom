import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:tashlehekomv2/services/logging_service.dart';
import 'package:tashlehekomv2/services/enhanced_error_handler.dart';
import 'package:tashlehekomv2/services/performance_service.dart';

/// خدمة الواقع الافتراضي
class VRService {
  static final VRService _instance = VRService._internal();
  factory VRService() => _instance;
  VRService._internal();

  static const MethodChannel _channel = MethodChannel('tashlehekomv2/vr');

  bool _isVRSupported = false;
  bool _isVRActive = false;
  VRSession? _currentSession;

  /// التحقق من دعم الواقع الافتراضي
  Future<bool> checkVRSupport() async {
    final result = await EnhancedErrorHandler.executeWithErrorHandling<bool>(
      () async {
        return PerformanceService.measureAsync('vr_support_check', () async {
          try {
            final result = await _channel.invokeMethod('checkVRSupport');
            _isVRSupported = result as bool;

            LoggingService.info('تم فحص دعم الواقع الافتراضي: $_isVRSupported');
            return _isVRSupported;
          } catch (e) {
            // في حالة عدم توفر المنصة، نعتبر أن VR غير مدعوم
            LoggingService.warning('الواقع الافتراضي غير مدعوم على هذا الجهاز');
            _isVRSupported = false;
            return false;
          }
        });
      },
      'فحص دعم الواقع الافتراضي',
    );
    return result ?? false;
  }

  /// بدء جلسة الواقع الافتراضي
  Future<VRSession?> startVRSession({
    required String carId,
    required VRExperienceType experienceType,
    Map<String, dynamic>? options,
  }) async {
    return EnhancedErrorHandler.executeWithErrorHandling(
      () async {
        return PerformanceService.measureAsync('vr_session_start', () async {
          if (!_isVRSupported) {
            throw Exception('الواقع الافتراضي غير مدعوم على هذا الجهاز');
          }

          if (_isVRActive) {
            throw Exception('جلسة واقع افتراضي نشطة بالفعل');
          }

          final sessionId = _generateSessionId();
          final session = VRSession(
            id: sessionId,
            carId: carId,
            experienceType: experienceType,
            startTime: DateTime.now(),
            options: options ?? {},
          );

          try {
            await _channel.invokeMethod('startVRSession', {
              'sessionId': sessionId,
              'carId': carId,
              'experienceType': experienceType.name,
              'options': options ?? {},
            });

            _currentSession = session;
            _isVRActive = true;

            LoggingService.success('تم بدء جلسة الواقع الافتراضي: $sessionId');
            return session;
          } catch (e) {
            LoggingService.error('فشل في بدء جلسة الواقع الافتراضي', error: e);
            rethrow;
          }
        });
      },
      'بدء جلسة الواقع الافتراضي',
    );
  }

  /// إنهاء جلسة الواقع الافتراضي
  Future<void> endVRSession() async {
    return EnhancedErrorHandler.executeWithErrorHandling(
      () async {
        return PerformanceService.measureAsync('vr_session_end', () async {
          if (!_isVRActive || _currentSession == null) {
            LoggingService.warning('لا توجد جلسة واقع افتراضي نشطة');
            return;
          }

          try {
            await _channel.invokeMethod('endVRSession', {
              'sessionId': _currentSession!.id,
            });

            _currentSession!.endTime = DateTime.now();
            _isVRActive = false;

            LoggingService.success(
                'تم إنهاء جلسة الواقع الافتراضي: ${_currentSession!.id}');
            _currentSession = null;
          } catch (e) {
            LoggingService.error('فشل في إنهاء جلسة الواقع الافتراضي',
                error: e);
            rethrow;
          }
        });
      },
      'إنهاء جلسة الواقع الافتراضي',
    );
  }

  /// تحديث موضع المستخدم في الواقع الافتراضي
  Future<void> updateVRPosition({
    required double x,
    required double y,
    required double z,
    required double rotationX,
    required double rotationY,
    required double rotationZ,
  }) async {
    if (!_isVRActive || _currentSession == null) return;

    try {
      await _channel.invokeMethod('updateVRPosition', {
        'sessionId': _currentSession!.id,
        'x': x,
        'y': y,
        'z': z,
        'rotationX': rotationX,
        'rotationY': rotationY,
        'rotationZ': rotationZ,
      });
    } catch (e) {
      LoggingService.error('فشل في تحديث موضع الواقع الافتراضي', error: e);
    }
  }

  /// التفاعل مع عنصر في الواقع الافتراضي
  Future<void> interactWithVRElement(String elementId) async {
    if (!_isVRActive || _currentSession == null) return;

    return EnhancedErrorHandler.executeWithErrorHandling(
      () async {
        await _channel.invokeMethod('interactWithVRElement', {
          'sessionId': _currentSession!.id,
          'elementId': elementId,
        });

        LoggingService.info('تفاعل مع عنصر الواقع الافتراضي: $elementId');
      },
      'التفاعل مع عنصر الواقع الافتراضي',
    );
  }

  /// الحصول على معلومات الجلسة الحالية
  VRSession? get currentSession => _currentSession;

  /// التحقق من حالة الواقع الافتراضي
  bool get isVRSupported => _isVRSupported;
  bool get isVRActive => _isVRActive;

  /// توليد معرف جلسة فريد
  String _generateSessionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(10000);
    return 'vr_session_${timestamp}_$random';
  }

  /// محاكاة تجربة الواقع الافتراضي (للاختبار)
  Future<VRSession> simulateVRExperience({
    required String carId,
    required VRExperienceType experienceType,
    Duration duration = const Duration(minutes: 5),
  }) async {
    LoggingService.info('بدء محاكاة تجربة الواقع الافتراضي');

    final session = VRSession(
      id: _generateSessionId(),
      carId: carId,
      experienceType: experienceType,
      startTime: DateTime.now(),
      options: {'simulated': true},
    );

    _currentSession = session;
    _isVRActive = true;

    // محاكاة التجربة
    Timer(duration, () {
      session.endTime = DateTime.now();
      _isVRActive = false;
      _currentSession = null;
      LoggingService.success('انتهت محاكاة تجربة الواقع الافتراضي');
    });

    return session;
  }

  /// الحصول على إحصائيات الجلسة
  VRSessionStats? getSessionStats() {
    if (_currentSession == null) return null;

    final duration = _currentSession!.endTime != null
        ? _currentSession!.endTime!.difference(_currentSession!.startTime)
        : DateTime.now().difference(_currentSession!.startTime);

    return VRSessionStats(
      sessionId: _currentSession!.id,
      duration: duration,
      experienceType: _currentSession!.experienceType,
      interactionCount: _currentSession!.interactions.length,
      averageFrameRate: 60.0, // قيمة افتراضية
      qualityScore: 0.85, // قيمة افتراضية
    );
  }
}

/// أنواع تجارب الواقع الافتراضي
enum VRExperienceType {
  carTour('جولة السيارة'),
  virtualShowroom('المعرض الافتراضي'),
  drivingExperience('تجربة القيادة'),
  interiorExploration('استكشاف الداخلية'),
  engineInspection('فحص المحرك');

  const VRExperienceType(this.displayName);
  final String displayName;
}

/// جلسة الواقع الافتراضي
class VRSession {
  final String id;
  final String carId;
  final VRExperienceType experienceType;
  final DateTime startTime;
  final Map<String, dynamic> options;
  final List<VRInteraction> interactions = [];

  DateTime? endTime;

  VRSession({
    required this.id,
    required this.carId,
    required this.experienceType,
    required this.startTime,
    required this.options,
  });

  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  void addInteraction(VRInteraction interaction) {
    interactions.add(interaction);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'carId': carId,
      'experienceType': experienceType.name,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'options': options,
      'interactions': interactions.map((i) => i.toMap()).toList(),
    };
  }
}

/// تفاعل في الواقع الافتراضي
class VRInteraction {
  final String elementId;
  final String action;
  final DateTime timestamp;
  final Map<String, dynamic> data;

  VRInteraction({
    required this.elementId,
    required this.action,
    required this.timestamp,
    this.data = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'elementId': elementId,
      'action': action,
      'timestamp': timestamp.toIso8601String(),
      'data': data,
    };
  }
}

/// إحصائيات جلسة الواقع الافتراضي
class VRSessionStats {
  final String sessionId;
  final Duration duration;
  final VRExperienceType experienceType;
  final int interactionCount;
  final double averageFrameRate;
  final double qualityScore;

  VRSessionStats({
    required this.sessionId,
    required this.duration,
    required this.experienceType,
    required this.interactionCount,
    required this.averageFrameRate,
    required this.qualityScore,
  });

  Map<String, dynamic> toMap() {
    return {
      'sessionId': sessionId,
      'duration': duration.inSeconds,
      'experienceType': experienceType.name,
      'interactionCount': interactionCount,
      'averageFrameRate': averageFrameRate,
      'qualityScore': qualityScore,
    };
  }
}
