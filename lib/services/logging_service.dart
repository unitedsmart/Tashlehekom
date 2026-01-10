import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// خدمة التسجيل المحسنة
class LoggingService {
  static const String _tag = 'TashlehekomApp';
  
  /// تسجيل معلومات عامة
  static void info(String message, {String? tag}) {
    final logTag = tag ?? _tag;
    if (kDebugMode) {
      developer.log(
        message,
        name: logTag,
        level: 800, // INFO level
      );
    }
  }
  
  /// تسجيل تحذيرات
  static void warning(String message, {String? tag}) {
    final logTag = tag ?? _tag;
    if (kDebugMode) {
      developer.log(
        '⚠️ $message',
        name: logTag,
        level: 900, // WARNING level
      );
    }
  }
  
  /// تسجيل أخطاء
  static void error(String message, {Object? error, StackTrace? stackTrace, String? tag}) {
    final logTag = tag ?? _tag;
    if (kDebugMode) {
      developer.log(
        '❌ $message',
        name: logTag,
        level: 1000, // ERROR level
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
  
  /// تسجيل نجاح العمليات
  static void success(String message, {String? tag}) {
    final logTag = tag ?? _tag;
    if (kDebugMode) {
      developer.log(
        '✅ $message',
        name: logTag,
        level: 800, // INFO level
      );
    }
  }
  
  /// تسجيل بداية العمليات
  static void start(String operation, {String? tag}) {
    final logTag = tag ?? _tag;
    if (kDebugMode) {
      developer.log(
        '🚀 بدء: $operation',
        name: logTag,
        level: 700, // DEBUG level
      );
    }
  }
  
  /// تسجيل انتهاء العمليات
  static void end(String operation, {String? tag}) {
    final logTag = tag ?? _tag;
    if (kDebugMode) {
      developer.log(
        '🏁 انتهاء: $operation',
        name: logTag,
        level: 700, // DEBUG level
      );
    }
  }
  
  /// تسجيل بيانات Firebase
  static void firebase(String message, {String? tag}) {
    final logTag = '${tag ?? _tag}_Firebase';
    if (kDebugMode) {
      developer.log(
        '🔥 $message',
        name: logTag,
        level: 800,
      );
    }
  }
  
  /// تسجيل بيانات الشبكة
  static void network(String message, {String? tag}) {
    final logTag = '${tag ?? _tag}_Network';
    if (kDebugMode) {
      developer.log(
        '🌐 $message',
        name: logTag,
        level: 800,
      );
    }
  }
  
  /// تسجيل بيانات قاعدة البيانات
  static void database(String message, {String? tag}) {
    final logTag = '${tag ?? _tag}_Database';
    if (kDebugMode) {
      developer.log(
        '💾 $message',
        name: logTag,
        level: 800,
      );
    }
  }
  
  /// تسجيل بيانات واجهة المستخدم
  static void ui(String message, {String? tag}) {
    final logTag = '${tag ?? _tag}_UI';
    if (kDebugMode) {
      developer.log(
        '🎨 $message',
        name: logTag,
        level: 700,
      );
    }
  }
  
  /// تسجيل بيانات الأداء
  static void performance(String message, {String? tag}) {
    final logTag = '${tag ?? _tag}_Performance';
    if (kDebugMode) {
      developer.log(
        '⚡ $message',
        name: logTag,
        level: 800,
      );
    }
  }
}
