import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tashlehekomv2/models/user_model.dart';
import 'package:tashlehekomv2/services/firebase_firestore_service.dart';

/// خدمة الأمان والتشفير
class SecurityService {
  static final SecurityService _instance = SecurityService._internal();
  factory SecurityService() => _instance;
  SecurityService._internal();

  final FirebaseFirestoreService _firestoreService = FirebaseFirestoreService();
  
  // مفاتيح التشفير
  static const String _encryptionKey = 'TashlehekomSecureKey2024';
  static const String _saltKey = 'TashlehekomSalt2024';
  
  // حدود الأمان
  static const int maxLoginAttempts = 5;
  static const int lockoutDurationMinutes = 30;
  static const int sessionTimeoutMinutes = 60;
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  
  /// تشفير النص
  String encryptText(String plainText) {
    try {
      final bytes = utf8.encode(plainText + _saltKey);
      final digest = sha256.convert(bytes);
      return base64.encode(digest.bytes);
    } catch (e) {
      throw Exception('فشل في تشفير النص: $e');
    }
  }

  /// تشفير كلمة المرور
  String hashPassword(String password) {
    final salt = _generateSalt();
    final bytes = utf8.encode(password + salt + _encryptionKey);
    final digest = sha256.convert(bytes);
    return '${base64.encode(digest.bytes)}:$salt';
  }

  /// التحقق من كلمة المرور
  bool verifyPassword(String password, String hashedPassword) {
    try {
      final parts = hashedPassword.split(':');
      if (parts.length != 2) return false;
      
      final hash = parts[0];
      final salt = parts[1];
      
      final bytes = utf8.encode(password + salt + _encryptionKey);
      final digest = sha256.convert(bytes);
      final newHash = base64.encode(digest.bytes);
      
      return hash == newHash;
    } catch (e) {
      return false;
    }
  }

  /// إنشاء salt عشوائي
  String _generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64.encode(bytes);
  }

  /// تشفير البيانات الحساسة
  String encryptSensitiveData(String data) {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final combined = '$data:$timestamp:$_encryptionKey';
      final bytes = utf8.encode(combined);
      final digest = sha256.convert(bytes);
      return base64.encode(digest.bytes);
    } catch (e) {
      throw Exception('فشل في تشفير البيانات الحساسة: $e');
    }
  }

  /// التحقق من صحة رقم الهاتف السعودي
  bool isValidSaudiPhoneNumber(String phoneNumber) {
    // إزالة المسافات والرموز
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    
    // التحقق من الأنماط المقبولة
    final patterns = [
      RegExp(r'^\+9665\d{8}$'),      // +9665xxxxxxxx
      RegExp(r'^9665\d{8}$'),        // 9665xxxxxxxx
      RegExp(r'^05\d{8}$'),          // 05xxxxxxxx
      RegExp(r'^5\d{8}$'),           // 5xxxxxxxx
    ];
    
    return patterns.any((pattern) => pattern.hasMatch(cleanNumber));
  }

  /// تنظيف وتعقيم النصوص من الهجمات
  String sanitizeInput(String input) {
    if (input.isEmpty) return input;
    
    // إزالة الأكواد الضارة
    String sanitized = input
        .replaceAll(RegExp(r'<script[^>]*>.*?</script>', caseSensitive: false), '')
        .replaceAll(RegExp(r'javascript:', caseSensitive: false), '')
        .replaceAll(RegExp(r'on\w+\s*=', caseSensitive: false), '')
        .replaceAll(RegExp(r'<iframe[^>]*>.*?</iframe>', caseSensitive: false), '')
        .replaceAll(RegExp(r'<object[^>]*>.*?</object>', caseSensitive: false), '')
        .replaceAll(RegExp(r'<embed[^>]*>.*?</embed>', caseSensitive: false), '');
    
    // تحديد طول النص
    if (sanitized.length > 1000) {
      sanitized = sanitized.substring(0, 1000);
    }
    
    return sanitized.trim();
  }

  /// التحقق من صحة البريد الإلكتروني
  bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// التحقق من قوة كلمة المرور
  PasswordStrength checkPasswordStrength(String password) {
    if (password.length < 6) return PasswordStrength.weak;
    
    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    bool hasNumbers = password.contains(RegExp(r'[0-9]'));
    bool hasSpecialChars = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    
    int score = 0;
    if (hasUppercase) score++;
    if (hasLowercase) score++;
    if (hasNumbers) score++;
    if (hasSpecialChars) score++;
    if (password.length >= 8) score++;
    
    if (score >= 4) return PasswordStrength.strong;
    if (score >= 2) return PasswordStrength.medium;
    return PasswordStrength.weak;
  }

  /// تسجيل محاولة تسجيل دخول فاشلة
  Future<void> logFailedLoginAttempt(String phoneNumber, String ipAddress) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'failed_attempts_$phoneNumber';
      final attempts = prefs.getInt(key) ?? 0;
      
      await prefs.setInt(key, attempts + 1);
      await prefs.setInt('last_attempt_$phoneNumber', DateTime.now().millisecondsSinceEpoch);
      
      // تسجيل في Firebase للمراقبة
      await _firestoreService.users.add({
        'type': 'security_log',
        'event': 'failed_login',
        'phoneNumber': phoneNumber,
        'ipAddress': ipAddress,
        'timestamp': DateTime.now().toIso8601String(),
        'attempts': attempts + 1,
      });
      
      print('🔒 تم تسجيل محاولة دخول فاشلة: $phoneNumber');
    } catch (e) {
      print('❌ خطأ في تسجيل محاولة الدخول الفاشلة: $e');
    }
  }

  /// التحقق من حالة القفل للمستخدم
  Future<bool> isUserLocked(String phoneNumber) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final attempts = prefs.getInt('failed_attempts_$phoneNumber') ?? 0;
      final lastAttempt = prefs.getInt('last_attempt_$phoneNumber') ?? 0;
      
      if (attempts >= maxLoginAttempts) {
        final lockoutTime = DateTime.fromMillisecondsSinceEpoch(lastAttempt)
            .add(const Duration(minutes: lockoutDurationMinutes));
        
        if (DateTime.now().isBefore(lockoutTime)) {
          return true; // المستخدم مقفل
        } else {
          // انتهت مدة القفل، إعادة تعيين العداد
          await prefs.remove('failed_attempts_$phoneNumber');
          await prefs.remove('last_attempt_$phoneNumber');
        }
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }

  /// إعادة تعيين محاولات تسجيل الدخول الفاشلة
  Future<void> resetFailedLoginAttempts(String phoneNumber) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('failed_attempts_$phoneNumber');
      await prefs.remove('last_attempt_$phoneNumber');
    } catch (e) {
      print('❌ خطأ في إعادة تعيين محاولات الدخول: $e');
    }
  }

  /// التحقق من صلاحيات المستخدم
  bool hasPermission(UserModel user, String permission) {
    switch (permission) {
      case 'add_car':
        return user.userType == UserType.seller || 
               user.userType == UserType.junkyardOwner ||
               user.userType == UserType.admin ||
               user.userType == UserType.superAdmin;
      
      case 'edit_car':
        return user.userType == UserType.seller || 
               user.userType == UserType.junkyardOwner ||
               user.userType == UserType.admin ||
               user.userType == UserType.superAdmin;
      
      case 'delete_car':
        return user.userType == UserType.admin ||
               user.userType == UserType.superAdmin;
      
      case 'manage_users':
        return user.userType == UserType.admin ||
               user.userType == UserType.superAdmin;
      
      case 'view_analytics':
        return user.userType == UserType.admin ||
               user.userType == UserType.superAdmin;
      
      case 'system_settings':
        return user.userType == UserType.superAdmin;
      
      default:
        return false;
    }
  }

  /// التحقق من حجم الملف
  bool isValidFileSize(int fileSize) {
    return fileSize <= maxFileSize;
  }

  /// التحقق من نوع الملف المسموح
  bool isValidFileType(String fileName) {
    final allowedExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
    final extension = fileName.toLowerCase().substring(fileName.lastIndexOf('.'));
    return allowedExtensions.contains(extension);
  }

  /// إنشاء رمز أمان عشوائي
  String generateSecureToken() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64.encode(bytes);
  }

  /// تسجيل نشاط مشبوه
  Future<void> logSuspiciousActivity(String userId, String activity, Map<String, dynamic> details) async {
    try {
      await _firestoreService.users.add({
        'type': 'security_alert',
        'userId': userId,
        'activity': activity,
        'details': details,
        'timestamp': DateTime.now().toIso8601String(),
        'severity': 'high',
      });
      
      print('🚨 تم تسجيل نشاط مشبوه: $activity');
    } catch (e) {
      print('❌ خطأ في تسجيل النشاط المشبوه: $e');
    }
  }
}

/// قوة كلمة المرور
enum PasswordStrength {
  weak,
  medium,
  strong,
}
