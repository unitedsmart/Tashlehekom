# دليل إنشاء Keystore للتوقيع - خطوة بخطوة

## 🔐 نظرة عامة

Keystore هو ملف يحتوي على مفاتيح التشفير المستخدمة لتوقيع التطبيق. هذا التوقيع ضروري لنشر التطبيق على Google Play Store ولضمان أن التحديثات المستقبلية تأتي من نفس المطور.

## ⚠️ تحذيرات مهمة

1. **لا تفقد keystore أبداً** - بدونه لن تتمكن من تحديث التطبيق
2. **احتفظ بكلمات المرور في مكان آمن** - فقدانها يعني فقدان القدرة على استخدام keystore
3. **أنشئ نسخ احتياطية متعددة** في أماكن مختلفة وآمنة
4. **لا تشارك keystore مع أحد** - هو بمثابة هويتك كمطور

## 🛠️ الخطوة 1: التحقق من متطلبات النظام

### 1.1 التحقق من Java JDK
```bash
# تحقق من وجود Java
java -version

# تحقق من وجود keytool
keytool -help
```

إذا لم يكن Java مثبتاً:
- **Windows**: حمّل من https://www.oracle.com/java/technologies/downloads/
- **macOS**: `brew install openjdk`
- **Linux**: `sudo apt install openjdk-11-jdk`

## 🔑 الخطوة 2: إنشاء Keystore

### 2.1 فتح Terminal/Command Prompt
1. **Windows**: اضغط `Win + R`، اكتب `cmd`، اضغط Enter
2. **macOS/Linux**: افتح Terminal

### 2.2 الانتقال إلى مجلد المشروع
```bash
cd d:\123\tashlehekomv2
```

### 2.3 إنشاء مجلد للـ keystore
```bash
mkdir android\keystore
cd android\keystore
```

### 2.4 تشغيل أمر إنشاء keystore
```bash
keytool -genkey -v -keystore tashlehekomv2-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias tashlehekomv2-key
```

## 📝 الخطوة 3: ملء المعلومات المطلوبة

سيطلب منك keytool المعلومات التالية:

### 3.1 كلمة مرور keystore
```
Enter keystore password:
```
**مثال**: `TashlehekomSecure2024!@#`
- استخدم كلمة مرور قوية (12+ حرف)
- امزج بين الأحرف والأرقام والرموز
- **احفظها في مكان آمن!**

### 3.2 تأكيد كلمة المرور
```
Re-enter new password:
```
أعد كتابة نفس كلمة المرور

### 3.3 كلمة مرور المفتاح
```
Enter key password for <tashlehekomv2-key>:
```
يمكنك:
- استخدام نفس كلمة مرور keystore (اضغط Enter)
- أو استخدام كلمة مرور مختلفة

### 3.4 المعلومات الشخصية/التنظيمية

#### الاسم الأول والأخير
```
What is your first and last name?
[Unknown]: 
```
**مثال**: `Ahmed Al-Saudi`

#### الوحدة التنظيمية
```
What is the name of your organizational unit?
[Unknown]:
```
**مثال**: `Development Team`

#### اسم المنظمة
```
What is the name of your organization?
[Unknown]:
```
**مثال**: `Tashlehekomv2 Tech`

#### المدينة
```
What is the name of your City or Locality?
[Unknown]:
```
**مثال**: `Riyadh`

#### الولاية/المقاطعة
```
What is the name of your State or Province?
[Unknown]:
```
**مثال**: `Riyadh Province`

#### رمز البلد
```
What is the two-letter country code for this unit?
[Unknown]:
```
**مثال**: `SA`

### 3.5 تأكيد المعلومات
```
Is CN=Ahmed Al-Saudi, OU=Development Team, O=Tashlehekomv2 Tech, L=Riyadh, ST=Riyadh Province, C=SA correct?
[no]:
```
اكتب `yes` واضغط Enter

## 📄 الخطوة 4: إنشاء ملف key.properties

### 4.1 إنشاء الملف
في مجلد `android/`، أنشئ ملف `key.properties`:

```bash
cd ..
echo storePassword=TashlehekomSecure2024!@# > key.properties
echo keyPassword=TashlehekomSecure2024!@# >> key.properties
echo keyAlias=tashlehekomv2-key >> key.properties
echo storeFile=keystore/tashlehekomv2-release-key.jks >> key.properties
```

### 4.2 محتوى الملف
```properties
storePassword=TashlehekomSecure2024!@#
keyPassword=TashlehekomSecure2024!@#
keyAlias=tashlehekomv2-key
storeFile=keystore/tashlehekomv2-release-key.jks
```

## 🔒 الخطوة 5: تأمين الملفات

### 5.1 تعيين صلاحيات الملفات (Linux/macOS)
```bash
chmod 600 key.properties
chmod 600 keystore/tashlehekomv2-release-key.jks
```

### 5.2 إضافة إلى .gitignore
تأكد من أن `.gitignore` يحتوي على:
```
# Keystore files
*.jks
*.keystore
android/key.properties
android/keystore/
keystore_backup/
```

## 💾 الخطوة 6: إنشاء نسخ احتياطية

### 6.1 إنشاء مجلد النسخ الاحتياطية
```bash
mkdir keystore_backup
mkdir keystore_backup\$(date +%Y%m%d)
```

### 6.2 نسخ الملفات
```bash
copy android\keystore\tashlehekomv2-release-key.jks keystore_backup\$(date +%Y%m%d)\
copy android\key.properties keystore_backup\$(date +%Y%m%d)\
```

### 6.3 إنشاء ملف معلومات
أنشئ ملف `keystore_backup/keystore_info.txt`:
```
معلومات Keystore لتطبيق تشليحكم
=====================================

تاريخ الإنشاء: [التاريخ]
اسم الملف: tashlehekomv2-release-key.jks
اسم المفتاح (Alias): tashlehekomv2-key
صالح حتى: [التاريخ + 27 سنة]

كلمة مرور keystore: [احفظها في مكان آمن]
كلمة مرور المفتاح: [احفظها في مكان آمن]

معلومات الشهادة:
- الاسم: Ahmed Al-Saudi
- الوحدة: Development Team
- المنظمة: Tashlehekomv2 Tech
- المدينة: Riyadh
- الولاية: Riyadh Province
- البلد: SA

تحذيرات:
- لا تشارك هذه المعلومات مع أحد
- احتفظ بنسخ احتياطية في أماكن متعددة
- فقدان keystore يعني عدم القدرة على تحديث التطبيق
```

## ✅ الخطوة 7: التحقق من keystore

### 7.1 عرض معلومات keystore
```bash
keytool -list -v -keystore android\keystore\tashlehekomv2-release-key.jks -alias tashlehekomv2-key
```

### 7.2 التحقق من SHA-1 fingerprint
```bash
keytool -list -v -keystore android\keystore\tashlehekomv2-release-key.jks -alias tashlehekomv2-key | findstr SHA1
```

احفظ SHA-1 fingerprint - ستحتاجه لإعداد Firebase

## 🧪 الخطوة 8: اختبار التوقيع

### 8.1 بناء APK موقع للاختبار
```bash
flutter build apk --release
```

### 8.2 التحقق من التوقيع
```bash
jarsigner -verify -verbose -certs build\app\outputs\flutter-apk\app-release.apk
```

يجب أن ترى رسالة: `jar verified.`

## 📋 الخطوة 9: قائمة التحقق النهائية

- [ ] تم إنشاء keystore بنجاح
- [ ] تم إنشاء ملف key.properties
- [ ] تم حفظ كلمات المرور في مكان آمن
- [ ] تم إنشاء نسخ احتياطية
- [ ] تم إضافة الملفات إلى .gitignore
- [ ] تم اختبار التوقيع بنجاح
- [ ] تم حفظ SHA-1 fingerprint

## 🆘 استكشاف الأخطاء

### خطأ: "keytool is not recognized"
**الحل**: تأكد من تثبيت Java JDK وإضافة مسار bin إلى PATH

### خطأ: "Keystore was tampered with"
**الحل**: تحقق من كلمة المرور أو أعد إنشاء keystore

### خطأ: "Certificate chain length is 0"
**الحل**: تأكد من استخدام نفس alias المحدد عند الإنشاء

## 📞 الدعم

إذا واجهت مشاكل:
1. راجع وثائق Android الرسمية
2. تحقق من إعدادات Java
3. تأكد من صحة كلمات المرور

**🎉 تهانينا! keystore جاهز للاستخدام!**

---

## 🔄 الخطوات التالية

1. استخدم SHA-1 fingerprint في إعدادات Firebase
2. اختبر بناء APK موقع
3. احتفظ بنسخ احتياطية آمنة
4. استعد لرفع التطبيق إلى Google Play Store
