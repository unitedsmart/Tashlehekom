# تحديث إعدادات Firebase 🔥

## إذا أنشأت مشروع Firebase جديد:

### 1. تحميل ملفات التكوين الجديدة:

#### للأندرويد:
1. في Firebase Console → Project Settings ⚙️
2. انقر على أيقونة Android
3. حمل `google-services.json`
4. ضعه في: `android/app/google-services.json`

#### لـ iOS (إذا كنت تستخدمه):
1. في Firebase Console → Project Settings ⚙️
2. انقر على أيقونة iOS
3. حمل `GoogleService-Info.plist`
4. ضعه في: `ios/Runner/GoogleService-Info.plist`

### 2. تفعيل الخدمات المطلوبة:

#### في Firebase Console:
- ✅ **Authentication** → Sign-in method → Phone
- ✅ **Firestore Database** → Create database
- ✅ **Storage** → Get started (يتطلب Blaze Plan)
- ✅ **Analytics** (اختياري)

### 3. إعداد قواعد الأمان:

#### Firestore Rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

#### Storage Rules:
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### 4. تشغيل التطبيق:
```bash
flutter clean
flutter pub get
flutter run
```
