import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tashlehekomv2/models/user_model.dart';
import 'package:tashlehekomv2/providers/user_provider.dart';

class WorkersManagementScreen extends StatefulWidget {
  const WorkersManagementScreen({super.key});

  @override
  State<WorkersManagementScreen> createState() => _WorkersManagementScreenState();
}

class _WorkersManagementScreenState extends State<WorkersManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة العمال'),
        backgroundColor: Colors.green,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'العمال غير المرتبطين'),
            Tab(text: 'العمال المرتبطين'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'البحث عن عامل...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUnlinkedWorkers(),
                _buildLinkedWorkers(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnlinkedWorkers() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final unlinkedWorkers = userProvider.unlinkedWorkers
            .where((worker) => _searchQuery.isEmpty ||
                worker.username.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

        if (unlinkedWorkers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _searchQuery.isEmpty ? Icons.check_circle_outline : Icons.search_off,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isEmpty
                      ? 'جميع العمال مرتبطين بتشاليح'
                      : 'لا توجد نتائج للبحث',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: unlinkedWorkers.length,
          itemBuilder: (context, index) {
            final worker = unlinkedWorkers[index];
            return _buildWorkerCard(worker, false, userProvider);
          },
        );
      },
    );
  }

  Widget _buildLinkedWorkers() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final linkedWorkers = userProvider.linkedWorkers
            .where((worker) => _searchQuery.isEmpty ||
                worker.username.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                (worker.junkyard?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false))
            .toList();

        if (linkedWorkers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _searchQuery.isEmpty ? Icons.work_off : Icons.search_off,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isEmpty
                      ? 'لا يوجد عمال مرتبطين بتشاليح'
                      : 'لا توجد نتائج للبحث',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: linkedWorkers.length,
          itemBuilder: (context, index) {
            final worker = linkedWorkers[index];
            return _buildWorkerCard(worker, true, userProvider);
          },
        );
      },
    );
  }

  Widget _buildWorkerCard(UserModel worker, bool isLinked, UserProvider userProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Worker info
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: isLinked ? Colors.green[100] : Colors.orange[100],
                  child: Icon(
                    Icons.work,
                    color: isLinked ? Colors.green[700] : Colors.orange[700],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        worker.username,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isLinked ? 'مرتبط بتشليح' : 'غير مرتبط',
                        style: TextStyle(
                          color: isLinked ? Colors.green[600] : Colors.orange[600],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: worker.isActive ? Colors.green[100] : Colors.red[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    worker.isActive ? 'نشط' : 'معطل',
                    style: TextStyle(
                      color: worker.isActive ? Colors.green[700] : Colors.red[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Worker details
            _buildDetailRow('رقم الجوال', worker.phoneNumber),
            if (worker.city != null)
              _buildDetailRow('المدينة', worker.city!),
            if (worker.junkyard != null)
              _buildDetailRow('التشليح', worker.junkyard!),
            _buildDetailRow('تاريخ التسجيل', _formatDate(worker.createdAt)),
            
            const SizedBox(height: 16),
            
            // Action buttons
            Row(
              children: [
                if (!isLinked)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _linkWorkerToJunkyard(worker, userProvider),
                      icon: const Icon(Icons.link),
                      label: const Text('ربط بتشليح'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                
                if (isLinked) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _unlinkWorker(worker, userProvider),
                      icon: const Icon(Icons.link_off),
                      label: const Text('إلغاء الربط'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange,
                        side: const BorderSide(color: Colors.orange),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _toggleWorkerStatus(worker, userProvider),
                    icon: Icon(worker.isActive ? Icons.block : Icons.check_circle),
                    label: Text(worker.isActive ? 'تعطيل' : 'تفعيل'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: worker.isActive ? Colors.red : Colors.green,
                      side: BorderSide(
                        color: worker.isActive ? Colors.red : Colors.green,
                      ),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _linkWorkerToJunkyard(UserModel worker, UserProvider userProvider) async {
    final TextEditingController junkyardController = TextEditingController();
    
    final junkyardName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('ربط ${worker.username} بتشليح'),
        content: TextField(
          controller: junkyardController,
          decoration: const InputDecoration(
            labelText: 'اسم التشليح',
            hintText: 'أدخل اسم التشليح',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (junkyardController.text.isNotEmpty) {
                Navigator.pop(context, junkyardController.text);
              }
            },
            child: const Text('ربط'),
          ),
        ],
      ),
    );

    if (junkyardName != null) {
      final success = await userProvider.linkWorkerToJunkyard(worker.id, junkyardName);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم ربط ${worker.username} بتشليح $junkyardName'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حدث خطأ في ربط العامل'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _unlinkWorker(UserModel worker, UserProvider userProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إلغاء الربط'),
        content: Text('هل أنت متأكد من إلغاء ربط ${worker.username} من ${worker.junkyard}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('إلغاء الربط'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await userProvider.linkWorkerToJunkyard(worker.id, '');
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم إلغاء ربط ${worker.username}'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حدث خطأ في إلغاء الربط'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleWorkerStatus(UserModel worker, UserProvider userProvider) async {
    final action = worker.isActive ? 'تعطيل' : 'تفعيل';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$action الحساب'),
        content: Text('هل أنت متأكد من $action حساب ${worker.username}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: worker.isActive ? Colors.red : Colors.green,
            ),
            child: Text(action),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await userProvider.toggleUserStatus(worker.id);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم $action حساب ${worker.username}'),
            backgroundColor: worker.isActive ? Colors.red : Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حدث خطأ في تغيير حالة الحساب'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
