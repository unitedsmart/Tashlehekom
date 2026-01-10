import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

class DeliveryMainScreen extends StatefulWidget {
  const DeliveryMainScreen({super.key});

  @override
  State<DeliveryMainScreen> createState() => _DeliveryMainScreenState();
}

class _DeliveryMainScreenState extends State<DeliveryMainScreen>
    with TickerProviderStateMixin {
  late AnimationController _truckController;
  late Animation<double> _truckAnimation;
  Timer? _trackingTimer;
  
  String _currentStatus = 'في الطريق';
  double _deliveryProgress = 0.65;

  @override
  void initState() {
    super.initState();
    _truckController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _truckAnimation = Tween<double>(begin: -0.1, end: 0.1).animate(
      CurvedAnimation(parent: _truckController, curve: Curves.easeInOut),
    );
    _truckController.repeat(reverse: true);
    _startTrackingSimulation();
  }

  void _startTrackingSimulation() {
    _trackingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          _deliveryProgress = min(1.0, _deliveryProgress + 0.05);
          if (_deliveryProgress >= 1.0) {
            _currentStatus = 'تم التسليم';
            timer.cancel();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التوصيل والشحن'),
        backgroundColor: Colors.orange[600],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 20),
            _buildActiveDelivery(),
            const SizedBox(height: 20),
            _buildDeliveryServices(),
            const SizedBox(height: 20),
            _buildDriverNetwork(),
            const SizedBox(height: 20),
            _buildDeliveryHistory(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _requestDelivery,
        backgroundColor: Colors.orange[600],
        child: const Icon(Icons.add, color: Colors.white),
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
            colors: [Colors.orange[600]!, Colors.orange[400]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AnimatedBuilder(
                  animation: _truckAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(_truckAnimation.value * 10, 0),
                      child: Icon(Icons.local_shipping, color: Colors.white, size: 32),
                    );
                  },
                ),
                const SizedBox(width: 12),
                const Text(
                  'خدمة التوصيل السريع',
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
              'توصيل السيارات إلى باب منزلك بأمان وسرعة',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildHeaderStat('السائقين النشطين', '247'),
                const SizedBox(width: 20),
                _buildHeaderStat('متوسط التوصيل', '45 دقيقة'),
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

  Widget _buildActiveDelivery() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.track_changes, color: Colors.orange[600]),
                const SizedBox(width: 8),
                const Text(
                  'تتبع الطلب الحالي',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.orange[600],
                        child: const Icon(Icons.directions_car, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'تويوتا كامري 2020',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'رقم الطلب: #TK2024001',
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange[600],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _currentStatus,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('التقدم'),
                          Text('${(_deliveryProgress * 100).toInt()}%'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: _deliveryProgress,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.orange[600]!),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDeliverySteps(),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _callDriver,
                    icon: const Icon(Icons.phone),
                    label: const Text('اتصال بالسائق'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _trackOnMap,
                    icon: const Icon(Icons.map),
                    label: const Text('تتبع على الخريطة'),
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

  Widget _buildDeliverySteps() {
    final steps = [
      {'title': 'تم استلام الطلب', 'completed': true},
      {'title': 'جاري التحضير', 'completed': true},
      {'title': 'في الطريق', 'completed': _deliveryProgress >= 0.5},
      {'title': 'تم التسليم', 'completed': _deliveryProgress >= 1.0},
    ];

    return Column(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final isCompleted = step['completed'] as bool;
        final isLast = index == steps.length - 1;

        return Row(
          children: [
            Column(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isCompleted ? Colors.orange[600] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 12)
                      : null,
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 30,
                    color: isCompleted ? Colors.orange[600] : Colors.grey[300],
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  step['title'] as String,
                  style: TextStyle(
                    fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                    color: isCompleted ? Colors.orange[600] : Colors.grey[600],
                  ),
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildDeliveryServices() {
    final services = [
      {'title': 'توصيل عادي', 'time': '2-3 أيام', 'price': '200 ريال', 'icon': Icons.local_shipping, 'color': Colors.blue},
      {'title': 'توصيل سريع', 'time': '24 ساعة', 'price': '350 ريال', 'icon': Icons.flash_on, 'color': Colors.orange},
      {'title': 'توصيل فوري', 'time': '2-4 ساعات', 'price': '500 ريال', 'icon': Icons.rocket_launch, 'color': Colors.red},
      {'title': 'توصيل مجدول', 'time': 'حسب الطلب', 'price': '250 ريال', 'icon': Icons.schedule, 'color': Colors.green},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'خدمات التوصيل',
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
            childAspectRatio: 0.9,
          ),
          itemCount: services.length,
          itemBuilder: (context, index) {
            final service = services[index];
            return Card(
              child: InkWell(
                onTap: () => _selectService(service['title'] as String),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (service['color'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          service['icon'] as IconData,
                          size: 32,
                          color: service['color'] as Color,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        service['title'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        service['time'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: service['color'] as Color,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          service['price'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
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

  Widget _buildDriverNetwork() {
    final drivers = [
      {'name': 'أحمد محمد', 'rating': 4.8, 'trips': 245, 'status': 'متاح'},
      {'name': 'سالم العتيبي', 'rating': 4.9, 'trips': 189, 'status': 'مشغول'},
      {'name': 'محمد الأحمد', 'rating': 4.7, 'trips': 312, 'status': 'متاح'},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.people, color: Colors.orange[600]),
                const SizedBox(width: 8),
                const Text(
                  'شبكة السائقين',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...drivers.map((driver) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.orange[100],
                    child: Icon(Icons.person, color: Colors.orange[600]),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          driver['name'] as String,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            Icon(Icons.star, size: 16, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              '${driver['rating']} • ${driver['trips']} رحلة',
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: driver['status'] == 'متاح' ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      driver['status'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
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

  Widget _buildDeliveryHistory() {
    final history = [
      {'car': 'هوندا أكورد 2019', 'date': '15 ديسمبر', 'status': 'مكتمل', 'price': '300 ريال'},
      {'car': 'نيسان التيما 2021', 'date': '10 ديسمبر', 'status': 'مكتمل', 'price': '250 ريال'},
      {'car': 'تويوتا كورولا 2020', 'date': '5 ديسمبر', 'status': 'مكتمل', 'price': '200 ريال'},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history, color: Colors.orange[600]),
                const SizedBox(width: 8),
                const Text(
                  'سجل التوصيل',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...history.map((item) => ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.check_circle, color: Colors.green),
              ),
              title: Text(item['car'] as String),
              subtitle: Text(item['date'] as String),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    item['price'] as String,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    item['status'] as String,
                    style: TextStyle(color: Colors.green, fontSize: 12),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  void _requestDelivery() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('طلب توصيل جديد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_shipping, size: 64, color: Colors.orange[600]),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'عنوان الاستلام',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'عنوان التسليم',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.flag),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم إرسال طلب التوصيل بنجاح!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[600]),
            child: const Text('طلب التوصيل', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _callDriver() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('جاري الاتصال بالسائق...'),
        backgroundColor: Colors.green[600],
      ),
    );
  }

  void _trackOnMap() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('فتح الخريطة للتتبع...'),
        backgroundColor: Colors.blue[600],
      ),
    );
  }

  void _selectService(String serviceName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم اختيار: $serviceName'),
        backgroundColor: Colors.orange[600],
      ),
    );
  }

  @override
  void dispose() {
    _truckController.dispose();
    _trackingTimer?.cancel();
    super.dispose();
  }
}
