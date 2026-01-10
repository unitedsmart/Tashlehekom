#!/bin/bash

# سكريبت إنشاء keystore لتوقيع تطبيق تشليحكم
# Script to create keystore for signing Tashlehekomv2 app

set -e

echo "🔐 إنشاء keystore لتوقيع تطبيق تشليحكم"
echo "============================================"

# التحقق من وجود keytool
if ! command -v keytool &> /dev/null; then
    echo "❌ keytool غير موجود. يرجى تثبيت Java JDK."
    exit 1
fi

# معلومات keystore
KEYSTORE_NAME="upload-keystore.jks"
KEY_ALIAS="upload"
VALIDITY_DAYS=10000

echo "📋 معلومات keystore:"
echo "اسم الملف: $KEYSTORE_NAME"
echo "اسم المفتاح: $KEY_ALIAS"
echo "صالح لمدة: $VALIDITY_DAYS يوم (~27 سنة)"
echo ""

# التحقق من عدم وجود keystore مسبقاً
if [ -f "android/$KEYSTORE_NAME" ]; then
    echo "⚠️  keystore موجود مسبقاً في android/$KEYSTORE_NAME"
    read -p "هل تريد إنشاء keystore جديد؟ (سيتم حذف القديم) [y/N]: " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "تم إلغاء العملية."
        exit 0
    fi
    rm "android/$KEYSTORE_NAME"
fi

echo "🔧 إنشاء keystore جديد..."
echo "سيتم طلب المعلومات التالية:"
echo "1. كلمة مرور keystore (احتفظ بها بأمان!)"
echo "2. كلمة مرور المفتاح (يمكن أن تكون نفس كلمة مرور keystore)"
echo "3. الاسم الأول والأخير"
echo "4. اسم الوحدة التنظيمية (مثل: IT Department)"
echo "5. اسم المنظمة (مثل: Tashlehekomv2 Tech)"
echo "6. اسم المدينة (مثل: Riyadh)"
echo "7. اسم الولاية (مثل: Riyadh Province)"
echo "8. رمز البلد (SA للسعودية)"
echo ""

# إنشاء keystore
keytool -genkey -v \
    -keystore "android/$KEYSTORE_NAME" \
    -keyalg RSA \
    -keysize 2048 \
    -validity $VALIDITY_DAYS \
    -alias $KEY_ALIAS

# التحقق من إنشاء keystore
if [ -f "android/$KEYSTORE_NAME" ]; then
    echo ""
    echo "✅ تم إنشاء keystore بنجاح!"
    echo "📁 الموقع: android/$KEYSTORE_NAME"
    
    # عرض معلومات keystore
    echo ""
    echo "📋 معلومات keystore:"
    keytool -list -v -keystore "android/$KEYSTORE_NAME" -alias $KEY_ALIAS
    
    # إنشاء ملف key.properties إذا لم يكن موجوداً
    if [ ! -f "android/key.properties" ]; then
        echo ""
        echo "📝 إنشاء ملف key.properties..."
        
        read -s -p "أدخل كلمة مرور keystore: " STORE_PASSWORD
        echo
        read -s -p "أدخل كلمة مرور المفتاح: " KEY_PASSWORD
        echo
        
        cat > android/key.properties << EOF
storePassword=$STORE_PASSWORD
keyPassword=$KEY_PASSWORD
keyAlias=$KEY_ALIAS
storeFile=../$KEYSTORE_NAME
EOF
        
        echo "✅ تم إنشاء android/key.properties"
        
        # تأمين ملف key.properties
        chmod 600 android/key.properties
        
        echo ""
        echo "⚠️  تحذير مهم:"
        echo "احتفظ بكلمات المرور في مكان آمن!"
        echo "فقدان keystore أو كلمات المرور يعني عدم القدرة على تحديث التطبيق!"
    else
        echo ""
        echo "ℹ️  ملف key.properties موجود مسبقاً."
        echo "يرجى تحديثه بمعلومات keystore الجديد إذا لزم الأمر."
    fi
    
    # إنشاء نسخة احتياطية
    BACKUP_DIR="keystore_backup/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    cp "android/$KEYSTORE_NAME" "$BACKUP_DIR/"
    
    echo ""
    echo "💾 تم إنشاء نسخة احتياطية في: $BACKUP_DIR"
    
    # نصائح الأمان
    echo ""
    echo "🔒 نصائح الأمان:"
    echo "1. احتفظ بنسخة احتياطية من keystore في مكان آمن"
    echo "2. لا تشارك keystore أو كلمات المرور مع أحد"
    echo "3. استخدم كلمات مرور قوية"
    echo "4. احتفظ بسجل آمن لكلمات المرور"
    echo "5. لا تضع keystore في نظام التحكم بالإصدارات (git)"
    
    # إضافة keystore إلى .gitignore
    if [ -f ".gitignore" ]; then
        if ! grep -q "*.jks" .gitignore; then
            echo "" >> .gitignore
            echo "# Keystore files" >> .gitignore
            echo "*.jks" >> .gitignore
            echo "*.keystore" >> .gitignore
            echo "android/key.properties" >> .gitignore
            echo "keystore_backup/" >> .gitignore
            echo ""
            echo "✅ تم إضافة keystore إلى .gitignore"
        fi
    fi
    
    echo ""
    echo "🎉 تم إعداد keystore بنجاح!"
    echo "يمكنك الآن بناء APK موقع باستخدام:"
    echo "flutter build apk --release"
    
else
    echo "❌ فشل في إنشاء keystore"
    exit 1
fi
