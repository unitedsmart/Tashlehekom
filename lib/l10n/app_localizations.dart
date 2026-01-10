import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('ar', 'SA'), // Arabic (Saudi Arabia)
    Locale('en', 'US'), // English (United States)
  ];

  // App Name
  String get appName => locale.languageCode == 'ar' ? 'تشليحكم' : 'Tashlehekom';
  String get appNameArabic => 'تشليحكم';
  String get appNameEnglish => 'Tashlehekom';

  // Navigation
  String get home => locale.languageCode == 'ar' ? 'الرئيسية' : 'Home';
  String get search => locale.languageCode == 'ar' ? 'البحث' : 'Search';
  String get addCar => locale.languageCode == 'ar' ? 'إضافة سيارة' : 'Add Car';
  String get profile =>
      locale.languageCode == 'ar' ? 'الملف الشخصي' : 'Profile';
  String get admin => locale.languageCode == 'ar' ? 'الإدارة' : 'Admin';

  // Authentication
  String get login => locale.languageCode == 'ar' ? 'تسجيل الدخول' : 'Login';
  String get register =>
      locale.languageCode == 'ar' ? 'إنشاء حساب' : 'Register';
  String get phoneNumber =>
      locale.languageCode == 'ar' ? 'رقم الجوال' : 'Phone Number';
  String get enterPhoneNumber =>
      locale.languageCode == 'ar' ? 'أدخل رقم الجوال' : 'Enter phone number';
  String get otpVerification =>
      locale.languageCode == 'ar' ? 'تأكيد رقم الجوال' : 'Phone Verification';
  String get enterOTP => locale.languageCode == 'ar'
      ? 'أدخل رمز التحقق'
      : 'Enter verification code';
  String get resendOTP =>
      locale.languageCode == 'ar' ? 'إعادة الإرسال' : 'Resend';
  String get verify => locale.languageCode == 'ar' ? 'تأكيد' : 'Verify';

  // User Types
  String get individual => locale.languageCode == 'ar' ? 'فرد' : 'Individual';
  String get worker => locale.languageCode == 'ar' ? 'عامل' : 'Worker';
  String get junkyardOwner =>
      locale.languageCode == 'ar' ? 'مالك تشليح' : 'Junkyard Owner';

  // Car Information
  String get brand => locale.languageCode == 'ar' ? 'الماركة' : 'Brand';
  String get model => locale.languageCode == 'ar' ? 'الموديل' : 'Model';
  String get year => locale.languageCode == 'ar' ? 'السنة' : 'Year';
  String get color => locale.languageCode == 'ar' ? 'اللون' : 'Color';
  String get city => locale.languageCode == 'ar' ? 'المدينة' : 'City';
  String get vinNumber =>
      locale.languageCode == 'ar' ? 'رقم الهيكل' : 'VIN Number';
  String get price => locale.languageCode == 'ar' ? 'السعر' : 'Price';
  String get description =>
      locale.languageCode == 'ar' ? 'الوصف' : 'Description';

  // Actions
  String get save => locale.languageCode == 'ar' ? 'حفظ' : 'Save';
  String get cancel => locale.languageCode == 'ar' ? 'إلغاء' : 'Cancel';
  String get delete => locale.languageCode == 'ar' ? 'حذف' : 'Delete';
  String get edit => locale.languageCode == 'ar' ? 'تعديل' : 'Edit';
  String get view => locale.languageCode == 'ar' ? 'عرض' : 'View';
  String get contact => locale.languageCode == 'ar' ? 'تواصل' : 'Contact';
  String get call => locale.languageCode == 'ar' ? 'اتصال' : 'Call';
  String get whatsapp => locale.languageCode == 'ar' ? 'واتساب' : 'WhatsApp';

  // Messages
  String get success => locale.languageCode == 'ar' ? 'تم بنجاح' : 'Success';
  String get error => locale.languageCode == 'ar' ? 'خطأ' : 'Error';
  String get loading =>
      locale.languageCode == 'ar' ? 'جاري التحميل...' : 'Loading...';
  String get noData =>
      locale.languageCode == 'ar' ? 'لا توجد بيانات' : 'No data available';
  String get tryAgain =>
      locale.languageCode == 'ar' ? 'حاول مرة أخرى' : 'Try again';

  // Settings
  String get settings => locale.languageCode == 'ar' ? 'الإعدادات' : 'Settings';
  String get language => locale.languageCode == 'ar' ? 'اللغة' : 'Language';
  String get arabic => locale.languageCode == 'ar' ? 'العربية' : 'Arabic';
  String get english => locale.languageCode == 'ar' ? 'الإنجليزية' : 'English';
  String get changeLanguage =>
      locale.languageCode == 'ar' ? 'تغيير اللغة' : 'Change Language';

  // Validation Messages
  String get fieldRequired => locale.languageCode == 'ar'
      ? 'هذا الحقل مطلوب'
      : 'This field is required';
  String get invalidPhoneNumber => locale.languageCode == 'ar'
      ? 'رقم الجوال غير صحيح'
      : 'Invalid phone number';
  String get invalidOTP => locale.languageCode == 'ar'
      ? 'رمز التحقق غير صحيح'
      : 'Invalid verification code';

  // Admin Panel
  String get userManagement =>
      locale.languageCode == 'ar' ? 'إدارة المستخدمين' : 'User Management';
  String get carManagement =>
      locale.languageCode == 'ar' ? 'إدارة السيارات' : 'Car Management';
  String get statistics =>
      locale.languageCode == 'ar' ? 'الإحصائيات' : 'Statistics';
  String get approve => locale.languageCode == 'ar' ? 'موافقة' : 'Approve';
  String get reject => locale.languageCode == 'ar' ? 'رفض' : 'Reject';
  String get pending =>
      locale.languageCode == 'ar' ? 'قيد المراجعة' : 'Pending';
  String get approved =>
      locale.languageCode == 'ar' ? 'مُوافق عليه' : 'Approved';
  String get rejected => locale.languageCode == 'ar' ? 'مرفوض' : 'Rejected';

  // Rating
  String get rating => locale.languageCode == 'ar' ? 'التقييم' : 'Rating';
  String get rateUser =>
      locale.languageCode == 'ar' ? 'تقييم المستخدم' : 'Rate User';
  String get responseSpeed =>
      locale.languageCode == 'ar' ? 'سرعة الرد' : 'Response Speed';
  String get cleanliness =>
      locale.languageCode == 'ar' ? 'النظافة' : 'Cleanliness';
  String get submitRating =>
      locale.languageCode == 'ar' ? 'إرسال التقييم' : 'Submit Rating';

  // Search & Filter
  String get searchCars =>
      locale.languageCode == 'ar' ? 'البحث عن السيارات' : 'Search Cars';
  String get filter => locale.languageCode == 'ar' ? 'فلترة' : 'Filter';
  String get clearFilter =>
      locale.languageCode == 'ar' ? 'مسح الفلتر' : 'Clear Filter';
  String get applyFilter =>
      locale.languageCode == 'ar' ? 'تطبيق الفلتر' : 'Apply Filter';

  // Location
  String get location => locale.languageCode == 'ar' ? 'الموقع' : 'Location';
  String get viewOnMap =>
      locale.languageCode == 'ar' ? 'عرض على الخريطة' : 'View on Map';
  String get getDirections =>
      locale.languageCode == 'ar' ? 'الحصول على الاتجاهات' : 'Get Directions';

  // AI Features
  String get artificialIntelligence => locale.languageCode == 'ar'
      ? 'الذكاء الاصطناعي'
      : 'Artificial Intelligence';
  String get carEvaluation =>
      locale.languageCode == 'ar' ? 'تقييم السيارة' : 'Car Evaluation';
  String get imageAnalysis =>
      locale.languageCode == 'ar' ? 'تحليل الصور' : 'Image Analysis';
  String get pricePredict =>
      locale.languageCode == 'ar' ? 'توقع السعر' : 'Price Prediction';
  String get smartAssistant =>
      locale.languageCode == 'ar' ? 'المساعد الذكي' : 'Smart Assistant';
  String get uploadImage =>
      locale.languageCode == 'ar' ? 'رفع صورة' : 'Upload Image';
  String get analyzing =>
      locale.languageCode == 'ar' ? 'جاري التحليل...' : 'Analyzing...';
  String get analysisComplete =>
      locale.languageCode == 'ar' ? 'تم التحليل' : 'Analysis Complete';

  // VR Features
  String get virtualReality =>
      locale.languageCode == 'ar' ? 'الواقع الافتراضي' : 'Virtual Reality';
  String get vrTour360 =>
      locale.languageCode == 'ar' ? 'جولة 360°' : '360° Tour';
  String get virtualDriving =>
      locale.languageCode == 'ar' ? 'القيادة الافتراضية' : 'Virtual Driving';
  String get virtualShowroom =>
      locale.languageCode == 'ar' ? 'المعرض الافتراضي' : 'Virtual Showroom';
  String get detailedInspection =>
      locale.languageCode == 'ar' ? 'فحص مفصل' : 'Detailed Inspection';
  String get vrConnected =>
      locale.languageCode == 'ar' ? 'متصل بـ VR' : 'VR Connected';
  String get startExperience =>
      locale.languageCode == 'ar' ? 'بدء التجربة' : 'Start Experience';

  // Analytics
  String get advancedAnalytics =>
      locale.languageCode == 'ar' ? 'التحليلات المتقدمة' : 'Advanced Analytics';
  String get salesChart =>
      locale.languageCode == 'ar' ? 'مخطط المبيعات' : 'Sales Chart';
  String get marketInsights =>
      locale.languageCode == 'ar' ? 'رؤى السوق' : 'Market Insights';
  String get userBehavior =>
      locale.languageCode == 'ar' ? 'سلوك المستخدمين' : 'User Behavior';
  String get conversionRate =>
      locale.languageCode == 'ar' ? 'معدل التحويل' : 'Conversion Rate';
  String get activeUsers =>
      locale.languageCode == 'ar' ? 'المستخدمون النشطون' : 'Active Users';
  String get carsSold =>
      locale.languageCode == 'ar' ? 'السيارات المباعة' : 'Cars Sold';

  // Gamification
  String get gamification =>
      locale.languageCode == 'ar' ? 'الألعاب والمكافآت' : 'Gamification';
  String get userProfile =>
      locale.languageCode == 'ar' ? 'الملف الشخصي' : 'User Profile';
  String get dailyChallenges =>
      locale.languageCode == 'ar' ? 'التحديات اليومية' : 'Daily Challenges';
  String get achievements =>
      locale.languageCode == 'ar' ? 'الإنجازات' : 'Achievements';
  String get rewardsShop =>
      locale.languageCode == 'ar' ? 'متجر المكافآت' : 'Rewards Shop';
  String get leaderboard =>
      locale.languageCode == 'ar' ? 'لوحة المتصدرين' : 'Leaderboard';
  String get points => locale.languageCode == 'ar' ? 'النقاط' : 'Points';
  String get level => locale.languageCode == 'ar' ? 'المستوى' : 'Level';
  String get rank => locale.languageCode == 'ar' ? 'الترتيب' : 'Rank';

  // Social Community
  String get socialCommunity =>
      locale.languageCode == 'ar' ? 'المجتمع الاجتماعي' : 'Social Community';
  String get forum => locale.languageCode == 'ar' ? 'المنتدى' : 'Forum';
  String get groups => locale.languageCode == 'ar' ? 'المجموعات' : 'Groups';
  String get experiences =>
      locale.languageCode == 'ar' ? 'التجارب' : 'Experiences';
  String get events => locale.languageCode == 'ar' ? 'الأحداث' : 'Events';
  String get createPost =>
      locale.languageCode == 'ar' ? 'إنشاء منشور' : 'Create Post';
  String get joinGroup =>
      locale.languageCode == 'ar' ? 'انضمام للمجموعة' : 'Join Group';
  String get shareExperience =>
      locale.languageCode == 'ar' ? 'مشاركة التجربة' : 'Share Experience';

  // IoT Features
  String get internetOfThings =>
      locale.languageCode == 'ar' ? 'إنترنت الأشياء' : 'Internet of Things';
  String get smartCarMonitoring => locale.languageCode == 'ar'
      ? 'مراقبة السيارة الذكية'
      : 'Smart Car Monitoring';
  String get remoteControl =>
      locale.languageCode == 'ar' ? 'التحكم عن بُعد' : 'Remote Control';
  String get engineTemp =>
      locale.languageCode == 'ar' ? 'حرارة المحرك' : 'Engine Temperature';
  String get fuelLevel =>
      locale.languageCode == 'ar' ? 'مستوى الوقود' : 'Fuel Level';
  String get batteryVoltage =>
      locale.languageCode == 'ar' ? 'جهد البطارية' : 'Battery Voltage';
  String get speed => locale.languageCode == 'ar' ? 'السرعة' : 'Speed';
  String get diagnostics =>
      locale.languageCode == 'ar' ? 'التشخيص' : 'Diagnostics';
  String get maintenanceAlerts =>
      locale.languageCode == 'ar' ? 'تنبيهات الصيانة' : 'Maintenance Alerts';

  // Cryptocurrency
  String get cryptocurrency =>
      locale.languageCode == 'ar' ? 'العملات الرقمية' : 'Cryptocurrency';
  String get digitalWallet =>
      locale.languageCode == 'ar' ? 'المحفظة الرقمية' : 'Digital Wallet';
  String get balance => locale.languageCode == 'ar' ? 'الرصيد' : 'Balance';
  String get buy => locale.languageCode == 'ar' ? 'شراء' : 'Buy';
  String get sell => locale.languageCode == 'ar' ? 'بيع' : 'Sell';
  String get trading => locale.languageCode == 'ar' ? 'التداول' : 'Trading';
  String get transactionHistory =>
      locale.languageCode == 'ar' ? 'سجل المعاملات' : 'Transaction History';
  String get livePrices =>
      locale.languageCode == 'ar' ? 'الأسعار المباشرة' : 'Live Prices';

  // Finance & Installments
  String get financeInstallments => locale.languageCode == 'ar'
      ? 'التمويل والتقسيط'
      : 'Finance & Installments';
  String get loanCalculator =>
      locale.languageCode == 'ar' ? 'حاسبة القرض' : 'Loan Calculator';
  String get monthlyPayment =>
      locale.languageCode == 'ar' ? 'القسط الشهري' : 'Monthly Payment';
  String get loanPeriod =>
      locale.languageCode == 'ar' ? 'فترة القرض' : 'Loan Period';
  String get interestRate =>
      locale.languageCode == 'ar' ? 'معدل الفائدة' : 'Interest Rate';
  String get downPayment =>
      locale.languageCode == 'ar' ? 'الدفعة المقدمة' : 'Down Payment';
  String get bankPartnerships =>
      locale.languageCode == 'ar' ? 'الشراكات البنكية' : 'Bank Partnerships';
  String get applyForLoan =>
      locale.languageCode == 'ar' ? 'طلب قرض' : 'Apply for Loan';

  // Augmented Reality
  String get augmentedReality =>
      locale.languageCode == 'ar' ? 'الواقع المعزز' : 'Augmented Reality';
  String get scanCar =>
      locale.languageCode == 'ar' ? 'مسح السيارة' : 'Scan Car';
  String get damageDetection =>
      locale.languageCode == 'ar' ? 'كشف الأضرار' : 'Damage Detection';
  String get measureDimensions =>
      locale.languageCode == 'ar' ? 'قياس الأبعاد' : 'Measure Dimensions';
  String get carInformation =>
      locale.languageCode == 'ar' ? 'معلومات السيارة' : 'Car Information';
  String get priceComparison =>
      locale.languageCode == 'ar' ? 'مقارنة الأسعار' : 'Price Comparison';
  String get carDetected =>
      locale.languageCode == 'ar' ? 'تم اكتشاف السيارة!' : 'Car Detected!';
  String get generateReport =>
      locale.languageCode == 'ar' ? 'إنشاء تقرير' : 'Generate Report';

  // Delivery & Shipping
  String get deliveryShipping =>
      locale.languageCode == 'ar' ? 'التوصيل والشحن' : 'Delivery & Shipping';
  String get trackOrder =>
      locale.languageCode == 'ar' ? 'تتبع الطلب' : 'Track Order';
  String get deliveryStatus =>
      locale.languageCode == 'ar' ? 'حالة التوصيل' : 'Delivery Status';
  String get onTheWay =>
      locale.languageCode == 'ar' ? 'في الطريق' : 'On the Way';
  String get delivered =>
      locale.languageCode == 'ar' ? 'تم التسليم' : 'Delivered';
  String get callDriver =>
      locale.languageCode == 'ar' ? 'اتصال بالسائق' : 'Call Driver';
  String get trackOnMap =>
      locale.languageCode == 'ar' ? 'تتبع على الخريطة' : 'Track on Map';
  String get deliveryServices =>
      locale.languageCode == 'ar' ? 'خدمات التوصيل' : 'Delivery Services';
  String get normalDelivery =>
      locale.languageCode == 'ar' ? 'توصيل عادي' : 'Normal Delivery';
  String get fastDelivery =>
      locale.languageCode == 'ar' ? 'توصيل سريع' : 'Fast Delivery';
  String get instantDelivery =>
      locale.languageCode == 'ar' ? 'توصيل فوري' : 'Instant Delivery';

  // Space Technology
  String get spaceTechnology =>
      locale.languageCode == 'ar' ? 'تقنيات الفضاء' : 'Space Technology';
  String get satelliteTracking => locale.languageCode == 'ar'
      ? 'تتبع الأقمار الصناعية'
      : 'Satellite Tracking';
  String get spaceNavigation =>
      locale.languageCode == 'ar' ? 'الملاحة الفضائية' : 'Space Navigation';
  String get preciseNavigation =>
      locale.languageCode == 'ar' ? 'ملاحة دقيقة' : 'Precise Navigation';
  String get realTimeTracking => locale.languageCode == 'ar'
      ? 'تتبع في الوقت الفعلي'
      : 'Real-time Tracking';
  String get threeDNavigation =>
      locale.languageCode == 'ar' ? 'ملاحة ثلاثية الأبعاد' : '3D Navigation';
  String get signalAccuracy =>
      locale.languageCode == 'ar' ? 'دقة الإشارة' : 'Signal Accuracy';
  String get connectedSatellites =>
      locale.languageCode == 'ar' ? 'الأقمار المتصلة' : 'Connected Satellites';

  // Quantum AI
  String get quantumAI =>
      locale.languageCode == 'ar' ? 'الذكاء الاصطناعي الكمي' : 'Quantum AI';
  String get quantumProcessor =>
      locale.languageCode == 'ar' ? 'المعالج الكمي' : 'Quantum Processor';
  String get quantumAnalysis =>
      locale.languageCode == 'ar' ? 'التحليل الكمي' : 'Quantum Analysis';
  String get quantumAccuracy =>
      locale.languageCode == 'ar' ? 'الدقة الكمية' : 'Quantum Accuracy';
  String get quantumProcessing =>
      locale.languageCode == 'ar' ? 'المعالجة الكمية' : 'Quantum Processing';
  String get quantumFeatures =>
      locale.languageCode == 'ar' ? 'الميزات الكمية' : 'Quantum Features';
  String get quantumSimulation =>
      locale.languageCode == 'ar' ? 'المحاكاة الكمية' : 'Quantum Simulation';
  String get quantumEncryption =>
      locale.languageCode == 'ar' ? 'التشفير الكمي' : 'Quantum Encryption';
  String get processingSpeed =>
      locale.languageCode == 'ar' ? 'سرعة المعالجة' : 'Processing Speed';
  String get confidenceLevel =>
      locale.languageCode == 'ar' ? 'مستوى الثقة' : 'Confidence Level';
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.any((supportedLocale) =>
        supportedLocale.languageCode == locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
