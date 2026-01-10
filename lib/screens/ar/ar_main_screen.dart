import 'package:flutter/material.dart';
import 'dart:math';

class ARMainScreen extends StatefulWidget {
  const ARMainScreen({super.key});

  @override
  State<ARMainScreen> createState() => _ARMainScreenState();
}

class _ARMainScreenState extends State<ARMainScreen>
    with TickerProviderStateMixin {
  late AnimationController _scanController;
  late Animation<double> _scanAnimation;
  bool _isScanning = false;
  bool _carDetected = false;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _scanAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.easeInOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الواقع المعزز'),
        backgroundColor: Colors.deepPurple[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isScanning ? Icons.stop : Icons.camera_alt),
            onPressed: _toggleScanning,
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
            _buildCameraView(),
            const SizedBox(height: 20),
            _buildARFeatures(),
            const SizedBox(height: 20),
            if (_carDetected) _buildCarAnalysis(),
            if (_carDetected) const SizedBox(height: 20),
            _buildARTools(),
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
            colors: [Colors.deepPurple[600]!, Colors.deepPurple[400]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.view_in_ar, color: Colors.white, size: 32),
                const SizedBox(width: 12),
                const Text(
                  'الواقع المعزز',
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
              'امسح السيارة بالكاميرا للحصول على معلومات تفاعلية',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildHeaderStat('السيارات الممسوحة', '1,247'),
                const SizedBox(width: 20),
                _buildHeaderStat('دقة التحليل', '95%'),
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

  Widget _buildCameraView() {
    return Card(
      child: Container(
        width: double.infinity,
        height: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.black87,
        ),
        child: Stack(
          children: [
            // Camera background simulation
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [Colors.grey[800]!, Colors.grey[600]!],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            
            // Scanning overlay
            if (_isScanning)
              AnimatedBuilder(
                animation: _scanAnimation,
                builder: (context, child) {
                  return Positioned(
                    top: 50 + (_scanAnimation.value * 200),
                    left: 20,
                    right: 20,
                    child: Container(
                      height: 2,
                      decoration: BoxDecoration(
                        color: Colors.cyan,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.cyan.withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

            // Car detection overlay
            if (_carDetected)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green, width: 3),
                  ),
                  child: Stack(
                    children: [
                      // Corner markers
                      ...List.generate(4, (index) {
                        final isTop = index < 2;
                        final isLeft = index % 2 == 0;
                        return Positioned(
                          top: isTop ? 20 : null,
                          bottom: isTop ? null : 20,
                          left: isLeft ? 20 : null,
                          right: isLeft ? null : 20,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              border: Border(
                                top: isTop ? BorderSide(color: Colors.green, width: 3) : BorderSide.none,
                                bottom: isTop ? BorderSide.none : BorderSide(color: Colors.green, width: 3),
                                left: isLeft ? BorderSide(color: Colors.green, width: 3) : BorderSide.none,
                                right: isLeft ? BorderSide.none : BorderSide(color: Colors.green, width: 3),
                              ),
                            ),
                          ),
                        );
                      }),
                      
                      // Car info overlay
                      Positioned(
                        top: 60,
                        left: 20,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'تويوتا كامري 2020',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'السعر: 85,000 ريال',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Center content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!_isScanning && !_carDetected) ...[
                    Icon(
                      Icons.camera_alt,
                      size: 64,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'اضغط على الكاميرا لبدء المسح',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 16,
                      ),
                    ),
                  ],
                  if (_isScanning && !_carDetected) ...[
                    Icon(
                      Icons.search,
                      size: 64,
                      color: Colors.cyan,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'جاري البحث عن السيارة...',
                      style: TextStyle(
                        color: Colors.cyan,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  if (_carDetected) ...[
                    Icon(
                      Icons.check_circle,
                      size: 64,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'تم اكتشاف السيارة!',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildARFeatures() {
    final features = [
      {'title': 'مسح الأضرار', 'icon': Icons.search, 'color': Colors.red, 'active': _carDetected},
      {'title': 'قياس الأبعاد', 'icon': Icons.straighten, 'color': Colors.blue, 'active': _carDetected},
      {'title': 'معلومات السيارة', 'icon': Icons.info, 'color': Colors.green, 'active': _carDetected},
      {'title': 'مقارنة الأسعار', 'icon': Icons.compare, 'color': Colors.orange, 'active': _carDetected},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ميزات الواقع المعزز',
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
            childAspectRatio: 1.2,
          ),
          itemCount: features.length,
          itemBuilder: (context, index) {
            final feature = features[index];
            final isActive = feature['active'] as bool;
            
            return Card(
              child: InkWell(
                onTap: isActive ? () => _useARFeature(feature['title'] as String) : null,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isActive 
                              ? (feature['color'] as Color).withOpacity(0.1)
                              : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          feature['icon'] as IconData,
                          size: 32,
                          color: isActive ? feature['color'] as Color : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        feature['title'] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isActive ? Colors.black : Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (!isActive)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'امسح سيارة',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 8,
                            ),
                          ),
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

  Widget _buildCarAnalysis() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Colors.deepPurple[600]),
                const SizedBox(width: 8),
                const Text(
                  'تحليل السيارة',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildAnalysisItem('الحالة العامة', 'ممتازة', Icons.check_circle, Colors.green),
            _buildAnalysisItem('الأضرار المكتشفة', 'لا توجد', Icons.shield, Colors.green),
            _buildAnalysisItem('الطلاء', 'أصلي 95%', Icons.palette, Colors.blue),
            _buildAnalysisItem('الإطارات', 'جيدة', Icons.tire_repair, Colors.orange),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _generateReport,
                    icon: const Icon(Icons.description),
                    label: const Text('تقرير مفصل'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _shareAnalysis,
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

  Widget _buildAnalysisItem(String title, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
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

  Widget _buildARTools() {
    final tools = [
      {'title': 'مقياس المسافة', 'desc': 'قياس المسافات بدقة', 'icon': Icons.straighten},
      {'title': 'كاشف الألوان', 'desc': 'تحديد ألوان الطلاء', 'icon': Icons.colorize},
      {'title': 'مقارن الأحجام', 'desc': 'مقارنة أحجام السيارات', 'icon': Icons.compare_arrows},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'أدوات الواقع المعزز',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...tools.map((tool) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                tool['icon'] as IconData,
                color: Colors.deepPurple[600],
              ),
            ),
            title: Text(
              tool['title'] as String,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(tool['desc'] as String),
            trailing: ElevatedButton(
              onPressed: _carDetected ? () => _useTool(tool['title'] as String) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _carDetected ? Colors.deepPurple[600] : Colors.grey[300],
                minimumSize: const Size(60, 32),
              ),
              child: Text(
                'استخدام',
                style: TextStyle(
                  color: _carDetected ? Colors.white : Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ),
          ),
        )),
      ],
    );
  }

  void _toggleScanning() {
    setState(() {
      _isScanning = !_isScanning;
      if (_isScanning) {
        _carDetected = false;
        _scanController.repeat();
        // Simulate car detection after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted && _isScanning) {
            setState(() {
              _carDetected = true;
              _isScanning = false;
            });
            _scanController.stop();
          }
        });
      } else {
        _scanController.stop();
        _carDetected = false;
      }
    });
  }

  void _useARFeature(String featureName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم تفعيل: $featureName'),
        backgroundColor: Colors.deepPurple[600],
      ),
    );
  }

  void _generateReport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تقرير تحليل السيارة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.description, size: 64, color: Colors.deepPurple[600]),
            const SizedBox(height: 16),
            const Text('تم إنشاء تقرير مفصل عن حالة السيارة'),
            const SizedBox(height: 16),
            const Text('• الحالة العامة: ممتازة'),
            const Text('• لا توجد أضرار مكتشفة'),
            const Text('• الطلاء أصلي بنسبة 95%'),
            const Text('• الإطارات في حالة جيدة'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم حفظ التقرير بنجاح!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple[600]),
            child: const Text('حفظ', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _shareAnalysis() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('تم مشاركة التحليل بنجاح!'),
        backgroundColor: Colors.blue[600],
      ),
    );
  }

  void _useTool(String toolName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم تفعيل أداة: $toolName'),
        backgroundColor: Colors.deepPurple[600],
      ),
    );
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }
}
