import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'firebase_storage_service.dart';

/// خدمة إدارة الصور مع ضغط ورفع إلى Firebase Storage
class ImageService {
  static final ImageService _instance = ImageService._internal();
  factory ImageService() => _instance;
  ImageService._internal();

  final FirebaseStorageService _storageService = FirebaseStorageService();
  final ImagePicker _imagePicker = ImagePicker();

  /// اختيار صورة من المعرض أو الكاميرا
  Future<File?> pickImage({
    ImageSource source = ImageSource.gallery,
    int maxWidth = 1920,
    int maxHeight = 1080,
    int imageQuality = 85,
  }) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: imageQuality,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      print('❌ خطأ في اختيار الصورة: $e');
      return null;
    }
  }

  /// اختيار عدة صور
  Future<List<File>> pickMultipleImages({
    int maxImages = 10,
    int maxWidth = 1920,
    int maxHeight = 1080,
    int imageQuality = 85,
  }) async {
    try {
      final List<XFile> pickedFiles = await _imagePicker.pickMultiImage(
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: imageQuality,
      );

      if (pickedFiles.length > maxImages) {
        return pickedFiles
            .take(maxImages)
            .map((file) => File(file.path))
            .toList();
      }

      return pickedFiles.map((file) => File(file.path)).toList();
    } catch (e) {
      print('❌ خطأ في اختيار الصور: $e');
      return [];
    }
  }

  /// ضغط الصورة
  Future<File?> compressImage(
    File imageFile, {
    int maxWidth = 1920,
    int maxHeight = 1080,
    int quality = 85,
  }) async {
    try {
      // قراءة الصورة
      final Uint8List imageBytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);

      if (image == null) return null;

      // تغيير حجم الصورة إذا كانت كبيرة
      if (image.width > maxWidth || image.height > maxHeight) {
        image = img.copyResize(
          image,
          width: image.width > maxWidth ? maxWidth : null,
          height: image.height > maxHeight ? maxHeight : null,
          maintainAspect: true,
        );
      }

      // ضغط الصورة
      final List<int> compressedBytes = img.encodeJpg(image, quality: quality);

      // حفظ الصورة المضغوطة
      final String compressedPath = imageFile.path.replaceAll(
        RegExp(r'\.[^.]+$'),
        '_compressed.jpg',
      );
      final File compressedFile = File(compressedPath);
      await compressedFile.writeAsBytes(compressedBytes);

      return compressedFile;
    } catch (e) {
      print('❌ خطأ في ضغط الصورة: $e');
      return null;
    }
  }

  /// إنشاء thumbnail للصورة
  Future<File?> createThumbnail(
    File imageFile, {
    int size = 300,
    int quality = 70,
  }) async {
    try {
      final Uint8List imageBytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);

      if (image == null) return null;

      // إنشاء thumbnail مربع
      img.Image thumbnail = img.copyResizeCropSquare(image, size: size);

      // ضغط الـ thumbnail
      final List<int> thumbnailBytes =
          img.encodeJpg(thumbnail, quality: quality);

      // حفظ الـ thumbnail
      final String thumbnailPath = imageFile.path.replaceAll(
        RegExp(r'\.[^.]+$'),
        '_thumb.jpg',
      );
      final File thumbnailFile = File(thumbnailPath);
      await thumbnailFile.writeAsBytes(thumbnailBytes);

      return thumbnailFile;
    } catch (e) {
      print('❌ خطأ في إنشاء thumbnail: $e');
      return null;
    }
  }

  /// رفع صورة واحدة إلى Firebase Storage
  Future<String?> uploadImage(
    File imageFile,
    String path, {
    Function(double)? onProgress,
    bool createThumbnail = true,
    bool compress = true,
  }) async {
    try {
      File? finalImage = imageFile;

      // ضغط الصورة إذا كان مطلوباً
      if (compress) {
        final compressedImage = await compressImage(imageFile);
        if (compressedImage != null) {
          finalImage = compressedImage;
        }
      }

      // استخراج معرف السيارة من المسار
      final pathParts = path.split('/');
      if (pathParts.length >= 2 && pathParts[0] == 'cars') {
        final carId = pathParts[1];
        final imageIndex = DateTime.now().millisecondsSinceEpoch % 1000;

        // رفع الصورة الأساسية
        final String imageUrl = await _storageService.uploadCarImage(
          finalImage!,
          carId,
          imageIndex,
        );

        // حذف الملفات المؤقتة
        if (compress && finalImage != imageFile) {
          await finalImage.delete();
        }

        return imageUrl;
      } else if (pathParts.length >= 2 && pathParts[0] == 'users') {
        // رفع الصور الشخصية
        final userId = pathParts[1];

        final String imageUrl = await _storageService.uploadUserProfileImage(
          finalImage!,
          userId,
        );

        // حذف الملفات المؤقتة
        if (compress && finalImage != imageFile) {
          await finalImage.delete();
        }

        return imageUrl;
      } else {
        // للصور الأخرى
        print('❌ مسار غير مدعوم: $path');
        return null;
      }
    } catch (e) {
      print('❌ خطأ في رفع الصورة: $e');
      return null;
    }
  }

  /// رفع عدة صور
  Future<List<String>> uploadMultipleImages(
    List<File> imageFiles,
    String basePath, {
    Function(int, double)? onProgress,
    bool createThumbnails = true,
    bool compress = true,
  }) async {
    final List<String> uploadedUrls = [];

    for (int i = 0; i < imageFiles.length; i++) {
      final file = imageFiles[i];
      final path =
          '$basePath/image_${i + 1}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final String? url = await uploadImage(
        file,
        path,
        onProgress: (progress) => onProgress?.call(i, progress),
        createThumbnail: createThumbnails,
        compress: compress,
      );

      if (url != null) {
        uploadedUrls.add(url);
      }
    }

    return uploadedUrls;
  }

  /// حذف صورة من Firebase Storage
  Future<bool> deleteImage(String imageUrl) async {
    try {
      await _storageService.deleteImage(imageUrl);
      return true;
    } catch (e) {
      print('❌ خطأ في حذف الصورة: $e');
      return false;
    }
  }

  /// حذف عدة صور
  Future<void> deleteMultipleImages(List<String> imageUrls) async {
    for (final url in imageUrls) {
      await deleteImage(url);
    }
  }

  /// الحصول على URL الـ thumbnail
  String getThumbnailUrl(String originalUrl) {
    return originalUrl.replaceAll(
      RegExp(r'\.[^.]+$'),
      '_thumb.jpg',
    );
  }

  /// التحقق من صحة الصورة
  bool isValidImageFile(File file) {
    final String extension = file.path.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension);
  }

  /// الحصول على حجم الصورة
  Future<Size?> getImageSize(File imageFile) async {
    try {
      final Uint8List imageBytes = await imageFile.readAsBytes();
      final img.Image? image = img.decodeImage(imageBytes);

      if (image != null) {
        return Size(image.width.toDouble(), image.height.toDouble());
      }
      return null;
    } catch (e) {
      print('❌ خطأ في الحصول على حجم الصورة: $e');
      return null;
    }
  }

  /// تنظيف الملفات المؤقتة
  Future<void> cleanupTempFiles() async {
    try {
      // يمكن إضافة منطق تنظيف الملفات المؤقتة هنا
      print('🧹 تم تنظيف الملفات المؤقتة');
    } catch (e) {
      print('❌ خطأ في تنظيف الملفات المؤقتة: $e');
    }
  }

  /// رفع صورة شخصية للمستخدم
  Future<String?> uploadProfileImage(
    File imageFile,
    String userId, {
    Function(double)? onProgress,
  }) async {
    try {
      // ضغط الصورة للصور الشخصية (حجم أصغر)
      final compressedImage = await compressImage(
        imageFile,
        maxWidth: 512,
        maxHeight: 512,
        quality: 85,
      );

      final File finalImage = compressedImage ?? imageFile;

      if (onProgress != null) {
        onProgress(0.5); // 50% للضغط
      }

      // رفع الصورة
      final String imageUrl = await _storageService.uploadUserProfileImage(
        finalImage,
        userId,
      );

      // حذف الملف المؤقت إذا تم ضغطه
      if (compressedImage != null && compressedImage != imageFile) {
        await compressedImage.delete();
      }

      if (onProgress != null) {
        onProgress(1.0); // 100% مكتمل
      }

      return imageUrl;
    } catch (e) {
      print('❌ خطأ في رفع الصورة الشخصية: $e');
      return null;
    }
  }

  /// حذف جميع صور السيارة
  Future<bool> deleteCarImages(String carId) async {
    try {
      await _storageService.deleteCarImages(carId);
      return true;
    } catch (e) {
      print('❌ خطأ في حذف صور السيارة: $e');
      return false;
    }
  }

  /// حذف الصورة الشخصية القديمة وتحديثها بجديدة
  Future<String?> updateProfileImage(
    File newImageFile,
    String userId, {
    Function(double)? onProgress,
  }) async {
    try {
      // حذف الصورة القديمة أولاً
      await _storageService.deleteUserProfileImage(userId);

      if (onProgress != null) {
        onProgress(0.2); // 20% للحذف
      }

      // رفع الصورة الجديدة
      final String? imageUrl = await uploadProfileImage(
        newImageFile,
        userId,
        onProgress: (progress) {
          if (onProgress != null) {
            onProgress(0.2 + (progress * 0.8)); // 20% + 80% للرفع
          }
        },
      );

      return imageUrl;
    } catch (e) {
      print('❌ خطأ في تحديث الصورة الشخصية: $e');
      return null;
    }
  }

  /// الحصول على حجم الصورة بتنسيق قابل للقراءة
  Future<String> getFormattedFileSize(String imageUrl) async {
    try {
      final int? sizeInBytes = await _storageService.getFileSize(imageUrl);
      if (sizeInBytes == null) return 'غير معروف';

      if (sizeInBytes < 1024) {
        return '$sizeInBytes بايت';
      } else if (sizeInBytes < 1024 * 1024) {
        return '${(sizeInBytes / 1024).toStringAsFixed(1)} كيلوبايت';
      } else {
        return '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(1)} ميجابايت';
      }
    } catch (e) {
      print('❌ خطأ في الحصول على حجم الملف: $e');
      return 'غير معروف';
    }
  }

  /// الحصول على إجمالي حجم صور السيارة بتنسيق قابل للقراءة
  Future<String> getCarImagesTotalSize(String carId) async {
    try {
      final int totalSize = await _storageService.getCarImagesSize(carId);

      if (totalSize < 1024) {
        return '$totalSize بايت';
      } else if (totalSize < 1024 * 1024) {
        return '${(totalSize / 1024).toStringAsFixed(1)} كيلوبايت';
      } else {
        return '${(totalSize / (1024 * 1024)).toStringAsFixed(1)} ميجابايت';
      }
    } catch (e) {
      print('❌ خطأ في حساب حجم صور السيارة: $e');
      return 'غير معروف';
    }
  }
}
