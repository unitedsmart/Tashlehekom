@echo off
echo ========================================
echo    تطبيق تشليحكم - Tashlehekom App
echo ========================================
echo.

echo جاري التحقق من وجود ملف APK...
if exist "build\app\outputs\flutter-apk\app-release.apk" (
    echo ✅ تم العثور على ملف APK
    echo.
    echo معلومات الملف:
    dir "build\app\outputs\flutter-apk\app-release.apk" | findstr "app-release.apk"
    echo.
    echo ========================================
    echo خيارات التثبيت:
    echo ========================================
    echo 1. نسخ APK إلى سطح المكتب
    echo 2. فتح مجلد APK
    echo 3. عرض دليل التثبيت
    echo 4. خروج
    echo.
    set /p choice="اختر رقم الخيار (1-4): "
    
    if "%choice%"=="1" (
        echo.
        echo جاري نسخ APK إلى سطح المكتب...
        copy "build\app\outputs\flutter-apk\app-release.apk" "%USERPROFILE%\Desktop\Tashlehekom.apk"
        if %errorlevel%==0 (
            echo ✅ تم نسخ الملف بنجاح إلى سطح المكتب باسم: Tashlehekom.apk
            echo.
            echo الآن يمكنك:
            echo - نقل الملف إلى هاتفك عبر USB
            echo - إرساله عبر البلوتوث
            echo - رفعه على Google Drive وتحميله على الهاتف
        ) else (
            echo ❌ فشل في نسخ الملف
        )
    ) else if "%choice%"=="2" (
        echo.
        echo فتح مجلد APK...
        explorer "build\app\outputs\flutter-apk\"
    ) else if "%choice%"=="3" (
        echo.
        echo فتح دليل التثبيت...
        if exist "APK_INSTALLATION_GUIDE.md" (
            notepad "APK_INSTALLATION_GUIDE.md"
        ) else (
            echo ❌ لم يتم العثور على دليل التثبيت
        )
    ) else if "%choice%"=="4" (
        echo.
        echo شكراً لاستخدام تطبيق تشليحكم!
        goto end
    ) else (
        echo.
        echo ❌ خيار غير صحيح
    )
) else (
    echo ❌ لم يتم العثور على ملف APK
    echo.
    echo يرجى التأكد من:
    echo 1. تم بناء التطبيق بنجاح
    echo 2. وجود المجلد: build\app\outputs\flutter-apk\
    echo 3. وجود الملف: app-release.apk
    echo.
    echo لبناء التطبيق، استخدم الأمر:
    echo flutter build apk --release --no-shrink
)

echo.
echo ========================================
echo نصائح مهمة للتثبيت:
echo ========================================
echo 1. فعّل "تثبيت من مصادر غير معروفة" في إعدادات الأمان
echo 2. إذا ظهرت رسالة Google Play Protect، اختر "Install anyway"
echo 3. امنح جميع الأذونات المطلوبة (SMS, Phone, Storage)
echo 4. للاختبار، استخدم رقم الإدارة: 0508423246
echo.

:end
pause
