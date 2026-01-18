import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('شروط الاستخدام'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('مقدمة', '''
مرحباً بك في تطبيق "تشليحكم". باستخدامك للتطبيق، فإنك توافق على الالتزام بهذه الشروط والأحكام.
'''),
            _buildSection('الخدمات المقدمة', '''
يوفر تطبيق تشليحكم منصة لـ:
• عرض وبيع السيارات المستعملة وقطع الغيار
• التواصل بين البائعين والمشترين
• طلب قطع غيار محددة
• تصفح التشاليح ومحلات قطع الغيار
'''),
            _buildSection('شروط الاستخدام', '''
• يجب أن يكون عمرك 18 عاماً أو أكثر
• يجب تقديم معلومات صحيحة ودقيقة
• أنت مسؤول عن الحفاظ على سرية حسابك
• يُحظر استخدام التطبيق لأغراض غير قانونية
'''),
            _buildSection('قواعد النشر', '''
عند نشر إعلان، يجب:
• أن تكون المعلومات صحيحة ودقيقة
• أن تكون الصور حقيقية للسيارة/القطعة
• عدم نشر محتوى مخالف أو مسيء
• عدم نشر إعلانات مكررة
• الالتزام بالأسعار المعلنة
'''),
            _buildSection('المسؤولية', '''
• التطبيق وسيط بين البائع والمشتري فقط
• لا نتحمل مسؤولية جودة السيارات أو القطع
• ننصح بفحص السيارة قبل الشراء
• المعاملات المالية تتم بين الطرفين مباشرة
'''),
            _buildSection('حقوق الملكية', '''
• جميع حقوق التطبيق محفوظة لـ "تشليحكم"
• يُحظر نسخ أو توزيع محتوى التطبيق
• العلامات التجارية مملوكة لأصحابها
'''),
            _buildSection('إنهاء الحساب', '''
يحق لنا إنهاء أو تعليق حسابك في حال:
• مخالفة شروط الاستخدام
• نشر محتوى مخالف
• الاحتيال أو التضليل
• الإساءة للمستخدمين الآخرين
'''),
            _buildSection('التعديلات', '''
نحتفظ بحق تعديل هذه الشروط في أي وقت. استمرارك في استخدام التطبيق يعني موافقتك على التعديلات.

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

