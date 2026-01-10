import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tashlehekomv2/providers/firebase_auth_provider.dart';
import 'package:tashlehekomv2/screens/auth/register_screen.dart';
import 'package:tashlehekomv2/screens/auth/firebase_otp_verification_screen.dart';
import 'package:tashlehekomv2/models/user_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل الدخول'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo
              const Icon(
                Icons.directions_car,
                size: 80,
                color: Colors.green,
              ),

              const SizedBox(height: 24),

              Text(
                'مرحباً بك في تشليحكم',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                'أدخل رقم جوالك للمتابعة',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

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

              const SizedBox(height: 24),

              // Login button
              Consumer<FirebaseAuthProvider>(
                builder: (context, authProvider, child) {
                  return ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
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
                        : const Text('تسجيل الدخول'),
                  );
                },
              ),

              const SizedBox(height: 16),

              const SizedBox(height: 8),

              // Register button
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterScreen(),
                    ),
                  );
                },
                child: const Text('إنشاء حساب جديد'),
              ),

              const SizedBox(height: 24),

              // Guest access info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'يمكنك تصفح السيارات بدون تسجيل دخول',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'لكن ستحتاج لتسجيل الدخول للتواصل مع البائعين',
                      style: TextStyle(
                        color: Colors.blue[600],
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
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

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    print('🔍 DEBUG: بدء _handleLogin');

    final authProvider =
        Provider.of<FirebaseAuthProvider>(context, listen: false);

    print('🔍 DEBUG: تم الحصول على authProvider: ${authProvider.runtimeType}');

    try {
      print('📤 محاولة إرسال OTP للرقم: ${_phoneController.text}');
      print('🔍 DEBUG: قبل استدعاء authProvider.sendOTP');

      // استخدام Firebase Auth لإرسال OTP
      await authProvider.sendOTP(_phoneController.text);

      print('✅ تم إرسال OTP بنجاح عبر Firebase');

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        Navigator.push(
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
        userType: UserType.individual,
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
