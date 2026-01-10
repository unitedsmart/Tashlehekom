import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tashlehekomv2/providers/user_provider.dart';
import 'package:tashlehekomv2/providers/car_provider.dart';
import 'package:tashlehekomv2/screens/admin/pending_approvals_screen.dart';
import 'package:tashlehekomv2/screens/admin/workers_management_screen.dart';
import 'package:tashlehekomv2/screens/admin/statistics_screen.dart';
import 'package:tashlehekomv2/screens/admin/image_management_screen.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final carProvider = Provider.of<CarProvider>(context, listen: false);

    await Future.wait([
      userProvider.loadUsers(),
      carProvider.loadCars(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة الإدارة'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final stats = userProvider.getStatistics();

          return RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome card
                  Card(
                    color: Colors.deepPurple[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.admin_panel_settings,
                            size: 48,
                            color: Colors.deepPurple[700],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'مرحباً بك في لوحة الإدارة',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        color: Colors.deepPurple[700],
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'إدارة المستخدمين والحسابات',
                                  style: TextStyle(
                                    color: Colors.deepPurple[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Quick stats
                  Text(
                    'إحصائيات سريعة',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'المستخدمين',
                          stats['totalUsers'].toString(),
                          Icons.people,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'قيد المراجعة',
                          stats['pendingApproval'].toString(),
                          Icons.pending_actions,
                          Colors.orange,
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
                          stats['workers'].toString(),
                          Icons.work,
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'مالكي التشاليح',
                          stats['junkyardOwners'].toString(),
                          Icons.business,
                          Colors.purple,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Management options
                  Text(
                    'إدارة النظام',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),

                  const SizedBox(height: 12),

                  // Pending approvals
                  _buildManagementCard(
                    title: 'الحسابات قيد المراجعة',
                    subtitle:
                        '${stats['pendingApproval']} حساب بانتظار الموافقة',
                    icon: Icons.pending_actions,
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PendingApprovalsScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // Workers management
                  _buildManagementCard(
                    title: 'إدارة العمال',
                    subtitle: '${stats['unlinkedWorkers']} عامل غير مرتبط',
                    icon: Icons.work,
                    color: Colors.green,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WorkersManagementScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // Image management
                  _buildManagementCard(
                    title: 'إدارة الصور المتقدمة',
                    subtitle: 'تنظيف وتحسين الصور',
                    icon: Icons.photo_library,
                    color: Colors.purple,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ImageManagementScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // Statistics
                  _buildManagementCard(
                    title: 'الإحصائيات التفصيلية',
                    subtitle: 'عرض جميع الإحصائيات والتقارير',
                    icon: Icons.analytics,
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StatisticsScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Contact info
                  Card(
                    color: Colors.grey[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.info_outline,
                                  color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(
                                'معلومات التواصل',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                              'البريد الإلكتروني: admin@tashlehekomv2.com'),
                          const SizedBox(height: 4),
                          const Text('رقم الجوال: +966501234567'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
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
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
