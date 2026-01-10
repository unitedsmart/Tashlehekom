import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../services/firebase_auth_service.dart';
import '../services/otp_service.dart';

/// مساعد تشخيص مشاكل OTP
class OTPDebugHelper {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseAuthService _authService = FirebaseAuthService();
  static final OTPService _otpService = OTPService();

  /// تشخيص شامل لمشاكل OTP
  static Future<Map<String, dynamic>> diagnoseOTPIssues(
      String phoneNumber) async {
    Map<String, dynamic> diagnosis = {
      'timestamp': DateTime.now().toIso8601String(),
      'phoneNumber': phoneNumber,
      'tests': {},
      'recommendations': [],
    };

    print('🔍 بدء تشخيص مشاكل OTP للرقم: $phoneNumber');

    // 1. فحص إعدادات Firebase
    diagnosis['tests']['firebase_config'] = await _testFirebaseConfig();

    // 2. فحص صحة رقم الهاتف
    diagnosis['tests']['phone_validation'] = _testPhoneValidation(phoneNumber);

    // 3. فحص حالة الشبكة
    diagnosis['tests']['network_status'] = await _testNetworkConnection();

    // 4. فحص أذونات SMS
    diagnosis['tests']['sms_permissions'] = await _testSMSPermissions();

    // 5. اختبار إرسال OTP عبر Firebase
    diagnosis['tests']['firebase_otp'] = await _testFirebaseOTP(phoneNumber);

    // 6. اختبار إرسال OTP عبر الخدمة المحلية
    diagnosis['tests']['local_otp'] = await _testLocalOTP(phoneNumber);

    // تحليل النتائج وإعطاء توصيات
    diagnosis['recommendations'] = _generateRecommendations(diagnosis['tests']);

    // طباعة التقرير
    _printDiagnosisReport(diagnosis);

    return diagnosis;
  }

  /// فحص إعدادات Firebase
  static Future<Map<String, dynamic>> _testFirebaseConfig() async {
    try {
      final app = Firebase.app();
      return {
        'status': 'success',
        'projectId': app.options.projectId,
        'apiKey': app.options.apiKey.substring(0, 10) + '...',
        'appId': app.options.appId,
      };
    } catch (e) {
      return {
        'status': 'error',
        'error': e.toString(),
      };
    }
  }

  /// فحص صحة رقم الهاتف
  static Map<String, dynamic> _testPhoneValidation(String phoneNumber) {
    try {
      bool isValid = _authService.isValidSaudiPhoneNumber(phoneNumber);
      String formatted = phoneNumber;

      // محاولة تنسيق الرقم
      if (phoneNumber.startsWith('05')) {
        formatted = '+966${phoneNumber.substring(1)}';
      } else if (phoneNumber.startsWith('5')) {
        formatted = '+966$phoneNumber';
      } else if (!phoneNumber.startsWith('+966')) {
        formatted = '+966$phoneNumber';
      }

      return {
        'status': isValid ? 'success' : 'warning',
        'original': phoneNumber,
        'formatted': formatted,
        'isValid': isValid,
      };
    } catch (e) {
      return {
        'status': 'error',
        'error': e.toString(),
      };
    }
  }

  /// فحص حالة الشبكة
  static Future<Map<String, dynamic>> _testNetworkConnection() async {
    try {
      // محاولة الاتصال بـ Firebase
      await _auth.fetchSignInMethodsForEmail('test@example.com');
      return {
        'status': 'success',
        'message': 'الاتصال بـ Firebase يعمل بشكل صحيح',
      };
    } catch (e) {
      if (e.toString().contains('network')) {
        return {
          'status': 'error',
          'error': 'مشكلة في الاتصال بالإنترنت',
          'details': e.toString(),
        };
      }
      return {
        'status': 'success',
        'message': 'الاتصال بـ Firebase يعمل (خطأ متوقع في الاختبار)',
      };
    }
  }

  /// فحص أذونات SMS
  static Future<Map<String, dynamic>> _testSMSPermissions() async {
    try {
      // هذا سيتم تنفيذه فقط على الأندرويد
      if (defaultTargetPlatform == TargetPlatform.android) {
        return {
          'status': 'info',
          'message': 'يجب فحص أذونات SMS يدوياً على الجهاز',
          'required_permissions': [
            'SEND_SMS',
            'READ_SMS',
            'RECEIVE_SMS',
            'READ_PHONE_STATE'
          ],
        };
      }
      return {
        'status': 'info',
        'message': 'فحص الأذونات غير مطلوب على هذه المنصة',
      };
    } catch (e) {
      return {
        'status': 'error',
        'error': e.toString(),
      };
    }
  }

  /// اختبار إرسال OTP عبر Firebase
  static Future<Map<String, dynamic>> _testFirebaseOTP(
      String phoneNumber) async {
    try {
      print('🧪 اختبار إرسال OTP عبر Firebase...');

      String verificationId = await _authService.sendOTP(phoneNumber);

      return {
        'status': 'success',
        'verificationId': verificationId.substring(0, 10) + '...',
        'message': 'تم إرسال OTP عبر Firebase بنجاح',
      };
    } catch (e) {
      return {
        'status': 'error',
        'error': e.toString(),
        'message': 'فشل في إرسال OTP عبر Firebase',
      };
    }
  }

  /// اختبار إرسال OTP عبر الخدمة المحلية
  static Future<Map<String, dynamic>> _testLocalOTP(String phoneNumber) async {
    try {
      print('🧪 اختبار إرسال OTP عبر الخدمة المحلية...');

      bool success = await _otpService.sendOTP(phoneNumber);

      return {
        'status': success ? 'success' : 'error',
        'message': success
            ? 'تم إرسال OTP عبر الخدمة المحلية'
            : 'فشل في إرسال OTP عبر الخدمة المحلية',
      };
    } catch (e) {
      return {
        'status': 'error',
        'error': e.toString(),
      };
    }
  }

  /// توليد التوصيات بناءً على نتائج الاختبارات
  static List<String> _generateRecommendations(Map<String, dynamic> tests) {
    List<String> recommendations = [];

    // فحص إعدادات Firebase
    if (tests['firebase_config']['status'] == 'error') {
      recommendations
          .add('❌ إعادة تكوين Firebase - تحقق من ملف google-services.json');
    }

    // فحص صحة رقم الهاتف
    if (tests['phone_validation']['status'] != 'success') {
      recommendations.add('⚠️ تحقق من صيغة رقم الهاتف - يجب أن يبدأ بـ +966');
    }

    // فحص الشبكة
    if (tests['network_status']['status'] == 'error') {
      recommendations.add('🌐 تحقق من اتصال الإنترنت');
    }

    // فحص Firebase OTP
    if (tests['firebase_otp']['status'] == 'error') {
      recommendations.add('🔥 تفعيل Phone Authentication في Firebase Console');
      recommendations.add('📱 إضافة SHA-256 fingerprint في Firebase Console');
      recommendations.add('🔑 التحقق من صحة API Keys');
    }

    // فحص OTP المحلي
    if (tests['local_otp']['status'] == 'error') {
      recommendations.add('📲 تحقق من أذونات SMS على الجهاز');
      recommendations.add('🔧 تحقق من إعدادات خدمات SMS الخارجية');
    }

    if (recommendations.isEmpty) {
      recommendations.add('✅ جميع الاختبارات نجحت - المشكلة قد تكون مؤقتة');
    }

    return recommendations;
  }

  /// طباعة تقرير التشخيص
  static void _printDiagnosisReport(Map<String, dynamic> diagnosis) {
    print('\n' + '=' * 50);
    print('📋 تقرير تشخيص مشاكل OTP');
    print('=' * 50);
    print('📞 رقم الهاتف: ${diagnosis['phoneNumber']}');
    print('⏰ وقت التشخيص: ${diagnosis['timestamp']}');
    print('\n🧪 نتائج الاختبارات:');

    diagnosis['tests'].forEach((testName, result) {
      String status = result['status'];
      String emoji = status == 'success'
          ? '✅'
          : status == 'warning'
              ? '⚠️'
              : status == 'error'
                  ? '❌'
                  : 'ℹ️';
      print('$emoji $testName: $status');
      if (result['message'] != null) {
        print('   📝 ${result['message']}');
      }
      if (result['error'] != null) {
        print('   🚨 ${result['error']}');
      }
    });

    print('\n💡 التوصيات:');
    for (String recommendation in diagnosis['recommendations']) {
      print('   $recommendation');
    }
    print('=' * 50 + '\n');
  }
}
