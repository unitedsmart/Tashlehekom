import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:tashlehekomv2/services/logging_service.dart';
import 'package:tashlehekomv2/services/enhanced_error_handler.dart';
import 'package:tashlehekomv2/services/performance_service.dart';
import 'package:tashlehekomv2/services/enhanced_cache_service.dart';

/// نتيجة تحليل السيارة
class CarAnalysisResult {
  final String overallCondition;
  final double confidence;
  final List<String> detectedFeatures;
  final List<String> detectedDamages;
  final List<String> extractedTexts;
  final int analysisCount;

  const CarAnalysisResult({
    required this.overallCondition,
    required this.confidence,
    required this.detectedFeatures,
    required this.detectedDamages,
    required this.extractedTexts,
    required this.analysisCount,
  });

  factory CarAnalysisResult.empty() {
    return const CarAnalysisResult(
      overallCondition: 'غير محدد',
      confidence: 0.0,
      detectedFeatures: [],
      detectedDamages: [],
      extractedTexts: [],
      analysisCount: 0,
    );
  }

  factory CarAnalysisResult.fromMap(Map<String, dynamic> map) {
    return CarAnalysisResult(
      overallCondition: map['overallCondition'] ?? 'غير محدد',
      confidence: (map['confidence'] ?? 0.0).toDouble(),
      detectedFeatures: List<String>.from(map['detectedFeatures'] ?? []),
      detectedDamages: List<String>.from(map['detectedDamages'] ?? []),
      extractedTexts: List<String>.from(map['extractedTexts'] ?? []),
      analysisCount: map['analysisCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'overallCondition': overallCondition,
      'confidence': confidence,
      'detectedFeatures': detectedFeatures,
      'detectedDamages': detectedDamages,
      'extractedTexts': extractedTexts,
      'analysisCount': analysisCount,
    };
  }
}

/// تحليل صورة واحدة
class ImageAnalysis {
  final List<String> labels;
  final List<String> objects;
  final List<String> texts;
  final double confidence;

  const ImageAnalysis({
    required this.labels,
    required this.objects,
    required this.texts,
    required this.confidence,
  });

  factory ImageAnalysis.fromGoogleVision(Map<String, dynamic> data) {
    final labels = <String>[];
    final objects = <String>[];
    final texts = <String>[];
    double totalConfidence = 0.0;
    int confidenceCount = 0;

    // استخراج التصنيفات
    if (data['labelAnnotations'] != null) {
      for (final label in data['labelAnnotations']) {
        labels.add(label['description']);
        totalConfidence += label['score'];
        confidenceCount++;
      }
    }

    // استخراج الكائنات
    if (data['localizedObjectAnnotations'] != null) {
      for (final obj in data['localizedObjectAnnotations']) {
        objects.add(obj['name']);
        totalConfidence += obj['score'];
        confidenceCount++;
      }
    }

    // استخراج النصوص
    if (data['textAnnotations'] != null) {
      for (final text in data['textAnnotations']) {
        texts.add(text['description']);
      }
    }

    final avgConfidence =
        confidenceCount > 0 ? totalConfidence / confidenceCount : 0.0;

    return ImageAnalysis(
      labels: labels,
      objects: objects,
      texts: texts,
      confidence: avgConfidence,
    );
  }
}

/// تنبؤ السعر
class PricePrediction {
  final double predictedPrice;
  final double minPrice;
  final double maxPrice;
  final double confidence;
  final List<String> factors;
  final String marketTrend;
  final String recommendation;

  const PricePrediction({
    required this.predictedPrice,
    required this.minPrice,
    required this.maxPrice,
    required this.confidence,
    required this.factors,
    required this.marketTrend,
    required this.recommendation,
  });

  factory PricePrediction.empty() {
    return const PricePrediction(
      predictedPrice: 0.0,
      minPrice: 0.0,
      maxPrice: 0.0,
      confidence: 0.0,
      factors: [],
      marketTrend: 'غير محدد',
      recommendation: 'لا توجد توصية',
    );
  }

  factory PricePrediction.fromMap(Map<String, dynamic> map) {
    return PricePrediction(
      predictedPrice: (map['predictedPrice'] ?? 0.0).toDouble(),
      minPrice: (map['minPrice'] ?? 0.0).toDouble(),
      maxPrice: (map['maxPrice'] ?? 0.0).toDouble(),
      confidence: (map['confidence'] ?? 0.0).toDouble(),
      factors: List<String>.from(map['factors'] ?? []),
      marketTrend: map['marketTrend'] ?? 'غير محدد',
      recommendation: map['recommendation'] ?? 'لا توجد توصية',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'predictedPrice': predictedPrice,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'confidence': confidence,
      'factors': factors,
      'marketTrend': marketTrend,
      'recommendation': recommendation,
    };
  }
}

/// خدمة الذكاء الاصطناعي المحسنة
class EnhancedAIService {
  static final EnhancedAIService _instance = EnhancedAIService._internal();
  factory EnhancedAIService() => _instance;
  EnhancedAIService._internal();

  final EnhancedCacheService _cache = EnhancedCacheService();

  // مفاتيح API (يجب استبدالها بمفاتيح حقيقية)
  static const String _openAIKey = 'your-openai-api-key';
  static const String _googleVisionKey = 'your-google-vision-api-key';

  /// تحليل صور السيارة بالذكاء الاصطناعي
  Future<CarAnalysisResult> analyzeCarImages(List<String> imagePaths) async {
    final result =
        await EnhancedErrorHandler.executeWithErrorHandling<CarAnalysisResult>(
      () async {
        return PerformanceService.measureAsync('ai_car_analysis', () async {
          final cacheKey = 'car_analysis_${imagePaths.join('_').hashCode}';

          // التحقق من التخزين المؤقت
          final cachedResult = await _cache.get<Map<String, dynamic>>(cacheKey);
          if (cachedResult != null) {
            LoggingService.info(
                'تم العثور على تحليل السيارة في التخزين المؤقت');
            return CarAnalysisResult.fromMap(cachedResult);
          }

          final analysisResults = <ImageAnalysis>[];

          for (final imagePath in imagePaths) {
            final analysis = await _analyzeImage(imagePath);
            if (analysis != null) {
              analysisResults.add(analysis);
            }
          }

          final result = _combineAnalysisResults(analysisResults);

          // حفظ في التخزين المؤقت
          await _cache.set(
            cacheKey,
            result.toMap(),
            expiration: const Duration(hours: 24),
          );

          LoggingService.success(
              'تم تحليل السيارة بنجاح: ${analysisResults.length} صورة');
          return result;
        });
      },
      'تحليل صور السيارة بالذكاء الاصطناعي',
    );
    return result ?? CarAnalysisResult.empty();
  }

  /// تقدير سعر السيارة بالذكاء الاصطناعي
  Future<PricePrediction> predictCarPrice({
    required String brand,
    required String model,
    required int year,
    required int mileage,
    required String condition,
    required String city,
    List<String>? imagePaths,
  }) async {
    final result =
        await EnhancedErrorHandler.executeWithErrorHandling<PricePrediction>(
      () async {
        return PerformanceService.measureAsync('ai_price_prediction', () async {
          final cacheKey =
              'price_prediction_${brand}_${model}_${year}_${mileage}';

          // التحقق من التخزين المؤقت
          final cachedResult = await _cache.get<Map<String, dynamic>>(cacheKey);
          if (cachedResult != null) {
            LoggingService.info('تم العثور على تنبؤ السعر في التخزين المؤقت');
            return PricePrediction.fromMap(cachedResult);
          }

          // تحليل الصور إذا توفرت
          CarAnalysisResult? imageAnalysis;
          if (imagePaths != null && imagePaths.isNotEmpty) {
            imageAnalysis = await analyzeCarImages(imagePaths);
          }

          // بناء البيانات للتنبؤ
          final predictionData = {
            'brand': brand,
            'model': model,
            'year': year,
            'mileage': mileage,
            'condition': condition,
            'city': city,
            'image_analysis': imageAnalysis?.toMap(),
          };

          // استدعاء API التنبؤ
          final prediction = await _callPricePredictionAPI(predictionData);

          // حفظ في التخزين المؤقت
          await _cache.set(
            cacheKey,
            prediction.toMap(),
            expiration: const Duration(hours: 6),
          );

          LoggingService.success(
              'تم تنبؤ السعر بنجاح: ${prediction.predictedPrice} ريال');
          return prediction;
        });
      },
      'تقدير سعر السيارة بالذكاء الاصطناعي',
    );
    return result ?? PricePrediction.empty();
  }

  /// توليد وصف ذكي للسيارة
  Future<String> generateCarDescription({
    required String brand,
    required String model,
    required int year,
    required String condition,
    List<String>? features,
    CarAnalysisResult? imageAnalysis,
  }) async {
    final result = await EnhancedErrorHandler.executeWithErrorHandling<String>(
      () async {
        return PerformanceService.measureAsync('ai_description_generation',
            () async {
          final prompt = _buildDescriptionPrompt(
            brand: brand,
            model: model,
            year: year,
            condition: condition,
            features: features,
            imageAnalysis: imageAnalysis,
          );

          final description = await _callOpenAI(prompt);

          LoggingService.success('تم توليد الوصف بنجاح');
          return description;
        });
      },
      'توليد وصف ذكي للسيارة',
    );
    return result ??
        'سيارة ${brand} ${model} موديل ${year} في حالة ${condition}';
  }

  /// اقتراح كلمات مفتاحية للبحث
  Future<List<String>> suggestSearchKeywords(String query) async {
    final result =
        await EnhancedErrorHandler.executeWithErrorHandling<List<String>>(
      () async {
        return PerformanceService.measureAsync('ai_keyword_suggestions',
            () async {
          final cacheKey = 'keywords_$query';

          // التحقق من التخزين المؤقت
          final cachedKeywords = await _cache.get<List<dynamic>>(cacheKey);
          if (cachedKeywords != null) {
            return cachedKeywords.cast<String>();
          }

          final prompt = '''
اقترح 10 كلمات مفتاحية للبحث عن السيارات باللغة العربية بناءً على الاستعلام التالي:
"$query"

يجب أن تكون الكلمات المفتاحية:
- مرتبطة بالسيارات
- باللغة العربية
- متنوعة (ماركات، موديلات، أنواع، ميزات)
- مفيدة للبحث

أعطني النتيجة كقائمة مفصولة بفواصل:
''';

          final response = await _callOpenAI(prompt);
          final keywords = response.split(',').map((k) => k.trim()).toList();

          // حفظ في التخزين المؤقت
          await _cache.set(
            cacheKey,
            keywords,
            expiration: const Duration(hours: 12),
          );

          return keywords;
        });
      },
      'اقتراح كلمات مفتاحية للبحث',
    );
    return result ?? [];
  }

  /// تحليل صورة واحدة
  Future<ImageAnalysis?> _analyzeImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) return null;

      // ضغط الصورة
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) return null;

      final resized = img.copyResize(image, width: 800);
      final compressedBytes = img.encodeJpg(resized, quality: 85);

      // استدعاء Google Vision API
      final response = await http.post(
        Uri.parse(
            'https://vision.googleapis.com/v1/images:annotate?key=$_googleVisionKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'requests': [
            {
              'image': {'content': base64Encode(compressedBytes)},
              'features': [
                {'type': 'LABEL_DETECTION', 'maxResults': 10},
                {'type': 'OBJECT_LOCALIZATION', 'maxResults': 10},
                {'type': 'TEXT_DETECTION', 'maxResults': 5},
              ],
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ImageAnalysis.fromGoogleVision(data['responses'][0]);
      }

      return null;
    } catch (e) {
      LoggingService.error('خطأ في تحليل الصورة', error: e);
      return null;
    }
  }

  /// دمج نتائج تحليل الصور
  CarAnalysisResult _combineAnalysisResults(List<ImageAnalysis> analyses) {
    if (analyses.isEmpty) return CarAnalysisResult.empty();

    final allLabels = <String>[];
    final allObjects = <String>[];
    final allTexts = <String>[];
    final damages = <String>[];
    final features = <String>[];

    for (final analysis in analyses) {
      allLabels.addAll(analysis.labels);
      allObjects.addAll(analysis.objects);
      allTexts.addAll(analysis.texts);
    }

    // تحليل الأضرار والميزات
    for (final label in allLabels) {
      if (_isDamageLabel(label)) {
        damages.add(label);
      } else if (_isFeatureLabel(label)) {
        features.add(label);
      }
    }

    // تقدير الحالة العامة
    final condition = _estimateCondition(damages, features);

    // تقدير الثقة
    final confidence = _calculateConfidence(analyses);

    return CarAnalysisResult(
      overallCondition: condition,
      confidence: confidence,
      detectedFeatures: features.toSet().toList(),
      detectedDamages: damages.toSet().toList(),
      extractedTexts: allTexts.toSet().toList(),
      analysisCount: analyses.length,
    );
  }

  /// استدعاء API تنبؤ السعر
  Future<PricePrediction> _callPricePredictionAPI(
      Map<String, dynamic> data) async {
    // محاكاة API تنبؤ السعر
    // في التطبيق الحقيقي، يجب استدعاء API حقيقي

    final basePrice = _calculateBasePrice(data);
    final adjustments = _calculatePriceAdjustments(data);

    final predictedPrice = basePrice + adjustments;
    final minPrice = predictedPrice * 0.85;
    final maxPrice = predictedPrice * 1.15;

    return PricePrediction(
      predictedPrice: predictedPrice,
      minPrice: minPrice,
      maxPrice: maxPrice,
      confidence: 0.85,
      factors: _getPriceFactors(data),
      marketTrend: 'stable',
      recommendation: _getPriceRecommendation(predictedPrice, data),
    );
  }

  /// استدعاء OpenAI API
  Future<String> _callOpenAI(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_openAIKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
          'max_tokens': 500,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      }

      return 'عذراً، لا يمكن توليد المحتوى في الوقت الحالي';
    } catch (e) {
      LoggingService.error('خطأ في استدعاء OpenAI', error: e);
      return 'عذراً، لا يمكن توليد المحتوى في الوقت الحالي';
    }
  }

  /// بناء prompt لتوليد الوصف
  String _buildDescriptionPrompt({
    required String brand,
    required String model,
    required int year,
    required String condition,
    List<String>? features,
    CarAnalysisResult? imageAnalysis,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('اكتب وصفاً جذاباً ومفصلاً لسيارة باللغة العربية:');
    buffer.writeln('الماركة: $brand');
    buffer.writeln('الموديل: $model');
    buffer.writeln('السنة: $year');
    buffer.writeln('الحالة: $condition');

    if (features != null && features.isNotEmpty) {
      buffer.writeln('الميزات: ${features.join(', ')}');
    }

    if (imageAnalysis != null) {
      buffer.writeln(
          'الميزات المكتشفة: ${imageAnalysis.detectedFeatures.join(', ')}');
      if (imageAnalysis.detectedDamages.isNotEmpty) {
        buffer.writeln(
            'الأضرار المكتشفة: ${imageAnalysis.detectedDamages.join(', ')}');
      }
    }

    buffer.writeln('\nيجب أن يكون الوصف:');
    buffer.writeln('- جذاباً ومقنعاً للمشترين');
    buffer.writeln('- يبرز نقاط القوة');
    buffer.writeln('- صادقاً حول الحالة');
    buffer.writeln('- لا يزيد عن 200 كلمة');

    return buffer.toString();
  }

  /// تحديد ما إذا كان التصنيف يشير إلى ضرر
  bool _isDamageLabel(String label) {
    final damageKeywords = [
      'scratch',
      'dent',
      'rust',
      'crack',
      'damage',
      'broken',
      'خدش',
      'صدأ',
      'كسر',
      'ضرر',
      'تلف'
    ];
    return damageKeywords
        .any((keyword) => label.toLowerCase().contains(keyword.toLowerCase()));
  }

  /// تحديد ما إذا كان التصنيف يشير إلى ميزة
  bool _isFeatureLabel(String label) {
    final featureKeywords = [
      'leather',
      'sunroof',
      'navigation',
      'camera',
      'sensor',
      'جلد',
      'فتحة سقف',
      'ملاحة',
      'كاميرا',
      'حساس'
    ];
    return featureKeywords
        .any((keyword) => label.toLowerCase().contains(keyword.toLowerCase()));
  }

  /// تقدير الحالة العامة
  String _estimateCondition(List<String> damages, List<String> features) {
    if (damages.isEmpty && features.isNotEmpty) return 'ممتازة';
    if (damages.length <= 2) return 'جيدة جداً';
    if (damages.length <= 5) return 'جيدة';
    return 'مقبولة';
  }

  /// حساب مستوى الثقة
  double _calculateConfidence(List<ImageAnalysis> analyses) {
    if (analyses.isEmpty) return 0.0;
    final avgConfidence =
        analyses.map((a) => a.confidence).reduce((a, b) => a + b) /
            analyses.length;
    return avgConfidence;
  }

  /// حساب السعر الأساسي
  double _calculateBasePrice(Map<String, dynamic> data) {
    // منطق حساب السعر الأساسي بناءً على الماركة والموديل والسنة
    final year = data['year'] as int;
    final currentYear = DateTime.now().year;
    final age = currentYear - year;

    // سعر أساسي افتراضي
    double basePrice = 50000.0;

    // تعديل حسب العمر
    basePrice -= (age * 2000);

    // تعديل حسب المسافة المقطوعة
    final mileage = data['mileage'] as int;
    basePrice -= (mileage / 10000) * 1000;

    return basePrice.clamp(10000, 500000);
  }

  /// حساب تعديلات السعر
  double _calculatePriceAdjustments(Map<String, dynamic> data) {
    double adjustments = 0.0;

    // تعديل حسب الحالة
    final condition = data['condition'] as String;
    switch (condition.toLowerCase()) {
      case 'ممتازة':
        adjustments += 5000;
        break;
      case 'جيدة جداً':
        adjustments += 2000;
        break;
      case 'جيدة':
        adjustments += 0;
        break;
      case 'مقبولة':
        adjustments -= 3000;
        break;
    }

    return adjustments;
  }

  /// الحصول على عوامل السعر
  List<String> _getPriceFactors(Map<String, dynamic> data) {
    return [
      'عمر السيارة',
      'المسافة المقطوعة',
      'الحالة العامة',
      'الماركة والموديل',
      'السوق المحلي',
    ];
  }

  /// الحصول على توصية السعر
  String _getPriceRecommendation(double price, Map<String, dynamic> data) {
    if (price > 100000) {
      return 'سعر مرتفع - مناسب للسيارات الفاخرة';
    } else if (price > 50000) {
      return 'سعر متوسط - مناسب لمعظم المشترين';
    } else {
      return 'سعر منخفض - فرصة جيدة للمشترين';
    }
  }
}
