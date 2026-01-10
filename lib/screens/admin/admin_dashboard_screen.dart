import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../services/firebase_firestore_service.dart';
import '../../services/error_handling_service.dart';
import '../../providers/firebase_auth_provider.dart';
import 'pending_cars_screen.dart';
import 'admin_users_screen.dart';
import 'admin_reports_screen.dart';
import 'admin_security_logs_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final FirebaseFirestoreService _firestoreService = FirebaseFirestoreService();
  final ErrorHandlingService _errorHandler = ErrorHandlingService();
  Map<String, int> _stats = {};
  bool _isLoading = true;
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      setState(() => _isLoading = true);

      // الحصول على المستخدم الحالي
      final authProvider =
          Provider.of<FirebaseAuthProvider>(context, listen: false);
      if (authProvider.currentUser != null) {
        _currentUser =
            await _firestoreService.getUser(authProvider.currentUser!.id);
      }

      // الحصول على إحصائيات مخصصة
      final totalUsers = await _firestoreService.getAllUsers();
      final totalCars = await _firestoreService.getAllCars();

      // إحصائيات بسيطة (يمكن تطويرها لاحقاً)
      final activeCars = totalCars.where((car) => car.isActive).length;
      final inactiveCars = totalCars.length - activeCars;

      setState(() {
        _stats = {
          'totalUsers': totalUsers.length,
          'totalCars': totalCars.length,
          'activeCars': activeCars,
          'inactiveCars': inactiveCars,
          'admins': totalUsers
              .where((user) =>
                  user.userType == UserType.admin ||
                  user.userType == UserType.superAdmin)
              .length,
          'sellers': totalUsers
              .where((user) => user.userType == UserType.seller)
              .length,
          'workers': totalUsers
              .where((user) => user.userType == UserType.worker)
              .length,
          'junkyardOwners': totalUsers
              .where((user) => user.userType == UserType.junkyardOwner)
              .length,
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        final errorMessage = _errorHandler.handleGenericError(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحميل الإحصائيات: $errorMessage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة الإدارة'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _loadStats();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ترحيب بالمدير
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: [Colors.blue[600]!, Colors.blue[800]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    Icons.admin_panel_settings,
                                    color: Colors.blue[600],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'مرحباً المدير العام',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Text(
                                        'المنصب: مدير عام',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
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
                    const SizedBox(height: 20),

                    // الإحصائيات
                    Text(
                      'الإحصائيات',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 12),

                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.2,
                      children: [
                        _buildStatCard(
                          'إجمالي المستخدمين',
                          _stats['totalUsers'] ?? 0,
                          Icons.people,
                          Colors.blue,
                          null,
                        ),
                        _buildStatCard(
                          'إجمالي السيارات',
                          _stats['totalCars'] ?? 0,
                          Icons.directions_car,
                          Colors.green,
                          null,
                        ),
                        _buildStatCard(
                          'السيارات النشطة',
                          _stats['activeCars'] ?? 0,
                          Icons.check_circle,
                          Colors.teal,
                          null,
                        ),
                        _buildStatCard(
                          'السيارات غير النشطة',
                          _stats['inactiveCars'] ?? 0,
                          Icons.cancel,
                          Colors.orange,
                          null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // الإجراءات السريعة
                    Text(
                      'الإجراءات السريعة',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 12),

                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue[100],
                              child: Icon(Icons.admin_panel_settings,
                                  color: Colors.blue[600]),
                            ),
                            title: const Text('إدارة المديرين'),
                            subtitle:
                                Text('${_stats['admins'] ?? 0} مدير في النظام'),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () => _navigateToUserManagement('admin'),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.green[100],
                              child:
                                  Icon(Icons.store, color: Colors.green[600]),
                            ),
                            title: const Text('إدارة البائعين'),
                            subtitle:
                                Text('${_stats['sellers'] ?? 0} بائع مسجل'),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () => _navigateToUserManagement('seller'),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.orange[100],
                              child:
                                  Icon(Icons.work, color: Colors.orange[600]),
                            ),
                            title: const Text('إدارة العمال'),
                            subtitle:
                                Text('${_stats['workers'] ?? 0} عامل مسجل'),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () => _navigateToUserManagement('worker'),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.purple[100],
                              child: Icon(Icons.business,
                                  color: Colors.purple[600]),
                            ),
                            title: const Text('إدارة مالكي التشاليح'),
                            subtitle: Text(
                                '${_stats['junkyardOwners'] ?? 0} مالك تشليح'),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () =>
                                _navigateToUserManagement('junkyardOwner'),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.red[100],
                              child: Icon(Icons.report_problem,
                                  color: Colors.red[600]),
                            ),
                            title: const Text('إدارة التقارير'),
                            subtitle: const Text('مراجعة تقارير المستخدمين'),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: _navigateToReports,
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.indigo[100],
                              child: Icon(Icons.security,
                                  color: Colors.indigo[600]),
                            ),
                            title: const Text('سجلات الأمان'),
                            subtitle: const Text('مراقبة الأنشطة الأمنية'),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: _navigateToSecurityLogs,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, int count, IconData icon, Color color,
      VoidCallback? onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                radius: 24,
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                count.toString(),
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
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToUserManagement(String userType) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AdminUsersScreen(userType: userType),
      ),
    );
  }

  void _navigateToReports() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AdminReportsScreen(),
      ),
    );
  }

  void _navigateToSecurityLogs() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AdminSecurityLogsScreen(),
      ),
    );
  }

  void _navigateToPendingCars(String status) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PendingCarsScreen(
          status: status,
        ),
      ),
    );
  }
}
