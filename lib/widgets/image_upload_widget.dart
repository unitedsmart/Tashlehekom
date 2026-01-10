import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/enhanced_firebase_storage_service.dart';

/// ويدجت لرفع الصور مع شريط التقدم
class ImageUploadWidget extends StatefulWidget {
  final String carId;
  final int imageIndex;
  final Function(String imageUrl) onImageUploaded;
  final String? initialImageUrl;

  const ImageUploadWidget({
    super.key,
    required this.carId,
    required this.imageIndex,
    required this.onImageUploaded,
    this.initialImageUrl,
  });

  @override
  State<ImageUploadWidget> createState() => _ImageUploadWidgetState();
}

class _ImageUploadWidgetState extends State<ImageUploadWidget> {
  final ImagePicker _picker = ImagePicker();
  final EnhancedFirebaseStorageService _storageService =
      EnhancedFirebaseStorageService();

  File? _selectedImage;
  String? _imageUrl;
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _imageUrl = widget.initialImageUrl;
  }

  /// اختيار صورة من المعرض أو الكاميرا
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 90,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
        await _uploadImage();
      }
    } catch (e) {
      _showErrorSnackBar('خطأ في اختيار الصورة: $e');
    }
  }

  /// رفع الصورة إلى Firebase Storage
  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      final imageUrl = await _storageService.uploadCarImage(
        _selectedImage!,
        widget.carId,
        widget.imageIndex,
        onProgress: (progress) {
          setState(() {
            _uploadProgress = progress;
          });
        },
      );

      setState(() {
        _imageUrl = imageUrl;
        _isUploading = false;
      });

      widget.onImageUploaded(imageUrl);
      _showSuccessSnackBar('تم رفع الصورة بنجاح!');
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      _showErrorSnackBar('خطأ في رفع الصورة: $e');
    }
  }

  /// حذف الصورة
  Future<void> _deleteImage() async {
    if (_imageUrl == null) return;

    try {
      await _storageService.deleteImage(_imageUrl!);
      setState(() {
        _imageUrl = null;
        _selectedImage = null;
      });
      _showSuccessSnackBar('تم حذف الصورة بنجاح!');
    } catch (e) {
      _showErrorSnackBar('خطأ في حذف الصورة: $e');
    }
  }

  /// عرض رسالة نجاح
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// عرض رسالة خطأ
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// عرض خيارات اختيار الصورة
  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('اختيار من المعرض'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('التقاط صورة'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              if (_imageUrl != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('حذف الصورة', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    _deleteImage();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          // عرض الصورة أو أيقونة الإضافة
          if (_imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _imageUrl!.startsWith('http')
                  ? Image.network(
                      _imageUrl!,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(Icons.error, color: Colors.red),
                        );
                      },
                    )
                  : Image.file(
                      File(_imageUrl!),
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(Icons.error, color: Colors.red),
                        );
                      },
                    ),
            )
          else
            InkWell(
              onTap: _isUploading ? null : _showImageSourceDialog,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo, size: 32, color: Colors.grey),
                    SizedBox(height: 4),
                    Text('إضافة صورة', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ),

          // شريط التقدم أثناء الرفع
          if (_isUploading)
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    value: _uploadProgress,
                    backgroundColor: Colors.white30,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(_uploadProgress * 100).toInt()}%',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),

          // زر التعديل للصور الموجودة
          if (_imageUrl != null && !_isUploading)
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: _showImageSourceDialog,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
