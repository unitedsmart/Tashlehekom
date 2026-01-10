import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:tashlehekomv2/services/enhanced_ai_service.dart';
import 'package:tashlehekomv2/utils/enhanced_animations.dart';
import 'package:tashlehekomv2/widgets/enhanced_card_widget.dart';
import 'package:tashlehekomv2/utils/app_theme.dart';

/// شاشة تحليل السيارة بالذكاء الاصطناعي
class CarAnalysisScreen extends StatefulWidget {
  const CarAnalysisScreen({super.key});

  @override
  State<CarAnalysisScreen> createState() => _CarAnalysisScreenState();
}

class _CarAnalysisScreenState extends State<CarAnalysisScreen> {
  final EnhancedAIService _aiService = EnhancedAIService();
  final ImagePicker _picker = ImagePicker();
  
  List<File> _selectedImages = [];
  CarAnalysisResult? _analysisResult;
  bool _isAnalyzing = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تحليل السيارة بالذكاء الاصطناعي'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInstructionsCard(),
            const SizedBox(height: 20),
            _buildImageSelectionSection(),
            const SizedBox(height: 20),
            if (_selectedImages.isNotEmpty) _buildAnalyzeButton(),
            const SizedBox(height: 20),
            if (_isAnalyzing) _buildAnalyzingIndicator(),
            if (_analysisResult != null) _buildAnalysisResults(),
          ],
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
                Icon(Icons.info_outline, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'كيفية استخدام التحليل الذكي',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInstructionItem('1. اختر صور واضحة للسيارة من زوايا مختلفة'),
            _buildInstructionItem('2. تأكد من جودة الإضاءة في الصور'),
            _buildInstructionItem('3. اضغط على "تحليل السيارة" للحصول على النتائج'),
            _buildInstructionItem('4. ستحصل على تقييم شامل لحالة السيارة'),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: AppTheme.successColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSelectionSection() {
    return EnhancedAnimations.slideUp(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'صور السيارة',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (_selectedImages.isEmpty)
            _buildImagePickerCard()
          else
            _buildSelectedImagesGrid(),
          const SizedBox(height: 12),
          _buildImageActionButtons(),
        ],
      ),
    );
  }

  Widget _buildImagePickerCard() {
    return EnhancedCard(
      onTap: _pickImages,
      child: Container(
        height: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate,
              size: 64,
              color: AppTheme.primaryColor.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'اضغط لإضافة صور السيارة',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'يمكنك إضافة عدة صور للحصول على تحليل أفضل',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedImagesGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: _selectedImages.length,
      itemBuilder: (context, index) {
        return EnhancedAnimations.scaleIn(
          delay: Duration(milliseconds: index * 100),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  _selectedImages[index],
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => _removeImage(index),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _pickImages,
            icon: const Icon(Icons.add_photo_alternate),
            label: const Text('إضافة صور'),
          ),
        ),
        if (_selectedImages.isNotEmpty) ...[
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _clearImages,
              icon: const Icon(Icons.clear_all),
              label: const Text('مسح الكل'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAnalyzeButton() {
    return EnhancedAnimations.scaleIn(
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _isAnalyzing ? null : _analyzeImages,
          icon: const Icon(Icons.psychology),
          label: const Text('تحليل السيارة بالذكاء الاصطناعي'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyzingIndicator() {
    return EnhancedAnimations.fadeIn(
      child: EnhancedCard(
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'جاري تحليل الصور...',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'قد تستغرق هذه العملية بضع ثوانٍ',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisResults() {
    return EnhancedAnimations.slideUp(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'نتائج التحليل',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildOverallConditionCard(),
          const SizedBox(height: 12),
          _buildDetectedFeaturesCard(),
          const SizedBox(height: 12),
          _buildDetectedDamagesCard(),
          const SizedBox(height: 12),
          _buildConfidenceCard(),
        ],
      ),
    );
  }

  Widget _buildOverallConditionCard() {
    final condition = _analysisResult!.overallCondition;
    Color conditionColor;
    IconData conditionIcon;

    switch (condition) {
      case 'ممتازة':
        conditionColor = AppTheme.successColor;
        conditionIcon = Icons.star;
        break;
      case 'جيدة جداً':
        conditionColor = Colors.green;
        conditionIcon = Icons.thumb_up;
        break;
      case 'جيدة':
        conditionColor = Colors.orange;
        conditionIcon = Icons.check_circle;
        break;
      default:
        conditionColor = Colors.red;
        conditionIcon = Icons.warning;
    }

    return InfoCard(
      title: 'الحالة العامة',
      value: condition,
      icon: conditionIcon,
      iconColor: conditionColor,
    );
  }

  Widget _buildDetectedFeaturesCard() {
    return EnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star_outline, color: AppTheme.successColor),
              const SizedBox(width: 8),
              Text(
                'الميزات المكتشفة',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_analysisResult!.detectedFeatures.isEmpty)
            Text(
              'لم يتم اكتشاف ميزات خاصة',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _analysisResult!.detectedFeatures.map((feature) {
                return Chip(
                  label: Text(feature),
                  backgroundColor: AppTheme.successColor.withOpacity(0.1),
                  labelStyle: TextStyle(color: AppTheme.successColor),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildDetectedDamagesCard() {
    return EnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_outlined, color: AppTheme.warningColor),
              const SizedBox(width: 8),
              Text(
                'الأضرار المكتشفة',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_analysisResult!.detectedDamages.isEmpty)
            Text(
              'لم يتم اكتشاف أضرار واضحة',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.successColor,
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _analysisResult!.detectedDamages.map((damage) {
                return Chip(
                  label: Text(damage),
                  backgroundColor: AppTheme.warningColor.withOpacity(0.1),
                  labelStyle: TextStyle(color: AppTheme.warningColor),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildConfidenceCard() {
    final confidence = _analysisResult!.confidence;
    final confidencePercent = (confidence * 100).toInt();
    
    return InfoCard(
      title: 'دقة التحليل',
      value: '$confidencePercent%',
      icon: Icons.analytics,
      iconColor: confidence > 0.8 ? AppTheme.successColor : 
                confidence > 0.6 ? AppTheme.warningColor : AppTheme.errorColor,
    );
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images.map((image) => File(image.path)));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في اختيار الصور: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _clearImages() {
    setState(() {
      _selectedImages.clear();
      _analysisResult = null;
    });
  }

  Future<void> _analyzeImages() async {
    if (_selectedImages.isEmpty) return;

    setState(() {
      _isAnalyzing = true;
      _analysisResult = null;
    });

    try {
      final imagePaths = _selectedImages.map((image) => image.path).toList();
      final result = await _aiService.analyzeCarImages(imagePaths);
      
      setState(() {
        _analysisResult = result;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تحليل الصور بنجاح!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تحليل الصور: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }
}
