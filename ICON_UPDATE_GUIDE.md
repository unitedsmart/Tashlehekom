# 🎨 تحديث أيقونة التطبيق إلى ES - United Saudi

## 📋 **الخطوات المطلوبة:**

### **1. إنشاء الأيقونات:**
- **افتح الملف:** `create_simple_es_icon.html` في المتصفح
- **اضغط على "تحميل جميع الأحجام"**
- **ستحصل على 6 ملفات:**
  - `ic_launcher_mdpi.png` (48x48)
  - `ic_launcher_hdpi.png` (72x72)
  - `ic_launcher_xhdpi.png` (96x96)
  - `ic_launcher_xxhdpi.png` (144x144)
  - `ic_launcher_xxxhdpi.png` (192x192)
  - `ic_launcher_main.png` (512x512)

### **2. وضع الأيقونات في المجلدات الصحيحة:**

```
ic_launcher_mdpi.png → android/app/src/main/res/mipmap-mdpi/ic_launcher.png
ic_launcher_hdpi.png → android/app/src/main/res/mipmap-hdpi/ic_launcher.png
ic_launcher_xhdpi.png → android/app/src/main/res/mipmap-xhdpi/ic_launcher.png
ic_launcher_xxhdpi.png → android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png
ic_launcher_xxxhdpi.png → android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png
ic_launcher_main.png → assets/images/app_icon.png
```

### **3. تحديث اسم التطبيق (اختياري):**

في `android/app/src/main/res/values/strings.xml`:
```xml
<string name="app_name">ES United Saudi</string>
```

في `android/app/src/main/res/values-ar/strings.xml`:
```xml
<string name="app_name">ES المتحدة السعودية</string>
```

### **4. بناء التطبيق:**
```bash
flutter clean
flutter build apk --release --no-shrink
```

---

## 🎯 **تصميم الأيقونة الجديدة:**

### **المواصفات:**
- **الخلفية:** بيضاء مع حدود رمادية فاتحة
- **النص الرئيسي:** "ES" بخط كبير وأزرق داكن (#295490)
- **النص الفرعي:** "United Saudi" بخط صغير ورمادي
- **الشكل:** دائري مع تصميم نظيف وبسيط

### **الألوان:**
- **الأزرق الداكن:** #295490 (للنص الرئيسي)
- **الرمادي:** #666666 (للنص الفرعي)
- **الأبيض:** #ffffff (للخلفية)
- **الرمادي الفاتح:** #e0e0e0 (للحدود)

---

## ⚡ **للتنفيذ السريع:**

1. **افتح:** `create_simple_es_icon.html`
2. **حمّل الأيقونات**
3. **انسخ الملفات للمجلدات المناسبة**
4. **شغّل:** `flutter build apk --release --no-shrink`

---

## 📱 **النتيجة المتوقعة:**

- **أيقونة جديدة:** ES - United Saudi
- **تصميم احترافي:** يعكس الهوية السعودية
- **وضوح عالي:** في جميع أحجام الشاشات
- **تناسق مع التطبيق:** يتماشى مع موضوع السيارات

**الأيقونة الجديدة ستظهر بعد إعادة تثبيت التطبيق! 🎊**
