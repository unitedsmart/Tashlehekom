@echo off
echo ========================================
echo    Tashlehekom App Installation Guide
echo ========================================
echo.
echo Method 1: Using ADB (Developer Mode Required)
echo ---------------------------------------------
echo 1. Enable Developer Options on your phone
echo 2. Enable USB Debugging
echo 3. Connect phone to computer
echo 4. Run: adb install app-release.apk
echo.
echo Method 2: Direct Installation
echo -----------------------------
echo 1. Copy APK to phone storage
echo 2. Open file manager
echo 3. Navigate to APK file
echo 4. Tap to install
echo 5. Allow installation from unknown sources when prompted
echo.
echo Method 3: Disable Play Protect Temporarily
echo ------------------------------------------
echo 1. Open Google Play Store
echo 2. Tap profile picture (top right)
echo 3. Select "Play Protect"
echo 4. Tap settings gear icon
echo 5. Turn off "Scan apps with Play Protect"
echo 6. Install the app
echo 7. Re-enable Play Protect after installation
echo.
echo APK Location: build\app\outputs\flutter-apk\app-release.apk
echo APK Size: 18.0 MB
echo.
pause
