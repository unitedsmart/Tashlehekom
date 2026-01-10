import 'package:flutter/material.dart';
import 'dart:math';

class AnalyticsMainScreen extends StatefulWidget {
  const AnalyticsMainScreen({super.key});

  @override
  State<AnalyticsMainScreen> createState() => _AnalyticsMainScreenState();
}

class _AnalyticsMainScreenState extends State<AnalyticsMainScreen>
    with TickerProviderStateMixin {
  late AnimationController _chartController;
  late Animation<double> _chartAnimation;
  String _selectedPeriod = 'هذا الشهر';

  @override
  void initState() {
    super.initState();
    _chartController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _chartAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _chartController, curve: Curves.easeInOut),
    );
    _chartController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التحليلات المتقدمة'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedPeriod = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'اليوم', child: Text('اليوم')),
              const PopupMenuItem(value: 'هذا الأسبوع', child: Text('هذا الأسبوع')),
              const PopupMenuItem(value: 'هذا الشهر', child: Text('هذا الشهر')),
              const PopupMenuItem(value: 'هذا العام', child: Text('هذا العام')),
            ],
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_selectedPeriod, style: const TextStyle(fontSize: 14)),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 20),
            _buildKPICards(),
            const SizedBox(height: 20),
            _buildSalesChart(),
            const SizedBox(height: 20),
            _buildMarketInsights(),
            const SizedBox(height: 20),
            _buildUserBehavior(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 4,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.green[600]!, Colors.green[400]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Colors.white, size: 32),
                const SizedBox(width: 12),
                const Text(
                  'التحليلات المتقدمة',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'تحليل شامل لبيانات السوق وسلوك المستخدمين',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildHeaderStat('البيانات المحللة', '2.5M'),
                const SizedBox(width: 20),
                _buildHeaderStat('التقارير المولدة', '847'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildKPICards() {
    final kpis = [
      {'title': 'إجمالي المبيعات', 'value': '2.4M ريال', 'change': '+12.5%', 'icon': Icons.attach_money, 'color': Colors.green},
      {'title': 'عدد السيارات المباعة', 'value': '1,247', 'change': '+8.3%', 'icon': Icons.directions_car, 'color': Colors.blue},
      {'title': 'المستخدمين النشطين', 'value': '15.6K', 'change': '+15.2%', 'icon': Icons.people, 'color': Colors.orange},
      {'title': 'معدل التحويل', 'value': '3.8%', 'change': '+2.1%', 'icon': Icons.trending_up, 'color': Colors.purple},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'المؤشرات الرئيسية',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
          ),
          itemCount: kpis.length,
          itemBuilder: (context, index) {
            final kpi = kpis[index];
            return AnimatedBuilder(
              animation: _chartAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _chartAnimation.value,
                  child: Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(
                                kpi['icon'] as IconData,
                                color: kpi['color'] as Color,
                                size: 24,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  kpi['change'] as String,
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            kpi['value'] as String,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            kpi['title'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildSalesChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'مخطط المبيعات',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Icon(Icons.show_chart, color: Colors.green[600]),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[50],
              ),
              child: AnimatedBuilder(
                animation: _chartAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    painter: ChartPainter(_chartAnimation.value),
                    size: const Size(double.infinity, 200),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildChartLegend('المبيعات', Colors.blue),
                _buildChartLegend('الأرباح', Colors.green),
                _buildChartLegend('التكاليف', Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartLegend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildMarketInsights() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.orange[600]),
                const SizedBox(width: 8),
                const Text(
                  'رؤى السوق',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInsightItem(
              'أكثر السيارات طلباً',
              'تويوتا كامري 2020',
              Icons.trending_up,
              Colors.green,
            ),
            _buildInsightItem(
              'أفضل وقت للبيع',
              'نهاية الأسبوع',
              Icons.schedule,
              Colors.blue,
            ),
            _buildInsightItem(
              'المدينة الأكثر نشاطاً',
              'الرياض',
              Icons.location_city,
              Colors.purple,
            ),
            _buildInsightItem(
              'متوسط سعر السوق',
              '85,000 ريال',
              Icons.price_change,
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(String title, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserBehavior() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.psychology, color: Colors.blue[600]),
                const SizedBox(width: 8),
                const Text(
                  'سلوك المستخدمين',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildBehaviorStat('متوسط الجلسة', '8.5 دقيقة', Icons.access_time),
                ),
                Expanded(
                  child: _buildBehaviorStat('الصفحات المشاهدة', '12.3', Icons.visibility),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildBehaviorStat('معدل الارتداد', '23.4%', Icons.exit_to_app),
                ),
                Expanded(
                  child: _buildBehaviorStat('المستخدمين الجدد', '67.8%', Icons.person_add),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBehaviorStat(String title, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.blue[600], size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _chartController.dispose();
    super.dispose();
  }
}

class ChartPainter extends CustomPainter {
  final double animationValue;

  ChartPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    final points = [
      Offset(0, size.height * 0.8),
      Offset(size.width * 0.2, size.height * 0.6),
      Offset(size.width * 0.4, size.height * 0.4),
      Offset(size.width * 0.6, size.height * 0.3),
      Offset(size.width * 0.8, size.height * 0.2),
      Offset(size.width, size.height * 0.1),
    ];

    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      final animatedX = points[i].dx * animationValue;
      final animatedY = points[i].dy;
      if (animatedX <= size.width * animationValue) {
        path.lineTo(animatedX, animatedY);
      }
    }

    canvas.drawPath(path, paint);

    // Draw points
    final pointPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    for (int i = 0; i < points.length; i++) {
      final animatedX = points[i].dx * animationValue;
      if (animatedX <= size.width * animationValue) {
        canvas.drawCircle(Offset(animatedX, points[i].dy), 4, pointPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
