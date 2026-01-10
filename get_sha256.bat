@echo off
echo ========================================
echo   استخراج SHA-256 Fingerprint
echo ========================================
echo.

REM البحث عن Java في مسارات مختلفة
set JAVA_PATH=""
if exist "%JAVA_HOME%\bin\keytool.exe" (
    set JAVA_PATH="%JAVA_HOME%\bin\keytool.exe"
    echo تم العثور على Java في JAVA_HOME
) else if exist "C:\Program Files\Java\jdk*\bin\keytool.exe" (
    for /d %%i in ("C:\Program Files\Java\jdk*") do (
        if exist "%%i\bin\keytool.exe" (
            set JAVA_PATH="%%i\bin\keytool.exe"
            echo تم العثور على Java في: %%i
            goto :found
        )
    )
) else if exist "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" (
    set JAVA_PATH="C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe"
    echo تم العثور على Java في Android Studio
) else (
    echo لم يتم العثور على Java keytool
    echo يرجى تثبيت Java أو Android Studio
    pause
    exit /b 1
)

:found
echo.
echo استخراج SHA-256 من debug keystore...
echo.

REM مسار debug keystore
set KEYSTORE_PATH="%USERPROFILE%\.android\debug.keystore"

if not exist %KEYSTORE_PATH% (
    echo لم يتم العثور على debug keystore في: %KEYSTORE_PATH%
    echo يرجى تشغيل flutter build apk أولاً
    pause
    exit /b 1
)

echo تشغيل keytool...
%JAVA_PATH% -list -v -keystore %KEYSTORE_PATH% -alias androiddebugkey -storepass android -keypass android

echo.
echo ========================================
echo   تم الانتهاء
echo ========================================
echo.
echo ابحث عن "SHA256:" في النتائج أعلاه
echo انسخ القيمة وأضفها إلى Firebase Console
echo.
pause
