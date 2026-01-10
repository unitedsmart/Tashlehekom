import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:tashlehekomv2/models/user_model.dart';
import 'package:tashlehekomv2/services/database_service.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _otpCode;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;

  Future<void> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    if (userId != null) {
      _currentUser = await DatabaseService.instance.getUser(userId);
      notifyListeners();
    }
  }

  Future<bool> sendOTP(String phoneNumber) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate OTP sending - في التطبيق الحقيقي سيتم إرسال OTP عبر SMS
      _otpCode = '1234'; // كود ثابت للاختبار

      await Future.delayed(const Duration(seconds: 2));

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyOTP(String enteredOTP) async {
    return enteredOTP == _otpCode;
  }

  Future<bool> register({
    required String username,
    required String phoneNumber,
    required UserType userType,
    String? city,
    String? junkyard,
  }) async {
    print(
        '📝 AuthProvider: بدء التسجيل للمستخدم: "$username" - الرقم: "$phoneNumber"');
    _isLoading = true;
    notifyListeners();

    try {
      // Check if user already exists
      print('🔍 التحقق من وجود المستخدم مسبقاً...');
      final existingUser =
          await DatabaseService.instance.getUserByPhone(phoneNumber);
      if (existingUser != null) {
        print('❌ المستخدم موجود مسبقاً');
        _isLoading = false;
        notifyListeners();
        return false;
      }

      print('✅ المستخدم غير موجود، إنشاء حساب جديد...');
      // Create new user
      final user = UserModel(
        id: const Uuid().v4(),
        username: username,
        name: username, // استخدام username كـ name
        phoneNumber: phoneNumber,
        userType: userType,
        createdAt: DateTime.now(),
        city: city,
        junkyard: junkyard,
        isApproved:
            userType == UserType.individual || userType == UserType.worker,
      );

      print('💾 حفظ المستخدم في قاعدة البيانات...');
      await DatabaseService.instance.createUser(user);

      // Save to preferences
      print('💾 حفظ معرف المستخدم في SharedPreferences...');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', user.id);

      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      print('✅ تم إنشاء الحساب بنجاح!');
      return true;
    } catch (e) {
      print('❌ خطأ في إنشاء الحساب: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String phoneNumber) async {
    print('🔐 AuthProvider: بدء تسجيل الدخول للرقم: "$phoneNumber"');
    _isLoading = true;
    notifyListeners();

    try {
      print('🔍 البحث عن المستخدم في قاعدة البيانات...');
      final user = await DatabaseService.instance.getUserByPhone(phoneNumber);
      print(
          '👤 نتيجة البحث: ${user != null ? 'تم العثور على المستخدم' : 'لم يتم العثور على المستخدم'}');

      if (user != null) {
        print('💾 حفظ معرف المستخدم في SharedPreferences...');
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', user.id);

        _currentUser = user;
        _isLoading = false;
        notifyListeners();
        print('✅ تم تسجيل الدخول بنجاح!');
        return true;
      }

      print('❌ فشل تسجيل الدخول: المستخدم غير موجود');
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print('❌ خطأ في تسجيل الدخول: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');

    _currentUser = null;
    notifyListeners();
  }

  bool canAddCar() {
    if (_currentUser == null) return false;

    return (_currentUser!.userType == UserType.junkyardOwner &&
            _currentUser!.isApproved) ||
        (_currentUser!.userType == UserType.worker) ||
        (_currentUser!.userType == UserType.individual &&
            _currentUser!.isApproved) ||
        (_currentUser!.userType == UserType.superAdmin);
  }

  bool needsApproval() {
    if (_currentUser == null) {
      return false;
    }

    return _currentUser!.userType == UserType.junkyardOwner &&
        !_currentUser!.isApproved;
  }
}
