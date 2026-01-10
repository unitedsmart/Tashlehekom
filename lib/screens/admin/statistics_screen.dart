import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tashlehekomv2/providers/user_provider.dart';
import 'package:tashlehekomv2/providers/car_provider.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإحصائيات التفصيلية'),
        backgroundColor: Colors.blue,
      ),
      body: Consumer2<UserProvider, CarProvider>(
        builder: (context, userProvider, carProvider, child) {
          final userStats = userProvider.getStatistics();
          final cars = carProvider.cars;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Users statistics
                _buildSectionTitle('إحصائيات المستخدمين'),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'إجمالي المستخدمين',
                        userStats['totalUsers'].toString(),
                        Icons.people,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'الأفراد',
                        userStats['individuals'].toString(),
                        Icons.person,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'العمال',
                        userStats['workers'].toString(),
                        Icons.work,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'مالكي التشاليح',
                        userStats['junkyardOwners'].toString(),
                        Icons.business,
                        Colors.purple,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Approval statistics
                _buildSectionTitle('إحصائيات الموافقات'),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'قيد المراجعة',
                        userStats['pendingApproval'].toString(),
                        Icons.pending_actions,
                        Colors.amber,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'العمال المرتبطين',
                        userStats['linkedWorkers'].toString(),
                        Icons.link,
                        Colors.teal,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                _buildStatCard(
                  'العمال غير المرتبطين',
                  userStats['unlinkedWorkers'].toString(),
                  Icons.link_off,
                  Colors.red,
                ),
                
                const SizedBox(height: 24),
                
                // Cars statistics
                _buildSectionTitle('إحصائيات السيارات'),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'إجمالي السيارات',
                        cars.length.toString(),
                        Icons.directions_car,
                        Colors.indigo,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'مع رقم هيكل',
                        cars.where((car) => car.vinNumber != null).length.toString(),
                        Icons.confirmation_number,
                        Colors.cyan,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                _buildStatCard(
                  'بدون رقم هيكل',
                  cars.where((car) => car.vinNumber == null).length.toString(),
                  Icons.directions_car_outlined,
                  Colors.grey,
                ),
                
                const SizedBox(height: 24),
                
                // Brand statistics
                if (cars.isNotEmpty) ...[
                  _buildSectionTitle('إحصائيات الماركات'),
                  
                  _buildBrandStatistics(cars),
                  
                  const SizedBox(height: 24),
                ],
                
                // City statistics
                if (cars.isNotEmpty) ...[
                  _buildSectionTitle('إحصائيات المدن'),
                  
                  _buildCityStatistics(cars),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandStatistics(List cars) {
    final brandCounts = <String, int>{};
    
    for (var car in cars) {
      brandCounts[car.brand] = (brandCounts[car.brand] ?? 0) + 1;
    }
    
    final sortedBrands = brandCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'أكثر الماركات',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...sortedBrands.take(5).map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entry.key),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      entry.value.toString(),
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildCityStatistics(List cars) {
    final cityCounts = <String, int>{};
    
    for (var car in cars) {
      cityCounts[car.city] = (cityCounts[car.city] ?? 0) + 1;
    }
    
    final sortedCities = cityCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'أكثر المدن نشاطاً',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...sortedCities.take(5).map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entry.key),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      entry.value.toString(),
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
