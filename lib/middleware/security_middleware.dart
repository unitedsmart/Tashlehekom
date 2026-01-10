import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../providers/firebase_auth_provider.dart';
import '../services/security_service.dart';
import '../services/activity_monitor_service.dart';

/// Middleware للتحقق من الأمان والصلاحيات
class SecurityMiddleware {
  static final SecurityService _securityService = SecurityService();
  static final ActivityMonitorService _activityMonitor = ActivityMonitorService();

  /// التحقق من صلاحية المستخدم للوصول إلى صفحة معينة
  static Future<bool> checkPageAccess(
    BuildContext context,
    String pageName,
    {String? requiredPermission}
  ) async {
    try {
      final authProvider = Provider.of<FirebaseAuthProvider>(context, listen: false);
      final user = authProvider.currentUser;

      // التحقق من تسجيل الدخول
      if (user == null) {
        _showAccessDeniedDialog(context, 'يجب تسجيل الدخول أولاً');
        return false;
      }

      // التحقق من الصلاحيات المطلوبة
      if (requiredPermission != null) {
        if (!_securityService.hasPermission(user, requiredPermission)) {
          await _activityMonitor.logUnauthorizedAccess(
            user.id,
            'attempted_access_$pageName',
            {'permission': requiredPermission}
          );
          _showAccessDeniedDialog(context, 'ليس لديك صلاحية للوصول إلى هذه الصفحة');
          return false;
        }
      }

      // تسجيل الوصول الناجح
      await _activityMonitor.logUserActivity(user.id, 'page_access', metadata: {
        'pageName': pageName,
        'permission': requiredPermission,
      });

      return true;
    } catch (e) {
      _showAccessDeniedDialog(context, 'خطأ في التحقق من الصلاحيات');
      return false;
    }
  }

  /// التحقق من إمكانية تنفيذ عملية معينة
  static Future<bool> checkActionPermission(
    BuildContext context,
    String action,
    {Map<String, dynamic>? metadata}
  ) async {
    try {
      final authProvider = Provider.of<FirebaseAuthProvider>(context, listen: false);
      final user = authProvider.currentUser;

      if (user == null) {
        _showAccessDeniedDialog(context, 'يجب تسجيل الدخول أولاً');
        return false;
      }

      // التحقق من القيود المطبقة على المستخدم
      if (await _activityMonitor.isUserRestricted(user.id, action)) {
        _showAccessDeniedDialog(context, 'تم تقييد هذا الإجراء مؤقتاً بسبب نشاط مشبوه');
        return false;
      }

      // التحقق من الصلاحيات حسب نوع العملية
      String? requiredPermission = _getRequiredPermissionForAction(action);
      if (requiredPermission != null && !_securityService.hasPermission(user, requiredPermission)) {
        await _activityMonitor.logUnauthorizedAccess(
          user.id,
          'attempted_action_$action',
          metadata ?? {}
        );
        _showAccessDeniedDialog(context, 'ليس لديك صلاحية لتنفيذ هذا الإجراء');
        return false;
      }

      // تسجيل العملية
      await _activityMonitor.logUserActivity(user.id, action, metadata: metadata);

      return true;
    } catch (e) {
      _showAccessDeniedDialog(context, 'خطأ في التحقق من الصلاحيات');
      return false;
    }
  }

  /// التحقق من صحة البيانات المدخلة
  static bool validateInput(String input, String inputType) {
    switch (inputType) {
      case 'phone':
        return _securityService.isValidSaudiPhoneNumber(input);
      case 'email':
        return _securityService.isValidEmail(input);
      default:
        return _securityService.sanitizeInput(input) == input;
    }
  }

  /// التحقق من صحة الملف المرفوع
  static bool validateFile(String fileName, int fileSize) {
    return _securityService.isValidFileType(fileName) && 
           _securityService.isValidFileSize(fileSize);
  }

  /// الحصول على الصلاحية المطلوبة لعملية معينة
  static String? _getRequiredPermissionForAction(String action) {
    switch (action) {
      case 'car_upload':
      case 'add_car':
        return 'add_car';
      case 'car_edit':
      case 'edit_car':
        return 'edit_car';
      case 'car_delete':
      case 'delete_car':
        return 'delete_car';
      case 'user_management':
        return 'manage_users';
      case 'view_analytics':
        return 'view_analytics';
      case 'system_settings':
        return 'system_settings';
      default:
        return null;
    }
  }

  /// عرض رسالة رفض الوصول
  static void _showAccessDeniedDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.security, color: Colors.red),
            SizedBox(width: 8),
            Text('تم رفض الوصول'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }
}

/// Widget للحماية من الوصول غير المصرح به
class SecurePageWrapper extends StatelessWidget {
  final Widget child;
  final String pageName;
  final String? requiredPermission;
  final Widget? fallbackWidget;

  const SecurePageWrapper({
    super.key,
    required this.child,
    required this.pageName,
    this.requiredPermission,
    this.fallbackWidget,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: SecurityMiddleware.checkPageAccess(
        context,
        pageName,
        requiredPermission: requiredPermission,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError || !(snapshot.data ?? false)) {
          return fallbackWidget ?? const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.security,
                    size: 64,
                    color: Colors.red,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'ليس لديك صلاحية للوصول إلى هذه الصفحة',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return child;
      },
    );
  }
}

/// Widget للحماية من تنفيذ عمليات غير مصرح بها
class SecureActionButton extends StatelessWidget {
  final Widget child;
  final String action;
  final VoidCallback onPressed;
  final Map<String, dynamic>? metadata;

  const SecureActionButton({
    super.key,
    required this.child,
    required this.action,
    required this.onPressed,
    this.metadata,
  });

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return GestureDetector(
          onTap: () async {
            final hasPermission = await SecurityMiddleware.checkActionPermission(
              context,
              action,
              metadata: metadata,
            );
            
            if (hasPermission) {
              onPressed();
            }
          },
          child: child,
        );
      },
    );
  }
}

/// Mixin للصفحات التي تحتاج حماية أمنية
mixin SecurePageMixin<T extends StatefulWidget> on State<T> {
  
  /// التحقق من الصلاحيات عند بناء الصفحة
  Future<bool> checkPageSecurity(String pageName, {String? requiredPermission}) async {
    return await SecurityMiddleware.checkPageAccess(
      context,
      pageName,
      requiredPermission: requiredPermission,
    );
  }

  /// التحقق من إمكانية تنفيذ عملية
  Future<bool> checkActionSecurity(String action, {Map<String, dynamic>? metadata}) async {
    return await SecurityMiddleware.checkActionPermission(
      context,
      action,
      metadata: metadata,
    );
  }

  /// تسجيل نشاط المستخدم
  Future<void> logUserActivity(String activityType, {Map<String, dynamic>? metadata}) async {
    final authProvider = Provider.of<FirebaseAuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    
    if (user != null) {
      await ActivityMonitorService().logUserActivity(
        user.id,
        activityType,
        metadata: metadata,
      );
    }
  }
}
