# دليل بناء APK الإنتاج - خطوة بخطوة

## 🎯 نظرة عامة

هذا الدليل سيوضح لك كيفية بناء APK موقع وجاهز للنشر على Google Play Store.

## ✅ المتطلبات المسبقة

قبل البدء، تأكد من:
- [ ] تم إنشاء مشروع Firebase للإنتاج
- [ ] تم تحميل `google-services.json` الصحيح
- [ ] تم إنشاء keystore للتوقيع
- [ ] تم إنشاء ملف `android/key.properties`
- [ ] تم تحديث مفاتيح Firebase في الكود

## 🔧 الخطوة 1: تحديث إعدادات Firebase

### 1.1 تحديث google-services.json
1. اذهب إلى Firebase Console
2. اختر مشروع الإنتاج: `tashlehekomv2-production`
3. اذهب إلى Project Settings > General
4. في قسم "Your apps"، انقر على تطبيق Android
5. حمّل `google-services.json` الجديد
6. استبدل الملف في `android/app/google-services.json`

### 1.2 تحديث firebase_options_production.dart
استبدل القيم النموذجية بالقيم الحقيقية من Firebase Console:

```dart
// في lib/firebase_options_production.dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'AIzaSyC7Kl8xQx9X8X8X8X8X8X8X8X8X8X8X8X8', // استبدل بالقيمة الحقيقية
  appId: '1:123456789012:android:abcdef1234567890abcdef', // استبدل بالقيمة الحقيقية
  messagingSenderId: '123456789012', // استبدل بالقيمة الحقيقية
  projectId: 'tashlehekomv2-production',
  storageBucket: 'tashlehekomv2-production.appspot.com',
);
```

### 1.3 تحديث main.dart للإنتاج
```dart
// في lib/main.dart
import 'firebase_options_production.dart'; // بدلاً من firebase_options.dart

await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

## 🔑 الخطوة 2: التحقق من إعدادات التوقيع

### 2.1 التحقق من وجود keystore
```cmd
dir android\keystore\tashlehekomv2-release-key.jks
```

### 2.2 التحقق من ملف key.properties
```cmd
type android\key.properties
```

يجب أن يحتوي على:
```properties
storePassword=TashlehekomSecure2024
keyPassword=TashlehekomSecure2024
keyAlias=tashlehekomv2-key
storeFile=keystore/tashlehekomv2-release-key.jks
```

### 2.3 التحقق من build.gradle
تأكد من أن `android/app/build.gradle` يحتوي على إعدادات التوقيع:

```gradle
signingConfigs {
    release {
        keyAlias keystoreProperties['keyAlias']
        keyPassword keystoreProperties['keyPassword']
        storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
        storePassword keystoreProperties['storePassword']
    }
}

buildTypes {
    release {
        signingConfig signingConfigs.release
        minifyEnabled true
        shrinkResources true
        proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
    }
}
```

## 🧹 الخطوة 3: تنظيف المشروع

### 3.1 تنظيف Flutter
```cmd
flutter clean
```

### 3.2 الحصول على التبعيات
```cmd
flutter pub get
```

### 3.3 تشغيل code generation (إذا كان مطلوباً)
```cmd
flutter packages pub run build_runner build --delete-conflicting-outputs
```

## 🔍 الخطوة 4: فحص الكود

### 4.1 تحليل الكود
```cmd
flutter analyze
```

يجب ألا تكون هناك أخطاء. إذا وُجدت أخطاء، أصلحها قبل المتابعة.

### 4.2 تشغيل الاختبارات
```cmd
flutter test test/basic_test.dart
```

تأكد من نجاح جميع الاختبارات.

## 🏗️ الخطوة 5: بناء APK الإنتاج

### 5.1 بناء APK موقع
```cmd
flutter build apk --release
```

### 5.2 بناء App Bundle (مفضل لـ Google Play)
```cmd
flutter build appbundle --release
```

### 5.3 مراقبة عملية البناء
- تأكد من عدم وجود أخطاء أثناء البناء
- راقب رسائل التحذير وأصلحها إن أمكن
- تأكد من نجاح عملية التوقيع

## ✅ الخطوة 6: التحقق من التوقيع

### 6.1 التحقق من توقيع APK
```cmd
jarsigner -verify -verbose -certs build\app\outputs\flutter-apk\app-release.apk
```

يجب أن ترى: `jar verified.`

### 6.2 التحقق من توقيع App Bundle
```cmd
jarsigner -verify -verbose -certs build\app\outputs\bundle\release\app-release.aab
```

### 6.3 عرض معلومات الشهادة
```cmd
keytool -printcert -jarfile build\app\outputs\flutter-apk\app-release.apk
```

## 📊 الخطوة 7: فحص حجم التطبيق

### 7.1 حجم APK
```cmd
dir build\app\outputs\flutter-apk\app-release.apk
```

### 7.2 حجم App Bundle
```cmd
dir build\app\outputs\bundle\release\app-release.aab
```

### 7.3 تحليل حجم التطبيق
```cmd
flutter build apk --analyze-size
```

## 🧪 الخطوة 8: اختبار APK

### 8.1 تثبيت APK على جهاز حقيقي
```cmd
adb install build\app\outputs\flutter-apk\app-release.apk
```

### 8.2 اختبار الوظائف الأساسية
- تسجيل الدخول بالهاتف
- البحث عن السيارات
- عرض تفاصيل السيارة
- إضافة إلى المفضلة
- التواصل مع البائع
- تحديث الملف الشخصي

### 8.3 اختبار الأداء
- سرعة تشغيل التطبيق
- سلاسة التنقل بين الشاشات
- سرعة تحميل الصور
- استجابة واجهة المستخدم

## 📁 الخطوة 9: تنظيم ملفات الإنتاج

### 9.1 إنشاء مجلد الإنتاج
```cmd
mkdir production_builds
mkdir production_builds\v1.0.0_%date:~-4,4%%date:~-10,2%%date:~-7,2%
```

### 9.2 نسخ الملفات المهمة
```cmd
copy build\app\outputs\flutter-apk\app-release.apk production_builds\v1.0.0_%date:~-4,4%%date:~-10,2%%date:~-7,2%\tashlehekomv2-v1.0.0-release.apk

copy build\app\outputs\bundle\release\app-release.aab production_builds\v1.0.0_%date:~-4,4%%date:~-10,2%%date:~-7,2%\tashlehekomv2-v1.0.0-release.aab
```

### 9.3 إنشاء تقرير البناء
أنشئ ملف `production_builds\v1.0.0_[التاريخ]\build_report.txt`:

```
تقرير بناء تطبيق تشليحكم - الإصدار 1.0.0
==========================================

تاريخ البناء: [التاريخ والوقت]
إصدار Flutter: [إصدار Flutter]
إصدار Dart: [إصدار Dart]

معلومات التطبيق:
- اسم التطبيق: تشليحكم
- Package Name: com.tashlehekomv2.app
- رقم الإصدار: 1.0.0
- رمز الإصدار: 1

ملفات الإخراج:
- APK: tashlehekomv2-v1.0.0-release.apk ([الحجم])
- App Bundle: tashlehekomv2-v1.0.0-release.aab ([الحجم])

معلومات التوقيع:
- Keystore: tashlehekomv2-release-key.jks
- Alias: tashlehekomv2-key
- SHA-1: [SHA-1 fingerprint]

الاختبارات:
- تحليل الكود: ✅ نجح
- الاختبارات الأساسية: ✅ نجح (6/6)
- التحقق من التوقيع: ✅ نجح
- اختبار التثبيت: ✅ نجح

الخدمات المُفعّلة:
- Firebase Authentication: ✅
- Cloud Firestore: ✅
- Firebase Storage: ✅
- Cloud Messaging: ✅
- Firebase Analytics: ✅

ملاحظات:
- التطبيق جاهز للنشر على Google Play Store
- تم اختبار جميع الوظائف الأساسية
- لا توجد أخطاء أو تحذيرات مهمة

الخطوات التالية:
1. رفع App Bundle إلى Google Play Console
2. إعداد صفحة المتجر
3. تشغيل الاختبار الداخلي
4. إرسال للمراجعة والنشر
```

## 🔒 الخطوة 10: الأمان والنسخ الاحتياطية

### 10.1 إنشاء checksums
```cmd
cd production_builds\v1.0.0_%date:~-4,4%%date:~-10,2%%date:~-7,2%
certutil -hashfile tashlehekomv2-v1.0.0-release.apk SHA256 > checksums.txt
certutil -hashfile tashlehekomv2-v1.0.0-release.aab SHA256 >> checksums.txt
```

### 10.2 نسخ احتياطية
- احفظ نسخة في التخزين السحابي
- احفظ نسخة في قرص صلب خارجي
- احتفظ بسجل لجميع الإصدارات

## 📋 قائمة التحقق النهائية

- [ ] تم تحديث إعدادات Firebase للإنتاج
- [ ] تم التحقق من keystore وإعدادات التوقيع
- [ ] تم تنظيف المشروع والحصول على التبعيات
- [ ] تم فحص الكود وتشغيل الاختبارات
- [ ] تم بناء APK و App Bundle بنجاح
- [ ] تم التحقق من التوقيع
- [ ] تم اختبار التطبيق على جهاز حقيقي
- [ ] تم تنظيم ملفات الإنتاج
- [ ] تم إنشاء تقرير البناء
- [ ] تم إنشاء نسخ احتياطية

## 🆘 استكشاف الأخطاء الشائعة

### خطأ: "Keystore file not found"
**الحل**: تأكد من وجود keystore في المسار الصحيح

### خطأ: "Wrong password"
**الحل**: تحقق من كلمات المرور في key.properties

### خطأ: "Firebase configuration error"
**الحل**: تأكد من صحة google-services.json ومفاتيح Firebase

### خطأ: "Build failed"
**الحل**: راجع رسائل الخطأ وأصلح المشاكل المحددة

## 🎉 النجاح!

إذا اكتملت جميع الخطوات بنجاح، فلديك الآن:
- **APK موقع وجاهز للنشر**
- **App Bundle محسن لـ Google Play**
- **تقرير شامل للبناء**
- **نسخ احتياطية آمنة**

**التطبيق جاهز للرفع إلى Google Play Store! 🚀**
