import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:tashlehekomv2/providers/firebase_auth_provider.dart';
import 'package:tashlehekomv2/models/user_model.dart';
import 'package:tashlehekomv2/services/image_service.dart';
import 'package:tashlehekomv2/services/firebase_storage_service.dart';
import 'package:tashlehekomv2/widgets/firebase_image_widget.dart';

import 'package:tashlehekomv2/screens/auth/login_screen.dart';
import 'package:tashlehekomv2/screens/auth/register_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _cityController = TextEditingController();
  final _junkyardController = TextEditingController();

  final ImageService _imageService = ImageService();
  final FirebaseStorageService _storageService = FirebaseStorageService();

  bool _isLoading = false;
  bool _isUploadingImage = false;
  double _uploadProgress = 0.0;
  String _uploadStatus = '';
  File? _selectedImage;
  String? _currentProfileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    _junkyardController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final authProvider =
        Provider.of<FirebaseAuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user != null) {
      _nameController.text = user.name;
      _usernameController.text = user.username;
      _emailController.text = user.email ?? '';
      _cityController.text = user.city ?? '';
      _junkyardController.text = user.junkyard ?? '';

      // TODO: Load profile image URL from user data
      // _currentProfileImageUrl = user.profileImageUrl;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveProfile,
          ),
        ],
      ),
      body: Consumer<FirebaseAuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.currentUser;

          if (user == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.person_outline,
                        size: 72, color: Colors.grey),
                    const SizedBox(height: 12),
                    const Text(
                      'للوصول إلى الملف الشخصي، يرجى تسجيل الدخول أو إنشاء حساب جديد',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.login),
                        label: const Text('تسجيل الدخول'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.person_add),
                        label: const Text('إنشاء حساب جديد'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Image Section
                  _buildProfileImageSection(),

                  const SizedBox(height: 24),

                  // Upload Progress
                  if (_isUploadingImage) _buildUploadProgress(),

                  // User Info Section
                  _buildUserInfoSection(user),

                  const SizedBox(height: 32),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text('جاري الحفظ...'),
                              ],
                            )
                          : const Text(
                              'حفظ التغييرات',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileImageSection() {
    return Center(
      child: Column(
        children: [
          // Profile Image
          GestureDetector(
            onTap: _isUploadingImage ? null : _pickProfileImage,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blue, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipOval(
                child: _selectedImage != null
                    ? Image.file(
                        _selectedImage!,
                        fit: BoxFit.cover,
                      )
                    : _currentProfileImageUrl != null &&
                            _currentProfileImageUrl!.isNotEmpty
                        ? FirebaseImageWidget(
                            imageUrl: _currentProfileImageUrl!,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.grey,
                            ),
                          ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Change Photo Button
          TextButton.icon(
            onPressed: _isUploadingImage ? null : _pickProfileImage,
            icon: const Icon(Icons.camera_alt),
            label: const Text('تغيير الصورة'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadProgress() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        children: [
          Text(
            _uploadStatus,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _uploadProgress,
            backgroundColor: Colors.grey.shade300,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          const SizedBox(height: 4),
          Text(
            '${(_uploadProgress * 100).toInt()}%',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoSection(UserModel user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'المعلومات الشخصية',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Name Field
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'الاسم الكامل',
            prefixIcon: Icon(Icons.person),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'يرجى إدخال الاسم الكامل';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // Username Field
        TextFormField(
          controller: _usernameController,
          decoration: const InputDecoration(
            labelText: 'اسم المستخدم',
            prefixIcon: Icon(Icons.alternate_email),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'يرجى إدخال اسم المستخدم';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // Phone Number (Read Only)
        TextFormField(
          initialValue: user.phoneNumber,
          decoration: const InputDecoration(
            labelText: 'رقم الهاتف',
            prefixIcon: Icon(Icons.phone),
            border: OutlineInputBorder(),
          ),
          enabled: false,
        ),

        const SizedBox(height: 16),

        // Email Field
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'البريد الإلكتروني (اختياري)',
            prefixIcon: Icon(Icons.email),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(value)) {
                return 'يرجى إدخال بريد إلكتروني صحيح';
              }
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // City Field
        TextFormField(
          controller: _cityController,
          decoration: const InputDecoration(
            labelText: 'المدينة (اختياري)',
            prefixIcon: Icon(Icons.location_city),
            border: OutlineInputBorder(),
          ),
        ),

        // Junkyard Field (for workers only)
        if (user.userType == UserType.worker) ...[
          const SizedBox(height: 16),
          TextFormField(
            controller: _junkyardController,
            decoration: const InputDecoration(
              labelText: 'اسم التشليح',
              prefixIcon: Icon(Icons.business),
              border: OutlineInputBorder(),
            ),
          ),
        ],

        const SizedBox(height: 16),

        // User Type (Read Only)
        TextFormField(
          initialValue: _getUserTypeText(user.userType),
          decoration: const InputDecoration(
            labelText: 'نوع الحساب',
            prefixIcon: Icon(Icons.account_circle),
            border: OutlineInputBorder(),
          ),
          enabled: false,
        ),

        const SizedBox(height: 20),

        // زر طلب التفعيل لمالك التشليح
        if (user.userType == UserType.junkyardOwner && !user.isApproved) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.pending_actions,
                  color: Colors.orange,
                  size: 32,
                ),
                const SizedBox(height: 8),
                const Text(
                  'حسابك قيد المراجعة',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'يرجى انتظار موافقة الإدارة لتفعيل حسابك',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _requestActivation,
                  icon: const Icon(Icons.send),
                  label: const Text('طلب التفعيل'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // معلومات الحساب المفعل
        if (user.isApproved) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.verified,
                  color: Colors.green,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'حسابك مفعل ويمكنك إضافة السيارات',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  String _getUserTypeText(UserType userType) {
    switch (userType) {
      case UserType.user:
        return 'مستخدم عادي';
      case UserType.seller:
        return 'بائع';
      case UserType.admin:
        return 'مدير';
      case UserType.individual:
        return 'فرد';
      case UserType.worker:
        return 'عامل تشليح';
      case UserType.junkyardOwner:
        return 'صاحب تشليح';
      case UserType.superAdmin:
        return 'مدير عام';
    }
  }

  /// طلب تفعيل الحساب لمالك التشليح
  Future<void> _requestActivation() async {
    final authProvider =
        Provider.of<FirebaseAuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user == null) return;

    try {
      // إظهار حوار تأكيد
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('طلب تفعيل الحساب'),
          content: const Text(
            'سيتم إرسال طلب تفعيل حسابك إلى الإدارة. '
            'ستتلقى إشعاراً عند الموافقة على طلبك.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('إرسال الطلب'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      // إظهار مؤشر التحميل
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      // محاكاة إرسال الطلب (يمكن ربطه بـ Firebase Functions أو API)
      await Future.delayed(const Duration(seconds: 2));

      // إغلاق مؤشر التحميل
      if (mounted) {
        Navigator.of(context).pop();
      }

      // إظهار رسالة نجاح
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إرسال طلب التفعيل بنجاح'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // إغلاق مؤشر التحميل في حالة الخطأ
      if (mounted) {
        Navigator.of(context).pop();
      }

      // إظهار رسالة خطأ
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickProfileImage() async {
    try {
      final File? image = await _imageService.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في اختيار الصورة: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider =
          Provider.of<FirebaseAuthProvider>(context, listen: false);
      final currentUser = authProvider.currentUser!;

      // Upload profile image if selected
      String? profileImageUrl = _currentProfileImageUrl;
      if (_selectedImage != null) {
        setState(() {
          _isUploadingImage = true;
          _uploadStatus = 'جاري رفع الصورة الشخصية...';
          _uploadProgress = 0.0;
        });

        profileImageUrl = await _imageService.uploadProfileImage(
          _selectedImage!,
          currentUser.id,
          onProgress: (progress) {
            setState(() {
              _uploadProgress = progress;
            });
          },
        );

        setState(() {
          _isUploadingImage = false;
          _currentProfileImageUrl = profileImageUrl;
          _selectedImage = null;
        });
      }

      // Update user data
      final updatedUser = currentUser.copyWith(
        name: _nameController.text.trim(),
        username: _usernameController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        city: _cityController.text.trim().isEmpty
            ? null
            : _cityController.text.trim(),
        junkyard: _junkyardController.text.trim().isEmpty
            ? null
            : _junkyardController.text.trim(),
        updatedAt: DateTime.now(),
      );

      await authProvider.updateUser(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ التغييرات بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في حفظ البيانات: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isUploadingImage = false;
        });
      }
    }
  }
}
