import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tashlehekomv2/models/user_model.dart';
import 'package:tashlehekomv2/providers/auth_provider.dart';
import 'package:tashlehekomv2/providers/car_provider.dart';
import 'package:tashlehekomv2/providers/firebase_auth_provider.dart';
import 'package:tashlehekomv2/screens/auth/firebase_otp_verification_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();

  // نوع الحساب ثابت: فرد فقط
  final UserType _selectedUserType = UserType.individual;
  String? _selectedCity;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CarProvider>(context, listen: false).loadCities();
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء حساب جديد'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'إنشاء حساب جديد',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // نوع الحساب ثابت: فرد فقط
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.person, color: Colors.green[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'نوع الحساب: فرد',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'للأفراد الذين يريدون شراء أو بيع السيارات',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.check_circle, color: Colors.green[700]),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Username field
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'اسم المستخدم',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال اسم المستخدم';
                  }
                  if (value.length < 3) {
                    return 'اسم المستخدم يجب أن يكون 3 أحرف على الأقل';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Phone number field
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.ltr,
                decoration: const InputDecoration(
                  labelText: 'رقم الجوال',
                  hintText: '05xxxxxxxx',
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال رقم الجوال';
                  }
                  if (!RegExp(r'^05\d{8}$').hasMatch(value)) {
                    return 'يرجى إدخال رقم جوال صحيح';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // City selection
              Consumer<CarProvider>(
                builder: (context, carProvider, child) {
                  return DropdownButtonFormField<String>(
                    value: _selectedCity,
                    decoration: const InputDecoration(
                      labelText: 'المدينة',
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    items: carProvider.cities
                        .map((city) => DropdownMenuItem(
                              value: city,
                              child: Text(city),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCity = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى اختيار المدينة';
                      }
                      return null;
                    },
                  );
                },
              ),

              const SizedBox(height: 32),

              // Register button
              ElevatedButton(
                onPressed: _isLoading ? null : _handleRegister,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('إنشاء الحساب'),
              ),

              const SizedBox(height: 16),

              // Test login button for blocked devices
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.warning_amber,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'مشكلة في إرسال رمز التحقق؟',
                      style: TextStyle(
                        color: Colors.orange[700],
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => _handleTestLogin(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 8),
                      ),
                      child: const Text('دخول تجريبي'),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'للاختبار فقط - سيتم إنشاء حساب مؤقت',
                      style: TextStyle(
                        color: Colors.orange[600],
                        fontSize: 11,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    print('🔍 DEBUG: بدء _handleRegister في register_screen');

    final firebaseAuthProvider =
        Provider.of<FirebaseAuthProvider>(context, listen: false);

    print(
        '🔍 DEBUG: تم الحصول على firebaseAuthProvider: ${firebaseAuthProvider.runtimeType}');

    try {
      print(
          '📤 محاولة إرسال OTP للرقم: ${_phoneController.text} من register_screen');
      print('🔍 DEBUG: قبل استدعاء firebaseAuthProvider.sendOTP');

      // Send OTP first using Firebase Auth
      await firebaseAuthProvider.sendOTP(_phoneController.text);

      print('✅ تم إرسال OTP بنجاح عبر Firebase من register_screen');

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FirebaseOTPVerificationScreen(
              phoneNumber: _phoneController.text,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleTestLogin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider =
          Provider.of<FirebaseAuthProvider>(context, listen: false);

      // إنشاء مستخدم تجريبي
      final testUser = UserModel(
        id: 'test_${DateTime.now().millisecondsSinceEpoch}',
        username: 'مستخدم تجريبي',
        name: 'مستخدم تجريبي',
        phoneNumber: _phoneController.text.isNotEmpty
            ? _phoneController.text
            : '0508432346',
        userType: _selectedUserType,
        isApproved: true,
        createdAt: DateTime.now(),
      );

      // تسجيل الدخول بالمستخدم التجريبي
      await authProvider.updateUser(testUser);

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تسجيل الدخول كمستخدم تجريبي'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تسجيل الدخول التجريبي: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
