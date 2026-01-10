import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  
  // Default language is Arabic
  Locale _currentLocale = const Locale('ar', 'SA');
  
  Locale get currentLocale => _currentLocale;
  
  bool get isArabic => _currentLocale.languageCode == 'ar';
  bool get isEnglish => _currentLocale.languageCode == 'en';
  
  String get currentLanguageName => isArabic ? 'العربية' : 'English';
  
  LanguageProvider() {
    _loadLanguage();
  }
  
  // Load saved language from SharedPreferences
  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageKey) ?? 'ar';
      
      if (languageCode == 'en') {
        _currentLocale = const Locale('en', 'US');
      } else {
        _currentLocale = const Locale('ar', 'SA');
      }
      
      notifyListeners();
    } catch (e) {
      print('Error loading language: $e');
    }
  }
  
  // Change language and save to SharedPreferences
  Future<void> changeLanguage(String languageCode) async {
    try {
      if (languageCode == 'en') {
        _currentLocale = const Locale('en', 'US');
      } else {
        _currentLocale = const Locale('ar', 'SA');
      }
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
      
      notifyListeners();
    } catch (e) {
      print('Error changing language: $e');
    }
  }
  
  // Toggle between Arabic and English
  Future<void> toggleLanguage() async {
    final newLanguageCode = isArabic ? 'en' : 'ar';
    await changeLanguage(newLanguageCode);
  }
  
  // Get text direction based on current language
  TextDirection get textDirection => isArabic ? TextDirection.rtl : TextDirection.ltr;
  
  // Get opposite text direction (useful for numbers, etc.)
  TextDirection get oppositeTextDirection => isArabic ? TextDirection.ltr : TextDirection.rtl;
}
