import 'package:flutter/material.dart';
import 'package:tashlehekomv2/services/iot_service.dart';
import 'package:tashlehekomv2/models/iot_models.dart';
import 'package:tashlehekomv2/utils/enhanced_animations.dart';
import 'package:tashlehekomv2/widgets/enhanced_card_widget.dart';
import 'package:tashlehekomv2/utils/app_theme.dart';

/// شاشة إنترنت الأشياء الرئيسية
class IoTMainScreen extends StatefulWidget {
  final String carId;
  final String userId;

  const IoTMainScreen({
    super.key,
    required this.carId,
    required this.userId,
  });

  @override
  State<IoTMainScreen> createState() => _IoTMainScreenState();
}

class _IoTMainScreenState extends State<IoTMainScreen>
    with TickerProviderStateMixin {
  final IoTService _iotService = IoTService();

  List<IoTDevice> _devices = [];
  SmartDiagnostics? _diagnostics;
  PredictiveMaintenance? _maintenance;
  UsageStatistics? _statistics;

  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadIoTData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _iotService.dispose();
    super.dispose();
  }

  Future<void> _loadIoTData() async {
    setState(() => _isLoading = true);

    try {
      final futures = await Future.wait([
        _iotService.getCarIoTDevices(widget.carId),
        _iotService.getSmartDiagnostics(widget.carId),
        _iotService.getPredictiveMaintenance(widget.carId),
        _iotService.getUsageStatistics(widget.carId),
      ]);

      setState(() {
        _devices = futures[0] as List<IoTDevice>;
        _diagnostics = futures[1] as SmartDiagnostics;
        _maintenance = futures[2] as PredictiveMaintenance;
        _statistics = futures[3] as UsageStatistics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تحميل بيانات IoT: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إنترنت الأشياء'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadIoTData,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: _showDeviceSettings,
            icon: const Icon(Icons.settings),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'نظرة عامة', icon: Icon(Icons.dashboard)),
            Tab(text: 'الأجهزة', icon: Icon(Icons.devices)),
            Tab(text: 'التشخيص', icon: Icon(Icons.health_and_safety)),
            Tab(text: 'الإحصائيات', icon: Icon(Icons.analytics)),
          ],
        ),
      ),
      body: _isLoading
          ? _buildLoadingScreen()
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildDevicesTab(),
                _buildDiagnosticsTab(),
                _buildStatisticsTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDeviceDialog,
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
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
            'جاري تحميل بيانات إنترنت الأشياء...',
            style: Theme.of(context).textTheme.titleMedium,
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
          _buildQuickActionsGrid(),
          const SizedBox(height: 20),
          if (_diagnostics != null) _buildHealthOverview(),
          const SizedBox(height: 20),
          if (_maintenance != null) _buildMaintenanceOverview(),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return EnhancedAnimations.fadeIn(
      child: EnhancedCard(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade600, Colors.purple.shade600],
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
                    Icons.router,
                    size: 32,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'مرحباً بك في نظام إنترنت الأشياء',
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
                'راقب سيارتك، احصل على التشخيص الذكي، وتحكم عن بُعد',
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

  Widget _buildQuickStatsGrid() {
    final stats = [
      StatsCard(
        title: 'الأجهزة المتصلة',
        value: _devices.where((d) => d.isOnline).length.toString(),
        icon: Icons.devices,
        color: Colors.green,
      ),
      StatsCard(
        title: 'الصحة العامة',
        value: '${_diagnostics?.overallHealth ?? 100}%',
        icon: Icons.health_and_safety,
        color: _getHealthColor(_diagnostics?.overallHealth ?? 100),
      ),
      StatsCard(
        title: 'المسافة اليوم',
        value: '${(_statistics?.totalDistance ?? 0).toStringAsFixed(0)} كم',
        icon: Icons.route,
        color: Colors.blue,
      ),
      StatsCard(
        title: 'استهلاك الوقود',
        value:
            '${(_statistics?.fuelEfficiency ?? 0).toStringAsFixed(1)} ل/100كم',
        icon: Icons.local_gas_station,
        color: Colors.orange,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إحصائيات سريعة',
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
            childAspectRatio: 1.2,
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) {
            return EnhancedAnimations.scaleIn(
              delay: Duration(milliseconds: index * 100),
              child: StatsCard(
                title: stats[index].title,
                value: stats[index].value,
                icon: stats[index].icon,
                color: stats[index].color,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickActionsGrid() {
    final actions = [
      QuickAction(
        title: 'تشغيل المحرك',
        description: 'تشغيل عن بُعد',
        icon: Icons.power_settings_new,
        color: Colors.green,
        onTap: () => _sendCommand(IoTCommand.startEngine),
      ),
      QuickAction(
        title: 'قفل الأبواب',
        description: 'قفل جميع الأبواب',
        icon: Icons.lock,
        color: Colors.red,
        onTap: () => _sendCommand(IoTCommand.lockDoors),
      ),
      QuickAction(
        title: 'تحديد الموقع',
        description: 'العثور على السيارة',
        icon: Icons.location_on,
        color: Colors.blue,
        onTap: () => _sendCommand(IoTCommand.locateCar),
      ),
      QuickAction(
        title: 'تشغيل التكييف',
        description: 'تبريد السيارة',
        icon: Icons.ac_unit,
        color: Colors.cyan,
        onTap: () => _sendCommand(IoTCommand.startAC),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'تحكم سريع',
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
            childAspectRatio: 1.1,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            return EnhancedAnimations.scaleIn(
              delay: Duration(milliseconds: index * 100),
              child: _buildQuickActionCard(actions[index]),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(QuickAction action) {
    return EnhancedCard(
      onTap: action.onTap,
      enableAnimation: true,
      enableHoverEffect: true,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: action.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                action.icon,
                size: 28,
                color: action.color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              action.title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              action.description,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthOverview() {
    return EnhancedAnimations.slideUp(
      child: EnhancedCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.health_and_safety,
                  color: _getHealthColor(_diagnostics!.overallHealth),
                ),
                const SizedBox(width: 8),
                Text(
                  'الصحة العامة للسيارة',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getHealthColor(_diagnostics!.overallHealth)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _diagnostics!.healthStatus,
                    style: TextStyle(
                      color: _getHealthColor(_diagnostics!.overallHealth),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _diagnostics!.overallHealth / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getHealthColor(_diagnostics!.overallHealth),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_diagnostics!.overallHealth}%',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _getHealthColor(_diagnostics!.overallHealth),
                      ),
                ),
                if (_diagnostics!.hasIssues)
                  Text(
                    '${_diagnostics!.issues.length} مشكلة',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaintenanceOverview() {
    return EnhancedAnimations.slideUp(
      child: EnhancedCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.build, color: AppTheme.warningColor),
                const SizedBox(width: 8),
                Text(
                  'الصيانة التنبؤية',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_maintenance!.predictions.isEmpty)
              Center(
                child: Text(
                  'لا توجد صيانة مطلوبة حالياً',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.green,
                      ),
                ),
              )
            else ...[
              Text(
                'الصيانة القادمة:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              ...(_maintenance!.predictions.take(3).map(
                    (prediction) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _getPriorityColor(prediction.priority),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${prediction.component} - ${prediction.daysUntilFailure} يوم',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          Text(
                            '${prediction.estimatedCost.toStringAsFixed(0)} ر.س',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                          ),
                        ],
                      ),
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDevicesTab() {
    return Center(
      child: Text(
        'شاشة الأجهزة - قيد التطوير',
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }

  Widget _buildDiagnosticsTab() {
    return Center(
      child: Text(
        'شاشة التشخيص - قيد التطوير',
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }

  Widget _buildStatisticsTab() {
    return Center(
      child: Text(
        'شاشة الإحصائيات - قيد التطوير',
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }

  // الطرق المساعدة
  Color _getHealthColor(int health) {
    if (health >= 90) return Colors.green;
    if (health >= 75) return Colors.orange;
    return Colors.red;
  }

  Color _getPriorityColor(MaintenancePriority priority) {
    switch (priority) {
      case MaintenancePriority.low:
        return Colors.green;
      case MaintenancePriority.medium:
        return Colors.orange;
      case MaintenancePriority.high:
        return Colors.red;
    }
  }

  // معالجات الأحداث
  Future<void> _sendCommand(IoTCommand command) async {
    if (_devices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا توجد أجهزة متصلة')),
      );
      return;
    }

    final success = await _iotService.sendDeviceCommand(
      deviceId: _devices.first.id,
      command: command,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'تم إرسال الأمر بنجاح: ${command.displayName}'
              : 'فشل في إرسال الأمر',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  void _showAddDeviceDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('سيتم إضافة نموذج إضافة الجهاز قريباً')),
    );
  }

  void _showDeviceSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('سيتم إضافة إعدادات الأجهزة قريباً')),
    );
  }
}

/// إجراء سريع
class QuickAction {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const QuickAction({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
