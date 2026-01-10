import 'package:flutter/material.dart';
import 'package:tashlehekomv2/services/advanced_image_management_service.dart';

class ImageManagementScreen extends StatefulWidget {
  const ImageManagementScreen({super.key});

  @override
  State<ImageManagementScreen> createState() => _ImageManagementScreenState();
}

class _ImageManagementScreenState extends State<ImageManagementScreen> {
  final AdvancedImageManagementService _managementService = AdvancedImageManagementService();
  
  bool _isLoading = false;
  StorageStats? _storageStats;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _loadStorageStats();
  }

  Future<void> _loadStorageStats() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'جاري تحميل إحصائيات التخزين...';
    });

    try {
      final stats = await _managementService.getStorageStatistics();
      setState(() {
        _storageStats = stats;
        _statusMessage = 'تم تحميل الإحصائيات بنجاح';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'خطأ في تحميل الإحصائيات: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الصور المتقدمة'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStorageStats,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Message
            if (_statusMessage.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Text(
                  _statusMessage,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Storage Statistics
            _buildStorageStatsCard(),
            
            const SizedBox(height: 16),
            
            // Management Actions
            _buildManagementActionsCard(),
            
            const SizedBox(height: 16),
            
            // Maintenance Tools
            _buildMaintenanceToolsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageStatsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                const Text(
                  'إحصائيات التخزين',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_storageStats != null) ...[
              _buildStatRow('إجمالي الحجم', _formatBytes(_storageStats!.totalSize)),
              _buildStatRow('عدد السيارات', '${_storageStats!.carCount}'),
              _buildStatRow('عدد الصور', '${_storageStats!.imageCount}'),
              _buildStatRow('متوسط حجم السيارة', _formatBytes(_storageStats!.averageCarSize.round())),
              _buildStatRow('متوسط حجم الصورة', _formatBytes(_storageStats!.averageImageSize.round())),
              if (_storageStats!.largestCarId != null)
                _buildStatRow('أكبر سيارة', '${_formatBytes(_storageStats!.largestCarSize)} (${_storageStats!.largestCarId})'),
            ] else
              const Text('لا توجد إحصائيات متاحة'),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementActionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.settings, color: Colors.green.shade600),
                const SizedBox(width: 8),
                const Text(
                  'أدوات الإدارة',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Cleanup Orphaned Images
            ListTile(
              leading: const Icon(Icons.cleaning_services, color: Colors.orange),
              title: const Text('تنظيف الصور المهجورة'),
              subtitle: const Text('حذف الصور التي لا تنتمي لأي سيارة'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _cleanupOrphanedImages,
            ),
            
            const Divider(),
            
            // Clear Image Cache
            ListTile(
              leading: const Icon(Icons.cached, color: Colors.blue),
              title: const Text('تنظيف ذاكرة التخزين المؤقت'),
              subtitle: const Text('حذف الصور المحفوظة مؤقتاً'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _clearImageCache,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaintenanceToolsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.build, color: Colors.purple.shade600),
                const SizedBox(width: 8),
                const Text(
                  'أدوات الصيانة',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Optimize Images
            ListTile(
              leading: const Icon(Icons.compress, color: Colors.green),
              title: const Text('تحسين جودة الصور'),
              subtitle: const Text('ضغط وتحسين جميع الصور'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showOptimizeDialog(),
            ),
            
            const Divider(),
            
            // Backup Images
            ListTile(
              leading: const Icon(Icons.backup, color: Colors.indigo),
              title: const Text('نسخ احتياطي للصور'),
              subtitle: const Text('إنشاء نسخة احتياطية من جميع الصور'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showBackupDialog(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes بايت';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} كيلوبايت';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} ميجابايت';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} جيجابايت';
    }
  }

  Future<void> _cleanupOrphanedImages() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تنظيف الصور المهجورة'),
        content: const Text(
          'هذا سيحذف جميع الصور التي لا تنتمي لأي سيارة موجودة.\n\nهل أنت متأكد؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('تنظيف'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
        _statusMessage = 'جاري تنظيف الصور المهجورة...';
      });

      try {
        final result = await _managementService.cleanupOrphanedImages();
        setState(() {
          _statusMessage = result.error != null
              ? 'خطأ: ${result.error}'
              : 'تم حذف ${result.deletedImages} صورة وتوفير ${_formatBytes(result.freedSpace)}';
        });
        
        // Reload stats
        await _loadStorageStats();
      } catch (e) {
        setState(() {
          _statusMessage = 'خطأ في التنظيف: $e';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _clearImageCache() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'جاري تنظيف ذاكرة التخزين المؤقت...';
    });

    try {
      final success = await _managementService.clearImageCache();
      setState(() {
        _statusMessage = success
            ? 'تم تنظيف ذاكرة التخزين المؤقت بنجاح'
            : 'فشل في تنظيف ذاكرة التخزين المؤقت';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'خطأ في التنظيف: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showOptimizeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تحسين الصور'),
        content: const Text('هذه الميزة قيد التطوير وستكون متاحة قريباً.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  void _showBackupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('النسخ الاحتياطي'),
        content: const Text('هذه الميزة قيد التطوير وستكون متاحة قريباً.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }
}
