import 'package:flutter/material.dart';
import '../../services/firebase_firestore_service.dart';
import '../../services/error_handling_service.dart';

class AdminSecurityLogsScreen extends StatefulWidget {
  const AdminSecurityLogsScreen({super.key});

  @override
  State<AdminSecurityLogsScreen> createState() => _AdminSecurityLogsScreenState();
}

class _AdminSecurityLogsScreenState extends State<AdminSecurityLogsScreen> {
  final FirebaseFirestoreService _firestoreService = FirebaseFirestoreService();
  final ErrorHandlingService _errorHandler = ErrorHandlingService();
  List<Map<String, dynamic>> _securityLogs = [];
  bool _isLoading = true;
  String _selectedType = 'all';

  @override
  void initState() {
    super.initState();
    _loadSecurityLogs();
  }

  Future<void> _loadSecurityLogs() async {
    try {
      setState(() => _isLoading = true);
      
      // الحصول على سجلات الأمان من Firestore
      final logs = await _firestoreService.getSecurityLogs();
      
      if (_selectedType == 'all') {
        _securityLogs = logs;
      } else {
        _securityLogs = logs.where((log) => log['type'] == _selectedType).toList();
      }
      
      // ترتيب السجلات حسب التاريخ (الأحدث أولاً)
      _securityLogs.sort((a, b) => (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime));
      
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        final errorMessage = _errorHandler.handleGenericError(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحميل سجلات الأمان: $errorMessage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getLogTypeText(String type) {
    switch (type) {
      case 'login_attempt':
        return 'محاولة تسجيل دخول';
      case 'failed_login':
        return 'فشل تسجيل دخول';
      case 'suspicious_activity':
        return 'نشاط مشبوه';
      case 'account_locked':
        return 'قفل حساب';
      case 'password_change':
        return 'تغيير كلمة مرور';
      case 'data_access':
        return 'الوصول للبيانات';
      case 'admin_action':
        return 'إجراء إداري';
      default:
        return type;
    }
  }

  Color _getLogTypeColor(String type) {
    switch (type) {
      case 'login_attempt':
        return Colors.blue;
      case 'failed_login':
        return Colors.orange;
      case 'suspicious_activity':
        return Colors.red;
      case 'account_locked':
        return Colors.purple;
      case 'password_change':
        return Colors.green;
      case 'data_access':
        return Colors.teal;
      case 'admin_action':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  IconData _getLogTypeIcon(String type) {
    switch (type) {
      case 'login_attempt':
        return Icons.login;
      case 'failed_login':
        return Icons.error_outline;
      case 'suspicious_activity':
        return Icons.warning;
      case 'account_locked':
        return Icons.lock;
      case 'password_change':
        return Icons.key;
      case 'data_access':
        return Icons.data_usage;
      case 'admin_action':
        return Icons.admin_panel_settings;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سجلات الأمان'),
        backgroundColor: Colors.purple[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSecurityLogs,
          ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _showClearLogsDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // فلتر نوع السجل
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text('نوع السجل: ', style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedType,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('جميع السجلات')),
                      DropdownMenuItem(value: 'login_attempt', child: Text('محاولات تسجيل الدخول')),
                      DropdownMenuItem(value: 'failed_login', child: Text('فشل تسجيل الدخول')),
                      DropdownMenuItem(value: 'suspicious_activity', child: Text('نشاط مشبوه')),
                      DropdownMenuItem(value: 'account_locked', child: Text('قفل الحسابات')),
                      DropdownMenuItem(value: 'admin_action', child: Text('الإجراءات الإدارية')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedType = value;
                        });
                        _loadSecurityLogs();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // إحصائيات سريعة
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'إجمالي السجلات',
                    _securityLogs.length.toString(),
                    Icons.list,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    'نشاط مشبوه',
                    _securityLogs.where((log) => log['type'] == 'suspicious_activity').length.toString(),
                    Icons.warning,
                    Colors.red,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // قائمة السجلات
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _securityLogs.isEmpty
                    ? const Center(
                        child: Text(
                          'لا توجد سجلات أمان',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadSecurityLogs,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _securityLogs.length,
                          itemBuilder: (context, index) {
                            final log = _securityLogs[index];
                            return _buildLogCard(log);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogCard(Map<String, dynamic> log) {
    final type = log['type'] as String;
    final timestamp = log['timestamp'] as DateTime;
    final userId = log['userId'] as String? ?? 'غير محدد';
    final details = log['details'] as String? ?? '';
    final ipAddress = log['ipAddress'] as String? ?? 'غير محدد';
    final deviceInfo = log['deviceInfo'] as String? ?? 'غير محدد';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getLogTypeColor(type).withOpacity(0.1),
          child: Icon(
            _getLogTypeIcon(type),
            color: _getLogTypeColor(type),
            size: 20,
          ),
        ),
        title: Text(
          _getLogTypeText(type),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('المستخدم: $userId', style: const TextStyle(fontSize: 12)),
            Text('الوقت: ${_formatDateTime(timestamp)}', style: const TextStyle(fontSize: 12)),
            if (details.isNotEmpty)
              Text('التفاصيل: $details', style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleLogAction(log, value),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'details',
              child: Text('عرض التفاصيل'),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Text(
                'حذف السجل',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _handleLogAction(Map<String, dynamic> log, String action) {
    switch (action) {
      case 'details':
        _showLogDetails(log);
        break;
      case 'delete':
        _deleteLog(log);
        break;
    }
  }

  void _showLogDetails(Map<String, dynamic> log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تفاصيل ${_getLogTypeText(log['type'])}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('النوع: ${_getLogTypeText(log['type'])}'),
              Text('المستخدم: ${log['userId'] ?? 'غير محدد'}'),
              Text('الوقت: ${_formatDateTime(log['timestamp'])}'),
              Text('عنوان IP: ${log['ipAddress'] ?? 'غير محدد'}'),
              Text('معلومات الجهاز: ${log['deviceInfo'] ?? 'غير محدد'}'),
              if (log['details'] != null && log['details'].toString().isNotEmpty)
                Text('التفاصيل: ${log['details']}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteLog(Map<String, dynamic> log) async {
    try {
      await _firestoreService.deleteSecurityLog(log['id']);
      await _loadSecurityLogs();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف السجل بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = _errorHandler.handleGenericError(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في حذف السجل: $errorMessage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showClearLogsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مسح جميع السجلات'),
        content: const Text('هل أنت متأكد من مسح جميع سجلات الأمان؟ هذا الإجراء لا يمكن التراجع عنه.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _clearAllLogs();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('مسح الكل', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _clearAllLogs() async {
    try {
      await _firestoreService.clearSecurityLogs();
      await _loadSecurityLogs();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم مسح جميع السجلات بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = _errorHandler.handleGenericError(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في مسح السجلات: $errorMessage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
