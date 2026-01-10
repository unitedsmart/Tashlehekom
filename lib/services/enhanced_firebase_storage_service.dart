import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// خدمة Firebase Storage المحسنة لإدارة الصور والملفات
class EnhancedFirebaseStorageService {
  // Singleton pattern
  static final EnhancedFirebaseStorageService _instance =
      EnhancedFirebaseStorageService._internal();
  
  EnhancedFirebaseStorageService._internal();
  
  factory EnhancedFirebaseStorageService() => _instance;

  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// رفع صورة سيارة مع تتبع التقدم
  Future<String> uploadCarImage(
    File imageFile,
    String carId,
    int imageIndex, {
    Function(double)? onProgress,
  }) async {
    try {
      _log('📤 بدء رفع صورة السيارة...');

      // التحقق من توفر Storage (يتطلب Blaze Plan)
      try {
        // ضغط الصورة قبل الرفع
        final compressedImage = await _compressImage(imageFile);

        // إنشاء مسار الملف
        final fileName = 'car_${carId}_image_$imageIndex.jpg';
        final filePath = 'cars/$carId/$fileName';

        // رفع الصورة
        final ref = _storage.ref().child(filePath);
        final uploadTask = ref.putData(
          compressedImage,
          SettableMetadata(
            contentType: 'image/jpeg',
            customMetadata: {
              'carId': carId,
              'imageIndex': imageIndex.toString(),
              'uploadedAt': DateTime.now().toIso8601String(),
            },
          ),
        );

        // تتبع التقدم
        if (onProgress != null) {
          uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
            final progress = snapshot.bytesTransferred / snapshot.totalBytes;
            onProgress(progress);
          });
        }

        // انتظار اكتمال الرفع
        final snapshot = await uploadTask;

        // الحصول على رابط التحميل
        final downloadUrl = await snapshot.ref.getDownloadURL();

        _log('✅ تم رفع صورة السيارة بنجاح: $downloadUrl');
        return downloadUrl;
      } catch (storageError) {
        _log('⚠️ Storage غير متاح (يتطلب Blaze Plan): $storageError');
        // حفظ الصورة محلياً كبديل
        return await _saveImageLocally(imageFile, carId, imageIndex);
      }
    } catch (e) {
      _log('❌ خطأ في رفع صورة السيارة: $e');
      rethrow;
    }
  }

  /// رفع صورة شخصية للمستخدم
  Future<String> uploadUserProfileImage(
    File imageFile,
    String userId, {
    Function(double)? onProgress,
  }) async {
    try {
      _log('📤 بدء رفع الصورة الشخصية...');

      // ضغط الصورة قبل الرفع
      final compressedImage = await _compressImage(
        imageFile,
        maxWidth: 300,
        maxHeight: 300,
      );

      // إنشاء مسار الملف
      final fileName = 'profile_$userId.jpg';
      final filePath = 'users/$userId/$fileName';

      // رفع الصورة
      final ref = _storage.ref().child(filePath);
      final uploadTask = ref.putData(
        compressedImage,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'userId': userId,
            'type': 'profile',
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      // تتبع التقدم
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      // انتظار اكتمال الرفع
      final snapshot = await uploadTask;

      // الحصول على رابط التحميل
      final downloadUrl = await snapshot.ref.getDownloadURL();

      _log('✅ تم رفع الصورة الشخصية بنجاح: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      _log('❌ خطأ في رفع الصورة الشخصية: $e');
      rethrow;
    }
  }

  /// رفع مرفق للبلاغ
  Future<String> uploadReportAttachment(
    File file,
    String reportId, {
    Function(double)? onProgress,
  }) async {
    try {
      _log('📤 بدء رفع مرفق البلاغ...');

      final fileExtension = path.extension(file.path);
      final fileName =
          'report_${reportId}_${DateTime.now().millisecondsSinceEpoch}$fileExtension';
      final filePath = 'reports/$reportId/$fileName';

      // تحديد نوع المحتوى
      final contentType = _getContentType(fileExtension);

      final ref = _storage.ref().child(filePath);
      UploadTask uploadTask;

      if (contentType.startsWith('image/')) {
        // ضغط الصورة إذا كانت صورة
        final compressedImage = await _compressImage(file);
        uploadTask = ref.putData(
          compressedImage,
          SettableMetadata(contentType: contentType),
        );
      } else {
        // رفع الملف كما هو إذا لم يكن صورة
        uploadTask = ref.putFile(
          file,
          SettableMetadata(contentType: contentType),
        );
      }

      // تتبع التقدم
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      _log('✅ تم رفع مرفق البلاغ بنجاح: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      _log('❌ خطأ في رفع مرفق البلاغ: $e');
      rethrow;
    }
  }

  /// حذف صورة من Storage
  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      _log('✅ تم حذف الصورة بنجاح');
    } catch (e) {
      _log('❌ خطأ في حذف الصورة: $e');
      // لا نرمي الخطأ هنا لأن حذف الصورة قد يفشل إذا كانت محذوفة مسبقاً
    }
  }

  /// حذف جميع صور السيارة
  Future<void> deleteCarImages(String carId) async {
    try {
      _log('🗑️ بدء حذف صور السيارة: $carId');

      final carRef = _storage.ref().child('cars/$carId');
      final result = await carRef.listAll();

      var deletedCount = 0;
      for (final ref in result.items) {
        await ref.delete();
        deletedCount++;
        _log('🗑️ تم حذف: ${ref.name}');
      }

      _log('✅ تم حذف $deletedCount صورة للسيارة بنجاح');
    } catch (e) {
      _log('❌ خطأ في حذف صور السيارة: $e');
    }
  }

  /// الحصول على معلومات الملف
  Future<FullMetadata?> getFileMetadata(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      return await ref.getMetadata();
    } catch (e) {
      _log('❌ خطأ في الحصول على معلومات الملف: $e');
      return null;
    }
  }

  /// ضغط الصورة
  Future<Uint8List> _compressImage(
    File imageFile, {
    int maxWidth = 800,
    int maxHeight = 600,
    int quality = 85,
  }) async {
    try {
      // قراءة الصورة
      final imageBytes = await imageFile.readAsBytes();
      var image = img.decodeImage(imageBytes);

      if (image == null) {
        throw Exception('فشل في قراءة الصورة');
      }

      // تغيير حجم الصورة إذا كانت أكبر من الحد المسموح
      if (image.width > maxWidth || image.height > maxHeight) {
        image = img.copyResize(
          image,
          width: image.width > maxWidth ? maxWidth : null,
          height: image.height > maxHeight ? maxHeight : null,
          maintainAspect: true,
        );
      }

      // ضغط الصورة وتحويلها إلى JPEG
      final compressedBytes = Uint8List.fromList(
        img.encodeJpg(image, quality: quality),
      );

      _log('📊 حجم الصورة الأصلي: ${imageBytes.length} bytes');
      _log('📊 حجم الصورة المضغوطة: ${compressedBytes.length} bytes');
      _log('📊 نسبة الضغط: ${((1 - compressedBytes.length / imageBytes.length) * 100).toStringAsFixed(1)}%');

      return compressedBytes;
    } catch (e) {
      _log('❌ خطأ في ضغط الصورة: $e');
      // في حالة فشل الضغط، إرجاع الصورة الأصلية
      return await imageFile.readAsBytes();
    }
  }

  /// تحديد نوع المحتوى بناءً على امتداد الملف
  String _getContentType(String fileExtension) {
    switch (fileExtension.toLowerCase()) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.webp':
        return 'image/webp';
      case '.pdf':
        return 'application/pdf';
      case '.doc':
        return 'application/msword';
      case '.docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case '.txt':
        return 'text/plain';
      default:
        return 'application/octet-stream';
    }
  }

  /// حفظ الصورة محلياً كبديل لـ Storage
  Future<String> _saveImageLocally(
    File imageFile,
    String carId,
    int imageIndex,
  ) async {
    try {
      // الحصول على مجلد التطبيق
      final appDir = await getApplicationDocumentsDirectory();
      final carImagesDir = Directory('${appDir.path}/car_images/$carId');

      // إنشاء المجلد إذا لم يكن موجوداً
      if (!await carImagesDir.exists()) {
        await carImagesDir.create(recursive: true);
      }

      // نسخ الصورة إلى المجلد المحلي
      final fileName = 'car_${carId}_image_$imageIndex.jpg';
      final localImagePath = '${carImagesDir.path}/$fileName';
      await imageFile.copy(localImagePath);

      _log('💾 تم حفظ الصورة محلياً: $localImagePath');
      return localImagePath;
    } catch (e) {
      _log('❌ خطأ في حفظ الصورة محلياً: $e');
      rethrow;
    }
  }

  /// دالة للطباعة (تستخدم debugPrint في وضع التطوير)
  void _log(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }
}
