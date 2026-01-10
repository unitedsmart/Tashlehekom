import 'package:flutter/material.dart';
import 'dart:math';

class QuantumMainScreen extends StatefulWidget {
  const QuantumMainScreen({super.key});

  @override
  State<QuantumMainScreen> createState() => _QuantumMainScreenState();
}

class _QuantumMainScreenState extends State<QuantumMainScreen>
    with TickerProviderStateMixin {
  late AnimationController _quantumController;
  late AnimationController _particleController;
  late Animation<double> _quantumAnimation;
  late Animation<double> _particleAnimation;
  
  bool _isProcessing = false;
  double _quantumAccuracy = 99.7;

  @override
  void initState() {
    super.initState();
    _quantumController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _particleController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _quantumAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(_quantumController);
    _particleAnimation = Tween<double>(begin: 0, end: 1).animate(_particleController);
    _quantumController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الذكاء الاصطناعي الكمي'),
        backgroundColor: Colors.deepPurple[900],
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple[900]!, Colors.purple[700]!, Colors.indigo[800]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(),
              const SizedBox(height: 20),
              _buildQuantumProcessor(),
              const SizedBox(height: 20),
              _buildQuantumFeatures(),
              const SizedBox(height: 20),
              _buildQuantumAnalytics(),
              const SizedBox(height: 20),
              _buildQuantumResults(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 4,
      color: Colors.deepPurple[800],
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AnimatedBuilder(
                  animation: _quantumAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _quantumAnimation.value,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [Colors.cyan[300]!, Colors.purple[300]!],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(Icons.psychology, color: Colors.white, size: 20),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),
                const Text(
                  'الذكاء الاصطناعي الكمي',
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
              'معالجة كمية متقدمة لتحليل السيارات بدقة فائقة',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildHeaderStat('دقة التحليل', '${_quantumAccuracy.toStringAsFixed(1)}%'),
                const SizedBox(width: 20),
                _buildHeaderStat('سرعة المعالجة', '10^12 عملية/ث'),
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

  Widget _buildQuantumProcessor() {
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.memory, color: Colors.cyan[300]),
                const SizedBox(width: 8),
                const Text(
                  'المعالج الكمي',
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
                  // Quantum field visualization
                  AnimatedBuilder(
                    animation: _quantumAnimation,
                    builder: (context, child) {
                      return CustomPaint(
                        size: const Size(double.infinity, 200),
                        painter: QuantumFieldPainter(_quantumAnimation.value),
                      );
                    },
                  ),
                  
                  // Central quantum core
                  Center(
                    child: AnimatedBuilder(
                      animation: _quantumAnimation,
                      builder: (context, child) {
                        return Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [
                                Colors.cyan[300]!.withOpacity(0.8),
                                Colors.purple[300]!.withOpacity(0.6),
                                Colors.transparent,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: Transform.rotate(
                            angle: _quantumAnimation.value * 2,
                            child: Icon(
                              Icons.psychology,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Quantum particles
                  ...List.generate(8, (index) {
                    return AnimatedBuilder(
                      animation: _quantumAnimation,
                      builder: (context, child) {
                        final angle = _quantumAnimation.value + (index * pi / 4);
                        final radius = 60.0 + sin(_quantumAnimation.value * 3) * 20;
                        final x = 100 + radius * cos(angle);
                        final y = 100 + radius * sin(angle);
                        
                        return Positioned(
                          left: x - 4,
                          top: y - 4,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.cyan[300],
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.cyan[300]!.withOpacity(0.5),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildProcessorStat('Qubits', '1024', Colors.cyan),
                _buildProcessorStat('Coherence', '100μs', Colors.purple),
                _buildProcessorStat('Fidelity', '99.9%', Colors.green),
                _buildProcessorStat('Gates', '10^6/s', Colors.orange),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isProcessing ? null : _startQuantumProcessing,
                icon: _isProcessing 
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.play_arrow),
                label: Text(_isProcessing ? 'جاري المعالجة...' : 'بدء المعالجة الكمية'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessorStat(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.memory, color: color, size: 16),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey[400], fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildQuantumFeatures() {
    final features = [
      {'title': 'تحليل كمي للأضرار', 'desc': 'دقة 99.9%', 'icon': Icons.search, 'color': Colors.red},
      {'title': 'تنبؤ كمي للأسعار', 'desc': 'خوارزميات متقدمة', 'icon': Icons.trending_up, 'color': Colors.green},
      {'title': 'محاكاة كمية', 'desc': 'سيناريوهات متعددة', 'icon': Icons.science, 'color': Colors.blue},
      {'title': 'تشفير كمي', 'desc': 'أمان مطلق', 'icon': Icons.security, 'color': Colors.orange},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'الميزات الكمية',
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
                onTap: () => _useQuantumFeature(feature['title'] as String),
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

  Widget _buildQuantumAnalytics() {
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Colors.purple[300]),
                const SizedBox(width: 8),
                const Text(
                  'التحليلات الكمية',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildAnalyticsItem('حالة النظام الكمي', 'مستقر', Icons.check_circle, Colors.green),
            _buildAnalyticsItem('مستوى التشابك', '98.7%', Icons.link, Colors.blue),
            _buildAnalyticsItem('معدل الخطأ الكمي', '0.001%', Icons.error_outline, Colors.orange),
            _buildAnalyticsItem('كفاءة الخوارزمية', '99.5%', Icons.speed, Colors.purple),
            _buildAnalyticsItem('استهلاك الطاقة', '1.2 كيلو واط', Icons.battery_charging_full, Colors.cyan),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsItem(String title, String value, IconData icon, Color color) {
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

  Widget _buildQuantumResults() {
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.insights, color: Colors.green[300]),
                const SizedBox(width: 8),
                const Text(
                  'نتائج المعالجة الكمية',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.deepPurple),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.car_repair, color: Colors.cyan[300], size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'تحليل كمي مكتمل',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'تم تحليل 1,247 متغير بدقة كمية',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildResultCard('احتمالية الشراء', '87.3%', Colors.green),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildResultCard('السعر المتوقع', '85,000 ريال', Colors.blue),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildResultCard('مستوى الثقة', '99.7%', Colors.orange),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildResultCard('وقت المعالجة', '0.003 ثانية', Colors.purple),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _exportResults,
                    icon: const Icon(Icons.download),
                    label: const Text('تصدير النتائج'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _shareResults,
                    icon: const Icon(Icons.share),
                    label: const Text('مشاركة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
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

  void _startQuantumProcessing() {
    setState(() {
      _isProcessing = true;
    });
    
    _particleController.forward();
    
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _quantumAccuracy = 99.7 + Random().nextDouble() * 0.2;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إكمال المعالجة الكمية بنجاح!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  void _useQuantumFeature(String featureName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم تفعيل: $featureName'),
        backgroundColor: Colors.deepPurple[600],
      ),
    );
  }

  void _exportResults() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم تصدير النتائج الكمية بنجاح!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _shareResults() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم مشاركة النتائج الكمية!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  void dispose() {
    _quantumController.dispose();
    _particleController.dispose();
    super.dispose();
  }
}

class QuantumFieldPainter extends CustomPainter {
  final double animationValue;

  QuantumFieldPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw quantum field lines
    for (int i = 0; i < 20; i++) {
      final progress = (animationValue + i * 0.1) % 1.0;
      final opacity = sin(progress * pi).abs();
      
      paint.color = Colors.cyan.withOpacity(opacity * 0.3);
      
      final startX = (i / 20) * size.width;
      final path = Path();
      path.moveTo(startX, 0);
      
      for (double y = 0; y <= size.height; y += 5) {
        final wave = sin((y / 20) + animationValue * 4) * 10;
        path.lineTo(startX + wave, y);
      }
      
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
