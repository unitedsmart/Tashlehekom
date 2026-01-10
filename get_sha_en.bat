@echo off
setlocal enabledelayedexpansion

echo ========================================
echo   Extracting SHA1 and SHA256 Fingerprints
echo ========================================
echo.

echo Looking for Java keytool...
echo.

REM Search for Java in different paths
set KEYTOOL_PATH=

REM Check JAVA_HOME first
if defined JAVA_HOME (
    if exist "%JAVA_HOME%\bin\keytool.exe" (
        set KEYTOOL_PATH=%JAVA_HOME%\bin\keytool.exe
        goto :found_keytool
    )
)

REM Check common Java installation paths
for %%i in ("C:\Program Files\Java\jdk*" "C:\Program Files\Java\jre*" "C:\Program Files (x86)\Java\jdk*" "C:\Program Files (x86)\Java\jre*") do (
    for /d %%j in (%%i) do (
        if exist "%%j\bin\keytool.exe" (
            set KEYTOOL_PATH=%%j\bin\keytool.exe
            goto :found_keytool
        )
    )
)

REM Check Android SDK
if defined ANDROID_HOME (
    if exist "%ANDROID_HOME%\jre\bin\keytool.exe" (
        set KEYTOOL_PATH=%ANDROID_HOME%\jre\bin\keytool.exe
        goto :found_keytool
    )
)

REM Try to find keytool in PATH
where keytool.exe >nul 2>&1
if %ERRORLEVEL% equ 0 (
    set KEYTOOL_PATH=keytool.exe
    goto :found_keytool
)

echo ERROR: Java keytool not found
echo Please install Java JDK or JRE
pause
exit /b 1

:found_keytool
echo SUCCESS: Found keytool at: %KEYTOOL_PATH%
echo.

REM Search for debug keystore
set KEYSTORE_PATH=

if exist "%USERPROFILE%\.android\debug.keystore" (
    set KEYSTORE_PATH=%USERPROFILE%\.android\debug.keystore
    goto :found_keystore
)

if exist "android\debug.keystore" (
    set KEYSTORE_PATH=android\debug.keystore
    goto :found_keystore
)

echo ERROR: debug.keystore not found
echo Please make sure the file exists at: %USERPROFILE%\.android\debug.keystore
pause
exit /b 1

:found_keystore
echo SUCCESS: Found keystore at: %KEYSTORE_PATH%
echo.

echo Extracting SHA Fingerprints...
echo.

"%KEYTOOL_PATH%" -list -v -keystore "%KEYSTORE_PATH%" -alias androiddebugkey -storepass android -keypass android > temp_keystore_info.txt 2>&1

if %ERRORLEVEL% neq 0 (
    echo ERROR: Failed to read keystore
    type temp_keystore_info.txt
    del temp_keystore_info.txt
    pause
    exit /b 1
)

echo ========================================
echo           SHA FINGERPRINTS
echo ========================================
echo.

REM Extract SHA1
for /f "tokens=2 delims=:" %%i in ('findstr /C:"SHA1:" temp_keystore_info.txt') do (
    set SHA1=%%i
    set SHA1=!SHA1: =!
    echo SHA1: !SHA1!
)

REM Extract SHA256
for /f "tokens=2 delims=:" %%i in ('findstr /C:"SHA256:" temp_keystore_info.txt') do (
    set SHA256=%%i
    set SHA256=!SHA256: =!
    echo SHA256: !SHA256!
)

echo.
echo ========================================
echo      Copy to Firebase Console
echo ========================================
echo.
echo Add these values to Firebase Console:
echo https://console.firebase.google.com/project/tashlehekom/settings/general
echo.
echo In "Your apps" section - Android app - SHA certificate fingerprints
echo.

del temp_keystore_info.txt

echo.
echo Press any key to exit...
pause >nul
