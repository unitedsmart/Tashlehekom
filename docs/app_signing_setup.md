# إعداد توقيع التطبيق للنشر على Google Play Store

## 📋 خطوات إنشاء مفاتيح التوقيع

### 1. إنشاء Upload Key

```bash
# إنشاء keystore جديد
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# معلومات مطلوبة:
# - كلمة المرور للـ keystore
# - كلمة المرور للـ key
# - الاسم الأول والأخير
# - اسم الوحدة التنظيمية
# - اسم المنظمة
# - اسم المدينة أو المنطقة
# - اسم الولاية أو المقاطعة
# - رمز البلد المكون من حرفين
```

### 2. إعداد ملف key.properties

```properties
# android/key.properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=../upload-keystore.jks
```

### 3. تحديث android/app/build.gradle

```gradle
// إضافة في أعلى الملف
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    // ... باقي الإعدادات

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
}
```

### 4. إعداد proguard-rules.pro

```proguard
# android/app/proguard-rules.pro

# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Gson
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Models
-keep class com.tashlehekomv2.models.** { *; }

# OkHttp
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**
-keepnames class okhttp3.internal.publicsuffix.PublicSuffixDatabase

# Retrofit
-dontwarn retrofit2.**
-keep class retrofit2.** { *; }
-keepattributes Signature
-keepattributes Exceptions

# SQLite
-keep class org.sqlite.** { *; }
-keep class org.sqlite.database.** { *; }
```

### 5. تحديث android/app/src/main/AndroidManifest.xml

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.tashlehekomv2.app">

    <!-- الصلاحيات المطلوبة -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.CALL_PHONE" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    <uses-permission android:name="android.permission.RECEIVE_SMS" />
    <uses-permission android:name="android.permission.READ_SMS" />

    <application
        android:label="تشليحكم"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher"
        android:usesCleartextTraffic="false"
        android:allowBackup="false"
        android:fullBackupContent="false">
        
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            
            <meta-data
              android:name="io.flutter.embedding.android.NormalTheme"
              android:resource="@style/NormalTheme" />
              
            <intent-filter android:autoVerify="true">
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>

        <!-- Firebase Cloud Messaging -->
        <service
            android:name="io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingService"
            android:exported="false">
            <intent-filter>
                <action android:name="com.google.firebase.MESSAGING_EVENT" />
            </intent-filter>
        </service>

        <!-- Don't delete the meta-data below.
             This is used by the Flutter tool to generate GeneratedPluginRegistrant.java -->
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
```

### 6. إعداد الأيقونات

```bash
# إنشاء أيقونات التطبيق
flutter packages pub run flutter_launcher_icons:main

# أو استخدام أداة أخرى
# ضع الأيقونات في:
# android/app/src/main/res/mipmap-hdpi/ic_launcher.png (72x72)
# android/app/src/main/res/mipmap-mdpi/ic_launcher.png (48x48)
# android/app/src/main/res/mipmap-xhdpi/ic_launcher.png (96x96)
# android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png (144x144)
# android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png (192x192)
```

### 7. بناء APK الإنتاج

```bash
# تنظيف المشروع
flutter clean

# الحصول على التبعيات
flutter pub get

# بناء APK موقع
flutter build apk --release

# أو بناء App Bundle (مفضل لـ Google Play)
flutter build appbundle --release

# الملفات الناتجة:
# build/app/outputs/flutter-apk/app-release.apk
# build/app/outputs/bundle/release/app-release.aab
```

### 8. التحقق من التوقيع

```bash
# التحقق من توقيع APK
jarsigner -verify -verbose -certs build/app/outputs/flutter-apk/app-release.apk

# عرض معلومات التوقيع
keytool -printcert -jarfile build/app/outputs/flutter-apk/app-release.apk
```

### 9. إعداد Google Play Console

1. **إنشاء حساب Google Play Console:**
   - زيارة: https://play.google.com/console/
   - دفع رسوم التسجيل ($25)

2. **إنشاء تطبيق جديد:**
   - اسم التطبيق: "تشليحكم"
   - اللغة الافتراضية: العربية
   - نوع التطبيق: تطبيق
   - مجاني أم مدفوع: مجاني

3. **رفع App Bundle:**
   - الذهاب إلى Production > Create new release
   - رفع ملف app-release.aab
   - إضافة Release notes

### 10. معلومات مهمة للأمان

```bash
# نسخ احتياطي من keystore
cp upload-keystore.jks backup/upload-keystore-backup.jks

# حفظ معلومات keystore بأمان
echo "Keystore Password: YOUR_PASSWORD" > keystore-info.txt
echo "Key Password: YOUR_KEY_PASSWORD" >> keystore-info.txt
echo "Key Alias: upload" >> keystore-info.txt

# تشفير الملف
gpg -c keystore-info.txt
rm keystore-info.txt
```

### 11. قائمة التحقق النهائية

- [ ] إنشاء upload keystore
- [ ] إعداد key.properties
- [ ] تحديث build.gradle
- [ ] إعداد proguard rules
- [ ] تحديث AndroidManifest.xml
- [ ] إنشاء أيقونات التطبيق
- [ ] بناء APK/AAB موقع
- [ ] التحقق من التوقيع
- [ ] إنشاء حساب Google Play Console
- [ ] رفع التطبيق للمراجعة
- [ ] حفظ نسخة احتياطية من keystore

### 12. أوامر مفيدة

```bash
# عرض SHA-1 fingerprint
keytool -list -v -keystore upload-keystore.jks -alias upload

# تحويل JKS إلى PKCS12
keytool -importkeystore -srckeystore upload-keystore.jks -destkeystore upload-keystore.p12 -deststoretype PKCS12

# فحص حجم APK
flutter build apk --analyze-size

# بناء مع تفاصيل إضافية
flutter build apk --release --verbose
```

---

**تحذير:** احتفظ بملف keystore وكلمات المرور في مكان آمن. فقدانها يعني عدم القدرة على تحديث التطبيق في المستقبل!
