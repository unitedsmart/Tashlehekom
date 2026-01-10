import 'package:flutter/material.dart';
import 'package:tashlehekomv2/services/analytics_service.dart';
import 'package:tashlehekomv2/models/analytics_models.dart';
import 'package:tashlehekomv2/utils/enhanced_animations.dart';
import 'package:tashlehekomv2/widgets/enhanced_card_widget.dart';
import 'package:tashlehekomv2/widgets/stats_card.dart';
import 'package:tashlehekomv2/utils/app_theme.dart';

/// شاشة تقرير السوق
class MarketReportScreen extends StatefulWidget {
  const MarketReportScreen({super.key});

  @override
  State<MarketReportScreen> createState() => _MarketReportScreenState();
}

class _MarketReportScreenState extends State<MarketReportScreen> {
  final AnalyticsService _analyticsService = AnalyticsService();
  
  MarketReport? _marketReport;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMarketReport();
  }

  Future<void> _loadMarketReport() async {
    setState(() => _isLoading = true);

    try {
      final report = await _analyticsService.getMarketReport();
      setState(() {
        _marketReport = report;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تحميل تقرير السوق: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تقرير السوق'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadMarketReport,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: _exportReport,
            icon: const Icon(Icons.download),
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingScreen()
          : _marketReport == null
              ? _buildErrorScreen()
              : _buildReportContent(),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'جاري تحميل تقرير السوق...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'فشل في تحميل تقرير السوق',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'يرجى المحاولة مرة أخرى',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadMarketReport,
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildReportContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReportHeader(),
          const SizedBox(height: 20),
          _buildPriceTrendsSection(),
          const SizedBox(height: 20),
          _buildPopularModelsSection(),
          const SizedBox(height: 20),
          _buildCityAnalyticsSection(),
          const SizedBox(height: 20),
          _buildSeasonalTrendsSection(),
        ],
      ),
    );
  }

  Widget _buildReportHeader() {
    return EnhancedAnimations.fadeIn(
      child: EnhancedCard(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo.shade600, Colors.purple.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.assessment,
                    size: 32,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'تقرير السوق الشامل',
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
                'تم إنشاؤه في: ${_formatDateTime(_marketReport!.generatedAt)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'تحليل شامل لاتجاهات السوق والأسعار والطلب على السيارات المستعملة',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceTrendsSection() {
    return EnhancedAnimations.slideUp(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: AppTheme.successColor),
              const SizedBox(width: 8),
              Text(
                'اتجاهات الأسعار',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...(_marketReport!.priceTrends.map((trend) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: EnhancedCard(
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getTrendColor(trend).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getTrendIcon(trend),
                    color: _getTrendColor(trend),
                    size: 20,
                  ),
                ),
                title: Text(
                  trend.brand,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'السعر الحالي: ${trend.currentPrice.toStringAsFixed(0)} ريال',
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${trend.changePercent > 0 ? '+' : ''}${trend.changePercent.toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: _getTrendColor(trend),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      trend.isIncreasing ? 'ارتفاع' : trend.isDecreasing ? 'انخفاض' : 'مستقر',
                      style: TextStyle(
                        fontSize: 12,
                        color: _getTrendColor(trend),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ))),
        ],
      ),
    );
  }

  Widget _buildPopularModelsSection() {
    return EnhancedAnimations.slideUp(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star, color: AppTheme.warningColor),
              const SizedBox(width: 8),
              Text(
                'الموديلات الأكثر شعبية',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            itemCount: _marketReport!.popularModels.length,
            itemBuilder: (context, index) {
              final model = _marketReport!.popularModels[index];
              return EnhancedAnimations.scaleIn(
                delay: Duration(milliseconds: index * 100),
                child: AdvancedStatsCard(
                  title: '${model.brand} ${model.model}',
                  value: model.searchCount.toString(),
                  subtitle: '${model.viewCount} مشاهدة',
                  icon: Icons.directions_car,
                  color: _getModelColor(index),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCityAnalyticsSection() {
    return EnhancedAnimations.slideUp(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_city, color: AppTheme.infoColor),
              const SizedBox(width: 8),
              Text(
                'تحليل المدن',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...(_marketReport!.cityAnalytics.map((city) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: EnhancedCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: AppTheme.infoColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          city.city,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.infoColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            city.popularBrand,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.infoColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'إجمالي السيارات',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                city.totalCars.toString(),
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.infoColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'متوسط السعر',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                '${city.averagePrice.toStringAsFixed(0)} ريال',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.successColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ))),
        ],
      ),
    );
  }

  Widget _buildSeasonalTrendsSection() {
    return EnhancedAnimations.slideUp(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_month, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Text(
                'الاتجاهات الموسمية',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          EnhancedCard(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'الشهر',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'المبيعات',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'متوسط السعر',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ...(_marketReport!.seasonalTrends.map((trend) => Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(trend.month),
                      ),
                      Expanded(
                        child: Text(
                          trend.salesCount.toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '${trend.averagePrice.toStringAsFixed(0)} ريال',
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            color: AppTheme.successColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getTrendColor(PriceTrend trend) {
    if (trend.isIncreasing) return Colors.green;
    if (trend.isDecreasing) return Colors.red;
    return Colors.grey;
  }

  IconData _getTrendIcon(PriceTrend trend) {
    if (trend.isIncreasing) return Icons.trending_up;
    if (trend.isDecreasing) return Icons.trending_down;
    return Icons.trending_flat;
  }

  Color _getModelColor(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];
    return colors[index % colors.length];
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _exportReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('سيتم إضافة ميزة تصدير التقرير قريباً'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
