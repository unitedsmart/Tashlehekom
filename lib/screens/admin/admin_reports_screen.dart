import 'package:flutter/material.dart';
import '../../models/report_model.dart';
import '../../services/firebase_firestore_service.dart';
import '../../services/error_handling_service.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  final FirebaseFirestoreService _firestoreService = FirebaseFirestoreService();
  final ErrorHandlingService _errorHandler = ErrorHandlingService();
  List<ReportModel> _reports = [];
  bool _isLoading = true;
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    try {
      setState(() => _isLoading = true);

      final allReports = await _firestoreService.getAllReports();

      if (_selectedStatus == 'all') {
        _reports = allReports;
      } else {
        final statusEnum = _getReportStatusFromString(_selectedStatus);
        _reports =
            allReports.where((report) => report.status == statusEnum).toList();
      }

      // ترتيب التقارير حسب التاريخ (الأحدث أولاً)
      _reports.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        final errorMessage = _errorHandler.handleGenericError(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحميل التقارير: $errorMessage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  ReportStatus _getReportStatusFromString(String status) {
    switch (status) {
      case 'pending':
        return ReportStatus.pending;
      case 'resolved':
        return ReportStatus.resolved;
      case 'rejected':
        return ReportStatus.rejected;
      case 'inProgress':
        return ReportStatus.inProgress;
      case 'closed':
        return ReportStatus.closed;
      default:
        return ReportStatus.pending;
    }
  }

  String _getReportTypeText(ReportType type) {
    switch (type) {
      case ReportType.user:
        return 'بلاغ على مستخدم';
      case ReportType.car:
        return 'بلاغ على سيارة';
      case ReportType.content:
        return 'بلاغ على محتوى';
      case ReportType.technical:
        return 'مشكلة تقنية';
      case ReportType.suggestion:
        return 'اقتراح';
    }
  }

  String _getStatusText(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return 'قيد المراجعة';
      case ReportStatus.inProgress:
        return 'قيد المعالجة';
      case ReportStatus.resolved:
        return 'تم الحل';
      case ReportStatus.rejected:
        return 'مرفوض';
      case ReportStatus.closed:
        return 'مغلق';
    }
  }

  Color _getStatusColor(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return Colors.orange;
      case ReportStatus.inProgress:
        return Colors.blue;
      case ReportStatus.resolved:
        return Colors.green;
      case ReportStatus.rejected:
        return Colors.red;
      case ReportStatus.closed:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة التقارير'),
        backgroundColor: Colors.red[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReports,
          ),
        ],
      ),
      body: Column(
        children: [
          // فلتر الحالة
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text('الحالة: ',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedStatus,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(
                          value: 'all', child: Text('جميع التقارير')),
                      DropdownMenuItem(
                          value: 'pending', child: Text('قيد المراجعة')),
                      DropdownMenuItem(
                          value: 'resolved', child: Text('تم الحل')),
                      DropdownMenuItem(value: 'rejected', child: Text('مرفوض')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedStatus = value;
                        });
                        _loadReports();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          // قائمة التقارير
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _reports.isEmpty
                    ? const Center(
                        child: Text(
                          'لا توجد تقارير',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadReports,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _reports.length,
                          itemBuilder: (context, index) {
                            final report = _reports[index];
                            return _buildReportCard(report);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(ReportModel report) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(report.status),
          child: Icon(
            _getReportIcon(report.type),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          _getReportTypeText(report.type),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('المُبلِغ: ${report.reporterId}'),
            Text('الحالة: ${_getStatusText(report.status)}'),
            Text('التاريخ: ${_formatDate(report.createdAt)}'),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'تفاصيل التقرير:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(report.description ?? 'لا توجد تفاصيل'),
                const SizedBox(height: 16),
                if (report.status == ReportStatus.pending)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _updateReportStatus(
                              report, ReportStatus.resolved),
                          icon: const Icon(Icons.check),
                          label: const Text('حل التقرير'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _updateReportStatus(
                              report, ReportStatus.rejected),
                          icon: const Icon(Icons.close),
                          label: const Text('رفض التقرير'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                if (report.status != ReportStatus.pending)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getStatusColor(report.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          report.status == ReportStatus.resolved
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: _getStatusColor(report.status),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'تم ${_getStatusText(report.status)}',
                          style: TextStyle(
                            color: _getStatusColor(report.status),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getReportIcon(ReportType type) {
    switch (type) {
      case ReportType.user:
        return Icons.person_off;
      case ReportType.car:
        return Icons.directions_car;
      case ReportType.content:
        return Icons.report;
      case ReportType.technical:
        return Icons.bug_report;
      case ReportType.suggestion:
        return Icons.lightbulb_outline;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _updateReportStatus(
      ReportModel report, ReportStatus newStatus) async {
    try {
      await _firestoreService
          .updateReport(report.id, {'status': newStatus.index});
      await _loadReports();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('تم تحديث حالة التقرير إلى ${_getStatusText(newStatus)}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = _errorHandler.handleGenericError(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحديث التقرير: $errorMessage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
