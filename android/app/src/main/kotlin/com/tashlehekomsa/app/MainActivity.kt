package com.tashlehekomsa.app

import android.Manifest
import android.content.pm.PackageManager
import android.telephony.SmsManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.google.firebase.auth.FirebaseAuth

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.tashlehekomv2/sms"
    private val SMS_PERMISSION_CODE = 101

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // تكوين Firebase Auth لتجنب reCAPTCHA
        FirebaseAuth.getInstance().setLanguageCode("ar")

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "sendSMS" -> {
                    val phoneNumber = call.argument<String>("phoneNumber")
                    val message = call.argument<String>("message")

                    if (phoneNumber != null && message != null) {
                        sendSMS(phoneNumber, message, result)
                    } else {
                        result.error("INVALID_ARGUMENTS", "Phone number and message are required", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun sendSMS(phoneNumber: String, message: String, result: MethodChannel.Result) {
        try {
            // التحقق من الأذونات
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.SEND_SMS)
                != PackageManager.PERMISSION_GRANTED) {

                ActivityCompat.requestPermissions(this,
                    arrayOf(Manifest.permission.SEND_SMS),
                    SMS_PERMISSION_CODE)

                result.error("PERMISSION_DENIED", "SMS permission not granted", null)
                return
            }

            // إرسال SMS مع نص مخصص لتطبيق تشليحكم
            val smsManager = SmsManager.getDefault()
            val customMessage = "رمز التحقق الخاص بك في تطبيق تشليحكم سيصل قريباً\nصالح لمدة 5 دقائق"
            smsManager.sendTextMessage(phoneNumber, null, customMessage, null, null)

            result.success(true)
        } catch (e: Exception) {
            result.error("SMS_FAILED", "Failed to send SMS: ${e.message}", null)
        }
    }
}
