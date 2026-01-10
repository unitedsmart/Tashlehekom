import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/ai_model.dart';
import '../models/car_model.dart';

class AIService {
  static const String _baseUrl = 'https://api.tashlehekom.com/ai';
  static const String _apiKey = 'your-ai-api-key';

  /// تقييم السيارة بالذكاء الاصطناعي
  static Future<AICarEvaluation> evaluateCar(CarModel car) async {
    try {
      // محاكاة استدعاء API للذكاء الاصطناعي
      await Future.delayed(const Duration(seconds: 2));

      // حساب التقييم بناءً على بيانات السيارة
      final evaluation = _generateCarEvaluation(car);
      
      return evaluation;
    } catch (e) {
      throw Exception('فشل في تقييم السيارة: $e');
    }
  }

  /// توليد تقييم السيارة (محاكاة)
  static AICarEvaluation _generateCarEvaluation(CarModel car) {
    final random = Random();
    
    // حساب السعر المتوقع بناءً على عوامل مختلفة
    double basePrice = _calculateBasePrice(car);
    double ageDepreciation = _calculateAgeDepreciation(car.year);
    double mileageImpact = _calculateMileageImpact(car.mileage);
    double conditionImpact = _calculateConditionImpact(car.condition);
    
    double predictedPrice = basePrice * ageDepreciation * mileageImpact * conditionImpact;
    
    // نقاط القوة والضعف
    List<String> strengths = _generateStrengths(car);
    List<String> weaknesses = _generateWeaknesses(car);
    
    // درجات المكونات
    Map<String, double> componentScores = {
      'المحرك': 70 + random.nextDouble() * 30,
      'ناقل الحركة': 65 + random.nextDouble() * 35,
      'الفرامل': 75 + random.nextDouble() * 25,
      'الإطارات': 60 + random.nextDouble() * 40,
      'التكييف': 70 + random.nextDouble() * 30,
      'الكهرباء': 65 + random.nextDouble() * 35,
      'الهيكل': 80 + random.nextDouble() * 20,
      'الداخلية': 75 + random.nextDouble() * 25,
    };
    
    return AICarEvaluation(
      id: 'eval_${DateTime.now().millisecondsSinceEpoch}',
      carId: car.id,
      predictedPrice: predictedPrice,
      confidenceScore: 0.75 + random.nextDouble() * 0.2,
      strengths: strengths,
      weaknesses: weaknesses,
      componentScores: componentScores,
      evaluatedAt: DateTime.now(),
      aiModelVersion: 'TashlehekomAI-v2.1',
    );
  }

  /// حساب السعر الأساسي
  static double _calculateBasePrice(CarModel car) {
    Map<String, double> brandPrices = {
      'تويوتا': 80000,
      'هوندا': 75000,
      'نيسان': 70000,
      'هيونداي': 65000,
      'كيا': 60000,
      'مازدا': 70000,
      'فورد': 75000,
      'شيفروليه': 70000,
      'BMW': 150000,
      'مرسيدس': 180000,
      'أودي': 160000,
      'لكزس': 200000,
    };
    
    return brandPrices[car.brand] ?? 70000;
  }

  /// حساب تأثير العمر
  static double _calculateAgeDepreciation(int year) {
    int age = DateTime.now().year - year;
    if (age <= 1) return 0.95;
    if (age <= 3) return 0.85;
    if (age <= 5) return 0.75;
    if (age <= 8) return 0.65;
    if (age <= 12) return 0.55;
    return 0.45;
  }

  /// حساب تأثير المسافة المقطوعة
  static double _calculateMileageImpact(int mileage) {
    if (mileage <= 50000) return 1.0;
    if (mileage <= 100000) return 0.95;
    if (mileage <= 150000) return 0.90;
    if (mileage <= 200000) return 0.85;
    if (mileage <= 300000) return 0.75;
    return 0.65;
  }

  /// حساب تأثير الحالة
  static double _calculateConditionImpact(String condition) {
    switch (condition) {
      case 'ممتازة':
        return 1.1;
      case 'جيدة جداً':
        return 1.0;
      case 'جيدة':
        return 0.9;
      case 'مقبولة':
        return 0.8;
      default:
        return 0.7;
    }
  }

  /// توليد نقاط القوة
  static List<String> _generateStrengths(CarModel car) {
    List<String> allStrengths = [
      'محرك قوي وموثوق',
      'استهلاك وقود اقتصادي',
      'صيانة منخفضة التكلفة',
      'قطع غيار متوفرة',
      'قيمة إعادة بيع عالية',
      'تقنيات أمان متقدمة',
      'راحة في القيادة',
      'تصميم عصري',
      'مساحة داخلية واسعة',
      'نظام ترفيه متطور',
    ];
    
    final random = Random();
    allStrengths.shuffle(random);
    return allStrengths.take(3 + random.nextInt(3)).toList();
  }

  /// توليد نقاط الضعف
  static List<String> _generateWeaknesses(CarModel car) {
    List<String> allWeaknesses = [
      'تآكل طفيف في الهيكل',
      'حاجة لصيانة دورية',
      'استهلاك وقود مرتفع نسبياً',
      'قطع غيار مكلفة',
      'ضوضاء في المحرك',
      'تسريب طفيف في الزيت',
      'تآكل في الإطارات',
      'مشاكل في التكييف',
      'خدوش في الطلاء',
      'تآكل في المقاعد',
    ];
    
    final random = Random();
    allWeaknesses.shuffle(random);
    return allWeaknesses.take(1 + random.nextInt(3)).toList();
  }

  /// توليد التوصيات الذكية
  static Future<List<SmartRecommendation>> generateRecommendations(
    String userId,
    List<CarModel> userHistory,
  ) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      
      List<SmartRecommendation> recommendations = [];
      final random = Random();
      
      // توصيات بناءً على التاريخ
      for (int i = 0; i < 5; i++) {
        recommendations.add(SmartRecommendation(
          id: 'rec_${DateTime.now().millisecondsSinceEpoch}_$i',
          userId: userId,
          carId: 'car_${random.nextInt(1000)}',
          type: RecommendationType.values[random.nextInt(RecommendationType.values.length)],
          title: _getRecommendationTitle(RecommendationType.values[i % RecommendationType.values.length]),
          description: _getRecommendationDescription(RecommendationType.values[i % RecommendationType.values.length]),
          relevanceScore: 0.6 + random.nextDouble() * 0.4,
          metadata: {'source': 'ai_analysis'},
          createdAt: DateTime.now(),
          isViewed: false,
        ));
      }
      
      return recommendations;
    } catch (e) {
      throw Exception('فشل في توليد التوصيات: $e');
    }
  }

  static String _getRecommendationTitle(RecommendationType type) {
    switch (type) {
      case RecommendationType.similarCar:
        return 'سيارة مشابهة لاهتماماتك';
      case RecommendationType.priceAlert:
        return 'تنبيه انخفاض السعر';
      case RecommendationType.maintenanceTip:
        return 'نصيحة صيانة';
      case RecommendationType.upgradeOpportunity:
        return 'فرصة ترقية';
      case RecommendationType.marketTrend:
        return 'اتجاه السوق';
      case RecommendationType.personalizedOffer:
        return 'عرض شخصي';
    }
  }

  static String _getRecommendationDescription(RecommendationType type) {
    switch (type) {
      case RecommendationType.similarCar:
        return 'وجدنا سيارة تطابق تفضيلاتك بسعر ممتاز';
      case RecommendationType.priceAlert:
        return 'انخفض سعر السيارة التي تتابعها بنسبة 15%';
      case RecommendationType.maintenanceTip:
        return 'حان وقت فحص الفرامل لسيارتك';
      case RecommendationType.upgradeOpportunity:
        return 'فرصة ممتازة لترقية سيارتك الحالية';
      case RecommendationType.marketTrend:
        return 'أسعار هذا النوع في ارتفاع - الآن وقت البيع';
      case RecommendationType.personalizedOffer:
        return 'عرض خاص لك بخصم 20% على هذه السيارة';
    }
  }

  /// تحليل الصور بالذكاء الاصطناعي
  static Future<AIImageAnalysis> analyzeCarImages(
    String carId,
    List<String> imageUrls,
  ) async {
    try {
      await Future.delayed(const Duration(seconds: 3));
      
      final random = Random();
      
      // محاكاة كشف الأضرار
      List<DetectedDamage> damages = [];
      for (int i = 0; i < random.nextInt(5); i++) {
        damages.add(DetectedDamage(
          type: ['خدش', 'انبعاج', 'صدأ', 'تشقق'][random.nextInt(4)],
          location: ['الباب الأمامي', 'المصد', 'الغطاء', 'الجانب'][random.nextInt(4)],
          severity: random.nextDouble(),
          description: 'ضرر طفيف يحتاج إصلاح بسيط',
          boundingBox: [
            random.nextDouble() * 100,
            random.nextDouble() * 100,
            20 + random.nextDouble() * 50,
            20 + random.nextDouble() * 50,
          ],
        ));
      }
      
      return AIImageAnalysis(
        id: 'img_analysis_${DateTime.now().millisecondsSinceEpoch}',
        carId: carId,
        imageUrl: imageUrls.first,
        damages: damages,
        overallConditionScore: 70 + random.nextDouble() * 30,
        identifiedFeatures: [
          'مصابيح LED',
          'عجلات سبائك',
          'نوافذ كهربائية',
          'مرايا كهربائية',
        ],
        partConditions: {
          'المحرك': 80 + random.nextDouble() * 20,
          'الهيكل': 75 + random.nextDouble() * 25,
          'الداخلية': 85 + random.nextDouble() * 15,
          'الطلاء': 70 + random.nextDouble() * 30,
        },
        analyzedAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('فشل في تحليل الصور: $e');
    }
  }

  /// التنبؤ بالأسعار
  static Future<PricePrediction> predictPrices(String carId) async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      
      final random = Random();
      double currentPrice = 50000 + random.nextDouble() * 100000;
      
      return PricePrediction(
        id: 'pred_${DateTime.now().millisecondsSinceEpoch}',
        carId: carId,
        currentPrice: currentPrice,
        predictedPrice30Days: currentPrice * (0.95 + random.nextDouble() * 0.1),
        predictedPrice90Days: currentPrice * (0.90 + random.nextDouble() * 0.2),
        predictedPrice180Days: currentPrice * (0.85 + random.nextDouble() * 0.3),
        factors: [
          PriceFactor(
            name: 'الموسم',
            impact: -0.05,
            description: 'انخفاض الطلب في الشتاء',
          ),
          PriceFactor(
            name: 'العرض والطلب',
            impact: 0.03,
            description: 'زيادة الطلب على هذا النوع',
          ),
        ],
        accuracy: 0.8 + random.nextDouble() * 0.15,
        predictedAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('فشل في التنبؤ بالأسعار: $e');
    }
  }
}
