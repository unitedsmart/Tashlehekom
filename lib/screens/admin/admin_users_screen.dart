import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/firebase_firestore_service.dart';
import '../../services/error_handling_service.dart';

class AdminUsersScreen extends StatefulWidget {
  final String? userType;

  const AdminUsersScreen({
    super.key,
    this.userType,
  });

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final FirebaseFirestoreService _firestoreService = FirebaseFirestoreService();
  final ErrorHandlingService _errorHandler = ErrorHandlingService();
  List<UserModel> _users = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      setState(() => _isLoading = true);

      final allUsers = await _firestoreService.getAllUsers();

      if (widget.userType != null) {
        final userTypeEnum = _getUserTypeFromString(widget.userType!);
        _users =
            allUsers.where((user) => user.userType == userTypeEnum).toList();
      } else {
        _users = allUsers;
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        final errorMessage = _errorHandler.handleGenericError(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحميل المستخدمين: $errorMessage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  UserType _getUserTypeFromString(String type) {
    switch (type) {
      case 'admin':
        return UserType.admin;
      case 'seller':
        return UserType.seller;
      case 'worker':
        return UserType.worker;
      case 'junkyardOwner':
        return UserType.junkyardOwner;
      default:
        return UserType.user;
    }
  }

  String _getUserTypeText(UserType type) {
    switch (type) {
      case UserType.admin:
        return 'مدير';
      case UserType.superAdmin:
        return 'مدير عام';
      case UserType.seller:
        return 'بائع';
      case UserType.worker:
        return 'عامل';
      case UserType.junkyardOwner:
        return 'مالك تشليح';
      case UserType.individual:
        return 'فرد';
      case UserType.user:
        return 'مستخدم';
    }
  }

  List<UserModel> get _filteredUsers {
    if (_searchQuery.isEmpty) return _users;

    return _users.where((user) {
      return user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.phoneNumber.contains(_searchQuery) ||
          (user.city?.toLowerCase() ?? '').contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userType != null
            ? 'إدارة ${_getUserTypeText(_getUserTypeFromString(widget.userType!))}'
            : 'إدارة المستخدمين'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
          ),
        ],
      ),
      body: Column(
        children: [
          // شريط البحث
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'البحث بالاسم أو رقم الهاتف أو المدينة...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // قائمة المستخدمين
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredUsers.isEmpty
                    ? const Center(
                        child: Text(
                          'لا توجد مستخدمين',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadUsers,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = _filteredUsers[index];
                            return _buildUserCard(user);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(UserModel user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: _getUserTypeColor(user.userType),
          child: Text(
            user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          user.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('📱 ${user.phoneNumber}'),
            Text('📍 ${user.city}'),
            Text('👤 ${_getUserTypeText(user.userType)}'),
            if (!user.isActive)
              const Text(
                '⚠️ غير نشط',
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleUserAction(user, value),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'toggle_status',
              child: Text(user.isActive ? 'تعطيل الحساب' : 'تفعيل الحساب'),
            ),
            const PopupMenuItem(
              value: 'view_details',
              child: Text('عرض التفاصيل'),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Text(
                'حذف المستخدم',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getUserTypeColor(UserType type) {
    switch (type) {
      case UserType.admin:
      case UserType.superAdmin:
        return Colors.red;
      case UserType.seller:
        return Colors.green;
      case UserType.worker:
        return Colors.orange;
      case UserType.junkyardOwner:
        return Colors.purple;
      case UserType.individual:
        return Colors.blue;
      case UserType.user:
        return Colors.grey;
    }
  }

  void _handleUserAction(UserModel user, String action) {
    switch (action) {
      case 'toggle_status':
        _toggleUserStatus(user);
        break;
      case 'view_details':
        _showUserDetails(user);
        break;
      case 'delete':
        _showDeleteConfirmation(user);
        break;
    }
  }

  Future<void> _toggleUserStatus(UserModel user) async {
    try {
      await _firestoreService.updateUser(user.id, {'isActive': !user.isActive});
      await _loadUsers();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(user.isActive ? 'تم تعطيل المستخدم' : 'تم تفعيل المستخدم'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = _errorHandler.handleGenericError(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: $errorMessage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showUserDetails(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تفاصيل ${user.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الاسم: ${user.name}'),
            Text('رقم الهاتف: ${user.phoneNumber}'),
            Text('المدينة: ${user.city}'),
            Text('نوع المستخدم: ${_getUserTypeText(user.userType)}'),
            Text('الحالة: ${user.isActive ? 'نشط' : 'غير نشط'}'),
            Text(
                'تاريخ التسجيل: ${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}'),
          ],
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

  void _showDeleteConfirmation(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف المستخدم "${user.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteUser(user);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteUser(UserModel user) async {
    try {
      await _firestoreService.deleteUser(user.id);
      await _loadUsers();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف المستخدم بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = _errorHandler.handleGenericError(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في حذف المستخدم: $errorMessage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
