# دليل إنشاء موقع إلكتروني لاستضافة السياسات

## 🌐 نظرة عامة

Google Play Store يتطلب أن تكون سياسة الخصوصية وشروط الخدمة متاحة على موقع إلكتروني عام. هذا الدليل يوضح كيفية إنشاء موقع بسيط وسريع لهذا الغرض.

## 🚀 الخيارات المتاحة

### 1. GitHub Pages (مجاني ومُوصى به)
- **التكلفة**: مجاني تماماً
- **السهولة**: سهل جداً
- **الوقت**: 15-30 دقيقة
- **الرابط**: yourname.github.io

### 2. Netlify (مجاني)
- **التكلفة**: مجاني للاستخدام الأساسي
- **السهولة**: سهل
- **الوقت**: 20-40 دقيقة
- **الرابط**: yourname.netlify.app

### 3. Firebase Hosting (مجاني)
- **التكلفة**: مجاني للاستخدام الأساسي
- **السهولة**: متوسط
- **الوقت**: 30-60 دقيقة
- **الرابط**: yourproject.web.app

### 4. استضافة مدفوعة (Namecheap, GoDaddy)
- **التكلفة**: 50-200 ريال سنوياً
- **السهولة**: متوسط
- **الوقت**: 1-2 ساعة
- **الرابط**: tashlehekomv2.com

## 📋 الطريقة الأولى: GitHub Pages (الأسرع والأسهل)

### الخطوة 1: إنشاء حساب GitHub
1. اذهب إلى https://github.com
2. انقر على "Sign up"
3. أنشئ حساب باسم مستخدم مثل: `tashlehekomv2`
4. تأكد من البريد الإلكتروني

### الخطوة 2: إنشاء مستودع جديد
1. انقر على "New repository"
2. اسم المستودع: `tashlehekomv2.github.io`
3. اجعله عام (Public)
4. أضف README file
5. انقر على "Create repository"

### الخطوة 3: إضافة الملفات
1. انقر على "Add file" > "Create new file"
2. أنشئ الملفات التالية:

#### ملف `index.html`:
```html
<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>تشليحكم - منصة قطع غيار السيارات</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            line-height: 1.6;
            margin: 0;
            padding: 20px;
            background-color: #f5f5f5;
            color: #333;
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 0 20px rgba(0,0,0,0.1);
        }
        h1 {
            color: #1B5E20;
            text-align: center;
            border-bottom: 3px solid #4CAF50;
            padding-bottom: 10px;
        }
        .nav {
            text-align: center;
            margin: 30px 0;
        }
        .nav a {
            display: inline-block;
            margin: 10px;
            padding: 15px 30px;
            background: #4CAF50;
            color: white;
            text-decoration: none;
            border-radius: 5px;
            transition: background 0.3s;
        }
        .nav a:hover {
            background: #45a049;
        }
        .footer {
            text-align: center;
            margin-top: 40px;
            padding-top: 20px;
            border-top: 1px solid #ddd;
            color: #666;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚗 تشليحكم</h1>
        <p style="text-align: center; font-size: 18px; color: #666;">
            منصة قطع غيار السيارات الأولى في المملكة العربية السعودية
        </p>
        
        <div class="nav">
            <a href="privacy-policy.html">سياسة الخصوصية</a>
            <a href="terms-of-service.html">شروط الخدمة</a>
            <a href="support.html">الدعم الفني</a>
        </div>
        
        <div style="text-align: center; margin: 40px 0;">
            <h2>حمّل التطبيق الآن</h2>
            <p>متوفر قريباً على Google Play Store</p>
            <img src="https://via.placeholder.com/200x60/4CAF50/FFFFFF?text=Google+Play" alt="Google Play" style="border-radius: 5px;">
        </div>
        
        <div class="footer">
            <p>&copy; 2024 شركة تشليحكم للتقنية. جميع الحقوق محفوظة.</p>
            <p>البريد الإلكتروني: info@tashlehekomv2.com | الهاتف: +966501234567</p>
        </div>
    </div>
</body>
</html>
```

#### ملف `privacy-policy.html`:
```html
<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>سياسة الخصوصية - تشليحكم</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            line-height: 1.6;
            margin: 0;
            padding: 20px;
            background-color: #f5f5f5;
            color: #333;
        }
        .container {
            max-width: 900px;
            margin: 0 auto;
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 0 20px rgba(0,0,0,0.1);
        }
        h1 {
            color: #1B5E20;
            border-bottom: 3px solid #4CAF50;
            padding-bottom: 10px;
        }
        h2 {
            color: #2E7D32;
            margin-top: 30px;
        }
        .back-link {
            display: inline-block;
            margin-bottom: 20px;
            padding: 10px 20px;
            background: #4CAF50;
            color: white;
            text-decoration: none;
            border-radius: 5px;
        }
        .back-link:hover {
            background: #45a049;
        }
    </style>
</head>
<body>
    <div class="container">
        <a href="index.html" class="back-link">← العودة للرئيسية</a>
        
        <!-- هنا يتم نسخ محتوى سياسة الخصوصية من الملف السابق -->
        <h1>سياسة الخصوصية - تطبيق تشليحكم</h1>
        <p><strong>تاريخ آخر تحديث: 2 أكتوبر 2024</strong></p>
        
        <!-- باقي المحتوى... -->
        
    </div>
</body>
</html>
```

### الخطوة 4: تفعيل GitHub Pages
1. اذهب إلى إعدادات المستودع (Settings)
2. انتقل إلى قسم "Pages"
3. اختر "Deploy from a branch"
4. اختر "main" branch
5. انقر على "Save"

### الخطوة 5: الوصول للموقع
- الرابط سيكون: `https://tashlehekomv2.github.io`
- قد يستغرق 5-10 دقائق ليصبح متاحاً

## 🔧 الطريقة الثانية: Netlify

### الخطوة 1: إنشاء حساب
1. اذهب إلى https://netlify.com
2. انقر على "Sign up"
3. يمكن التسجيل بحساب GitHub

### الخطوة 2: إنشاء موقع جديد
1. انقر على "New site from Git"
2. اختر GitHub
3. اختر المستودع الذي أنشأته
4. انقر على "Deploy site"

### الخطوة 3: تخصيص الرابط
1. اذهب إلى "Site settings"
2. انقر على "Change site name"
3. غيّر الاسم إلى "tashlehekomv2"
4. الرابط سيصبح: `https://tashlehekomv2.netlify.app`

## 📱 الطريقة الثالثة: Firebase Hosting

### الخطوة 1: إعداد Firebase CLI
```bash
npm install -g firebase-tools
firebase login
firebase init hosting
```

### الخطوة 2: إنشاء الملفات
1. أنشئ مجلد `public`
2. أضف ملفات HTML داخله
3. قم بالتحديث:
```bash
firebase deploy
```

## 🛠️ إضافة المحتوى

### ملفات HTML المطلوبة:
1. **index.html** - الصفحة الرئيسية
2. **privacy-policy.html** - سياسة الخصوصية
3. **terms-of-service.html** - شروط الخدمة
4. **support.html** - صفحة الدعم الفني

### محتوى إضافي مُوصى به:
- **about.html** - عن التطبيق
- **contact.html** - التواصل معنا
- **faq.html** - الأسئلة الشائعة

## 🎨 تحسين التصميم

### CSS أساسي:
```css
/* ألوان التطبيق */
:root {
    --primary-color: #1B5E20;
    --secondary-color: #4CAF50;
    --accent-color: #FFD700;
    --text-color: #333;
    --bg-color: #f5f5f5;
}

/* تصميم متجاوب */
@media (max-width: 768px) {
    .container {
        padding: 15px;
        margin: 10px;
    }
    
    .nav a {
        display: block;
        margin: 5px 0;
    }
}
```

## 📋 قائمة التحقق

### قبل النشر:
- [ ] جميع الروابط تعمل بشكل صحيح
- [ ] المحتوى باللغة العربية ومقروء
- [ ] التصميم متجاوب مع الهواتف
- [ ] معلومات الاتصال صحيحة
- [ ] تاريخ آخر تحديث محدث

### بعد النشر:
- [ ] اختبار الموقع على أجهزة مختلفة
- [ ] التأكد من سرعة التحميل
- [ ] اختبار جميع الروابط
- [ ] إضافة الرابط إلى Google Play Console

## 🔗 الروابط المطلوبة لـ Google Play

بعد إنشاء الموقع، ستحتاج هذه الروابط:

```
الموقع الرئيسي: https://tashlehekomv2.github.io
سياسة الخصوصية: https://tashlehekomv2.github.io/privacy-policy.html
شروط الخدمة: https://tashlehekomv2.github.io/terms-of-service.html
الدعم الفني: https://tashlehekomv2.github.io/support.html
```

## 💡 نصائح إضافية

### للأمان:
- استخدم HTTPS دائماً
- تأكد من صحة جميع المعلومات
- حدّث المحتوى بانتظام

### للتحسين:
- أضف Google Analytics لتتبع الزوار
- استخدم أدوات SEO الأساسية
- تأكد من سرعة التحميل

### للصيانة:
- راجع المحتوى شهرياً
- حدّث معلومات الاتصال عند الحاجة
- تابع أي تغييرات في متطلبات Google Play

**🌐 الموقع الإلكتروني البسيط جاهز لدعم نشر التطبيق على Google Play Store!**
