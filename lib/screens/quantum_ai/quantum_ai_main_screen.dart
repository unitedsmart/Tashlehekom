import 'package:flutter/material.dart';
import 'package:tashlehekomv2/models/quantum_ai_models.dart';
import 'package:tashlehekomv2/services/quantum_ai_service.dart';
import 'package:tashlehekomv2/utils/enhanced_animations.dart';
import 'package:tashlehekomv2/widgets/stats_card.dart';

/// شاشة الذكاء الاصطناعي الكمي الرئيسية
class QuantumAIMainScreen extends StatefulWidget {
  const QuantumAIMainScreen({super.key});

  @override
  State<QuantumAIMainScreen> createState() => _QuantumAIMainScreenState();
}

class _QuantumAIMainScreenState extends State<QuantumAIMainScreen>
    with TickerProviderStateMixin {
  final QuantumAIService _quantumService = QuantumAIService();
  
  late TabController _tabController;
  
  QuantumSystemStatus? _systemStatus;
  QuantumMarketAnalysis? _marketAnalysis;
  QuantumDemandForecast? _demandForecast;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadQuantumData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadQuantumData() async {
    setState(() => _isLoading = true);
    
    try {
      final results = await Future.wait([
        _quantumService.getQuantumSystemStatus(),
        _quantumService.analyzeMarketWithQuantum(
          region: 'الرياض',
          carType: 'سيدان',
        ),
        _quantumService.forecastDemandWithQuantum(
          carCategory: 'سيدان',
          region: 'الرياض',
        ),
      ]);

      setState(() {
        _systemStatus = results[0] as QuantumSystemStatus;
        _marketAnalysis = results[1] as QuantumMarketAnalysis;
        _demandForecast = results[2] as QuantumDemandForecast;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحميل البيانات الكمية: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الذكاء الاصطناعي الكمي'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'النظرة العامة', icon: Icon(Icons.dashboard)),
            Tab(text: 'تحليل السوق', icon: Icon(Icons.analytics)),
            Tab(text: 'التنبؤات', icon: Icon(Icons.trending_up)),
            Tab(text: 'النظام', icon: Icon(Icons.settings_input_component)),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade50,
              Colors.white,
            ],
          ),
        ),
        child: _isLoading
            ? _buildLoadingScreen()
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(),
                  _buildMarketAnalysisTab(),
                  _buildPredictionsTab(),
                  _buildSystemTab(),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _loadQuantumData,
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.refresh, color: Colors.white),
        label: const Text('تحديث', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          EnhancedAnimations.pulse(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.psychology,
                size: 40,
                color: Colors.deepPurple,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'جاري تحليل البيانات الكمية...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 16),
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeCard(),
          const SizedBox(height: 20),
          _buildQuickStatsGrid(),
          const SizedBox(height: 20),
          _buildQuantumCapabilitiesCard(),
          const SizedBox(height: 20),
          _buildRecentAnalysisCard(),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return EnhancedAnimations.slideInFromTop(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.deepPurple.shade600,
              Colors.deepPurple.shade800,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.psychology,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الذكاء الاصطناعي الكمي',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'تحليل متقدم باستخدام الحوسبة الكمية',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'استفد من قوة الحوسبة الكمية للحصول على تحليلات دقيقة وتنبؤات متطورة لسوق السيارات',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatsGrid() {
    final stats = [
      _StatItem(
        title: 'المعالجات النشطة',
        value: '${_systemStatus?.activeProcessors ?? 0}',
        icon: Icons.memory,
        color: Colors.blue,
      ),
      _StatItem(
        title: 'إجمالي الكيوبتس',
        value: '${_systemStatus?.totalQubits ?? 0}',
        icon: Icons.scatter_plot,
        color: Colors.green,
      ),
      _StatItem(
        title: 'دقة التحليل',
        value: '${((_marketAnalysis?.confidenceLevel ?? 0) * 100).toInt()}%',
        icon: Icons.precision_manufacturing,
        color: Colors.orange,
      ),
      _StatItem(
        title: 'حالة النظام',
        value: _systemStatus?.systemHealth ?? 'غير معروف',
        icon: Icons.health_and_safety,
        color: Colors.purple,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) => EnhancedAnimations.scaleIn(
        delay: Duration(milliseconds: index * 100),
        child: StatsCard(
          title: stats[index].title,
          value: stats[index].value,
          icon: stats[index].icon,
          color: stats[index].color,
        ),
      ),
    );
  }

  Widget _buildQuantumCapabilitiesCard() {
    return EnhancedAnimations.slideInFromLeft(
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Colors.deepPurple,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'القدرات الكمية',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildCapabilityItem(
                'تحليل السوق الكمي',
                'تحليل معقد لاتجاهات السوق باستخدام الخوارزميات الكمية',
                Icons.trending_up,
              ),
              _buildCapabilityItem(
                'التنبؤ بالأسعار',
                'تنبؤات دقيقة بأسعار السيارات مع مستويات ثقة عالية',
                Icons.attach_money,
              ),
              _buildCapabilityItem(
                'تحليل السلوك',
                'فهم عميق لسلوك المستخدمين وتفضيلاتهم',
                Icons.psychology,
              ),
              _buildCapabilityItem(
                'كشف الاحتيال',
                'كشف متقدم للمعاملات المشبوهة والأنشطة الاحتيالية',
                Icons.security,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCapabilityItem(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.deepPurple, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAnalysisCard() {
    return EnhancedAnimations.slideInFromRight(
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.analytics,
                      color: Colors.green,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'آخر التحليلات',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_marketAnalysis != null) ...[
                _buildAnalysisItem(
                  'تحليل السوق - ${_marketAnalysis!.region}',
                  'نظرة السوق: ${_marketAnalysis!.marketOutlook}',
                  'مستوى التقلب: ${_marketAnalysis!.volatilityLevel}',
                  Colors.blue,
                ),
              ],
              if (_demandForecast != null) ...[
                _buildAnalysisItem(
                  'التنبؤ بالطلب - ${_demandForecast!.carCategory}',
                  'الاتجاه العام: ${_demandForecast!.overallTrend.displayName}',
                  'متوسط الطلب: ${(_demandForecast!.averageDemand * 100).toInt()}%',
                  Colors.orange,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisItem(
    String title,
    String subtitle,
    String detail,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: color.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: color.shade600,
              fontSize: 14,
            ),
          ),
          Text(
            detail,
            style: TextStyle(
              color: color.shade600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketAnalysisTab() {
    return Center(
      child: Text(
        'تحليل السوق الكمي - قيد التطوير',
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }

  Widget _buildPredictionsTab() {
    return Center(
      child: Text(
        'التنبؤات الكمية - قيد التطوير',
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }

  Widget _buildSystemTab() {
    return Center(
      child: Text(
        'حالة النظام الكمي - قيد التطوير',
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}

/// عنصر إحصائي
class _StatItem {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
}
