import 'package:flutter/material.dart';
import 'dart:math';

class SpaceMainScreen extends StatefulWidget {
  const SpaceMainScreen({super.key});

  @override
  State<SpaceMainScreen> createState() => _SpaceMainScreenState();
}

class _SpaceMainScreenState extends State<SpaceMainScreen>
    with TickerProviderStateMixin {
  late AnimationController _satelliteController;
  late AnimationController _earthController;
  late Animation<double> _satelliteAnimation;
  late Animation<double> _earthAnimation;

  @override
  void initState() {
    super.initState();
    _satelliteController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    _earthController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    _satelliteAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(_satelliteController);
    _earthAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(_earthController);
    _satelliteController.repeat();
    _earthController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تقنيات الفضاء'),
        backgroundColor: Colors.indigo[900],
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo[900]!, Colors.black87],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(),
              const SizedBox(height: 20),
              _buildSatelliteTracking(),
              const SizedBox(height: 20),
              _buildSpaceNavigation(),
              const SizedBox(height: 20),
              _buildAdvancedTracking(),
              const SizedBox(height: 20),
              _buildSpaceStats(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 4,
      color: Colors.indigo[800],
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AnimatedBuilder(
                  animation: _earthAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _earthAnimation.value,
                      child: Icon(Icons.public, color: Colors.blue[300], size: 32),
                    );
                  },
                ),
                const SizedBox(width: 12),
                const Text(
                  'تقنيات الفضاء المتقدمة',
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
              'تتبع وملاحة فضائية متطورة للسيارات',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildHeaderStat('الأقمار المتصلة', '24'),
                const SizedBox(width: 20),
                _buildHeaderStat('دقة التتبع', '±1 متر'),
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
            fontSize: 16,
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

  Widget _buildSatelliteTracking() {
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.satellite_alt, color: Colors.cyan[300]),
                const SizedBox(width: 8),
                const Text(
                  'تتبع الأقمار الصناعية',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.cyan[300]!),
              ),
              child: Stack(
                children: [
                  // Earth in center
                  Center(
                    child: AnimatedBuilder(
                      animation: _earthAnimation,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _earthAnimation.value,
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.blue[400],
                              borderRadius: BorderRadius.circular(30),
                              gradient: RadialGradient(
                                colors: [Colors.blue[300]!, Colors.blue[700]!],
                              ),
                            ),
                            child: Icon(Icons.public, color: Colors.white, size: 30),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Satellites orbiting
                  ...List.generate(6, (index) {
                    final angle = (index * pi / 3);
                    return AnimatedBuilder(
                      animation: _satelliteAnimation,
                      builder: (context, child) {
                        final currentAngle = _satelliteAnimation.value + angle;
                        final radius = 80.0;
                        final x = 100 + radius * cos(currentAngle);
                        final y = 100 + radius * sin(currentAngle);
                        
                        return Positioned(
                          left: x - 10,
                          top: y - 10,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.yellow[300],
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.yellow[300]!.withOpacity(0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(Icons.satellite, color: Colors.black, size: 12),
                          ),
                        );
                      },
                    );
                  }),
                  
                  // Connection lines
                  AnimatedBuilder(
                    animation: _satelliteAnimation,
                    builder: (context, child) {
                      return CustomPaint(
                        size: const Size(200, 200),
                        painter: SatelliteConnectionPainter(_satelliteAnimation.value),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSatelliteInfo('GPS', '8 أقمار', Colors.green),
                _buildSatelliteInfo('GLONASS', '6 أقمار', Colors.blue),
                _buildSatelliteInfo('Galileo', '4 أقمار', Colors.orange),
                _buildSatelliteInfo('BeiDou', '6 أقمار', Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSatelliteInfo(String system, String count, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.satellite, color: color, size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          system,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
        ),
        Text(
          count,
          style: TextStyle(color: Colors.grey[400], fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildSpaceNavigation() {
    final features = [
      {'title': 'ملاحة دقيقة', 'desc': 'دقة ±1 متر', 'icon': Icons.gps_fixed, 'color': Colors.green},
      {'title': 'تتبع في الوقت الفعلي', 'desc': 'تحديث كل ثانية', 'icon': Icons.track_changes, 'color': Colors.blue},
      {'title': 'ملاحة ثلاثية الأبعاد', 'desc': 'ارتفاع وموقع', 'icon': Icons.threed_rotation, 'color': Colors.purple},
      {'title': 'مقاومة التشويش', 'desc': 'إشارة مستقرة', 'icon': Icons.security, 'color': Colors.orange},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ميزات الملاحة الفضائية',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          itemCount: features.length,
          itemBuilder: (context, index) {
            final feature = features[index];
            return Card(
              color: Colors.grey[850],
              child: InkWell(
                onTap: () => _activateFeature(feature['title'] as String),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (feature['color'] as Color).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          feature['icon'] as IconData,
                          size: 28,
                          color: feature['color'] as Color,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        feature['title'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        feature['desc'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[400],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAdvancedTracking() {
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.radar, color: Colors.red[300]),
                const SizedBox(width: 8),
                const Text(
                  'التتبع المتقدم',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTrackingItem('الموقع الحالي', '24.7136° N, 46.6753° E', Icons.location_on, Colors.green),
            _buildTrackingItem('السرعة', '65 كم/س', Icons.speed, Colors.blue),
            _buildTrackingItem('الاتجاه', 'شمال شرق (45°)', Icons.navigation, Colors.orange),
            _buildTrackingItem('الارتفاع', '612 متر', Icons.height, Colors.purple),
            _buildTrackingItem('دقة الإشارة', '±0.8 متر', Icons.gps_fixed, Colors.cyan),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _calibrateSystem,
                icon: const Icon(Icons.tune),
                label: const Text('معايرة النظام'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo[600],
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingItem(String title, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpaceStats() {
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Colors.yellow[300]),
                const SizedBox(width: 8),
                const Text(
                  'إحصائيات الفضاء',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard('المسافة المقطوعة', '1,247 كم', Icons.route, Colors.blue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard('وقت التتبع', '24/7', Icons.access_time, Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard('دقة المتوسط', '±0.9 متر', Icons.center_focus_strong, Colors.orange),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard('الأقمار النشطة', '24/32', Icons.satellite, Colors.purple),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[400],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _activateFeature(String featureName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم تفعيل: $featureName'),
        backgroundColor: Colors.indigo[600],
      ),
    );
  }

  void _calibrateSystem() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('معايرة النظام', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.tune, size: 64, color: Colors.indigo[300]),
            const SizedBox(height: 16),
            const Text(
              'جاري معايرة أنظمة الملاحة الفضائية...',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo[300]!),
              backgroundColor: Colors.grey[700],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم معايرة النظام بنجاح!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _satelliteController.dispose();
    _earthController.dispose();
    super.dispose();
  }
}

class SatelliteConnectionPainter extends CustomPainter {
  final double animationValue;

  SatelliteConnectionPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.cyan.withOpacity(0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = 80.0;

    for (int i = 0; i < 6; i++) {
      final angle = animationValue + (i * pi / 3);
      final satellitePos = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      
      canvas.drawLine(center, satellitePos, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
