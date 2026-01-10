import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class OTPService {
  static final OTPService _instance = OTPService._internal();
  factory OTPService() => _instance;
  OTPService._internal();

  // تخزين مؤقت لرموز OTP (في التطبيق الحقيقي يجب استخدام قاعدة بيانات آمنة)
  final Map<String, OTPData> _otpStorage = {};

  // توليد رمز OTP عشوائي
  String _generateOTP() {
    // توليد رمز OTP عشوائي من 4 أرقام (1000-9999)
    final random = Random();
    final otpCode = (1000 + random.nextInt(9000)).toString();
    print('🎲 تم توليد رمز OTP عشوائي: $otpCode');
    return otpCode;
  }

  // إرسال OTP عبر SMS (محاكاة - في التطبيق الحقيقي استخدم خدمة SMS)
  Future<bool> sendOTP(String phoneNumber) async {
    try {
      print('📤 بدء إرسال OTP للرقم: "$phoneNumber"');

      // إزالة أي OTP قديم لضمان توليد رمز جديد
      _otpStorage.remove(phoneNumber);
      print('🗑️ تم مسح OTP القديم إن وجد');

      final otp = _generateOTP();
      print('🔢 تم توليد الرمز: "$otp"');
      final expiryTime = DateTime.now().add(const Duration(minutes: 5));
      print('⏰ وقت انتهاء الصلاحية: $expiryTime');

      // حفظ OTP مؤقتاً
      _otpStorage[phoneNumber] = OTPData(
        code: otp,
        expiryTime: expiryTime,
        attempts: 0,
      );
      print('💾 تم حفظ OTP في التخزين المؤقت');

      // إرسال OTP عبر SMS حقيقي
      bool smsSent = await _sendRealSMS(phoneNumber, otp);

      if (smsSent) {
        print('📱 OTP sent successfully to $phoneNumber: $otp');
      } else {
        // في حالة فشل الإرسال، نعرض الرمز للاختبار
        print('📱 SMS failed, OTP for testing $phoneNumber: $otp');
      }

      return true;
    } catch (e) {
      print('Error sending OTP: $e');
      return false;
    }
  }

  // التحقق من صحة OTP
  Future<bool> verifyOTP(String phoneNumber, String enteredOTP) async {
    try {
      print('🔍 OTP Service: بدء التحقق');
      print('📱 رقم الهاتف: "$phoneNumber"');
      print('🔢 الرمز المدخل: "$enteredOTP"');

      final otpData = _otpStorage[phoneNumber];
      print(
          '💾 بيانات OTP المحفوظة: ${otpData != null ? 'موجودة' : 'غير موجودة'}');

      if (otpData == null) {
        print('❌ لا يوجد OTP مرسل لهذا الرقم');
        return false; // لا يوجد OTP مرسل لهذا الرقم
      }

      print('🔢 الرمز المحفوظ: "${otpData.code}"');
      print('⏰ وقت انتهاء الصلاحية: ${otpData.expiryTime}');
      print('🔄 عدد المحاولات: ${otpData.attempts}');

      if (DateTime.now().isAfter(otpData.expiryTime)) {
        print('❌ OTP منتهي الصلاحية');
        _otpStorage.remove(phoneNumber); // إزالة OTP منتهي الصلاحية
        return false; // OTP منتهي الصلاحية
      }

      if (otpData.attempts >= 3) {
        print('❌ تم تجاوز عدد المحاولات المسموحة');
        _otpStorage.remove(phoneNumber); // إزالة OTP بعد 3 محاولات فاشلة
        return false; // تم تجاوز عدد المحاولات المسموحة
      }

      if (otpData.code == enteredOTP) {
        print('✅ OTP صحيح!');
        _otpStorage.remove(phoneNumber); // إزالة OTP بعد التحقق الناجح
        return true; // OTP صحيح
      } else {
        print(
            '❌ OTP خاطئ - المحفوظ: "${otpData.code}" vs المدخل: "$enteredOTP"');
        otpData.attempts++; // زيادة عدد المحاولات
        return false; // OTP خاطئ
      }
    } catch (e) {
      print('Error verifying OTP: $e');
      return false;
    }
  }

  // إرسال SMS عبر خدمة خارجية (مثال)
  Future<bool> _sendSMSViaProvider(String phoneNumber, String otp) async {
    try {
      // مثال لاستخدام خدمة SMS (يجب تخصيصها حسب مزود الخدمة)
      final response = await http.post(
        Uri.parse('https://api.sms-provider.com/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_API_KEY', // ضع مفتاح API الخاص بك
        },
        body: jsonEncode({
          'to': phoneNumber,
          'message':
              'رمز التحقق الخاص بك في تطبيق تشليحكم: $otp\nصالح لمدة 5 دقائق.',
          'from': 'Tashlehekomv2',
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error sending SMS: $e');
      return false;
    }
  }

  // إعادة إرسال OTP
  Future<bool> resendOTP(String phoneNumber) async {
    // إزالة OTP القديم
    _otpStorage.remove(phoneNumber);
    // إرسال OTP جديد
    return await sendOTP(phoneNumber);
  }

  // التحقق من وجود OTP صالح
  bool hasValidOTP(String phoneNumber) {
    final otpData = _otpStorage[phoneNumber];
    if (otpData == null) return false;
    return DateTime.now().isBefore(otpData.expiryTime);
  }

  // الحصول على الوقت المتبقي لانتهاء صلاحية OTP
  Duration? getRemainingTime(String phoneNumber) {
    final otpData = _otpStorage[phoneNumber];
    if (otpData == null) return null;

    final remaining = otpData.expiryTime.difference(DateTime.now());
    return remaining.isNegative ? null : remaining;
  }

  // إرسال SMS حقيقي عبر خدمات متعددة
  Future<bool> _sendRealSMS(String phoneNumber, String otp) async {
    try {
      // الطريقة الأولى: استخدام Telephony (للأندرويد فقط)
      if (await _sendViaTelephony(phoneNumber, otp)) {
        return true;
      }

      // الطريقة الثانية: استخدام خدمة SMS خارجية
      if (await _sendViaExternalService(phoneNumber, otp)) {
        return true;
      }

      // الطريقة الثالثة: استخدام خدمة أخرى كبديل
      return await _sendViaBackupService(phoneNumber, otp);
    } catch (e) {
      print('Error in _sendRealSMS: $e');
      return false;
    }
  }

  // إرسال عبر Platform Channel (الأندرويد فقط)
  Future<bool> _sendViaTelephony(String phoneNumber, String otp) async {
    try {
      // التحقق من أذونات SMS
      final smsPermission = await Permission.sms.request();

      if (smsPermission.isGranted) {
        const platform = MethodChannel('com.tashlehekomv2/sms');

        final message =
            'رمز التحقق الخاص بك في تطبيق تشليحكم هو: $otp\nصالح لمدة 5 دقائق';

        final result = await platform.invokeMethod('sendSMS', {
          'phoneNumber': phoneNumber,
          'message': message,
        });

        return result == true;
      }

      return false;
    } catch (e) {
      print('Platform SMS failed: $e');
      return false;
    }
  }

  // إرسال عبر خدمة خارجية (مثل Twilio)
  Future<bool> _sendViaExternalService(String phoneNumber, String otp) async {
    try {
      // يمكن استخدام خدمات مثل Twilio, AWS SNS, أو خدمات SMS محلية
      final response = await http.post(
        Uri.parse(
            'https://api.twilio.com/2010-04-01/Accounts/YOUR_ACCOUNT_SID/Messages.json'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Basic YOUR_AUTH_TOKEN', // Base64 encoded
        },
        body: {
          'From': '+1234567890', // رقم Twilio
          'To': phoneNumber,
          'Body':
              'رمز التحقق الخاص بك في تطبيق تشليحكم هو: $otp\nصالح لمدة 5 دقائق',
        },
      );

      return response.statusCode == 201;
    } catch (e) {
      print('External SMS service failed: $e');
      return false;
    }
  }

  // خدمة احتياطية (يمكن استخدام خدمة SMS محلية سعودية)
  Future<bool> _sendViaBackupService(String phoneNumber, String otp) async {
    try {
      // مثال لخدمة SMS محلية سعودية
      final response = await http.post(
        Uri.parse('https://www.msegat.com/gw/sendsms.php'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'userName': 'YOUR_USERNAME',
          'apiKey': 'YOUR_API_KEY',
          'numbers': phoneNumber,
          'userSender': 'TASHLEHEKOMV2',
          'msg': 'رمز التحقق: $otp - تطبيق تشليحكم',
        },
      );

      return response.statusCode == 200 && response.body.contains('1');
    } catch (e) {
      print('Backup SMS service failed: $e');
      return false;
    }
  }
}

// فئة لتخزين بيانات OTP
class OTPData {
  final String code;
  final DateTime expiryTime;
  int attempts;

  OTPData({
    required this.code,
    required this.expiryTime,
    this.attempts = 0,
  });
}
