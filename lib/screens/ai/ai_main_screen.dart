import 'package:flutter/material.dart';
import 'package:tashlehekomv2/screens/ai/car_analysis_screen.dart';
import 'package:tashlehekomv2/screens/ai/price_prediction_screen.dart';
import 'package:tashlehekomv2/utils/enhanced_animations.dart';
import 'package:tashlehekomv2/widgets/enhanced_card_widget.dart';
import 'package:tashlehekomv2/utils/app_theme.dart';

/// الشاشة الرئيسية للذكاء الاصطناعي
class AIMainScreen extends StatelessWidget {
  const AIMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الذكاء الاصطناعي'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(context),
            const SizedBox(height: 20),
            _buildAIFeaturesGrid(context),
            const SizedBox(height: 20),
            _buildComingSoonSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    return EnhancedAnimations.fadeIn(
      child: EnhancedCard(
        child: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.psychology,
                    size: 32,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'مرحباً بك في عالم الذكاء الاصطناعي',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'استخدم أحدث تقنيات الذكاء الاصطناعي لتحليل السيارات وتقدير الأسعار بدقة عالية',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAIFeaturesGrid(BuildContext context) {
    final features = [
      AIFeature(
        title: 'تحليل السيارة',
        description: 'تحليل شامل لحالة السيارة باستخدام الذكاء الاصطناعي',
        icon: Icons.analytics,
        color: Colors.blue,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CarAnalysisScreen()),
        ),
      ),
      AIFeature(
        title: 'تقدير السعر',
        description: 'احصل على تقدير دقيق لسعر السيارة',
        icon: Icons.calculate,
        color: Colors.green,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PricePredictionScreen()),
        ),
      ),
      AIFeature(
        title: 'كشف الأضرار',
        description: 'اكتشاف الأضرار والعيوب في السيارة تلقائياً',
        icon: Icons.search,
        color: Colors.orange,
        onTap: () => _showComingSoonDialog(context, 'كشف الأضرار'),
      ),
      AIFeature(
        title: 'توليد الوصف',
        description: 'توليد وصف جذاب ومفصل للسيارة',
        icon: Icons.description,
        color: Colors.purple,
        onTap: () => _showComingSoonDialog(context, 'توليد الوصف'),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الميزات المتاحة',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: features.length,
          itemBuilder: (context, index) {
            return EnhancedAnimations.scaleIn(
              delay: Duration(milliseconds: index * 100),
              child: _buildFeatureCard(context, features[index]),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFeatureCard(BuildContext context, AIFeature feature) {
    return EnhancedCard(
      onTap: feature.onTap,
      enableAnimation: true,
      enableHoverEffect: true,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: feature.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                feature.icon,
                size: 32,
                color: feature.color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              feature.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              feature.description,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComingSoonSection(BuildContext context) {
    final upcomingFeatures = [
      'التعرف على الأصوات والاهتزازات',
      'تحليل تاريخ الصيانة',
      'التنبؤ بالأعطال المستقبلية',
      'مقارنة السيارات الذكية',
      'تقييم قيمة الاستثمار',
    ];

    return EnhancedAnimations.slideUp(
      child: EnhancedCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.upcoming, color: AppTheme.infoColor),
                const SizedBox(width: 8),
                Text(
                  'ميزات قادمة قريباً',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.infoColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...upcomingFeatures.map((feature) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: AppTheme.infoColor.withOpacity(0.7),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      feature,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.infoColor.withOpacity(0.8),
                      ),
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.infoColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.infoColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppTheme.infoColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'نعمل باستمرار على تطوير ميزات جديدة لتحسين تجربتك',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.infoColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context, String featureName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.upcoming, color: AppTheme.infoColor),
            const SizedBox(width: 8),
            Text('قريباً'),
          ],
        ),
        content: Text(
          'ميزة "$featureName" ستكون متاحة قريباً في التحديثات القادمة.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }
}

/// نموذج ميزة الذكاء الاصطناعي
class AIFeature {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const AIFeature({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
