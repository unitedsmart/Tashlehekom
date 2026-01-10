import 'package:flutter/material.dart';
import 'package:tashlehekomv2/services/analytics_service.dart';
import 'package:tashlehekomv2/models/analytics_models.dart';
import 'package:tashlehekomv2/utils/enhanced_animations.dart';
import 'package:tashlehekomv2/widgets/enhanced_card_widget.dart';
import 'package:tashlehekomv2/utils/app_theme.dart';

/// شاشة لوحة تحكم التحليلات
class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() =>
      _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen>
    with TickerProviderStateMixin {
  final AnalyticsService _analyticsService = AnalyticsService();

  AppStatistics? _appStats;
  SalesAnalytics? _salesAnalytics;
  UserAnalytics? _userAnalytics;
  PerformanceMetrics? _performanceMetrics;

  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAnalytics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);

    try {
      final futures = await Future.wait([
        _analyticsService.getAppStatistics(),
        _analyticsService.getSalesAnalytics(),
        _analyticsService.getUserAnalytics(),
        _analyticsService.getPerformanceMetrics(),
      ]);

      setState(() {
        _appStats = futures[0] as AppStatistics;
        _salesAnalytics = futures[1] as SalesAnalytics;
        _userAnalytics = futures[2] as UserAnalytics;
        _performanceMetrics = futures[3] as PerformanceMetrics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تحميل التحليلات: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم التحليلية'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadAnalytics,
            icon: const Icon(Icons.refresh),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'عام', icon: Icon(Icons.dashboard)),
            Tab(text: 'المبيعات', icon: Icon(Icons.trending_up)),
            Tab(text: 'المستخدمين', icon: Icon(Icons.people)),
            Tab(text: 'الأداء', icon: Icon(Icons.speed)),
          ],
        ),
      ),
      body: _isLoading
          ? _buildLoadingScreen()
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildSalesTab(),
                _buildUsersTab(),
                _buildPerformanceTab(),
              ],
            ),
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
            'جاري تحميل التحليلات...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    if (_appStats == null) return const SizedBox();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeCard(),
          const SizedBox(height: 20),
          _buildStatsGrid(),
          const SizedBox(height: 20),
          _buildPopularBrandsSection(),
          const SizedBox(height: 20),
          _buildAveragePricesSection(),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
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
                    Icons.analytics,
                    size: 32,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'نظرة عامة على التحليلات',
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
                'آخر تحديث: ${_formatDateTime(_appStats!.lastUpdated)}',
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

  Widget _buildStatsGrid() {
    final stats = [
      StatCard(
        title: 'إجمالي المستخدمين',
        value: _appStats!.totalUsers.toString(),
        icon: Icons.people,
        color: Colors.blue,
      ),
      StatCard(
        title: 'إجمالي السيارات',
        value: _appStats!.totalCars.toString(),
        icon: Icons.directions_car,
        color: Colors.green,
      ),
      StatCard(
        title: 'إجمالي المعاملات',
        value: _appStats!.totalTransactions.toString(),
        icon: Icons.receipt,
        color: Colors.orange,
      ),
      StatCard(
        title: 'المستخدمين النشطين',
        value: _appStats!.activeUsers.toString(),
        icon: Icons.trending_up,
        color: Colors.purple,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        return EnhancedAnimations.scaleIn(
          delay: Duration(milliseconds: index * 100),
          child: _buildStatCard(stats[index]),
        );
      },
    );
  }

  Widget _buildStatCard(StatCard stat) {
    return StatsCard(
      title: stat.title,
      value: stat.value,
      icon: stat.icon,
      color: stat.color,
    );
  }

  Widget _buildPopularBrandsSection() {
    return EnhancedAnimations.slideUp(
      child: EnhancedCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'الماركات الأكثر شعبية',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...(_appStats!.popularBrands.take(5).map((brand) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(brand.brand),
                      ),
                      Text(
                        '${brand.count} سيارة',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${brand.percentage.toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ))),
          ],
        ),
      ),
    );
  }

  Widget _buildAveragePricesSection() {
    return EnhancedAnimations.slideUp(
      child: EnhancedCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.attach_money, color: AppTheme.successColor),
                const SizedBox(width: 8),
                Text(
                  'متوسط الأسعار حسب الماركة',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...(_appStats!.averagePrices.entries.take(5).map((entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(entry.key),
                      ),
                      Text(
                        '${entry.value.toStringAsFixed(0)} ريال',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.successColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ))),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesTab() {
    if (_salesAnalytics == null) return const SizedBox();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSalesStatsGrid(),
          const SizedBox(height: 20),
          _buildSalesTrendsChart(),
        ],
      ),
    );
  }

  Widget _buildSalesStatsGrid() {
    final stats = [
      StatCard(
        title: 'إجمالي المبيعات',
        value: _salesAnalytics!.totalSales.toString(),
        icon: Icons.shopping_cart,
        color: Colors.blue,
      ),
      StatCard(
        title: 'إجمالي الإيرادات',
        value: '${_salesAnalytics!.totalRevenue.toStringAsFixed(0)} ريال',
        icon: Icons.monetization_on,
        color: Colors.green,
      ),
      StatCard(
        title: 'متوسط السعر',
        value: '${_salesAnalytics!.averagePrice.toStringAsFixed(0)} ريال',
        icon: Icons.trending_up,
        color: Colors.orange,
      ),
      StatCard(
        title: 'معدل التحويل',
        value: '${(_salesAnalytics!.conversionRate * 100).toStringAsFixed(1)}%',
        icon: Icons.trending_up,
        color: Colors.purple,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        return EnhancedAnimations.scaleIn(
          delay: Duration(milliseconds: index * 100),
          child: _buildStatCard(stats[index]),
        );
      },
    );
  }

  Widget _buildSalesTrendsChart() {
    return EnhancedAnimations.slideUp(
      child: EnhancedCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.show_chart, color: AppTheme.infoColor),
                const SizedBox(width: 8),
                Text(
                  'اتجاهات المبيعات اليومية',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              child: Center(
                child: Text(
                  'الرسم البياني للمبيعات\n(${_salesAnalytics!.dailyTrends.length} نقطة بيانات)',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersTab() {
    if (_userAnalytics == null) return const SizedBox();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserDemographics(),
          const SizedBox(height: 20),
          _buildUserActivity(),
          const SizedBox(height: 20),
          _buildUserRetention(),
        ],
      ),
    );
  }

  Widget _buildUserDemographics() {
    return EnhancedAnimations.fadeIn(
      child: EnhancedCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_city, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'التوزيع الجغرافي للمستخدمين',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...(_userAnalytics!.demographics.entries.map((entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(entry.key),
                      ),
                      Text(
                        '${entry.value}%',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ))),
          ],
        ),
      ),
    );
  }

  Widget _buildUserActivity() {
    return EnhancedAnimations.slideUp(
      child: EnhancedCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: AppTheme.successColor),
                const SizedBox(width: 8),
                Text(
                  'أنشطة المستخدمين',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...(_userAnalytics!.activityData.map((activity) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(activity.label),
                      ),
                      Text(
                        '${activity.value.toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.successColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ))),
          ],
        ),
      ),
    );
  }

  Widget _buildUserRetention() {
    return EnhancedAnimations.slideUp(
      child: EnhancedCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.people_alt, color: AppTheme.warningColor),
                const SizedBox(width: 8),
                Text(
                  'معدل الاحتفاظ بالمستخدمين',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...(_userAnalytics!.retentionData.entries.map((entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(entry.key),
                      ),
                      Text(
                        '${entry.value.toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.warningColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ))),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceTab() {
    if (_performanceMetrics == null) return const SizedBox();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPerformanceStatsGrid(),
          const SizedBox(height: 20),
          _buildApiResponseTimes(),
        ],
      ),
    );
  }

  Widget _buildPerformanceStatsGrid() {
    final stats = [
      StatCard(
        title: 'متوسط وقت التحميل',
        value: '${_performanceMetrics!.averageLoadTime.toStringAsFixed(1)}s',
        icon: Icons.speed,
        color: Colors.blue,
      ),
      StatCard(
        title: 'معدل الأخطاء',
        value: '${(_performanceMetrics!.errorRate * 100).toStringAsFixed(2)}%',
        icon: Icons.error,
        color: Colors.red,
      ),
      StatCard(
        title: 'معدل التعطل',
        value: '${(_performanceMetrics!.crashRate * 100).toStringAsFixed(2)}%',
        icon: Icons.bug_report,
        color: Colors.orange,
      ),
      StatCard(
        title: 'رضا المستخدمين',
        value: '${_performanceMetrics!.userSatisfaction.toStringAsFixed(1)}/5',
        icon: Icons.star,
        color: Colors.green,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        return EnhancedAnimations.scaleIn(
          delay: Duration(milliseconds: index * 100),
          child: _buildStatCard(stats[index]),
        );
      },
    );
  }

  Widget _buildApiResponseTimes() {
    return EnhancedAnimations.slideUp(
      child: EnhancedCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.api, color: AppTheme.infoColor),
                const SizedBox(width: 8),
                Text(
                  'أوقات استجابة API',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...(_performanceMetrics!.apiResponseTimes.entries
                .map((entry) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(entry.key),
                          ),
                          Text(
                            '${entry.value.toStringAsFixed(0)}ms',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppTheme.infoColor,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ))),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

/// نموذج بطاقة الإحصائية
class StatCard {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
}
