import 'package:flutter/material.dart';
import '../../models/admin_approval_model.dart';
import '../../services/database_service.dart';

class CarApprovalScreen extends StatefulWidget {
  final PendingCar pendingCar;

  const CarApprovalScreen({
    super.key,
    required this.pendingCar,
  });

  @override
  State<CarApprovalScreen> createState() => _CarApprovalScreenState();
}

class _CarApprovalScreenState extends State<CarApprovalScreen> {
  final DatabaseService _databaseService = DatabaseService.instance;
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _rejectionController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مراجعة السيارة'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // معلومات السيارة
            _buildCarInfoCard(),
            const SizedBox(height: 16),
            
            // معلومات البائع
            _buildSellerInfoCard(),
            const SizedBox(height: 16),
            
            // ملاحظات الإدارة
            _buildNotesSection(),
            const SizedBox(height: 24),
            
            // أزرار الإجراءات
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildCarInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'معلومات السيارة',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            const Divider(),
            _buildInfoRow('الماركة', widget.pendingCar.brand),
            _buildInfoRow('الموديل', widget.pendingCar.model),
            _buildInfoRow('السنة', widget.pendingCar.year.toString()),
            _buildInfoRow('المدينة', widget.pendingCar.city),
            _buildInfoRow('السعر', '${widget.pendingCar.price.toStringAsFixed(0)} ريال'),
            _buildInfoRow('الحالة', widget.pendingCar.condition),
            const SizedBox(height: 8),
            Text(
              'الوصف:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(widget.pendingCar.description),
          ],
        ),
      ),
    );
  }

  Widget _buildSellerInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'معلومات البائع',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const Divider(),
            _buildInfoRow('الاسم', widget.pendingCar.userName),
            _buildInfoRow('رقم الهاتف', widget.pendingCar.userPhone),
            _buildInfoRow('تاريخ الإرسال', _formatDate(widget.pendingCar.submittedAt)),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ملاحظات الإدارة',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'أضف ملاحظاتك هنا...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // زر الموافقة
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _approveCar,
            icon: const Icon(Icons.check_circle),
            label: const Text('موافقة على السيارة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 12),
        
        // زر الرفض
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _showRejectDialog,
            icon: const Icon(Icons.cancel),
            label: const Text('رفض السيارة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 12),
        
        // زر طلب التعديل
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _requestRevision,
            icon: const Icon(Icons.edit),
            label: const Text('طلب تعديل'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _approveCar() async {
    setState(() => _isLoading = true);
    
    try {
      final success = await _databaseService.approveCar(
        widget.pendingCar.id,
        'admin_001', // ID المدير الافتراضي
        'المدير العام',
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم اعتماد السيارة بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('حدث خطأ أثناء اعتماد السيارة'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showRejectDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('رفض السيارة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('يرجى إدخال سبب الرفض:'),
            const SizedBox(height: 8),
            TextField(
              controller: _rejectionController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'سبب الرفض...',
                border: OutlineInputBorder(),
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
              _rejectCar();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('رفض', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _rejectCar() async {
    if (_rejectionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال سبب الرفض'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final success = await _databaseService.rejectCar(
        widget.pendingCar.id,
        'admin_001',
        'المدير العام',
        _rejectionController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم رفض السيارة'),
              backgroundColor: Colors.orange,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('حدث خطأ أثناء رفض السيارة'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _requestRevision() async {
    setState(() => _isLoading = true);
    
    try {
      final success = await _databaseService.requestRevision(
        widget.pendingCar.id,
        'admin_001',
        'المدير العام',
        notes: _notesController.text.trim().isEmpty ? 'يرجى مراجعة البيانات وإعادة الإرسال' : _notesController.text.trim(),
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم طلب التعديل من البائع'),
              backgroundColor: Colors.blue,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('حدث خطأ أثناء طلب التعديل'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _rejectionController.dispose();
    super.dispose();
  }
}
