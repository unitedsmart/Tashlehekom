import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

/// خدمة SMS مخصصة لتطبيق تشليحكم
class CustomSMSService {
  static final CustomSMSService _instance = CustomSMSService._internal();
  factory CustomSMSService() => _instance;
  CustomSMSService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  static const platform = MethodChannel('com.tashlehekomv2/sms');

  /// إرسال OTP مع نص مخصص
  Future<String> sendCustomOTP(String phoneNumber) async {
    try {
      print('📤 بدء إرسال OTP مخصص للرقم: "$phoneNumber"');

      // تنسيق رقم الهاتف
      String formattedPhone = _formatPhoneNumber(phoneNumber);
      print('📱 رقم الهاتف المنسق: $formattedPhone');

      // تعيين اللغة العربية
      await _auth.setLanguageCode('ar');

      // إعداد Firebase Auth مع إعدادات مخصصة
      final Completer<String> completer = Completer<String>();

      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        forceResendingToken: null,
        verificationCompleted: (PhoneAuthCredential credential) async {
          print('✅ التحقق التلقائي مكتمل');
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          print('❌ فشل في إرسال OTP: ${e.message}');
          if (!completer.isCompleted) {
            completer.completeError(
                Exception('فشل في إرسال رمز التحقق: ${e.message}'));
          }
        },
        codeSent: (String verId, int? resendToken) async {
          print('📱 تم إرسال رمز OTP بنجاح. معرف التحقق: $verId');
          
          // محاولة إرسال SMS مخصص
          try {
            await _sendCustomSMS(phoneNumber, "سيصلك رمز التحقق قريباً");
          } catch (e) {
            print('⚠️ فشل في إرسال SMS مخصص: $e');
          }
          
          if (!completer.isCompleted) {
            completer.complete(verId);
          }
        },
        codeAutoRetrievalTimeout: (String verId) {
          print('⏰ انتهت مهلة الاستلام التلقائي. معرف التحقق: $verId');
          if (!completer.isCompleted) {
            completer.complete(verId);
          }
        },
        timeout: const Duration(seconds: 60),
      );

      return await completer.future;
    } catch (e) {
      print('❌ خطأ في إرسال OTP مخصص: $e');
      rethrow;
    }
  }

  /// إرسال SMS مخصص
  Future<void> _sendCustomSMS(String phoneNumber, String message) async {
    try {
      final customMessage = 'رمز التحقق الخاص بك في تطبيق تشليحكم هو: [سيصل قريباً]\nصالح لمدة 5 دقائق';
      
      await platform.invokeMethod('sendSMS', {
        'phoneNumber': phoneNumber,
        'message': customMessage,
      });
      
      print('✅ تم إرسال SMS مخصص بنجاح');
    } catch (e) {
      print('❌ فشل في إرسال SMS مخصص: $e');
      throw e;
    }
  }

  /// تنسيق رقم الهاتف للمملكة العربية السعودية
  String _formatPhoneNumber(String phoneNumber) {
    // إزالة المسافات والرموز الخاصة
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    // إذا كان الرقم يبدأ بـ 05، استبدله بـ +9665
    if (cleanNumber.startsWith('05')) {
      return '+9665${cleanNumber.substring(2)}';
    }
    
    // إذا كان الرقم يبدأ بـ 5، أضف +966
    if (cleanNumber.startsWith('5') && cleanNumber.length == 9) {
      return '+966$cleanNumber';
    }
    
    // إذا كان الرقم يبدأ بـ +966، أرجعه كما هو
    if (cleanNumber.startsWith('+966')) {
      return cleanNumber;
    }
    
    // إذا كان الرقم يبدأ بـ 966، أضف +
    if (cleanNumber.startsWith('966')) {
      return '+$cleanNumber';
    }
    
    // افتراضي: أضف +966
    return '+966$cleanNumber';
  }

  /// التحقق من صحة رقم الهاتف السعودي
  bool isValidSaudiPhoneNumber(String phoneNumber) {
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    
    // الأنماط المقبولة للأرقام السعودية
    List<RegExp> patterns = [
      RegExp(r'^05[0-9]{8}$'),           // 05xxxxxxxx
      RegExp(r'^5[0-9]{8}$'),            // 5xxxxxxxx
      RegExp(r'^\+9665[0-9]{8}$'),       // +9665xxxxxxxx
      RegExp(r'^9665[0-9]{8}$'),         // 9665xxxxxxxx
    ];
    
    return patterns.any((pattern) => pattern.hasMatch(cleanNumber));
  }
}
