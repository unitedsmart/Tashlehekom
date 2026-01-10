# دليل إنشاء مشروع Firebase للإنتاج - خطوة بخطوة

## 🚀 الخطوة 1: إنشاء مشروع Firebase

### 1.1 الذهاب إلى Firebase Console
1. افتح المتصفح واذهب إلى: https://console.firebase.google.com/
2. سجل الدخول بحساب Google الخاص بك
3. انقر على "إنشاء مشروع" أو "Create a project"

### 1.2 إعداد المشروع
1. **اسم المشروع**: `tashlehekomv2-production`
2. **معرف المشروع**: `tashlehekomv2-production` (سيتم إنشاؤه تلقائياً)
3. **المنطقة**: اختر `asia-southeast1` (سنغافورة) للأداء الأفضل في المنطقة
4. **Google Analytics**: فعّل الخيار لتتبع الاستخدام
5. انقر "إنشاء المشروع"

## 🔐 الخطوة 2: إعداد Firebase Authentication

### 2.1 تفعيل Authentication
1. من القائمة الجانبية، انقر على "Authentication"
2. انقر على "البدء" أو "Get started"
3. اذهب إلى تبويب "Sign-in method"

### 2.2 تفعيل Phone Authentication
1. انقر على "Phone" من قائمة مقدمي الخدمة
2. فعّل الخيار "Enable"
3. في قسم "Phone numbers for testing" أضف:
   - `+966501234567` (للاختبار)
   - كود التحقق: `123456`
4. انقر "Save"

### 2.3 إعداد reCAPTCHA (للويب)
1. في إعدادات Phone Authentication
2. أضف النطاقات المسموحة:
   - `localhost` (للتطوير)
   - `tashlehekomv2.com` (للإنتاج)

## 🗄️ الخطوة 3: إعداد Cloud Firestore

### 3.1 إنشاء قاعدة البيانات
1. من القائمة الجانبية، انقر على "Firestore Database"
2. انقر "إنشاء قاعدة بيانات" أو "Create database"
3. اختر "Start in production mode"
4. اختر الموقع: `asia-southeast1` (سنغافورة)
5. انقر "Done"

### 3.2 إعداد قواعد الأمان
1. اذهب إلى تبويب "Rules"
2. استبدل القواعد الافتراضية بالقواعد التالية:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // قواعد المستخدمين
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      allow read: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.userType in ['admin', 'superAdmin'];
    }
    
    // قواعد السيارات
    match /cars/{carId} {
      allow read: if true;
      allow create: if request.auth != null && request.auth.uid == resource.data.sellerId;
      allow update, delete: if request.auth != null && 
        (request.auth.uid == resource.data.sellerId || 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.userType in ['admin', 'superAdmin']);
    }
    
    // قواعد المفضلة
    match /favorites/{favoriteId} {
      allow read, write: if request.auth != null && request.auth.uid == resource.data.userId;
    }
    
    // قواعد التقييمات
    match /ratings/{ratingId} {
      allow read: if true;
      allow create: if request.auth != null && request.auth.uid == resource.data.userId;
      allow update, delete: if request.auth != null && 
        (request.auth.uid == resource.data.userId || 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.userType in ['admin', 'superAdmin']);
    }
    
    // قواعد التقارير
    match /reports/{reportId} {
      allow read: if request.auth != null && 
        (request.auth.uid == resource.data.reporterId || 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.userType in ['admin', 'superAdmin']);
      allow create: if request.auth != null && request.auth.uid == resource.data.reporterId;
      allow update: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.userType in ['admin', 'superAdmin'];
    }
    
    // قواعد الإشعارات
    match /notifications/{notificationId} {
      allow read, write: if request.auth != null && request.auth.uid == resource.data.userId;
      allow create: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.userType in ['admin', 'superAdmin'];
    }
    
    // قواعد سجلات الأمان
    match /security_logs/{logId} {
      allow read: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.userType in ['admin', 'superAdmin'];
      allow create: if request.auth != null;
    }
  }
}
```

3. انقر "Publish" لحفظ القواعد

### 3.3 إنشاء الفهارس المطلوبة
1. اذهب إلى تبويب "Indexes"
2. أضف الفهارس التالية:

**فهرس السيارات:**
- Collection: `cars`
- Fields: `city` (Ascending), `brand` (Ascending), `createdAt` (Descending)

**فهرس التقييمات:**
- Collection: `ratings`
- Fields: `sellerId` (Ascending), `createdAt` (Descending)

## 📁 الخطوة 4: إعداد Firebase Storage

### 4.1 إنشاء Storage
1. من القائمة الجانبية، انقر على "Storage"
2. انقر "البدء" أو "Get started"
3. اختر "Start in production mode"
4. اختر الموقع: `asia-southeast1`
5. انقر "Done"

### 4.2 إعداد قواعد Storage
1. اذهب إلى تبويب "Rules"
2. استبدل القواعد بالتالي:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // صور السيارات
    match /cars/{carId}/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null && 
        (request.auth.uid == resource.metadata.uploadedBy ||
         firestore.get(/databases/(default)/documents/users/$(request.auth.uid)).data.userType in ['admin', 'superAdmin']);
    }
    
    // صور المستخدمين
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // ملفات النظام
    match /system/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null && 
        firestore.get(/databases/(default)/documents/users/$(request.auth.uid)).data.userType in ['admin', 'superAdmin'];
    }
  }
}
```

3. انقر "Publish"

## 📱 الخطوة 5: إضافة تطبيق Android

### 5.1 تسجيل التطبيق
1. من الصفحة الرئيسية للمشروع، انقر على أيقونة Android
2. أدخل المعلومات التالية:
   - **Package name**: `com.tashlehekomv2.app`
   - **App nickname**: `Tashlehekom Production`
   - **Debug signing certificate SHA-1**: (سنحصل عليه لاحقاً)
3. انقر "Register app"

### 5.2 تحميل google-services.json
1. انقر "Download google-services.json"
2. احفظ الملف في مجلد `android/app/` في مشروع Flutter
3. انقر "Next"

### 5.3 إضافة Firebase SDK
1. تأكد من أن `build.gradle` يحتوي على:
```gradle
dependencies {
    classpath 'com.google.gms:google-services:4.3.15'
}
```

2. في `android/app/build.gradle`:
```gradle
apply plugin: 'com.google.gms.google-services'
```

3. انقر "Next" ثم "Continue to console"

## 🔔 الخطوة 6: إعداد Cloud Messaging

### 6.1 تفعيل FCM
1. من القائمة الجانبية، انقر على "Cloud Messaging"
2. الخدمة ستكون مفعلة تلقائياً

### 6.2 إعداد الإشعارات
1. يمكنك إرسال إشعار تجريبي للتأكد من العمل
2. استخدم الرمز المميز للجهاز للاختبار

## 📊 الخطوة 7: تفعيل Analytics (اختياري)

### 7.1 إعداد Google Analytics
1. من القائمة الجانبية، انقر على "Analytics"
2. انقر "Enable Google Analytics"
3. اختر حساب Analytics موجود أو أنشئ جديد
4. انقر "Enable Analytics"

## ✅ الخطوة 8: التحقق من الإعداد

### 8.1 قائمة التحقق
- [ ] تم إنشاء المشروع بنجاح
- [ ] تم تفعيل Phone Authentication
- [ ] تم إعداد Firestore مع القواعد
- [ ] تم إعداد Storage مع القواعد
- [ ] تم تحميل google-services.json
- [ ] تم تفعيل Cloud Messaging
- [ ] تم تفعيل Analytics (اختياري)

### 8.2 الحصول على المفاتيح
1. اذهب إلى "Project Settings" (الترس في الأعلى)
2. في تبويب "General"، ستجد:
   - **Project ID**: `tashlehekomv2-production`
   - **Web API Key**: انسخه لاستخدامه في التطبيق
   - **Project Number**: هذا هو Sender ID

### 8.3 تحديث ملف التكوين
استخدم هذه المعلومات لتحديث `lib/firebase_options_production.dart`

## 🔄 الخطوة 9: الاختبار

### 9.1 اختبار الاتصال
1. قم بتشغيل التطبيق مع إعدادات Firebase الجديدة
2. جرب تسجيل الدخول بالهاتف
3. جرب إضافة بيانات إلى Firestore
4. جرب رفع صورة إلى Storage

### 9.2 مراقبة الأخطاء
1. راقب تبويب "Crashlytics" للأخطاء
2. راقب "Analytics" للاستخدام
3. راقب "Performance" للأداء

---

## 📞 الدعم

إذا واجهت أي مشاكل:
1. راجع وثائق Firebase الرسمية
2. تحقق من إعدادات الشبكة والصلاحيات
3. راجع سجلات الأخطاء في Firebase Console

**🎉 تهانينا! مشروع Firebase جاهز للإنتاج!**
