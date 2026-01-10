import 'package:flutter/material.dart';
import 'package:tashlehekomv2/services/enhanced_ai_service.dart';
import 'package:tashlehekomv2/utils/enhanced_animations.dart';
import 'package:tashlehekomv2/widgets/enhanced_card_widget.dart';
import 'package:tashlehekomv2/utils/app_theme.dart';

/// شاشة تقدير الأسعار بالذكاء الاصطناعي
class PricePredictionScreen extends StatefulWidget {
  const PricePredictionScreen({super.key});

  @override
  State<PricePredictionScreen> createState() => _PricePredictionScreenState();
}

class _PricePredictionScreenState extends State<PricePredictionScreen> {
  final EnhancedAIService _aiService = EnhancedAIService();
  final _formKey = GlobalKey<FormState>();
  
  // متحكمات النص
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _mileageController = TextEditingController();
  final _cityController = TextEditingController();
  
  String _selectedCondition = 'جيدة';
  PricePrediction? _prediction;
  bool _isPredicting = false;

  final List<String> _conditions = [
    'ممتازة',
    'جيدة جداً',
    'جيدة',
    'مقبولة',
  ];

  final List<String> _popularBrands = [
    'تويوتا',
    'هوندا',
    'نيسان',
    'هيونداي',
    'كيا',
    'مازدا',
    'فورد',
    'شيفروليه',
    'بي إم دبليو',
    'مرسيدس',
  ];

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _mileageController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تقدير السعر بالذكاء الاصطناعي'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInstructionsCard(),
              const SizedBox(height: 20),
              _buildCarDetailsForm(),
              const SizedBox(height: 20),
              _buildPredictButton(),
              const SizedBox(height: 20),
              if (_isPredicting) _buildPredictingIndicator(),
              if (_prediction != null) _buildPredictionResults(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionsCard() {
    return EnhancedAnimations.fadeIn(
      child: EnhancedCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calculate, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'تقدير السعر الذكي',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'احصل على تقدير دقيق لسعر سيارتك باستخدام الذكاء الاصطناعي. '
              'يعتمد التقدير على بيانات السوق الحالية وحالة السيارة.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarDetailsForm() {
    return EnhancedAnimations.slideUp(
      child: EnhancedCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'بيانات السيارة',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // الماركة
            _buildBrandField(),
            const SizedBox(height: 16),
            
            // الموديل
            TextFormField(
              controller: _modelController,
              decoration: const InputDecoration(
                labelText: 'الموديل',
                hintText: 'مثال: كامري، أكورد، التيما',
                prefixIcon: Icon(Icons.directions_car),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى إدخال موديل السيارة';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // السنة والمسافة
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _yearController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'سنة الصنع',
                      hintText: '2020',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال السنة';
                      }
                      final year = int.tryParse(value);
                      if (year == null || year < 1990 || year > DateTime.now().year + 1) {
                        return 'سنة غير صحيحة';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _mileageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'المسافة المقطوعة',
                      hintText: '50000',
                      prefixIcon: Icon(Icons.speed),
                      suffixText: 'كم',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال المسافة';
                      }
                      final mileage = int.tryParse(value);
                      if (mileage == null || mileage < 0) {
                        return 'مسافة غير صحيحة';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // الحالة
            DropdownButtonFormField<String>(
              value: _selectedCondition,
              decoration: const InputDecoration(
                labelText: 'حالة السيارة',
                prefixIcon: Icon(Icons.star),
              ),
              items: _conditions.map((condition) {
                return DropdownMenuItem(
                  value: condition,
                  child: Text(condition),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCondition = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            
            // المدينة
            TextFormField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: 'المدينة',
                hintText: 'الرياض، جدة، الدمام...',
                prefixIcon: Icon(Icons.location_city),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى إدخال المدينة';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandField() {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return _popularBrands;
        }
        return _popularBrands.where((brand) =>
          brand.toLowerCase().contains(textEditingValue.text.toLowerCase()));
      },
      onSelected: (String selection) {
        _brandController.text = selection;
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        _brandController.text = controller.text;
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: const InputDecoration(
            labelText: 'الماركة',
            hintText: 'اختر أو اكتب اسم الماركة',
            prefixIcon: Icon(Icons.branding_watermark),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'يرجى إدخال ماركة السيارة';
            }
            return null;
          },
          onFieldSubmitted: (value) => onFieldSubmitted(),
        );
      },
    );
  }

  Widget _buildPredictButton() {
    return EnhancedAnimations.scaleIn(
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _isPredicting ? null : _predictPrice,
          icon: const Icon(Icons.calculate),
          label: const Text('تقدير السعر'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildPredictingIndicator() {
    return EnhancedAnimations.fadeIn(
      child: EnhancedCard(
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'جاري تحليل بيانات السوق...',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'يتم مقارنة سيارتك مع آلاف السيارات المماثلة',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionResults() {
    return EnhancedAnimations.slideUp(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تقدير السعر',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildPriceCard(),
          const SizedBox(height: 12),
          _buildPriceRangeCard(),
          const SizedBox(height: 12),
          _buildMarketTrendCard(),
          const SizedBox(height: 12),
          _buildRecommendationCard(),
          const SizedBox(height: 12),
          _buildPriceFactorsCard(),
        ],
      ),
    );
  }

  Widget _buildPriceCard() {
    final price = _prediction!.predictedPrice;
    return StatsCard(
      title: 'السعر المتوقع',
      value: '${price.toStringAsFixed(0)} ريال',
      icon: Icons.attach_money,
      color: AppTheme.primaryColor,
    );
  }

  Widget _buildPriceRangeCard() {
    return EnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: AppTheme.infoColor),
              const SizedBox(width: 8),
              Text(
                'نطاق السعر المتوقع',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildPriceRangeItem(
                  'الحد الأدنى',
                  _prediction!.minPrice,
                  Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPriceRangeItem(
                  'الحد الأعلى',
                  _prediction!.maxPrice,
                  Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRangeItem(String title, double price, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${price.toStringAsFixed(0)} ريال',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketTrendCard() {
    return InfoCard(
      title: 'اتجاه السوق',
      value: _prediction!.marketTrend,
      icon: Icons.show_chart,
      iconColor: AppTheme.infoColor,
    );
  }

  Widget _buildRecommendationCard() {
    return EnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: AppTheme.warningColor),
              const SizedBox(width: 8),
              Text(
                'التوصية',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _prediction!.recommendation,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceFactorsCard() {
    return EnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: AppTheme.successColor),
              const SizedBox(width: 8),
              Text(
                'العوامل المؤثرة في السعر',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...(_prediction!.factors.map((factor) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Icon(Icons.check_circle, size: 16, color: AppTheme.successColor),
                const SizedBox(width: 8),
                Text(factor),
              ],
            ),
          ))),
        ],
      ),
    );
  }

  Future<void> _predictPrice() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isPredicting = true;
      _prediction = null;
    });

    try {
      final prediction = await _aiService.predictCarPrice(
        brand: _brandController.text,
        model: _modelController.text,
        year: int.parse(_yearController.text),
        mileage: int.parse(_mileageController.text),
        condition: _selectedCondition,
        city: _cityController.text,
      );
      
      setState(() {
        _prediction = prediction;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تقدير السعر بنجاح!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تقدير السعر: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isPredicting = false;
      });
    }
  }
}
