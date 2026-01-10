import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// خدمة إدارة الأخطاء والاستثناءات
class ErrorHandlingService {
  static final ErrorHandlingService _instance = ErrorHandlingService._internal();
  factory ErrorHandlingService() => _instance;
  ErrorHandlingService._internal();

  /// معالجة أخطاء Firebase Auth
  String handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'لم يتم العثور على المستخدم';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة';
      case 'email-already-in-use':
        return 'البريد الإلكتروني مستخدم بالفعل';
      case 'weak-password':
        return 'كلمة المرور ضعيفة جداً';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صحيح';
      case 'user-disabled':
        return 'تم تعطيل هذا الحساب';
      case 'too-many-requests':
        return 'تم تجاوز عدد المحاولات المسموح. حاول لاحقاً';
      case 'operation-not-allowed':
        return 'العملية غير مسموحة';
      case 'invalid-verification-code':
        return 'رمز التحقق غير صحيح';
      case 'invalid-verification-id':
        return 'معرف التحقق غير صحيح';
      case 'session-expired':
        return 'انتهت صلاحية الجلسة';
      case 'quota-exceeded':
        return 'تم تجاوز الحد المسموح';
      case 'invalid-phone-number':
        return 'رقم الهاتف غير صحيح';
      case 'missing-phone-number':
        return 'رقم الهاتف مطلوب';
      case 'credential-already-in-use':
        return 'بيانات الاعتماد مستخدمة بالفعل';
      case 'invalid-credential':
        return 'بيانات الاعتماد غير صحيحة';
      case 'requires-recent-login':
        return 'يتطلب تسجيل دخول حديث';
      default:
        return 'خطأ في المصادقة: ${e.message ?? 'خطأ غير معروف'}';
    }
  }

  /// معالجة أخطاء Firestore
  String handleFirestoreError(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'ليس لديك صلاحية للوصول لهذه البيانات';
      case 'unavailable':
        return 'الخدمة غير متاحة حالياً. حاول لاحقاً';
      case 'deadline-exceeded':
        return 'انتهت مهلة الاتصال. تحقق من الإنترنت';
      case 'resource-exhausted':
        return 'تم تجاوز الحد المسموح للاستخدام';
      case 'failed-precondition':
        return 'فشل في تنفيذ العملية';
      case 'aborted':
        return 'تم إلغاء العملية';
      case 'out-of-range':
        return 'البيانات خارج النطاق المسموح';
      case 'unimplemented':
        return 'العملية غير مدعومة';
      case 'internal':
        return 'خطأ داخلي في الخادم';
      case 'data-loss':
        return 'فقدان في البيانات';
      case 'unauthenticated':
        return 'يجب تسجيل الدخول أولاً';
      case 'invalid-argument':
        return 'البيانات المدخلة غير صحيحة';
      case 'not-found':
        return 'البيانات المطلوبة غير موجودة';
      case 'already-exists':
        return 'البيانات موجودة بالفعل';
      case 'cancelled':
        return 'تم إلغاء العملية';
      default:
        return 'خطأ في قاعدة البيانات: ${e.message ?? 'خطأ غير معروف'}';
    }
  }

  /// معالجة أخطاء Firebase Storage
  String handleStorageError(FirebaseException e) {
    switch (e.code) {
      case 'storage/object-not-found':
        return 'الملف غير موجود';
      case 'storage/bucket-not-found':
        return 'مساحة التخزين غير موجودة';
      case 'storage/project-not-found':
        return 'المشروع غير موجود';
      case 'storage/quota-exceeded':
        return 'تم تجاوز مساحة التخزين المسموحة';
      case 'storage/unauthenticated':
        return 'يجب تسجيل الدخول لرفع الملفات';
      case 'storage/unauthorized':
        return 'ليس لديك صلاحية لرفع الملفات';
      case 'storage/retry-limit-exceeded':
        return 'تم تجاوز عدد المحاولات. حاول لاحقاً';
      case 'storage/invalid-checksum':
        return 'الملف تالف أو غير صحيح';
      case 'storage/canceled':
        return 'تم إلغاء رفع الملف';
      case 'storage/invalid-event-name':
        return 'اسم الحدث غير صحيح';
      case 'storage/invalid-url':
        return 'رابط الملف غير صحيح';
      case 'storage/invalid-argument':
        return 'معطيات الملف غير صحيحة';
      case 'storage/no-default-bucket':
        return 'لا توجد مساحة تخزين افتراضية';
      case 'storage/cannot-slice-blob':
        return 'لا يمكن تقسيم الملف';
      case 'storage/server-file-wrong-size':
        return 'حجم الملف غير متطابق';
      default:
        return 'خطأ في رفع الملف: ${e.message ?? 'خطأ غير معروف'}';
    }
  }

  /// معالجة أخطاء الشبكة
  String handleNetworkError(Exception e) {
    if (e is SocketException) {
      return 'لا يوجد اتصال بالإنترنت';
    } else if (e is TimeoutException) {
      return 'انتهت مهلة الاتصال';
    } else if (e is HttpException) {
      return 'خطأ في الخادم';
    } else {
      return 'خطأ في الشبكة: ${e.toString()}';
    }
  }

  /// معالجة الأخطاء العامة
  String handleGenericError(dynamic error) {
    if (error is FirebaseAuthException) {
      return handleAuthError(error);
    } else if (error is FirebaseException) {
      // تحديد نوع Firebase Exception
      if (error.plugin == 'cloud_firestore') {
        return handleFirestoreError(error);
      } else if (error.plugin == 'firebase_storage') {
        return handleStorageError(error);
      } else {
        return 'خطأ في Firebase: ${error.message ?? 'خطأ غير معروف'}';
      }
    } else if (error is Exception) {
      return handleNetworkError(error);
    } else {
      return 'خطأ غير متوقع: ${error.toString()}';
    }
  }

  /// تسجيل الأخطاء
  void logError(String operation, dynamic error, [StackTrace? stackTrace]) {
    print('🔴 خطأ في العملية: $operation');
    print('   التفاصيل: ${error.toString()}');
    if (stackTrace != null) {
      print('   Stack Trace: $stackTrace');
    }
    print('   الوقت: ${DateTime.now().toIso8601String()}');
    
    // يمكن إضافة تسجيل الأخطاء في خدمة خارجية مثل Crashlytics
    // FirebaseCrashlytics.instance.recordError(error, stackTrace);
  }

  /// معالجة الأخطاء مع إعادة المحاولة
  Future<T?> executeWithRetry<T>(
    Future<T> Function() operation,
    String operationName, {
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 1),
  }) async {
    int attempts = 0;
    
    while (attempts < maxRetries) {
      try {
        attempts++;
        return await operation();
      } catch (e, stackTrace) {
        logError('$operationName (محاولة $attempts)', e, stackTrace);
        
        if (attempts >= maxRetries) {
          rethrow;
        }
        
        // انتظار قبل المحاولة التالية
        await Future.delayed(delay * attempts);
      }
    }
    
    return null;
  }

  /// التحقق من حالة الاتصال
  Future<bool> checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// معالجة الأخطاء مع التحقق من الاتصال
  Future<T?> executeWithConnectivityCheck<T>(
    Future<T> Function() operation,
    String operationName,
  ) async {
    try {
      // التحقق من الاتصال أولاً
      bool isConnected = await checkConnectivity();
      if (!isConnected) {
        throw Exception('لا يوجد اتصال بالإنترنت');
      }
      
      return await operation();
    } catch (e, stackTrace) {
      logError(operationName, e, stackTrace);
      rethrow;
    }
  }

  /// إنشاء رسالة خطأ مخصصة للمستخدم
  String createUserFriendlyMessage(dynamic error, String context) {
    String baseMessage = handleGenericError(error);
    
    switch (context) {
      case 'login':
        return 'فشل في تسجيل الدخول: $baseMessage';
      case 'register':
        return 'فشل في إنشاء الحساب: $baseMessage';
      case 'upload':
        return 'فشل في رفع الملف: $baseMessage';
      case 'save':
        return 'فشل في حفظ البيانات: $baseMessage';
      case 'load':
        return 'فشل في تحميل البيانات: $baseMessage';
      case 'delete':
        return 'فشل في حذف البيانات: $baseMessage';
      case 'update':
        return 'فشل في تحديث البيانات: $baseMessage';
      default:
        return baseMessage;
    }
  }
}
