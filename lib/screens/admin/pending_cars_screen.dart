import 'package:flutter/material.dart';
import '../../models/admin_approval_model.dart';
import '../../services/database_service.dart';
import 'car_approval_screen.dart';

class PendingCarsScreen extends StatefulWidget {
  final String status;

  const PendingCarsScreen({
    Key? key,
    required this.status,
  }) : super(key: key);

  @override
  State<PendingCarsScreen> createState() => _PendingCarsScreenState();
}

class _PendingCarsScreenState extends State<PendingCarsScreen> {
  final DatabaseService _databaseService = DatabaseService.instance;
  List<Map<String, dynamic>> _cars = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCars();
  }

  Future<void> _loadCars() async {
    try {
      final cars = await _databaseService.getPendingCars(status: widget.status);
      setState(() {
        _cars = cars;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحميل السيارات: $e'),
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
        title: Text(_getTitle()),
        backgroundColor: _getStatusColor(),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _loadCars();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadCars,
              child: _cars.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _cars.length,
                      itemBuilder: (context, index) {
                        final car = _cars[index];
                        return _buildCarCard(car);
                      },
                    ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getStatusIcon(),
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد سيارات ${_getStatusText()}',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getEmptyMessage(),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCarCard(Map<String, dynamic> car) {
    final images =
        car['images'].toString().split(',').where((s) => s.isNotEmpty).toList();
    final submittedAt = DateTime.parse(car['submittedAt']);
    final reviewedAt =
        car['reviewedAt'] != null ? DateTime.parse(car['reviewedAt']) : null;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _navigateToCarDetails(car),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // رأس البطاقة
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${car['brand']} ${car['model']}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'سنة ${car['year']} - ${car['city']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _getStatusColor()),
                    ),
                    child: Text(
                      _getStatusText(),
                      style: TextStyle(
                        color: _getStatusColor(),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // معلومات السيارة
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      Icons.attach_money,
                      'السعر',
                      '${car['price']} ريال',
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      Icons.build,
                      'الحالة',
                      car['condition'],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // معلومات البائع
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.person, color: Colors.grey[600], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            car['userName'],
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            car['userPhone'],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // التواريخ
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      Icons.schedule,
                      'تاريخ الإرسال',
                      _formatDate(submittedAt),
                    ),
                  ),
                  if (reviewedAt != null)
                    Expanded(
                      child: _buildInfoItem(
                        Icons.check_circle,
                        'تاريخ المراجعة',
                        _formatDate(reviewedAt),
                      ),
                    ),
                ],
              ),

              // ملاحظات الإدارة (إن وجدت)
              if (car['adminNotes'] != null &&
                  car['adminNotes'].toString().isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.note, color: Colors.blue[600], size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'ملاحظات الإدارة:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        car['adminNotes'],
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],

              // سبب الرفض (إن وجد)
              if (car['rejectionReason'] != null &&
                  car['rejectionReason'].toString().isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.error, color: Colors.red[600], size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'سبب الرفض:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red[800],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        car['rejectionReason'],
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getTitle() {
    switch (widget.status) {
      case 'pending':
        return 'السيارات المعلقة';
      case 'approved':
        return 'السيارات المعتمدة';
      case 'rejected':
        return 'السيارات المرفوضة';
      default:
        return 'السيارات';
    }
  }

  String _getStatusText() {
    switch (widget.status) {
      case 'pending':
        return 'معلقة';
      case 'approved':
        return 'معتمدة';
      case 'rejected':
        return 'مرفوضة';
      default:
        return 'غير محدد';
    }
  }

  Color _getStatusColor() {
    switch (widget.status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    switch (widget.status) {
      case 'pending':
        return Icons.pending_actions;
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  String _getEmptyMessage() {
    switch (widget.status) {
      case 'pending':
        return 'لا توجد سيارات في انتظار المراجعة حالياً';
      case 'approved':
        return 'لم يتم اعتماد أي سيارات بعد';
      case 'rejected':
        return 'لم يتم رفض أي سيارات';
      default:
        return 'لا توجد سيارات';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _navigateToCarDetails(Map<String, dynamic> car) {
    final pendingCar = PendingCar(
      id: car['id'],
      userId: car['userId'],
      userName: car['userName'],
      userPhone: car['userPhone'],
      brand: car['brand'],
      model: car['model'],
      year: car['year'],
      city: car['city'],
      price: car['price'].toDouble(),
      condition: car['condition'],
      description: car['description'],
      images: car['images'].split(','),
      submittedAt: DateTime.parse(car['submittedAt']),
      status: ApprovalStatus.values.firstWhere(
        (e) => e.toString().split('.').last == car['status'],
        orElse: () => ApprovalStatus.pending,
      ),
      adminNotes: car['adminNotes'],
      rejectionReason: car['rejectionReason'],
      reviewedAt:
          car['reviewedAt'] != null ? DateTime.parse(car['reviewedAt']) : null,
      reviewedBy: car['reviewedBy'],
    );

    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => CarApprovalScreen(
          pendingCar: pendingCar,
        ),
      ),
    )
        .then((result) {
      if (result == true) {
        _loadCars();
      }
    });
  }
}
