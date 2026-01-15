/// إعدادات الإنتاج لتطبيق تشليحكم
class ProductionConfig {
  // معلومات التطبيق
  static const String appName = 'تشليحكم';
  static const String appVersion = '1.0.0';
  static const int buildNumber = 1;
  static const String packageName = 'com.tashlehekomv2.app';

  // إعدادات البيئة
  static const bool isProduction = true;
  static const bool enableDebugMode = false;
  static const bool enableLogging = false; // تعطيل السجلات في الإنتاج

  // إعدادات Firebase (يجب استبدالها بالقيم الحقيقية)
  static const String firebaseProjectId = 'tashlehekomv2-production';
  static const String firebaseApiKey = 'YOUR_PRODUCTION_API_KEY_HERE';
  static const String firebaseAppId = 'YOUR_PRODUCTION_APP_ID_HERE';
  static const String firebaseMessagingSenderId = 'YOUR_SENDER_ID_HERE';
  static const String firebaseStorageBucket =
      'tashlehekomv2-production.appspot.com';
  static const String firebaseAuthDomain =
      'tashlehekomv2-production.firebaseapp.com';
  static const String firebaseDatabaseURL =
      'https://tashlehekomv2-production-default-rtdb.firebaseio.com';

  // إعدادات الأمان
  static const String encryptionKey = 'YOUR_ENCRYPTION_KEY_HERE'; // 32 حرف
  static const String saltKey = 'YOUR_SALT_KEY_HERE'; // 16 حرف
  static const int maxLoginAttempts = 5;
  static const int lockoutDurationMinutes = 30;

  // إعدادات التخزين المؤقت
  static const int cacheExpirationHours = 24;
  static const int maxCacheSize = 100; // MB
  static const bool enableOfflineMode = true;

  // إعدادات الصور
  static const int maxImageSize = 5; // MB
  static const int imageQuality = 85; // 0-100
  static const int thumbnailSize = 300; // pixels
  static const List<String> allowedImageFormats = ['jpg', 'jpeg', 'png'];

  // إعدادات الشبكة
  static const int connectionTimeoutSeconds = 30;
  static const int receiveTimeoutSeconds = 30;
  static const int maxRetryAttempts = 3;

  // إعدادات الإشعارات
  static const bool enablePushNotifications = true;
  static const bool enableLocalNotifications = true;
  static const String notificationChannelId = 'tashlehekomv2_notifications';
  static const String notificationChannelName = 'إشعارات تشليحكم';

  // إعدادات التطبيق
  static const int maxCarsPerUser = 50;
  static const int maxImagesPerCar = 10;
  static const int maxFavoritesPerUser = 100;
  static const int searchResultsLimit = 20;

  // إعدادات الموقع الجغرافي
  static const double defaultLatitude = 24.7136; // الرياض
  static const double defaultLongitude = 46.6753; // الرياض
  static const double searchRadiusKm = 50.0;

  // إعدادات التقييم
  static const int minRatingValue = 1;
  static const int maxRatingValue = 5;
  static const int minReviewLength = 10;
  static const int maxReviewLength = 500;

  // إعدادات الاتصال
  static const String supportEmail = 'support@tashlehekomv2.com';
  static const String supportPhone = '+966501234567';
  static const String websiteUrl = 'https://tashlehekomv2.com';
  static const String privacyPolicyUrl =
      'https://tashlehekomv2.com/privacy-policy';
  static const String termsOfServiceUrl =
      'https://tashlehekomv2.com/terms-of-service';

  // إعدادات وسائل التواصل الاجتماعي
  static const String twitterUrl = 'https://twitter.com/tashlehekomv2';
  static const String instagramUrl = 'https://instagram.com/tashlehekomv2';
  static const String facebookUrl = 'https://facebook.com/tashlehekomv2';
  static const String youtubeUrl = 'https://youtube.com/tashlehekomv2';

  // المدن السعودية المدعومة - القائمة الكاملة
  static const List<String> supportedCities = [
    // المنطقة الوسطى
    'الرياض', 'الخرج', 'الدوادمي', 'المجمعة', 'الزلفي', 'وادي الدواسر',
    'الأفلاج', 'حوطة بني تميم', 'عفيف', 'السليل', 'ضرما', 'المزاحمية',
    'رماح', 'ثادق', 'حريملاء', 'الحريق', 'الغاط', 'الدرعية',
    // المنطقة الغربية
    'جدة', 'مكة المكرمة', 'المدينة المنورة', 'الطائف', 'ينبع', 'رابغ',
    'القنفذة', 'الليث', 'خليص', 'الجموم', 'بحرة',
    // المنطقة الشرقية
    'الدمام', 'الخبر', 'الظهران', 'الأحساء', 'الهفوف', 'المبرز',
    'الجبيل', 'القطيف', 'رأس تنورة', 'بقيق', 'الخفجي', 'النعيرية',
    'قرية العليا', 'حفر الباطن',
    // المنطقة الشمالية
    'حائل', 'بريدة', 'عنيزة', 'الرس', 'البكيرية', 'البدائع',
    'المذنب', 'رياض الخبراء', 'عيون الجواء', 'الشماسية',
    // منطقة تبوك
    'تبوك', 'الوجه', 'ضباء', 'تيماء', 'أملج', 'حقل', 'البدع',
    // منطقة الجوف
    'سكاكا', 'القريات', 'دومة الجندل', 'طبرجل',
    // منطقة الحدود الشمالية
    'عرعر', 'رفحاء', 'طريف', 'العويقيلة',
    // منطقة عسير
    'أبها', 'خميس مشيط', 'بيشة', 'النماص', 'محايل عسير', 'سراة عبيدة',
    'أحد رفيدة', 'ظهران الجنوب', 'تثليث', 'رجال ألمع', 'بلقرن',
    // منطقة جازان
    'جازان', 'صبيا', 'أبو عريش', 'صامطة', 'الدرب', 'فرسان', 'الريث', 'فيفا',
    // منطقة نجران
    'نجران', 'شرورة', 'حبونا', 'بدر الجنوب',
    // منطقة الباحة
    'الباحة', 'بلجرشي', 'المندق', 'المخواة', 'قلوة', 'العقيق',
  ];

  // ماركات السيارات المدعومة
  static const List<String> supportedCarBrands = [
    'تويوتا',
    'هوندا',
    'نيسان',
    'هيونداي',
    'كيا',
    'فورد',
    'شيفروليه',
    'بي إم دبليو',
    'مرسيدس بنز',
    'أودي',
    'لكزس',
    'إنفينيتي',
    'أكورا',
    'مازدا',
    'سوبارو',
    'ميتسوبيشي',
    'جيب',
    'لاند روفر',
    'فولكس واجن',
    'بورش',
    'جاكوار',
    'فولفو',
    'كاديلاك',
    'لينكولن',
    'جي إم سي',
    'دودج',
    'كرايسلر',
    'فيات',
    'ألفا روميو',
    'بنتلي',
    'رولز رويس',
    'فيراري',
    'لامبورغيني',
    'مكلارين',
    'أستون مارتن',
  ];

  // أنواع قطع الغيار
  static const List<String> carPartTypes = [
    'محرك',
    'ناقل حركة',
    'فرامل',
    'تعليق',
    'كهرباء',
    'تكييف',
    'عادم',
    'إطارات',
    'جنوط',
    'مصابيح',
    'مرايا',
    'أبواب',
    'شبابيك',
    'مقاعد',
    'عجلة قيادة',
    'لوحة عدادات',
    'بطارية',
    'راديتر',
    'مضخة ماء',
    'فلتر هواء',
    'فلتر زيت',
    'شمعات احتراق',
    'حساسات',
    'كمبيوتر',
    'أخرى',
  ];

  // إعدادات التحليلات
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
  static const bool enablePerformanceMonitoring = true;

  // إعدادات التحديث
  static const bool enableAutoUpdate = true;
  static const bool forceUpdateRequired = false;
  static const String minimumSupportedVersion = '1.0.0';

  // إعدادات الصيانة
  static const bool maintenanceMode = false;
  static const String maintenanceMessage =
      'التطبيق تحت الصيانة، يرجى المحاولة لاحقاً';

  // إعدادات الإعلانات (إذا كانت مطلوبة)
  static const bool enableAds = false;
  static const String adMobAppId = 'YOUR_ADMOB_APP_ID_HERE';
  static const String bannerAdUnitId = 'YOUR_BANNER_AD_UNIT_ID_HERE';
  static const String interstitialAdUnitId =
      'YOUR_INTERSTITIAL_AD_UNIT_ID_HERE';

  // دوال مساعدة
  static bool get isDebugMode => !isProduction;

  static String get environmentName =>
      isProduction ? 'Production' : 'Development';

  static Map<String, dynamic> get firebaseConfig => {
        'apiKey': firebaseApiKey,
        'appId': firebaseAppId,
        'messagingSenderId': firebaseMessagingSenderId,
        'projectId': firebaseProjectId,
        'authDomain': firebaseAuthDomain,
        'databaseURL': firebaseDatabaseURL,
        'storageBucket': firebaseStorageBucket,
      };

  static Map<String, String> get contactInfo => {
        'email': supportEmail,
        'phone': supportPhone,
        'website': websiteUrl,
      };

  static Map<String, String> get socialMediaLinks => {
        'twitter': twitterUrl,
        'instagram': instagramUrl,
        'facebook': facebookUrl,
        'youtube': youtubeUrl,
      };

  static Map<String, String> get legalLinks => {
        'privacy': privacyPolicyUrl,
        'terms': termsOfServiceUrl,
      };

  // التحقق من صحة الإعدادات
  static bool validateConfig() {
    if (firebaseApiKey == 'YOUR_PRODUCTION_API_KEY_HERE') {
      throw Exception('يجب تحديث مفتاح Firebase API للإنتاج');
    }

    if (firebaseAppId == 'YOUR_PRODUCTION_APP_ID_HERE') {
      throw Exception('يجب تحديث معرف تطبيق Firebase للإنتاج');
    }

    if (encryptionKey == 'YOUR_ENCRYPTION_KEY_HERE') {
      throw Exception('يجب تحديث مفتاح التشفير للإنتاج');
    }

    return true;
  }
}
