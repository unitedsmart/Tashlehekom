# إعداد Firebase للإنتاج - تطبيق تشليحكم

## 📋 خطوات إنشاء مشروع Firebase للإنتاج

### 1. إنشاء مشروع Firebase جديد

1. **الذهاب إلى Firebase Console:**
   - زيارة: https://console.firebase.google.com/
   - تسجيل الدخول بحساب Google

2. **إنشاء مشروع جديد:**
   - النقر على "Create a project"
   - اسم المشروع: `tashlehekomv2-production`
   - تفعيل Google Analytics (اختياري)
   - اختيار المنطقة: `asia-southeast1` (سنغافورة - الأقرب للسعودية)

### 2. تكوين Firebase Authentication

```javascript
// إعدادات Authentication
{
  "providers": [
    {
      "providerId": "phone",
      "enabled": true,
      "testPhoneNumbers": {
        "+966501234567": "123456"  // للاختبار فقط
      }
    }
  ],
  "signInOptions": {
    "phoneNumber": {
      "enabled": true,
      "recaptchaEnforcement": "AUDIT"
    }
  }
}
```

**خطوات التكوين:**
1. الذهاب إلى Authentication > Sign-in method
2. تفعيل Phone provider
3. إضافة أرقام الاختبار (اختياري)
4. حفظ الإعدادات

### 3. تكوين Cloud Firestore

```javascript
// قواعد Firestore للإنتاج
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
      allow read: if true; // قراءة عامة
      allow create: if request.auth != null && 
        request.auth.uid == resource.data.sellerId;
      allow update, delete: if request.auth != null && 
        (request.auth.uid == resource.data.sellerId || 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.userType in ['admin', 'superAdmin']);
    }
    
    // قواعد المفضلة
    match /favorites/{favoriteId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.userId;
    }
    
    // قواعد التقييمات
    match /ratings/{ratingId} {
      allow read: if true;
      allow create: if request.auth != null && 
        request.auth.uid == resource.data.raterId;
      allow update, delete: if request.auth != null && 
        (request.auth.uid == resource.data.raterId || 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.userType in ['admin', 'superAdmin']);
    }
    
    // قواعد التقارير
    match /reports/{reportId} {
      allow read: if request.auth != null && 
        (request.auth.uid == resource.data.reporterId || 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.userType in ['admin', 'superAdmin']);
      allow create: if request.auth != null && 
        request.auth.uid == resource.data.reporterId;
      allow update: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.userType in ['admin', 'superAdmin'];
    }
    
    // قواعد الإشعارات
    match /notifications/{notificationId} {
      allow read: if request.auth != null && 
        request.auth.uid == resource.data.userId;
      allow create: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.userType in ['admin', 'superAdmin'];
    }
    
    // قواعد سجلات الأمان (للإداريين فقط)
    match /security_logs/{logId} {
      allow read, write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.userType in ['admin', 'superAdmin'];
    }
  }
}
```

**خطوات التكوين:**
1. الذهاب إلى Firestore Database
2. إنشاء قاعدة بيانات في Production mode
3. اختيار المنطقة: `asia-southeast1`
4. تطبيق القواعد أعلاه في Rules tab

### 4. تكوين Firebase Storage

```javascript
// قواعد Storage للإنتاج
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // صور السيارات
    match /cars/{carId}/{allPaths=**} {
      allow read: if true; // قراءة عامة للصور
      allow write: if request.auth != null && 
        (request.auth.uid == carId.split('_')[0] || 
         isAdmin());
    }
    
    // صور المستخدمين
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && 
        (request.auth.uid == userId || isAdmin());
    }
    
    // دالة مساعدة للتحقق من الإدارة
    function isAdmin() {
      return request.auth != null && 
        firestore.get(/databases/(default)/documents/users/$(request.auth.uid)).data.userType in ['admin', 'superAdmin'];
    }
  }
}
```

**خطوات التكوين:**
1. الذهاب إلى Storage
2. إنشاء bucket جديد
3. اختيار المنطقة: `asia-southeast1`
4. تطبيق القواعد أعلاه

### 5. تكوين Firebase Cloud Messaging

**خطوات التكوين:**
1. الذهاب إلى Cloud Messaging
2. تفعيل الخدمة
3. إنشاء Server Key للإشعارات
4. تكوين إعدادات الإشعارات

### 6. إعداد Firebase للتطبيق

**للأندرويد:**
1. إضافة تطبيق Android جديد
2. Package name: `com.tashlehekomv2.app`
3. تحميل `google-services.json`
4. وضع الملف في `android/app/`

**معلومات التطبيق:**
```json
{
  "package_name": "com.tashlehekomv2.app",
  "app_name": "تشليحكم",
  "sha1_certificate_fingerprints": [
    "YOUR_SHA1_FINGERPRINT_HERE"
  ]
}
```

### 7. متغيرات البيئة للإنتاج

```dart
// lib/config/production_config.dart
class ProductionConfig {
  static const String firebaseProjectId = 'tashlehekomv2-production';
  static const String firebaseApiKey = 'YOUR_PRODUCTION_API_KEY';
  static const String firebaseAppId = 'YOUR_PRODUCTION_APP_ID';
  static const String firebaseMessagingSenderId = 'YOUR_SENDER_ID';
  static const String firebaseStorageBucket = 'tashlehekomv2-production.appspot.com';
  
  // إعدادات أخرى
  static const bool isProduction = true;
  static const String appVersion = '1.0.0';
  static const int buildNumber = 1;
}
```

### 8. قائمة التحقق النهائية

- [ ] إنشاء مشروع Firebase للإنتاج
- [ ] تكوين Authentication مع Phone provider
- [ ] إعداد Firestore مع قواعد الأمان
- [ ] تكوين Storage مع قواعد الوصول
- [ ] تفعيل Cloud Messaging
- [ ] إضافة التطبيق Android للمشروع
- [ ] تحميل google-services.json
- [ ] تحديث متغيرات البيئة
- [ ] اختبار الاتصال مع Firebase
- [ ] تطبيق قواعد الأمان
- [ ] إعداد النسخ الاحتياطية

### 9. أوامر مفيدة

```bash
# تحديث Firebase CLI
npm install -g firebase-tools

# تسجيل الدخول
firebase login

# تهيئة المشروع
firebase init

# نشر قواعد Firestore
firebase deploy --only firestore:rules

# نشر قواعد Storage
firebase deploy --only storage

# عرض المشاريع
firebase projects:list
```

### 10. معلومات الاتصال والدعم

- **Firebase Console:** https://console.firebase.google.com/
- **Documentation:** https://firebase.google.com/docs
- **Support:** https://firebase.google.com/support

---

**ملاحظة:** يجب استبدال جميع القيم النموذجية بالقيم الحقيقية من مشروع Firebase الخاص بك.
