@echo off
echo ========================================
echo   Extract SHA-256 Fingerprint
echo ========================================
echo.

REM Find Java in different paths
set JAVA_PATH=""
if exist "%JAVA_HOME%\bin\keytool.exe" (
    set JAVA_PATH="%JAVA_HOME%\bin\keytool.exe"
    echo Found Java in JAVA_HOME
) else (
    for /d %%i in ("C:\Program Files\Java\jdk*") do (
        if exist "%%i\bin\keytool.exe" (
            set JAVA_PATH="%%i\bin\keytool.exe"
            echo Found Java in: %%i
            goto :found
        )
    )
    if exist "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" (
        set JAVA_PATH="C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe"
        echo Found Java in Android Studio
    ) else (
        echo Java keytool not found
        echo Please install Java or Android Studio
        pause
        exit /b 1
    )
)

:found
echo.
echo Extracting SHA-256 from debug keystore...
echo.

REM Debug keystore path
set KEYSTORE_PATH="%USERPROFILE%\.android\debug.keystore"

if not exist %KEYSTORE_PATH% (
    echo Debug keystore not found at: %KEYSTORE_PATH%
    echo Please run flutter build apk first
    pause
    exit /b 1
)

echo Running keytool...
%JAVA_PATH% -list -v -keystore %KEYSTORE_PATH% -alias androiddebugkey -storepass android -keypass android

echo.
echo ========================================
echo   Completed
echo ========================================
echo.
echo Look for "SHA256:" in the output above
echo Copy the value and add it to Firebase Console
echo.
pause
