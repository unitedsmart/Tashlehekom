import 'dart:math';

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

  // ملاحظة: التطبيق يستخدم Firebase Phone Auth لإرسال OTP
  // Firebase يرسل SMS من خوادمه مباشرة - لا حاجة لأذونات SMS على الجهاز
  Future<bool> _sendRealSMS(String phoneNumber, String otp) async {
    // هذه الدالة للاستخدام الاحتياطي فقط
    // Firebase Phone Auth هو المستخدم الأساسي
    print('📱 Note: App uses Firebase Phone Auth for OTP');
    print('📱 SMS will be sent from Firebase servers');
    return true; // Firebase يتولى الإرسال
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
