import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/vr_service.dart';
import '../../utils/app_theme.dart';

/// الشاشة الرئيسية للواقع الافتراضي
class VRMainScreen extends StatefulWidget {
  const VRMainScreen({super.key});

  @override
  State<VRMainScreen> createState() => _VRMainScreenState();
}

class _VRMainScreenState extends State<VRMainScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final VRService _vrService = VRService();
  bool _isVRSupported = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _checkVRSupport();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _checkVRSupport() async {
    try {
      final isSupported = await _vrService.checkVRSupport();
      setState(() {
        _isVRSupported = isSupported;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isVRSupported = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الواقع الافتراضي'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.home), text: 'الرئيسية'),
            Tab(icon: Icon(Icons.directions_car), text: 'السيارات'),
            Tab(icon: Icon(Icons.view_in_ar), text: 'الجولات'),
            Tab(icon: Icon(Icons.settings), text: 'الإعدادات'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildCarsTab(),
                _buildToursTab(),
                _buildSettingsTab(),
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
          _buildVRStatusCard(),
          const SizedBox(height: 16),
          _buildFeaturesGrid(),
          const SizedBox(height: 16),
          _buildQuickActionsCard(),
        ],
      ),
    );
  }

  Widget _buildVRStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isVRSupported ? Icons.check_circle : Icons.error,
                  color: _isVRSupported ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  'حالة الواقع الافتراضي',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _isVRSupported
                  ? 'جهازك يدعم الواقع الافتراضي'
                  : 'جهازك لا يدعم الواقع الافتراضي',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (!_isVRSupported) ...[
              const SizedBox(height: 8),
              const Text(
                'يمكنك استخدام الوضع العادي لاستكشاف السيارات',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesGrid() {
    final features = [
      {
        'icon': Icons.directions_car,
        'title': 'جولات السيارات',
        'subtitle': 'استكشف السيارات بتقنية VR',
        'enabled': _isVRSupported,
      },
      {
        'icon': Icons.view_in_ar,
        'title': 'الواقع المعزز',
        'subtitle': 'اعرض السيارات في بيئتك',
        'enabled': true,
      },
      {
        'icon': Icons.threed_rotation,
        'title': 'عرض ثلاثي الأبعاد',
        'subtitle': 'تفاصيل دقيقة للسيارات',
        'enabled': true,
      },
      {
        'icon': Icons.camera_alt,
        'title': 'التصوير التفاعلي',
        'subtitle': 'التقط صور من زوايا مختلفة',
        'enabled': _isVRSupported,
      },
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
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        return Card(
          child: InkWell(
            onTap: feature['enabled'] as bool
                ? () => _onFeatureTap(feature['title'] as String)
                : null,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    feature['icon'] as IconData,
                    size: 40,
                    color: feature['enabled'] as bool
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    feature['title'] as String,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color:
                              feature['enabled'] as bool ? null : Colors.grey,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    feature['subtitle'] as String,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'إجراءات سريعة',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickAction(
                  icon: Icons.play_arrow,
                  label: 'بدء جولة',
                  onTap: _isVRSupported ? () => _startVRTour() : null,
                ),
                _buildQuickAction(
                  icon: Icons.settings,
                  label: 'الإعدادات',
                  onTap: () => _openSettings(),
                ),
                _buildQuickAction(
                  icon: Icons.help,
                  label: 'المساعدة',
                  onTap: () => _showHelp(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor:
                onTap != null ? Theme.of(context).primaryColor : Colors.grey,
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: onTap != null ? null : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarsTab() {
    return const Center(
      child: Text('قائمة السيارات المتاحة للواقع الافتراضي'),
    );
  }

  Widget _buildToursTab() {
    return const Center(
      child: Text('الجولات الافتراضية المتاحة'),
    );
  }

  Widget _buildSettingsTab() {
    return const Center(
      child: Text('إعدادات الواقع الافتراضي'),
    );
  }

  void _onFeatureTap(String featureName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم النقر على: $featureName')),
    );
  }

  void _startVRTour() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('بدء الجولة الافتراضية...')),
    );
  }

  void _openSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('فتح الإعدادات...')),
    );
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('المساعدة'),
        content: const Text(
          'الواقع الافتراضي يتيح لك استكشاف السيارات بطريقة تفاعلية. '
          'تأكد من أن جهازك يدعم هذه التقنية للحصول على أفضل تجربة.',
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
