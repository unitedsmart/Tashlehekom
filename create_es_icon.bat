@echo off
echo ========================================
echo    إنشاء أيقونة ES - United Saudi
echo ========================================
echo.

echo جاري إنشاء مجلدات الأيقونات...

REM إنشاء مجلدات الأيقونات للأندرويد
mkdir "android\app\src\main\res\mipmap-mdpi" 2>nul
mkdir "android\app\src\main\res\mipmap-hdpi" 2>nul
mkdir "android\app\src\main\res\mipmap-xhdpi" 2>nul
mkdir "android\app\src\main\res\mipmap-xxhdpi" 2>nul
mkdir "android\app\src\main\res\mipmap-xxxhdpi" 2>nul
mkdir "assets\images" 2>nul

echo ✅ تم إنشاء المجلدات

echo.
echo 📋 الخطوات التالية:
echo ========================================
echo 1. افتح الملف: convert_new_icon.html في المتصفح
echo 2. حمّل جميع أحجام الأيقونات:
echo    - 48x48 (mdpi)
echo    - 72x72 (hdpi) 
echo    - 96x96 (xhdpi)
echo    - 144x144 (xxhdpi)
echo    - 192x192 (xxxhdpi)
echo    - 512x512 (أساسي)
echo.
echo 3. ضع الملفات في المجلدات التالية:
echo    - ic_launcher_mdpi.png → android\app\src\main\res\mipmap-mdpi\ic_launcher.png
echo    - ic_launcher_hdpi.png → android\app\src\main\res\mipmap-hdpi\ic_launcher.png
echo    - ic_launcher_xhdpi.png → android\app\src\main\res\mipmap-xhdpi\ic_launcher.png
echo    - ic_launcher_xxhdpi.png → android\app\src\main\res\mipmap-xxhdpi\ic_launcher.png
echo    - ic_launcher_xxxhdpi.png → android\app\src\main\res\mipmap-xxxhdpi\ic_launcher.png
echo    - app_icon_512.png → assets\images\app_icon.png
echo.
echo 4. اضغط أي مفتاح لفتح المتصفح...
pause >nul

start "" "convert_new_icon.html"

echo.
echo 5. بعد تحميل الأيقونات، اضغط أي مفتاح لبناء التطبيق...
pause >nul

echo.
echo جاري بناء التطبيق مع الأيقونة الجديدة...
flutter clean
flutter build apk --release --no-shrink

echo.
echo ========================================
echo ✅ تم الانتهاء!
echo ========================================
echo الأيقونة الجديدة جاهزة في:
echo build\app\outputs\flutter-apk\app-release.apk
echo.
pause
