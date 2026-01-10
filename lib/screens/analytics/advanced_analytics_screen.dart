import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:tashlehekomv2/services/database_service.dart';
import 'package:tashlehekomv2/l10n/app_localizations.dart';

class AdvancedAnalyticsScreen extends StatefulWidget {
  const AdvancedAnalyticsScreen({super.key});

  @override
  State<AdvancedAnalyticsScreen> createState() => _AdvancedAnalyticsScreenState();
}

class _AdvancedAnalyticsScreenState extends State<AdvancedAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  
  Map<String, dynamic> _stats = {};
  List<Map<String, dynamic>> _brandStats = [];
  List<Map<String, dynamic>> _cityStats = [];
  List<Map<String, dynamic>> _monthlyStats = [];

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
      final results = await Future.wait([
        _loadGeneralStats(),
        _loadBrandStats(),
        _loadCityStats(),
        _loadMonthlyStats(),
      ]);

      setState(() {
        _stats = results[0] as Map<String, dynamic>;
        _brandStats = results[1] as List<Map<String, dynamic>>;
        _cityStats = results[2] as List<Map<String, dynamic>>;
        _monthlyStats = results[3] as List<Map<String, dynamic>>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحميل الإحصائيات: $e')),
        );
      }
    }
  }

  Future<Map<String, dynamic>> _loadGeneralStats() async {
    final db = await DatabaseService.instance.database;
    
    final totalCars = await db.rawQuery('SELECT COUNT(*) as count FROM cars');
    final totalUsers = await db.rawQuery('SELECT COUNT(*) as count FROM users');
    final activeCars = await db.rawQuery('SELECT COUNT(*) as count FROM cars WHERE is_active = 1');
    final carsWithVin = await db.rawQuery('SELECT COUNT(*) as count FROM cars WHERE vin_number IS NOT NULL');
    
    final userTypes = await db.rawQuery('''
      SELECT user_type, COUNT(*) as count 
      FROM users 
      GROUP BY user_type
    ''');

    return {
      'total_cars': totalCars.first['count'],
      'total_users': totalUsers.first['count'],
      'active_cars': activeCars.first['count'],
      'cars_with_vin': carsWithVin.first['count'],
      'user_types': userTypes,
    };
  }

  Future<List<Map<String, dynamic>>> _loadBrandStats() async {
    final db = await DatabaseService.instance.database;
    
    final result = await db.rawQuery('''
      SELECT brand, COUNT(*) as count 
      FROM cars 
      GROUP BY brand 
      ORDER BY count DESC 
      LIMIT 10
    ''');

    return result.map((row) => {
      'name': row['brand'],
      'count': row['count'],
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _loadCityStats() async {
    final db = await DatabaseService.instance.database;
    
    final result = await db.rawQuery('''
      SELECT city, COUNT(*) as count 
      FROM cars 
      GROUP BY city 
      ORDER BY count DESC 
      LIMIT 10
    ''');

    return result.map((row) => {
      'name': row['city'],
      'count': row['count'],
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _loadMonthlyStats() async {
    final db = await DatabaseService.instance.database;
    
    final result = await db.rawQuery('''
      SELECT 
        strftime('%Y-%m', created_at) as month,
        COUNT(*) as count
      FROM cars 
      WHERE created_at >= date('now', '-12 months')
      GROUP BY strftime('%Y-%m', created_at)
      ORDER BY month
    ''');

    return result.map((row) => {
      'month': row['month'],
      'count': row['count'],
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.advancedAnalytics),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'نظرة عامة', icon: Icon(Icons.dashboard)),
            Tab(text: 'الماركات', icon: Icon(Icons.pie_chart)),
            Tab(text: 'المدن', icon: Icon(Icons.location_city)),
            Tab(text: 'الاتجاهات', icon: Icon(Icons.trending_up)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildBrandsTab(),
                _buildCitiesTab(),
                _buildTrendsTab(),
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
          Text(
            'الإحصائيات العامة',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          _buildStatsGrid(),
          const SizedBox(height: 24),
          Text(
            'توزيع أنواع المستخدمين',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          _buildUserTypesChart(),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    final stats = [
      {
        'title': 'إجمالي السيارات',
        'value': _stats['total_cars']?.toString() ?? '0',
        'icon': Icons.directions_car,
        'color': Colors.blue,
      },
      {
        'title': 'إجمالي المستخدمين',
        'value': _stats['total_users']?.toString() ?? '0',
        'icon': Icons.people,
        'color': Colors.green,
      },
      {
        'title': 'السيارات النشطة',
        'value': _stats['active_cars']?.toString() ?? '0',
        'icon': Icons.check_circle,
        'color': Colors.orange,
      },
      {
        'title': 'سيارات برقم هيكل',
        'value': _stats['cars_with_vin']?.toString() ?? '0',
        'icon': Icons.verified,
        'color': Colors.purple,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return _buildStatCard(
          title: stat['title'] as String,
          value: stat['value'] as String,
          icon: stat['icon'] as IconData,
          color: stat['color'] as Color,
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserTypesChart() {
    if (_stats['user_types'] == null || (_stats['user_types'] as List).isEmpty) {
      return const Center(child: Text('لا توجد بيانات'));
    }

    final userTypes = _stats['user_types'] as List<Map<String, dynamic>>;
    final total = userTypes.fold<int>(0, (sum, item) => sum + (item['count'] as int));

    return Container(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: userTypes.map((userType) {
            final count = userType['count'] as int;
            final percentage = (count / total * 100).toStringAsFixed(1);
            final type = userType['user_type'] as int;
            
            return PieChartSectionData(
              value: count.toDouble(),
              title: '$percentage%',
              color: _getUserTypeColor(type),
              radius: 60,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          }).toList(),
          centerSpaceRadius: 40,
          sectionsSpace: 2,
        ),
      ),
    );
  }

  Widget _buildBrandsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'أشهر الماركات',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          _buildBarChart(_brandStats, 'الماركات'),
          const SizedBox(height: 24),
          _buildTopItemsList(_brandStats, 'ماركة'),
        ],
      ),
    );
  }

  Widget _buildCitiesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'أشهر المدن',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          _buildBarChart(_cityStats, 'المدن'),
          const SizedBox(height: 24),
          _buildTopItemsList(_cityStats, 'مدينة'),
        ],
      ),
    );
  }

  Widget _buildTrendsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'اتجاهات الإضافة الشهرية',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          _buildLineChart(),
        ],
      ),
    );
  }

  Widget _buildBarChart(List<Map<String, dynamic>> data, String title) {
    if (data.isEmpty) {
      return const Center(child: Text('لا توجد بيانات'));
    }

    return Container(
      height: 300,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: data.first['count'].toDouble() * 1.2,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < data.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        data[index]['name'].toString(),
                        style: const TextStyle(fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: data.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value['count'].toDouble(),
                  color: Theme.of(context).primaryColor,
                  width: 20,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildLineChart() {
    if (_monthlyStats.isEmpty) {
      return const Center(child: Text('لا توجد بيانات'));
    }

    return Container(
      height: 300,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: true),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < _monthlyStats.length) {
                    final month = _monthlyStats[index]['month'].toString();
                    return Text(
                      month.substring(5), // Show only MM part
                      style: const TextStyle(fontSize: 10),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: _monthlyStats.asMap().entries.map((entry) {
                return FlSpot(
                  entry.key.toDouble(),
                  entry.value['count'].toDouble(),
                );
              }).toList(),
              isCurved: true,
              color: Theme.of(context).primaryColor,
              barWidth: 3,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Theme.of(context).primaryColor.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopItemsList(List<Map<String, dynamic>> data, String itemType) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'أفضل 10 $itemType',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        ...data.take(10).map((item) {
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                child: Text(
                  '${data.indexOf(item) + 1}',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(item['name'].toString()),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item['count'].toString(),
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Color _getUserTypeColor(int userType) {
    switch (userType) {
      case 0: // individual
        return Colors.blue;
      case 1: // worker
        return Colors.green;
      case 2: // junkyard owner
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
