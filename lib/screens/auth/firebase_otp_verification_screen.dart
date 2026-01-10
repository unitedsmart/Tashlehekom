import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../providers/firebase_auth_provider.dart';

/// شاشة التحقق من OTP باستخدام Firebase Auth
class FirebaseOTPVerificationScreen extends StatefulWidget {
  final String phoneNumber;

  const FirebaseOTPVerificationScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<FirebaseOTPVerificationScreen> createState() =>
      _FirebaseOTPVerificationScreenState();
}

class _FirebaseOTPVerificationScreenState
    extends State<FirebaseOTPVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  int _resendTimer = 60;
  bool _canResend = false;
  String _currentOTP = "";

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      _resendTimer = 60;
      _canResend = false;
    });

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _resendTimer--;
          if (_resendTimer <= 0) {
            _canResend = true;
          }
        });
      }
      return _resendTimer > 0 && mounted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التحقق من رمز OTP'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Icon
            const Icon(
              Icons.sms,
              size: 80,
              color: Colors.green,
            ),

            const SizedBox(height: 24),

            // Title
            const Text(
              'التحقق من رقم الهاتف',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // Description
            Text(
              'تم إرسال رمز التحقق إلى\n${widget.phoneNumber}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // OTP Input
            PinCodeTextField(
              appContext: context,
              length: 6,
              controller: _otpController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(8),
                fieldHeight: 50,
                fieldWidth: 45,
                activeFillColor: Colors.white,
                inactiveFillColor: Colors.grey[100],
                selectedFillColor: Colors.green[50],
                activeColor: Colors.green,
                inactiveColor: Colors.grey,
                selectedColor: Colors.green,
              ),
              enableActiveFill: true,
              onChanged: (value) {
                setState(() {
                  _currentOTP = value;
                });
              },
              onCompleted: (value) {
                _verifyOTP(value);
              },
            ),

            const SizedBox(height: 24),

            // Verify Button
            Consumer<FirebaseAuthProvider>(
              builder: (context, authProvider, child) {
                return ElevatedButton(
                  onPressed: _isLoading || _currentOTP.length < 6
                      ? null
                      : () => _verifyOTP(_currentOTP),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
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
                      : const Text(
                          'تحقق',
                          style: TextStyle(fontSize: 16),
                        ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Resend Button
            Consumer<FirebaseAuthProvider>(
              builder: (context, authProvider, child) {
                return TextButton(
                  onPressed:
                      _canResend && !authProvider.isLoading ? _resendOTP : null,
                  child: Text(
                    _canResend
                        ? 'إعادة إرسال الرمز'
                        : 'إعادة الإرسال خلال $_resendTimer ثانية',
                    style: TextStyle(
                      color: _canResend ? Colors.green : Colors.grey,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Help Text
            const Text(
              'لم تستلم الرمز؟ تأكد من رقم الهاتف وحاول مرة أخرى',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// التحقق من رمز OTP
  Future<void> _verifyOTP(String otp) async {
    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال رمز التحقق كاملاً (6 أرقام)'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider =
          Provider.of<FirebaseAuthProvider>(context, listen: false);
      print('🔄 بدء التحقق من OTP: $otp');
      print('📱 رقم الهاتف المرسل للتحقق: "${widget.phoneNumber}"');

      // التحقق من OTP باستخدام Firebase Auth
      final isValidOTP = await authProvider.verifyOTP(otp);
      print('✅ نتيجة التحقق: $isValidOTP');

      if (isValidOTP) {
        print('نجح التحقق من OTP، تسجيل الدخول بنجاح');

        // إظهار رسالة نجاح
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تسجيل الدخول بنجاح!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          // تأخير قصير للتأكد من تحديث الحالة
          await Future.delayed(const Duration(milliseconds: 500));

          if (mounted) {
            // الانتقال إلى الشاشة الرئيسية مباشرة
            await Navigator.of(context).pushNamedAndRemoveUntil(
              '/home',
              (route) => false,
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('رمز التحقق غير صحيح'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      print('❌ خطأ في التحقق من OTP: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// إعادة إرسال رمز OTP
  Future<void> _resendOTP() async {
    try {
      final authProvider =
          Provider.of<FirebaseAuthProvider>(context, listen: false);
      await authProvider.resendOTP();

      _startResendTimer();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إعادة إرسال رمز التحقق'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في إعادة الإرسال: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
