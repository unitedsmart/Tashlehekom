import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سياسة الخصوصية'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('مقدمة', '''
نحن في تطبيق "تشليحكم" نقدر خصوصيتك ونلتزم بحماية بياناتك الشخصية. توضح هذه السياسة كيفية جمع واستخدام وحماية معلوماتك.
'''),
            _buildSection('البيانات التي نجمعها', '''
• معلومات الحساب: رقم الجوال، الاسم
• معلومات السيارات: صور السيارات، تفاصيل السيارة، الموقع
• بيانات الاستخدام: تفاعلك مع التطبيق
• الموقع الجغرافي: لعرض التشاليح القريبة منك
'''),
            _buildSection('كيف نستخدم بياناتك', '''
• لتقديم خدمات التطبيق وتحسينها
• للتواصل معك بشأن حسابك
• لعرض السيارات وقطع الغيار المناسبة
• لتحسين تجربة المستخدم
• للأغراض الأمنية ومنع الاحتيال
'''),
            _buildSection('مشاركة البيانات', '''
• لا نبيع بياناتك الشخصية لأطراف ثالثة
• قد نشارك البيانات مع مقدمي الخدمات الموثوقين
• قد نشارك البيانات عند الضرورة القانونية
'''),
            _buildSection('أمان البيانات', '''
نستخدم إجراءات أمنية متقدمة لحماية بياناتك:
• تشفير البيانات أثناء النقل والتخزين
• خوادم آمنة مع Firebase
• مراقبة مستمرة للأنظمة
'''),
            _buildSection('حقوقك', '''
لديك الحق في:
• الوصول إلى بياناتك الشخصية
• تصحيح بياناتك
• حذف حسابك وبياناتك
• الاعتراض على معالجة بياناتك
'''),
            _buildSection('الأذونات المستخدمة', '''
• الكاميرا: لالتقاط صور السيارات
• الموقع: لعرض التشاليح القريبة
• التخزين: لحفظ واختيار الصور
• الهاتف: للاتصال بالبائعين
• الإشعارات: لإرسال التنبيهات المهمة
'''),
            _buildSection('التواصل معنا', '''
للاستفسارات حول سياسة الخصوصية:
البريد الإلكتروني: acc.ibrahim.arboud@gmail.com
الجوال: +966508423246
'''),
            _buildSection('تحديث السياسة', '''
قد نقوم بتحديث هذه السياسة من وقت لآخر. سيتم إعلامك بأي تغييرات جوهرية.

آخر تحديث: يناير 2026
'''),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'تطبيق تشليحكم © 2026',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content.trim(),
            style: const TextStyle(fontSize: 14, height: 1.6),
          ),
        ],
      ),
    );
  }
}

