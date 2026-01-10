# تعليمات بناء APK لتطبيق تشليحكم

## المشكلة الحالية
- مساحة القرص ممتلئة مما يمنع بناء APK
- المكتبات الثقيلة مثل Firebase و Google Maps تحتاج مساحة كبيرة

## الحلول المقترحة

### 1. تنظيف مساحة القرص
```bash
# حذف ملفات Gradle المؤقتة
rm -rf ~/.gradle/caches/
rm -rf ~/.gradle/wrapper/

# حذف ملفات Flutter المؤقتة  
flutter clean
rm -rf ~/.pub-cache/

# حذف ملفات Android SDK غير المستخدمة
```

### 2. بناء APK مبسط
```bash
# بناء APK للهندسة المعمارية الواحدة فقط (ARM64)
flutter build apk --release --target-platform android-arm64

# أو بناء APK صغير الحجم
flutter build apk --release --shrink --obfuscate --split-debug-info=debug-info/
```

### 3. استخدام بناء تدريجي
```bash
# بناء debug أولاً (أسرع وأقل استهلاكاً للمساحة)
flutter build apk --debug

# ثم بناء release
flutter build apk --release
```

## الملفات المعدلة للتبسيط
- تم تعليق Firebase packages في pubspec.yaml
- تم تعليق Google Maps packages
- تم تعليق Location packages

## التطبيق الحالي يحتوي على:
✅ واجهة المستخدم الكاملة
✅ قاعدة البيانات المحلية (SQLite)
✅ إدارة الحالة (Provider)
✅ التقييمات والتعليقات
✅ رفع الصور
✅ البحث والفلترة
✅ لوحة الإدارة

## ما تم إزالته مؤقتاً:
❌ Firebase Authentication (يمكن استخدام OTP محلي)
❌ Google Maps (يمكن استخدام نص الموقع)
❌ GPS Location (يمكن إدخال الموقع يدوياً)

## خطوات البناء النهائية:
1. تنظيف مساحة القرص
2. `flutter clean`
3. `flutter pub get`
4. `flutter build apk --release --target-platform android-arm64`

## موقع APK النهائي:
`build/app/outputs/flutter-apk/app-release.apk`
