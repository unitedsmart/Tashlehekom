import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:tashlehekomv2/providers/auth_provider.dart';
import 'package:tashlehekomv2/models/report_model.dart';
import 'package:tashlehekomv2/services/database_service.dart';
import 'package:tashlehekomv2/l10n/app_localizations.dart';

class ReportScreen extends StatefulWidget {
  final String? reportedUserId;
  final String? reportedCarId;
  final ReportType initialType;

  const ReportScreen({
    super.key,
    this.reportedUserId,
    this.reportedCarId,
    this.initialType = ReportType.technical,
  });

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _descriptionController = TextEditingController();

  late ReportType _selectedType;
  bool _isSubmitting = false;

  final Map<ReportType, String> _reportTypeNames = {
    ReportType.user: 'بلاغ على مستخدم',
    ReportType.car: 'بلاغ على سيارة',
    ReportType.content: 'بلاغ على محتوى',
    ReportType.technical: 'مشكلة تقنية',
    ReportType.suggestion: 'اقتراح',
  };

  final Map<ReportType, List<String>> _predefinedReasons = {
    ReportType.user: [
      'سلوك غير لائق',
      'محتوى مخالف',
      'انتحال شخصية',
      'احتيال أو نصب',
      'أخرى',
    ],
    ReportType.car: [
      'معلومات خاطئة',
      'صور مضللة',
      'سعر غير حقيقي',
      'سيارة غير موجودة',
      'أخرى',
    ],
    ReportType.content: [
      'محتوى غير لائق',
      'صور مخالفة',
      'معلومات خاطئة',
      'أخرى',
    ],
    ReportType.technical: [
      'مشكلة في التطبيق',
      'بطء في التحميل',
      'خطأ في البيانات',
      'مشكلة في الدفع',
      'أخرى',
    ],
    ReportType.suggestion: [
      'تحسين الواجهة',
      'إضافة ميزة جديدة',
      'تحسين الأداء',
      'أخرى',
    ],
  };

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('بلاغ أو اقتراح'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTypeSelection(),
              const SizedBox(height: 24),
              _buildReasonSelection(),
              const SizedBox(height: 24),
              _buildDescriptionField(),
              const SizedBox(height: 32),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'نوع البلاغ',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        ...ReportType.values.map((type) {
          return RadioListTile<ReportType>(
            title: Text(_reportTypeNames[type]!),
            value: type,
            groupValue: _selectedType,
            onChanged: (value) {
              setState(() {
                _selectedType = value!;
                _reasonController.clear();
              });
            },
          );
        }),
      ],
    );
  }

  Widget _buildReasonSelection() {
    final reasons = _predefinedReasons[_selectedType] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'السبب',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _reasonController.text.isEmpty ? null : _reasonController.text,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'اختر السبب',
          ),
          items: reasons.map((reason) {
            return DropdownMenuItem(
              value: reason,
              child: Text(reason),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _reasonController.text = value ?? '';
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'يرجى اختيار السبب';
            }
            return null;
          },
        ),
        if (_reasonController.text == 'أخرى') ...[
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'اكتب السبب',
              hintText: 'وضح السبب بالتفصيل',
            ),
            maxLines: 2,
            onChanged: (value) {
              _reasonController.text = value;
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'يرجى كتابة السبب';
              }
              return null;
            },
          ),
        ],
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'التفاصيل (اختياري)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'اكتب تفاصيل إضافية عن البلاغ...',
          ),
          maxLines: 5,
          maxLength: 500,
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitReport,
        child: _isSubmitting
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text('جاري الإرسال...'),
                ],
              )
            : const Text('إرسال البلاغ'),
      ),
    );
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يجب تسجيل الدخول أولاً')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final report = ReportModel(
        id: const Uuid().v4(),
        reporterId: authProvider.currentUser!.id,
        reportedUserId: widget.reportedUserId,
        reportedCarId: widget.reportedCarId,
        type: _selectedType,
        reason: _reasonController.text,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        createdAt: DateTime.now(),
      );

      await DatabaseService.instance.insertReport(report);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إرسال البلاغ بنجاح. سيتم مراجعته قريباً.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في إرسال البلاغ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

// شاشة عرض البلاغات للإدارة
class ReportsManagementScreen extends StatefulWidget {
  const ReportsManagementScreen({super.key});

  @override
  State<ReportsManagementScreen> createState() =>
      _ReportsManagementScreenState();
}

class _ReportsManagementScreenState extends State<ReportsManagementScreen> {
  List<ReportModel> _reports = [];
  bool _isLoading = true;
  ReportStatus? _filterStatus;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() => _isLoading = true);

    try {
      final reports =
          await DatabaseService.instance.getAllReports(_filterStatus);
      setState(() {
        _reports = reports;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحميل البلاغات: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة البلاغات'),
        actions: [
          PopupMenuButton<ReportStatus?>(
            icon: const Icon(Icons.filter_list),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('جميع البلاغات'),
              ),
              ...ReportStatus.values.map((status) {
                return PopupMenuItem(
                  value: status,
                  child: Text(_getStatusName(status)),
                );
              }),
            ],
            onSelected: (status) {
              setState(() => _filterStatus = status);
              _loadReports();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildReportsList(),
    );
  }

  Widget _buildReportsList() {
    if (_reports.isEmpty) {
      return const Center(
        child: Text('لا توجد بلاغات'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadReports,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _reports.length,
        itemBuilder: (context, index) {
          final report = _reports[index];
          return _buildReportCard(report);
        },
      ),
    );
  }

  Widget _buildReportCard(ReportModel report) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: _getReportIcon(report.type),
        title: Text(report.reason),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('النوع: ${_getTypeName(report.type)}'),
            Text('الحالة: ${_getStatusName(report.status)}'),
            Text('التاريخ: ${_formatDate(report.createdAt)}'),
          ],
        ),
        trailing: _buildStatusChip(report.status),
        onTap: () => _showReportDetails(report),
      ),
    );
  }

  Widget _getReportIcon(ReportType type) {
    IconData iconData;
    Color color;

    switch (type) {
      case ReportType.user:
        iconData = Icons.person_off;
        color = Colors.red;
        break;
      case ReportType.car:
        iconData = Icons.directions_car_filled;
        color = Colors.orange;
        break;
      case ReportType.content:
        iconData = Icons.content_copy;
        color = Colors.purple;
        break;
      case ReportType.technical:
        iconData = Icons.bug_report;
        color = Colors.blue;
        break;
      case ReportType.suggestion:
        iconData = Icons.lightbulb;
        color = Colors.green;
        break;
    }

    return Icon(iconData, color: color);
  }

  Widget _buildStatusChip(ReportStatus status) {
    Color color;
    String text;

    switch (status) {
      case ReportStatus.pending:
        color = Colors.orange;
        text = 'قيد المراجعة';
        break;
      case ReportStatus.inProgress:
        color = Colors.blue;
        text = 'قيد المعالجة';
        break;
      case ReportStatus.resolved:
        color = Colors.green;
        text = 'تم الحل';
        break;
      case ReportStatus.rejected:
        color = Colors.red;
        text = 'مرفوض';
        break;
      case ReportStatus.closed:
        color = Colors.grey;
        text = 'مغلق';
        break;
    }

    return Chip(
      label: Text(text, style: const TextStyle(fontSize: 12)),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color),
    );
  }

  String _getTypeName(ReportType type) {
    const names = {
      ReportType.user: 'بلاغ على مستخدم',
      ReportType.car: 'بلاغ على سيارة',
      ReportType.content: 'بلاغ على محتوى',
      ReportType.technical: 'مشكلة تقنية',
      ReportType.suggestion: 'اقتراح',
    };
    return names[type] ?? '';
  }

  String _getStatusName(ReportStatus status) {
    const names = {
      ReportStatus.pending: 'قيد المراجعة',
      ReportStatus.inProgress: 'قيد المعالجة',
      ReportStatus.resolved: 'تم الحل',
      ReportStatus.rejected: 'مرفوض',
      ReportStatus.closed: 'مغلق',
    };
    return names[status] ?? '';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showReportDetails(ReportModel report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تفاصيل البلاغ'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('النوع: ${_getTypeName(report.type)}'),
              const SizedBox(height: 8),
              Text('السبب: ${report.reason}'),
              if (report.description != null) ...[
                const SizedBox(height: 8),
                Text('التفاصيل: ${report.description}'),
              ],
              const SizedBox(height: 8),
              Text('الحالة: ${_getStatusName(report.status)}'),
              const SizedBox(height: 8),
              Text('التاريخ: ${_formatDate(report.createdAt)}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
          if (report.status == ReportStatus.pending)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _updateReportStatus(report, ReportStatus.inProgress);
              },
              child: const Text('بدء المعالجة'),
            ),
        ],
      ),
    );
  }

  Future<void> _updateReportStatus(
      ReportModel report, ReportStatus newStatus) async {
    try {
      await DatabaseService.instance.updateReportStatus(report.id, newStatus);
      _loadReports();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديث حالة البلاغ')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحديث البلاغ: $e')),
        );
      }
    }
  }
}
