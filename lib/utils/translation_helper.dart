import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../l10n/app_localizations.dart';

class TranslationHelper {
  static String translate(BuildContext context, String arabicText, String englishText) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    return languageProvider.isArabic ? arabicText : englishText;
  }

  static Widget buildLocalizedText(
    BuildContext context, 
    String arabicText, 
    String englishText, {
    TextStyle? style,
    TextAlign? textAlign,
  }) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return Text(
          languageProvider.isArabic ? arabicText : englishText,
          style: style,
          textAlign: textAlign,
        );
      },
    );
  }

  static Widget buildLocalizedTitle(
    BuildContext context,
    String arabicTitle,
    String englishTitle, {
    double fontSize = 18,
    FontWeight fontWeight = FontWeight.bold,
    Color? color,
  }) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return Text(
          languageProvider.isArabic ? arabicTitle : englishTitle,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: color,
          ),
        );
      },
    );
  }

  static Widget buildLocalizedSubtitle(
    BuildContext context,
    String arabicSubtitle,
    String englishSubtitle, {
    double fontSize = 14,
    Color? color,
  }) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return Text(
          languageProvider.isArabic ? arabicSubtitle : englishSubtitle,
          style: TextStyle(
            fontSize: fontSize,
            color: color ?? Colors.grey[600],
          ),
        );
      },
    );
  }

  static Widget buildLocalizedButton(
    BuildContext context,
    String arabicText,
    String englishText,
    VoidCallback onPressed, {
    Color? backgroundColor,
    Color? foregroundColor,
    IconData? icon,
  }) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        if (icon != null) {
          return ElevatedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon),
            label: Text(languageProvider.isArabic ? arabicText : englishText),
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              foregroundColor: foregroundColor,
            ),
          );
        } else {
          return ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              foregroundColor: foregroundColor,
            ),
            child: Text(languageProvider.isArabic ? arabicText : englishText),
          );
        }
      },
    );
  }

  static Widget buildLocalizedAppBar(
    BuildContext context,
    String arabicTitle,
    String englishTitle, {
    Color? backgroundColor,
    Color? foregroundColor,
    List<Widget>? actions,
  }) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return AppBar(
          title: Text(languageProvider.isArabic ? arabicTitle : englishTitle),
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          actions: actions,
        );
      },
    );
  }

  static SnackBar buildLocalizedSnackBar(
    BuildContext context,
    String arabicMessage,
    String englishMessage, {
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
  }) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    return SnackBar(
      content: Text(languageProvider.isArabic ? arabicMessage : englishMessage),
      backgroundColor: backgroundColor,
      duration: duration,
    );
  }

  static AlertDialog buildLocalizedDialog(
    BuildContext context,
    String arabicTitle,
    String englishTitle,
    String arabicContent,
    String englishContent, {
    List<Widget>? actions,
  }) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    return AlertDialog(
      title: Text(languageProvider.isArabic ? arabicTitle : englishTitle),
      content: Text(languageProvider.isArabic ? arabicContent : englishContent),
      actions: actions,
    );
  }

  // Common translations for all screens
  static const Map<String, Map<String, String>> commonTranslations = {
    'save': {'ar': 'حفظ', 'en': 'Save'},
    'cancel': {'ar': 'إلغاء', 'en': 'Cancel'},
    'close': {'ar': 'إغلاق', 'en': 'Close'},
    'ok': {'ar': 'موافق', 'en': 'OK'},
    'yes': {'ar': 'نعم', 'en': 'Yes'},
    'no': {'ar': 'لا', 'en': 'No'},
    'loading': {'ar': 'جاري التحميل...', 'en': 'Loading...'},
    'error': {'ar': 'خطأ', 'en': 'Error'},
    'success': {'ar': 'تم بنجاح', 'en': 'Success'},
    'warning': {'ar': 'تحذير', 'en': 'Warning'},
    'info': {'ar': 'معلومات', 'en': 'Information'},
    'confirm': {'ar': 'تأكيد', 'en': 'Confirm'},
    'delete': {'ar': 'حذف', 'en': 'Delete'},
    'edit': {'ar': 'تعديل', 'en': 'Edit'},
    'add': {'ar': 'إضافة', 'en': 'Add'},
    'search': {'ar': 'بحث', 'en': 'Search'},
    'filter': {'ar': 'فلترة', 'en': 'Filter'},
    'sort': {'ar': 'ترتيب', 'en': 'Sort'},
    'share': {'ar': 'مشاركة', 'en': 'Share'},
    'download': {'ar': 'تحميل', 'en': 'Download'},
    'upload': {'ar': 'رفع', 'en': 'Upload'},
    'send': {'ar': 'إرسال', 'en': 'Send'},
    'receive': {'ar': 'استقبال', 'en': 'Receive'},
    'connect': {'ar': 'اتصال', 'en': 'Connect'},
    'disconnect': {'ar': 'قطع الاتصال', 'en': 'Disconnect'},
    'online': {'ar': 'متصل', 'en': 'Online'},
    'offline': {'ar': 'غير متصل', 'en': 'Offline'},
    'available': {'ar': 'متاح', 'en': 'Available'},
    'unavailable': {'ar': 'غير متاح', 'en': 'Unavailable'},
    'active': {'ar': 'نشط', 'en': 'Active'},
    'inactive': {'ar': 'غير نشط', 'en': 'Inactive'},
    'enabled': {'ar': 'مفعل', 'en': 'Enabled'},
    'disabled': {'ar': 'معطل', 'en': 'Disabled'},
    'start': {'ar': 'بدء', 'en': 'Start'},
    'stop': {'ar': 'إيقاف', 'en': 'Stop'},
    'pause': {'ar': 'إيقاف مؤقت', 'en': 'Pause'},
    'resume': {'ar': 'استئناف', 'en': 'Resume'},
    'restart': {'ar': 'إعادة تشغيل', 'en': 'Restart'},
    'refresh': {'ar': 'تحديث', 'en': 'Refresh'},
    'update': {'ar': 'تحديث', 'en': 'Update'},
    'upgrade': {'ar': 'ترقية', 'en': 'Upgrade'},
    'settings': {'ar': 'الإعدادات', 'en': 'Settings'},
    'preferences': {'ar': 'التفضيلات', 'en': 'Preferences'},
    'profile': {'ar': 'الملف الشخصي', 'en': 'Profile'},
    'account': {'ar': 'الحساب', 'en': 'Account'},
    'login': {'ar': 'تسجيل الدخول', 'en': 'Login'},
    'logout': {'ar': 'تسجيل الخروج', 'en': 'Logout'},
    'register': {'ar': 'تسجيل', 'en': 'Register'},
    'forgot_password': {'ar': 'نسيت كلمة المرور', 'en': 'Forgot Password'},
    'change_password': {'ar': 'تغيير كلمة المرور', 'en': 'Change Password'},
    'home': {'ar': 'الرئيسية', 'en': 'Home'},
    'back': {'ar': 'رجوع', 'en': 'Back'},
    'next': {'ar': 'التالي', 'en': 'Next'},
    'previous': {'ar': 'السابق', 'en': 'Previous'},
    'continue': {'ar': 'متابعة', 'en': 'Continue'},
    'finish': {'ar': 'إنهاء', 'en': 'Finish'},
    'complete': {'ar': 'مكتمل', 'en': 'Complete'},
    'incomplete': {'ar': 'غير مكتمل', 'en': 'Incomplete'},
    'pending': {'ar': 'قيد الانتظار', 'en': 'Pending'},
    'approved': {'ar': 'موافق عليه', 'en': 'Approved'},
    'rejected': {'ar': 'مرفوض', 'en': 'Rejected'},
    'processing': {'ar': 'جاري المعالجة', 'en': 'Processing'},
    'completed': {'ar': 'مكتمل', 'en': 'Completed'},
    'failed': {'ar': 'فشل', 'en': 'Failed'},
    'retry': {'ar': 'إعادة المحاولة', 'en': 'Retry'},
    'skip': {'ar': 'تخطي', 'en': 'Skip'},
    'help': {'ar': 'مساعدة', 'en': 'Help'},
    'support': {'ar': 'الدعم', 'en': 'Support'},
    'contact': {'ar': 'اتصل بنا', 'en': 'Contact'},
    'about': {'ar': 'حول', 'en': 'About'},
    'version': {'ar': 'الإصدار', 'en': 'Version'},
    'language': {'ar': 'اللغة', 'en': 'Language'},
    'theme': {'ar': 'المظهر', 'en': 'Theme'},
    'notifications': {'ar': 'الإشعارات', 'en': 'Notifications'},
    'privacy': {'ar': 'الخصوصية', 'en': 'Privacy'},
    'terms': {'ar': 'الشروط والأحكام', 'en': 'Terms & Conditions'},
    'feedback': {'ar': 'التعليقات', 'en': 'Feedback'},
    'rate': {'ar': 'تقييم', 'en': 'Rate'},
    'review': {'ar': 'مراجعة', 'en': 'Review'},
  };

  static String getCommonTranslation(BuildContext context, String key) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final translations = commonTranslations[key];
    if (translations != null) {
      return languageProvider.isArabic ? translations['ar']! : translations['en']!;
    }
    return key; // Return key if translation not found
  }
}
