# دليل تثبيت Java وإنشاء Keystore

## 🎯 المطلوب

لإنشاء keystore للتوقيع، نحتاج إلى تثبيت Java JDK أولاً.

## ☕ الخطوة 1: تثبيت Java JDK

### 1.1 تحميل Java JDK
1. اذهب إلى: https://www.oracle.com/java/technologies/downloads/
2. اختر **Java 11** أو **Java 17** (مستقر ومدعوم)
3. اختر نظام التشغيل: **Windows x64**
4. حمّل ملف التثبيت (مثل: `jdk-11.0.20_windows-x64_bin.exe`)

### 1.2 تثبيت Java
1. شغّل ملف التثبيت كمدير (Run as Administrator)
2. اتبع خطوات التثبيت الافتراضية
3. اختر مجلد التثبيت (افتراضي: `C:\Program Files\Java\jdk-11.0.20`)

### 1.3 إعداد متغيرات البيئة
1. اضغط `Win + R`، اكتب `sysdm.cpl`، اضغط Enter
2. انقر على تبويب "Advanced"
3. انقر "Environment Variables"
4. في "System Variables"، انقر "New":
   - **Variable name**: `JAVA_HOME`
   - **Variable value**: `C:\Program Files\Java\jdk-11.0.20`
5. ابحث عن متغير `Path` وانقر "Edit"
6. انقر "New" وأضف: `%JAVA_HOME%\bin`
7. انقر "OK" لحفظ جميع التغييرات

### 1.4 التحقق من التثبيت
افتح Command Prompt جديد واكتب:
```cmd
java -version
javac -version
keytool -help
```

يجب أن ترى معلومات الإصدار لكل أمر.

## 🔑 الخطوة 2: إنشاء Keystore

### 2.1 فتح Command Prompt
1. اضغط `Win + R`
2. اكتب `cmd`
3. اضغط Enter

### 2.2 الانتقال إلى مجلد المشروع
```cmd
cd /d D:\123\tashlehekomv2
```

### 2.3 إنشاء Keystore
```cmd
keytool -genkey -v -keystore android\keystore\tashlehekomv2-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias tashlehekomv2-key
```

### 2.4 ملء المعلومات المطلوبة

سيطلب منك الأمر المعلومات التالية:

#### كلمة مرور keystore:
```
Enter keystore password: TashlehekomSecure2024
Re-enter new password: TashlehekomSecure2024
```

#### كلمة مرور المفتاح:
```
Enter key password for <tashlehekomv2-key>: TashlehekomSecure2024
Re-enter new password: TashlehekomSecure2024
```

#### المعلومات الشخصية:
```
What is your first and last name?
[Unknown]: Tashlehekomv2 Tech

What is the name of your organizational unit?
[Unknown]: Development Team

What is the name of your organization?
[Unknown]: Tashlehekomv2 Company

What is the name of your City or Locality?
[Unknown]: Riyadh

What is the name of your State or Province?
[Unknown]: Riyadh Province

What is the two-letter country code for this unit?
[Unknown]: SA
```

#### تأكيد المعلومات:
```
Is CN=Tashlehekomv2 Tech, OU=Development Team, O=Tashlehekomv2 Company, L=Riyadh, ST=Riyadh Province, C=SA correct?
[no]: yes
```

## 📄 الخطوة 3: إنشاء ملف key.properties

### 3.1 نسخ الملف النموذجي
```cmd
copy android\key.properties.example android\key.properties
```

### 3.2 التحقق من محتوى الملف
افتح `android\key.properties` وتأكد من أنه يحتوي على:
```properties
storePassword=TashlehekomSecure2024
keyPassword=TashlehekomSecure2024
keyAlias=tashlehekomv2-key
storeFile=keystore/tashlehekomv2-release-key.jks
```

## ✅ الخطوة 4: التحقق من keystore

### 4.1 عرض معلومات keystore
```cmd
keytool -list -v -keystore android\keystore\tashlehekomv2-release-key.jks -alias tashlehekomv2-key
```

### 4.2 الحصول على SHA-1 fingerprint
```cmd
keytool -list -v -keystore android\keystore\tashlehekomv2-release-key.jks -alias tashlehekomv2-key | findstr SHA1
```

**احفظ SHA-1 fingerprint - ستحتاجه لإعداد Firebase!**

## 🧪 الخطوة 5: اختبار التوقيع

### 5.1 بناء APK موقع
```cmd
flutter build apk --release
```

### 5.2 التحقق من التوقيع
```cmd
jarsigner -verify -verbose -certs build\app\outputs\flutter-apk\app-release.apk
```

يجب أن ترى: `jar verified.`

## 💾 الخطوة 6: إنشاء نسخ احتياطية

### 6.1 إنشاء مجلد النسخ الاحتياطية
```cmd
mkdir keystore_backup
mkdir keystore_backup\%date:~-4,4%%date:~-10,2%%date:~-7,2%
```

### 6.2 نسخ الملفات المهمة
```cmd
copy android\keystore\tashlehekomv2-release-key.jks keystore_backup\%date:~-4,4%%date:~-10,2%%date:~-7,2%\
copy android\key.properties keystore_backup\%date:~-4,4%%date:~-10,2%%date:~-7,2%\
```

### 6.3 إنشاء ملف معلومات
أنشئ ملف `keystore_backup\keystore_info.txt`:
```
معلومات Keystore لتطبيق تشليحكم
=====================================

تاريخ الإنشاء: [اليوم]
اسم الملف: tashlehekomv2-release-key.jks
اسم المفتاح: tashlehekomv2-key
كلمة مرور keystore: TashlehekomSecure2024
كلمة مرور المفتاح: TashlehekomSecure2024

معلومات الشهادة:
CN=Tashlehekomv2 Tech
OU=Development Team
O=Tashlehekomv2 Company
L=Riyadh
ST=Riyadh Province
C=SA

SHA-1 Fingerprint: [ضع هنا SHA-1 fingerprint]

تحذيرات مهمة:
- احتفظ بهذه المعلومات في مكان آمن
- لا تشارك keystore أو كلمات المرور مع أحد
- فقدان keystore يعني عدم القدرة على تحديث التطبيق
- أنشئ نسخ احتياطية في أماكن متعددة
```

## 🔒 الخطوة 7: تأمين الملفات

### 7.1 إضافة إلى .gitignore
تأكد من أن `.gitignore` يحتوي على:
```
# Keystore files
*.jks
*.keystore
android/key.properties
android/keystore/
keystore_backup/
```

### 7.2 حماية كلمات المرور
- احفظ كلمات المرور في مدير كلمات مرور آمن
- لا تكتبها في ملفات نصية عادية
- لا تشاركها عبر البريد الإلكتروني أو الرسائل

## 🆘 استكشاف الأخطاء

### خطأ: "keytool is not recognized"
**السبب**: Java غير مثبت أو PATH غير مُعدّ
**الحل**: 
1. تأكد من تثبيت Java JDK
2. أعد تشغيل Command Prompt
3. تحقق من متغيرات البيئة

### خطأ: "Keystore was tampered with"
**السبب**: كلمة مرور خاطئة
**الحل**: تأكد من كلمة المرور الصحيحة

### خطأ: "Certificate chain length is 0"
**السبب**: alias خاطئ
**الحل**: استخدم نفس alias المحدد عند الإنشاء

## ✅ قائمة التحقق النهائية

- [ ] تم تثبيت Java JDK بنجاح
- [ ] تم إعداد متغيرات البيئة
- [ ] تم إنشاء keystore بنجاح
- [ ] تم إنشاء ملف key.properties
- [ ] تم الحصول على SHA-1 fingerprint
- [ ] تم اختبار التوقيع بنجاح
- [ ] تم إنشاء نسخ احتياطية
- [ ] تم تأمين الملفات

## 🎯 الخطوات التالية

1. استخدم SHA-1 fingerprint في إعدادات Firebase
2. اختبر بناء APK موقع
3. استعد لرفع التطبيق إلى Google Play Store

**🎉 تهانينا! keystore جاهز للاستخدام في الإنتاج!**
