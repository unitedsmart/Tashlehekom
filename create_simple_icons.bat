@echo off
echo ========================================
echo    إنشاء أيقونات بسيطة للتطبيق
echo ========================================

REM نسخ الأيقونات الموجودة من مجلد آخر أو إنشاء أيقونات بسيطة
echo جاري إنشاء أيقونات بسيطة...

REM إنشاء أيقونة بسيطة باستخدام ImageMagick إذا كان متوفراً
where magick >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo تم العثور على ImageMagick، جاري إنشاء الأيقونات...
    
    REM إنشاء أيقونة أساسية
    magick -size 192x192 xc:white -fill "#295490" -font Arial-Bold -pointsize 60 -gravity center -annotate +0-10 "ES" -fill "#666666" -pointsize 14 -annotate +0+40 "United Saudi" android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png
    magick android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png -resize 144x144 android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png
    magick android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png -resize 96x96 android/app/src/main/res/mipmap-xhdpi/ic_launcher.png
    magick android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png -resize 72x72 android/app/src/main/res/mipmap-hdpi/ic_launcher.png
    magick android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png -resize 48x48 android/app/src/main/res/mipmap-mdpi/ic_launcher.png
    
    echo ✅ تم إنشاء الأيقونات بنجاح!
) else (
    echo ❌ ImageMagick غير متوفر
    echo 📝 يرجى تحميل الأيقونات يدوياً من: auto_create_icons.html
    echo.
    echo 🌐 فتح مولد الأيقونات في المتصفح...
    start "" "auto_create_icons.html"
    echo.
    echo ⏳ انتظر حتى تحمل الأيقونات، ثم اضغط أي مفتاح للمتابعة...
    pause >nul
)

echo.
echo 🔨 جاري بناء التطبيق...
flutter clean
flutter build apk --release --no-shrink

echo.
echo ========================================
echo ✅ تم الانتهاء!
echo ========================================
echo APK جاهز في: build\app\outputs\flutter-apk\app-release.apk
echo.
pause
