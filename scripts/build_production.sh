#!/bin/bash

# سكريبت بناء تطبيق تشليحكم للإنتاج
# Build script for Tashlehekom Production

set -e  # إيقاف السكريبت عند حدوث خطأ

echo "🚀 بدء بناء تطبيق تشليحكم للإنتاج..."
echo "=================================================="

# التحقق من وجود Flutter
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter غير مثبت. يرجى تثبيت Flutter أولاً."
    exit 1
fi

# التحقق من إصدار Flutter
echo "📋 التحقق من إصدار Flutter..."
flutter --version

# التحقق من وجود ملف key.properties
if [ ! -f "android/key.properties" ]; then
    echo "❌ ملف android/key.properties غير موجود."
    echo "يرجى إنشاء ملف key.properties مع معلومات التوقيع."
    exit 1
fi

# التحقق من وجود keystore
KEYSTORE_FILE=$(grep "storeFile" android/key.properties | cut -d'=' -f2)
if [ ! -f "android/$KEYSTORE_FILE" ]; then
    echo "❌ ملف keystore غير موجود: android/$KEYSTORE_FILE"
    echo "يرجى إنشاء keystore للتوقيع."
    exit 1
fi

# التحقق من وجود google-services.json
if [ ! -f "android/app/google-services.json" ]; then
    echo "❌ ملف google-services.json غير موجود."
    echo "يرجى تحميل الملف من Firebase Console."
    exit 1
fi

# تنظيف المشروع
echo "🧹 تنظيف المشروع..."
flutter clean

# الحصول على التبعيات
echo "📦 الحصول على التبعيات..."
flutter pub get

# تشغيل code generation إذا كان مطلوباً
echo "🔧 تشغيل code generation..."
flutter packages pub run build_runner build --delete-conflicting-outputs

# التحقق من عدم وجود أخطاء في الكود
echo "🔍 فحص الكود..."
flutter analyze

# تشغيل الاختبارات
echo "🧪 تشغيل الاختبارات..."
flutter test test/basic_test.dart

# إنشاء مجلد للمخرجات
OUTPUT_DIR="build_outputs/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUTPUT_DIR"

echo "📁 مجلد المخرجات: $OUTPUT_DIR"

# بناء APK للإنتاج
echo "🔨 بناء APK للإنتاج..."
flutter build apk --release --verbose

# نسخ APK إلى مجلد المخرجات
cp build/app/outputs/flutter-apk/app-release.apk "$OUTPUT_DIR/tashlehekomv2-release.apk"

# بناء App Bundle للإنتاج (مفضل لـ Google Play)
echo "📦 بناء App Bundle للإنتاج..."
flutter build appbundle --release --verbose

# نسخ App Bundle إلى مجلد المخرجات
cp build/app/outputs/bundle/release/app-release.aab "$OUTPUT_DIR/tashlehekomv2-release.aab"

# الحصول على معلومات البناء
echo "📊 جمع معلومات البناء..."

# حجم APK
APK_SIZE=$(du -h "$OUTPUT_DIR/tashlehekomv2-release.apk" | cut -f1)

# حجم App Bundle
AAB_SIZE=$(du -h "$OUTPUT_DIR/tashlehekomv2-release.aab" | cut -f1)

# معلومات التوقيع
echo "🔐 التحقق من التوقيع..."
jarsigner -verify -verbose -certs "$OUTPUT_DIR/tashlehekomv2-release.apk" > "$OUTPUT_DIR/signature_verification.txt"

# إنشاء تقرير البناء
cat > "$OUTPUT_DIR/build_report.txt" << EOF
تقرير بناء تطبيق تشليحكم
============================

تاريخ البناء: $(date)
إصدار Flutter: $(flutter --version | head -n1)
إصدار Dart: $(dart --version)

ملفات الإخراج:
- APK: tashlehekomv2-release.apk ($APK_SIZE)
- App Bundle: tashlehekomv2-release.aab ($AAB_SIZE)

معلومات التوقيع:
$(keytool -printcert -jarfile "$OUTPUT_DIR/tashlehekomv2-release.apk" 2>/dev/null | head -n10)

الاختبارات:
- تم تشغيل الاختبارات الأساسية: ✅
- تم فحص الكود: ✅
- تم التحقق من التوقيع: ✅

الملفات المطلوبة للنشر:
- ✅ APK موقع
- ✅ App Bundle موقع
- ✅ تقرير التوقيع
- ✅ معلومات البناء

الخطوات التالية:
1. اختبار APK على أجهزة مختلفة
2. رفع App Bundle إلى Google Play Console
3. إعداد صفحة المتجر
4. تشغيل الاختبار الداخلي
5. النشر للمراجعة

EOF

# إنشاء checksums للملفات
echo "🔒 إنشاء checksums..."
cd "$OUTPUT_DIR"
sha256sum *.apk *.aab > checksums.txt
cd - > /dev/null

# عرض النتائج
echo ""
echo "✅ تم بناء التطبيق بنجاح!"
echo "=================================================="
echo "📁 مجلد المخرجات: $OUTPUT_DIR"
echo "📱 APK: $APK_SIZE"
echo "📦 App Bundle: $AAB_SIZE"
echo ""
echo "الملفات المنشأة:"
ls -la "$OUTPUT_DIR"
echo ""

# نصائح للنشر
echo "💡 نصائح للنشر:"
echo "1. اختبر APK على أجهزة مختلفة قبل النشر"
echo "2. استخدم App Bundle للنشر على Google Play"
echo "3. احتفظ بنسخة احتياطية من keystore"
echo "4. راجع تقرير البناء في: $OUTPUT_DIR/build_report.txt"
echo ""

# فتح مجلد المخرجات (على Windows)
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    explorer "$OUTPUT_DIR"
fi

echo "🎉 انتهى بناء التطبيق بنجاح!"
