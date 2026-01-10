import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/firebase_auth_service.dart';
import '../services/hybrid_database_service.dart';
import '../services/firebase_service.dart';
import '../services/security_service.dart';
import '../services/activity_monitor_service.dart';

/// مزود المصادقة باستخدام Firebase Auth
class FirebaseAuthProvider with ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _verificationId;
  String? _phoneNumber;

  final FirebaseAuthService _authService = FirebaseAuthService();
  final HybridDatabaseService _dbService = HybridDatabaseService();
  final FirebaseService _firebaseService = FirebaseService();
  final SecurityService _securityService = SecurityService();
  final ActivityMonitorService _activityMonitor = ActivityMonitorService();

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  String? get phoneNumber => _phoneNumber;

  /// تهيئة المزود
  Future<void> initialize() async {
    await _checkAuthStatus();
    await _dbService.initialize();

    // الاستماع لتغييرات حالة المصادقة
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  /// التحقق من حالة المصادقة المحفوظة
  Future<void> _checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');

      if (userId != null) {
        // محاولة الحصول على المستخدم من قاعدة البيانات
        _currentUser = await _dbService.getUser(userId);

        // التحقق من Firebase Auth أيضاً
        User? firebaseUser = _authService.currentUser;
        if (firebaseUser != null && firebaseUser.uid == userId) {
          print(
              '✅ المستخدم مسجل دخول في Firebase: ${firebaseUser.phoneNumber}');
        }

        notifyListeners();
      }
    } catch (e) {
      print('❌ خطأ في التحقق من حالة المصادقة: $e');
    }
  }

  /// معالج تغيير حالة المصادقة في Firebase
  void _onAuthStateChanged(User? firebaseUser) async {
    try {
      if (firebaseUser != null) {
        print('🔄 تغيرت حالة المصادقة: مستخدم مسجل دخول');

        // الحصول على بيانات المستخدم من قاعدة البيانات
        UserModel? user = await _dbService.getUser(firebaseUser.uid);

        if (user != null) {
          _currentUser = user;
          await _saveUserSession(user.id);
          notifyListeners();
        }
      } else {
        print('🔄 تغيرت حالة المصادقة: لا يوجد مستخدم');
        await _clearUserSession();
      }
    } catch (e) {
      print('❌ خطأ في معالجة تغيير حالة المصادقة: $e');
    }
  }

  /// إرسال رمز OTP
  Future<bool> sendOTP(String phoneNumber) async {
    _isLoading = true;
    _phoneNumber = phoneNumber;
    notifyListeners();

    try {
      print('📤 إرسال OTP إلى: $phoneNumber');

      // التحقق من صحة رقم الهاتف
      if (!_authService.isValidSaudiPhoneNumber(phoneNumber)) {
        throw Exception('رقم الهاتف غير صحيح. يرجى إدخال رقم هاتف سعودي صحيح');
      }

      // إرسال OTP عبر Firebase Auth
      _verificationId = await _authService.sendOTP(phoneNumber);

      // تسجيل الحدث في Analytics
      await _firebaseService.logEvent('otp_sent', {
        'phone_number': phoneNumber,
        'timestamp': DateTime.now().toIso8601String(),
      });

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ خطأ في إرسال OTP: $e');
      _isLoading = false;
      notifyListeners();
      throw Exception('فشل في إرسال رمز التحقق: ${e.toString()}');
    }
  }

  /// التحقق من رمز OTP وتسجيل الدخول
  Future<bool> verifyOTP(String otp) async {
    if (_verificationId == null) {
      throw Exception('لم يتم إرسال رمز التحقق بعد');
    }

    _isLoading = true;
    notifyListeners();

    try {
      print('🔍 التحقق من OTP: $otp');

      // التحقق من OTP عبر Firebase Auth
      UserModel? user = await _authService.verifyOTP(_verificationId!, otp);

      if (user != null) {
        _currentUser = user;
        await _saveUserSession(user.id);

        // تسجيل الحدث في Analytics
        try {
          await _firebaseService.logLogin('phone');
        } catch (analyticsError) {
          print('⚠️ خطأ في Analytics (غير مؤثر): $analyticsError');
        }

        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print('❌ خطأ في التحقق من OTP: $e');
      _isLoading = false;
      notifyListeners();

      // إذا كان الخطأ من Firebase Auth نفسه، نعيد رسالة مناسبة
      if (e.toString().contains('PigeonUserDetails') ||
          e.toString().contains('type cast')) {
        print(
            '⚠️ خطأ في type casting - Firebase Auth نجح لكن هناك مشكلة في معالجة البيانات');
        return false;
      }

      throw Exception('رمز التحقق غير صحيح');
    }
  }

  /// تسجيل مستخدم جديد
  Future<bool> register({
    required String name,
    required String phoneNumber,
    String? email,
    UserType userType = UserType.user,
  }) async {
    try {
      print('📝 تسجيل مستخدم جديد: $name');

      if (_currentUser != null) {
        // تحديث بيانات المستخدم الحالي
        UserModel updatedUser = _currentUser!.copyWith(
          name: name,
          email: email ?? _currentUser!.email,
          userType: userType,
          updatedAt: DateTime.now(),
        );

        await _dbService.updateUser(updatedUser);
        _currentUser = updatedUser;

        // تسجيل الحدث في Analytics
        await _firebaseService.logSignUp('phone');

        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      print('❌ خطأ في تسجيل المستخدم: $e');
      throw Exception('فشل في تسجيل المستخدم: ${e.toString()}');
    }
  }

  /// تسجيل الخروج
  Future<void> logout() async {
    try {
      print('🚪 تسجيل الخروج...');

      // تسجيل الخروج من Firebase Auth
      await _authService.signOut();

      // مسح الجلسة المحلية
      await _clearUserSession();

      print('✅ تم تسجيل الخروج بنجاح');
    } catch (e) {
      print('❌ خطأ في تسجيل الخروج: $e');
      throw Exception('فشل في تسجيل الخروج: ${e.toString()}');
    }
  }

  /// حذف الحساب
  Future<void> deleteAccount() async {
    try {
      print('🗑️ حذف الحساب...');

      if (_currentUser != null) {
        // حذف الحساب من Firebase Auth و Firestore
        await _authService.deleteAccount();

        // مسح الجلسة المحلية
        await _clearUserSession();

        print('✅ تم حذف الحساب بنجاح');
      }
    } catch (e) {
      print('❌ خطأ في حذف الحساب: $e');
      throw Exception('فشل في حذف الحساب: ${e.toString()}');
    }
  }

  /// تحديث بيانات المستخدم
  Future<void> updateUser(UserModel user) async {
    try {
      await _dbService.updateUser(user);
      _currentUser = user;
      notifyListeners();
    } catch (e) {
      print('❌ خطأ في تحديث المستخدم: $e');
      throw Exception('فشل في تحديث البيانات: ${e.toString()}');
    }
  }

  /// التحقق من صلاحية إضافة السيارات
  bool canAddCar() {
    if (_currentUser == null) return false;

    return _currentUser!.userType == UserType.seller ||
        _currentUser!.userType == UserType.admin ||
        _currentUser!.userType == UserType.superAdmin;
  }

  /// التحقق من صلاحية الإدارة
  bool isAdmin() {
    if (_currentUser == null) return false;

    return _currentUser!.userType == UserType.admin ||
        _currentUser!.userType == UserType.superAdmin;
  }

  /// حفظ جلسة المستخدم
  Future<void> _saveUserSession(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', userId);
      print('💾 تم حفظ جلسة المستخدم: $userId');
    } catch (e) {
      print('❌ خطأ في حفظ الجلسة: $e');
    }
  }

  /// مسح جلسة المستخدم
  Future<void> _clearUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_id');
      _currentUser = null;
      _verificationId = null;
      _phoneNumber = null;
      notifyListeners();
      print('🗑️ تم مسح جلسة المستخدم');
    } catch (e) {
      print('❌ خطأ في مسح الجلسة: $e');
    }
  }

  /// إعادة إرسال OTP
  Future<bool> resendOTP() async {
    if (_phoneNumber != null) {
      return await sendOTP(_phoneNumber!);
    }
    return false;
  }

  /// التحقق من حالة الاتصال
  bool get isOnline => _dbService.isOnline;

  // ==================== دوال إضافية للتوافق مع HomeScreen ====================

  /// فحص حالة المصادقة
  Future<void> checkAuthStatus() async {
    await initialize();
  }

  /// هل المستخدم بحاجة لموافقة؟
  bool needsApproval() {
    if (_currentUser == null) return false;
    return !_currentUser!.isApproved;
  }
}
