import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'firebase_firestore_service.dart';

/// خدمة المصادقة باستخدام Firebase Auth
class FirebaseAuthService {
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();
  factory FirebaseAuthService() => _instance;
  FirebaseAuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestoreService _firestoreService = FirebaseFirestoreService();

  /// الحصول على المستخدم الحالي
  User? get currentUser => _auth.currentUser;

  /// تدفق حالة المصادقة
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// إرسال رمز OTP إلى رقم الهاتف مع معالجة متقدمة للحظر
  Future<String> sendOTP(String phoneNumber) async {
    try {
      print('📤 بدء إرسال OTP للرقم: "$phoneNumber"');

      // تنسيق رقم الهاتف للمملكة العربية السعودية
      String formattedPhone = _formatPhoneNumber(phoneNumber);
      print('📱 رقم الهاتف المنسق: $formattedPhone');

      // تعيين اللغة العربية لـ Firebase Auth
      _auth.setLanguageCode('ar');

      // محاولة إعادة تعيين Firebase Auth للتخلص من الحظر
      try {
        await _auth.signOut();
        print('🔄 تم تسجيل الخروج من Firebase Auth');
      } catch (e) {
        print('⚠️ تحذير: فشل في تسجيل الخروج: $e');
      }

      print('🚀 إرسال SMS عبر Firebase للرقم: $formattedPhone');

      // استخدام Completer للانتظار حتى يتم استلام verificationId
      Completer<String> completer = Completer<String>();

      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          print('✅ التحقق التلقائي مكتمل');
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          print('❌ فشل في إرسال OTP: ${e.message}');
          print('❌ كود الخطأ: ${e.code}');

          // معالجة خاصة لخطأ الحظر
          if (e.code == 'too-many-requests' ||
              e.message?.contains('blocked') == true ||
              e.message?.contains('unusual activity') == true ||
              e.message?.contains('quota') == true) {
            print('🚫 تم اكتشاف حظر Firebase - محاولة حل بديل');
            if (!completer.isCompleted) {
              completer.completeError(Exception(
                  'تم حظر إرسال الرسائل مؤقتاً بسبب محاولات متكررة.\n\nالحلول:\n• انتظر 15-30 دقيقة ثم حاول مرة أخرى\n• استخدم شبكة إنترنت مختلفة\n• جرب من جهاز آخر\n• تواصل مع الدعم الفني'));
            }
          } else if (e.code == 'invalid-phone-number') {
            if (!completer.isCompleted) {
              completer.completeError(Exception(
                  'رقم الهاتف غير صحيح. تأكد من إدخال رقم سعودي صحيح'));
            }
          } else if (e.code == 'network-request-failed') {
            if (!completer.isCompleted) {
              completer.completeError(Exception(
                  'مشكلة في الاتصال بالإنترنت. تحقق من الاتصال وحاول مرة أخرى'));
            }
          } else if (e.code == 'internal-error' ||
              e.message?.contains('Error code-39') == true) {
            if (!completer.isCompleted) {
              completer.completeError(Exception(
                  'خطأ داخلي في الخدمة. يرجى:\n• المحاولة مرة أخرى بعد دقائق\n• استخدام "دخول تجريبي" أسفل الشاشة\n• التواصل مع الدعم الفني'));
            }
          } else {
            if (!completer.isCompleted) {
              completer.completeError(Exception(
                  'فشل في إرسال رمز التحقق: ${e.message ?? 'خطأ غير معروف'}\n\nجرب "دخول تجريبي" أسفل الشاشة'));
            }
          }
        },
        codeSent: (String verId, int? resendToken) {
          print('📱 تم إرسال رمز OTP بنجاح. معرف التحقق: $verId');
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
        timeout: const Duration(seconds: 60), // تقليل المهلة لتجنب الحظر
      );

      // انتظار الحصول على verificationId
      String verificationId = await completer.future;

      print('✅ تم إرسال OTP بنجاح. معرف التحقق: $verificationId');
      return verificationId;
    } catch (e) {
      print('❌ خطأ في إرسال OTP: $e');
      rethrow;
    }
  }

  /// التحقق من رمز OTP وتسجيل الدخول
  Future<UserModel?> verifyOTP(String verificationId, String otp) async {
    try {
      print('🔍 بدء التحقق من OTP: $otp');
      print('🚀 التحقق من OTP عبر Firebase');

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      // استخدام Completer للانتظار حتى يتم تسجيل الدخول
      Completer<UserModel?> completer = Completer<UserModel?>();

      // الاستماع لتغييرات حالة المصادقة
      StreamSubscription? authSubscription;

      authSubscription = _auth.authStateChanges().listen((User? firebaseUser) {
        if (firebaseUser != null && !completer.isCompleted) {
          print('✅ تم التحقق من OTP بنجاح عبر authStateChanges');
          print('🔍 معرف المستخدم: ${firebaseUser.uid}');
          print('🔍 رقم الهاتف: ${firebaseUser.phoneNumber}');

          // تحديد نوع المستخدم بناءً على رقم الهاتف
          UserType userType = UserType.user;
          bool isApproved = false;
          String username = 'مستخدم جديد';
          String name = 'مستخدم جديد';

          // الأرقام الإدارية
          if (firebaseUser.phoneNumber == '+966508423246') {
            userType = UserType.superAdmin;
            isApproved = true;
            username = 'المدير العام';
            name = 'المدير العام';
          } else if (firebaseUser.phoneNumber == '+966583342520') {
            userType = UserType.admin;
            isApproved = true;
            username = 'مدير النظام';
            name = 'مدير النظام';
          }

          // إنشاء مستخدم محلي مباشرة
          UserModel user = UserModel(
            id: firebaseUser.uid,
            username: username,
            name: name,
            phoneNumber: firebaseUser.phoneNumber!,
            userType: userType,
            createdAt: DateTime.now(),
            email: firebaseUser.email ?? '',
            isActive: true,
            isApproved: isApproved,
            updatedAt: DateTime.now(),
          );

          print('✅ تم إنشاء مستخدم محلي بنجاح');
          print('🔍 بيانات المستخدم: ${user.name} - ${user.phoneNumber}');

          authSubscription?.cancel();
          completer.complete(user);
        }
      });

      // محاولة تسجيل الدخول (تجاهل النتيجة المباشرة تماماً)
      print('🔄 محاولة تسجيل الدخول...');
      // تشغيل signInWithCredential في background وتجاهل النتيجة تماماً
      _auth.signInWithCredential(credential).then((_) {
        print('🔄 تم تسجيل الدخول بنجاح');
      }).catchError((error) {
        print('⚠️ خطأ في signInWithCredential (سيتم تجاهله): $error');
        // تجاهل الخطأ تماماً - authStateChanges سيتولى الأمر
      });
      print('🔄 تم إرسال طلب تسجيل الدخول');

      // انتظار النتيجة لمدة 10 ثوان
      return await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          authSubscription?.cancel();
          print('❌ انتهت مهلة انتظار تسجيل الدخول');
          return null;
        },
      );
    } catch (e) {
      print('❌ خطأ في التحقق من OTP: $e');
      rethrow;
    }
  }

  /// تسجيل الخروج
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      print('✅ تم تسجيل الخروج بنجاح');
    } catch (e) {
      print('❌ خطأ في تسجيل الخروج: $e');
      rethrow;
    }
  }

  /// حذف الحساب
  Future<void> deleteAccount() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // حذف بيانات المستخدم من Firestore
        await _firestoreService.deleteUser(user.uid);

        // حذف الحساب من Firebase Auth
        await user.delete();
        print('✅ تم حذف الحساب بنجاح');
      }
    } catch (e) {
      print('❌ خطأ في حذف الحساب: $e');
      rethrow;
    }
  }

  /// تنسيق رقم الهاتف للمملكة العربية السعودية
  String _formatPhoneNumber(String phoneNumber) {
    // إزالة أي مسافات أو رموز
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    // إذا كان الرقم يبدأ بـ 05، استبداله بـ +9665
    if (cleaned.startsWith('05')) {
      return '+966${cleaned.substring(1)}';
    }

    // إذا كان الرقم يبدأ بـ 5، إضافة +966
    if (cleaned.startsWith('5') && cleaned.length == 9) {
      return '+966$cleaned';
    }

    // إذا كان الرقم يبدأ بـ 966، إضافة +
    if (cleaned.startsWith('966')) {
      return '+$cleaned';
    }

    // إذا كان الرقم يبدأ بـ +966، إرجاعه كما هو
    if (phoneNumber.startsWith('+966')) {
      return phoneNumber;
    }

    // افتراضي: إضافة +966
    return '+966$cleaned';
  }

  /// التحقق من صحة رقم الهاتف السعودي
  bool isValidSaudiPhoneNumber(String phoneNumber) {
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    // التحقق من الأنماط المختلفة لأرقام الهواتف السعودية
    return cleaned.startsWith('05') && cleaned.length == 10 ||
        cleaned.startsWith('5') && cleaned.length == 9 ||
        cleaned.startsWith('9665') && cleaned.length == 13 ||
        phoneNumber.startsWith('+9665') && phoneNumber.length == 14;
  }
}
