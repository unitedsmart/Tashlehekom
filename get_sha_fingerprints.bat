@echo off
echo ========================================
echo   استخراج SHA1 و SHA256 Fingerprints
echo ========================================
echo.

echo جاري البحث عن Java keytool...
echo.

REM البحث عن Java في المسارات المختلفة
set JAVA_HOME_PATHS="%JAVA_HOME%" "C:\Program Files\Java\jdk*" "C:\Program Files\Java\jre*" "C:\Program Files (x86)\Java\jdk*" "C:\Program Files (x86)\Java\jre*" "%ANDROID_HOME%\jre" "%LOCALAPPDATA%\Android\Sdk\jre"

for %%i in (%JAVA_HOME_PATHS%) do (
    if exist "%%~i\bin\keytool.exe" (
        set KEYTOOL_PATH=%%~i\bin\keytool.exe
        goto :found_keytool
    )
)

REM البحث في Flutter SDK
for /f "tokens=*" %%i in ('where flutter 2^>nul') do (
    set FLUTTER_PATH=%%i
    goto :check_flutter_java
)

:check_flutter_java
if defined FLUTTER_PATH (
    for %%i in ("%FLUTTER_PATH%") do set FLUTTER_DIR=%%~dpi
    if exist "%FLUTTER_DIR%\..\jre\bin\keytool.exe" (
        set KEYTOOL_PATH=%FLUTTER_DIR%\..\jre\bin\keytool.exe
        goto :found_keytool
    )
)

echo ❌ لم يتم العثور على Java keytool
echo يرجى تثبيت Java JDK أو JRE
pause
exit /b 1

:found_keytool
echo ✅ تم العثور على keytool: %KEYTOOL_PATH%
echo.

REM البحث عن debug keystore
set KEYSTORE_PATHS="%USERPROFILE%\.android\debug.keystore" "%ANDROID_HOME%\debug.keystore" "android\debug.keystore"

for %%i in (%KEYSTORE_PATHS%) do (
    if exist "%%~i" (
        set KEYSTORE_PATH=%%~i
        goto :found_keystore
    )
)

echo ❌ لم يتم العثور على debug.keystore
echo يرجى التأكد من وجود الملف في: %USERPROFILE%\.android\debug.keystore
pause
exit /b 1

:found_keystore
echo ✅ تم العثور على keystore: %KEYSTORE_PATH%
echo.

echo جاري استخراج SHA Fingerprints...
echo.

"%KEYTOOL_PATH%" -list -v -keystore "%KEYSTORE_PATH%" -alias androiddebugkey -storepass android -keypass android > temp_keystore_info.txt 2>&1

if %ERRORLEVEL% neq 0 (
    echo ❌ فشل في قراءة keystore
    type temp_keystore_info.txt
    del temp_keystore_info.txt
    pause
    exit /b 1
)

echo ========================================
echo           SHA FINGERPRINTS
echo ========================================
echo.

REM استخراج SHA1
for /f "tokens=2 delims=:" %%i in ('findstr /C:"SHA1:" temp_keystore_info.txt') do (
    set SHA1=%%i
    set SHA1=!SHA1: =!
    echo 🔑 SHA1: !SHA1!
)

REM استخراج SHA256
for /f "tokens=2 delims=:" %%i in ('findstr /C:"SHA256:" temp_keystore_info.txt') do (
    set SHA256=%%i
    set SHA256=!SHA256: =!
    echo 🔑 SHA256: !SHA256!
)

echo.
echo ========================================
echo      معلومات للنسخ إلى Firebase
echo ========================================
echo.
echo أضف هذه القيم إلى Firebase Console:
echo https://console.firebase.google.com/project/tashlehekom/settings/general
echo.
echo في قسم "Your apps" → Android app → SHA certificate fingerprints
echo.

del temp_keystore_info.txt

echo.
echo اضغط أي مفتاح للخروج...
pause >nul
