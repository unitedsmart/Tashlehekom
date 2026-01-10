# 🔥 دليل إعداد Firebase Phone Authentication

## المشكلة الحالية
الرمز لا يأتي من Firebase، بل من الجهاز المحلي. هذا يعني أن Firebase Phone Authentication غير مُعد بشكل صحيح.

## ✅ الحلول المطلوبة

### 1. **تفعيل Phone Authentication في Firebase Console**

#### الخطوات:
1. اذهب إلى [Firebase Console](https://console.firebase.google.com/project/tashlehekom/authentication/providers)
2. في قسم **Authentication** → **Sign-in method**
3. ابحث عن **Phone** في قائمة Sign-in providers
4. اضغط على **Phone** لتفعيله
5. اضغط **Save**

#### التحقق:
- يجب أن ترى **Phone** مُفعل في قائمة Sign-in providers
- يجب أن يظهر **Enabled** بجانب Phone

### 2. **إضافة SHA-256 Fingerprint للتطبيق**

#### لماذا مهم؟
Firebase يحتاج SHA-256 fingerprint للتحقق من هوية التطبيق قبل إرسال SMS.

#### الحصول على SHA-256:

##### الطريقة الأولى - من Android Studio:
1. افتح Android Studio
2. اذهب إلى **View** → **Tool Windows** → **Gradle**
3. في نافذة Gradle: **android** → **Tasks** → **android** → **signingReport**
4. انقر نقراً مزدوجاً على **signingReport**
5. ابحث عن **SHA256** في النتائج

##### الطريقة الثانية - من Command Line:
```bash
# Windows
"%JAVA_HOME%\bin\keytool" -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android

# macOS/Linux
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

#### إضافة SHA-256 إلى Firebase:
1. اذهب إلى [Firebase Console](https://console.firebase.google.com/project/tashlehekom/settings/general)
2. في قسم **Your apps** → اختر تطبيق Android
3. اضغط على **Add fingerprint**
4. الصق SHA-256 fingerprint
5. اضغط **Save**

### 3. **التحقق من إعدادات المنطقة (Region)**

#### المشكلة:
Firebase قد يحتاج تفعيل منطقة السعودية لإرسال SMS.

#### الحل:
1. في Firebase Console → **Authentication** → **Settings**
2. ابحث عن **SMS region policy**
3. تأكد من إضافة **Saudi Arabia (+966)** إلى القائمة المسموحة

### 4. **إعداد Test Phone Numbers (للاختبار)**

#### للاختبار السريع:
1. في Firebase Console → **Authentication** → **Sign-in method**
2. اضغط على **Phone** → **Phone numbers for testing**
3. أضف رقم هاتف للاختبار مع رمز OTP ثابت
4. مثال: `+966501234567` → `123456`

### 5. **التحقق من Quota والفوترة**

#### المشكلة المحتملة:
Firebase له حد مجاني لإرسال SMS (10 رسائل/يوم).

#### الحل:
1. تفعيل Billing في Google Cloud Console
2. أو استخدام Test Phone Numbers للاختبار

## 🧪 **اختبار الإعداد**

### بعد تطبيق الحلول أعلاه:

1. **استخدم أداة الاختبار في التطبيق:**
   - اضغط "اختبار سريع" في شاشة تسجيل الدخول
   - راقب السجلات للتأكد من إرسال الطلب إلى Firebase

2. **راقب Firebase Console:**
   - اذهب إلى **Authentication** → **Users**
   - يجب أن ترى محاولات تسجيل الدخول

3. **تحقق من السجلات:**
   ```
   ✅ يجب أن ترى: "تم إرسال OTP عبر Firebase"
   ❌ لا يجب أن ترى: "فشل Firebase Auth"
   ```

## 🚨 **مشاكل شائعة وحلولها**

### المشكلة: "This app is not authorized to use Firebase Authentication"
**الحل:** تأكد من إضافة SHA-256 fingerprint الصحيح

### المشكلة: "SMS quota exceeded"
**الحل:** استخدم Test Phone Numbers أو فعّل Billing

### المشكلة: "Invalid phone number"
**الحل:** تأكد من تنسيق الرقم: `+966xxxxxxxxx`

### المشكلة: "Region not supported"
**الحل:** أضف السعودية إلى SMS region policy

## 📞 **أرقام الاختبار المقترحة**

أضف هذه الأرقام في Firebase Console للاختبار:
- `+966501234567` → `123456`
- `+966551234567` → `654321`
- `+966561234567` → `111111`

## 🔍 **التحقق النهائي**

بعد تطبيق جميع الحلول، يجب أن ترى في السجلات:
```
📤 بدء إرسال OTP للرقم: "+966xxxxxxxxx"
🚀 Production Mode: إرسال SMS حقيقي للرقم: +966xxxxxxxxx
✅ تم إرسال OTP عبر Firebase بنجاح
```

وليس:
```
❌ فشل Firebase Auth: [خطأ]
📱 SMS failed, OTP for testing: xxxx
```
