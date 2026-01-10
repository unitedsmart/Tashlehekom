import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:tashlehekomv2/services/logging_service.dart';

/// معالج الأخطاء المحسن
class EnhancedErrorHandler {
  static bool _isInitialized = false;
  
  /// تهيئة معالج الأخطاء
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    // معالجة الأخطاء غير المتوقعة في Flutter
    FlutterError.onError = (FlutterErrorDetails details) {
      LoggingService.error(
        'Flutter Error: ${details.exception}',
        error: details.exception,
        stackTrace: details.stack,
      );
      
      // إرسال إلى Firebase Crashlytics في الإنتاج
      if (!kDebugMode) {
        FirebaseCrashlytics.instance.recordFlutterError(details);
      }
    };
    
    // معالجة الأخطاء غير المتوقعة في Dart
    PlatformDispatcher.instance.onError = (error, stack) {
      LoggingService.error(
        'Platform Error: $error',
        error: error,
        stackTrace: stack,
      );
      
      // إرسال إلى Firebase Crashlytics في الإنتاج
      if (!kDebugMode) {
        FirebaseCrashlytics.instance.recordError(error, stack);
      }
      
      return true;
    };
    
    _isInitialized = true;
    LoggingService.success('تم تهيئة معالج الأخطاء المحسن');
  }
  
  /// معالجة أخطاء Firebase
  static void handleFirebaseError(Object error, StackTrace? stackTrace, {String? operation}) {
    final message = operation != null 
        ? 'خطأ في Firebase - $operation: $error'
        : 'خطأ في Firebase: $error';
        
    LoggingService.firebase(message);
    
    if (!kDebugMode) {
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: operation,
      );
    }
  }
  
  /// معالجة أخطاء الشبكة
  static void handleNetworkError(Object error, StackTrace? stackTrace, {String? operation}) {
    final message = operation != null 
        ? 'خطأ في الشبكة - $operation: $error'
        : 'خطأ في الشبكة: $error';
        
    LoggingService.network(message);
    
    if (!kDebugMode) {
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: operation,
      );
    }
  }
  
  /// معالجة أخطاء قاعدة البيانات
  static void handleDatabaseError(Object error, StackTrace? stackTrace, {String? operation}) {
    final message = operation != null 
        ? 'خطأ في قاعدة البيانات - $operation: $error'
        : 'خطأ في قاعدة البيانات: $error';
        
    LoggingService.database(message);
    
    if (!kDebugMode) {
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: operation,
      );
    }
  }
  
  /// معالجة أخطاء واجهة المستخدم
  static void handleUIError(Object error, StackTrace? stackTrace, {String? operation}) {
    final message = operation != null 
        ? 'خطأ في واجهة المستخدم - $operation: $error'
        : 'خطأ في واجهة المستخدم: $error';
        
    LoggingService.ui(message);
    
    if (!kDebugMode) {
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: operation,
      );
    }
  }
  
  /// تسجيل حدث مخصص
  static void logCustomEvent(String event, Map<String, dynamic>? parameters) {
    LoggingService.info('حدث مخصص: $event - ${parameters?.toString() ?? ''}');
    
    if (!kDebugMode) {
      FirebaseCrashlytics.instance.log('$event: ${parameters?.toString() ?? ''}');
    }
  }
  
  /// تسجيل معلومات المستخدم
  static void setUserInfo(String userId, {String? email, String? name}) {
    if (!kDebugMode) {
      FirebaseCrashlytics.instance.setUserIdentifier(userId);
      if (email != null) {
        FirebaseCrashlytics.instance.setCustomKey('user_email', email);
      }
      if (name != null) {
        FirebaseCrashlytics.instance.setCustomKey('user_name', name);
      }
    }
    
    LoggingService.info('تم تسجيل معلومات المستخدم: $userId');
  }
  
  /// تنفيذ عملية مع معالجة الأخطاء
  static Future<T?> executeWithErrorHandling<T>(
    Future<T> Function() operation,
    String operationName, {
    T? defaultValue,
    bool showUserError = false,
  }) async {
    try {
      LoggingService.start(operationName);
      final result = await operation();
      LoggingService.success('تمت العملية بنجاح: $operationName');
      return result;
    } catch (error, stackTrace) {
      LoggingService.error(
        'فشلت العملية: $operationName',
        error: error,
        stackTrace: stackTrace,
      );
      
      if (!kDebugMode) {
        FirebaseCrashlytics.instance.recordError(
          error,
          stackTrace,
          reason: operationName,
        );
      }
      
      return defaultValue;
    }
  }
  
  /// تنفيذ عملية متزامنة مع معالجة الأخطاء
  static T? executeSyncWithErrorHandling<T>(
    T Function() operation,
    String operationName, {
    T? defaultValue,
  }) {
    try {
      LoggingService.start(operationName);
      final result = operation();
      LoggingService.success('تمت العملية بنجاح: $operationName');
      return result;
    } catch (error, stackTrace) {
      LoggingService.error(
        'فشلت العملية: $operationName',
        error: error,
        stackTrace: stackTrace,
      );
      
      if (!kDebugMode) {
        FirebaseCrashlytics.instance.recordError(
          error,
          stackTrace,
          reason: operationName,
        );
      }
      
      return defaultValue;
    }
  }
}
