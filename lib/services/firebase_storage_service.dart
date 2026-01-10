import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// خدمة Firebase Storage لإدارة الصور والملفات
class FirebaseStorageService {
  static final FirebaseStorageService _instance =
      FirebaseStorageService._internal();
  factory FirebaseStorageService() => _instance;
  FirebaseStorageService._internal();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// رفع صورة سيارة
  Future<String> uploadCarImage(
      File imageFile, String carId, int imageIndex) async {
    try {
      print('📤 بدء رفع صورة السيارة...');

      // التحقق من توفر Storage (يتطلب Blaze Plan)
      try {
        // ضغط الصورة قبل الرفع
        Uint8List compressedImage = await _compressImage(imageFile);

        // إنشاء مسار الملف
        String fileName = 'car_${carId}_image_$imageIndex.jpg';
        String filePath = 'cars/$carId/$fileName';

        // رفع الصورة
        Reference ref = _storage.ref().child(filePath);
        UploadTask uploadTask = ref.putData(
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

        // انتظار اكتمال الرفع
        TaskSnapshot snapshot = await uploadTask;

        // الحصول على رابط التحميل
        String downloadUrl = await snapshot.ref.getDownloadURL();

        print('✅ تم رفع صورة السيارة بنجاح: $downloadUrl');
        return downloadUrl;
      } catch (storageError) {
        print('⚠️ Storage غير متاح (يتطلب Blaze Plan): $storageError');
        // حفظ الصورة محلياً كبديل
        return await _saveImageLocally(imageFile, carId, imageIndex);
      }
    } catch (e) {
      print('❌ خطأ في رفع صورة السيارة: $e');
      rethrow;
    }
  }

  /// رفع صورة شخصية للمستخدم
  Future<String> uploadUserProfileImage(File imageFile, String userId) async {
    try {
      print('📤 بدء رفع الصورة الشخصية...');

      // ضغط الصورة قبل الرفع
      Uint8List compressedImage =
          await _compressImage(imageFile, maxWidth: 300, maxHeight: 300);

      // إنشاء مسار الملف
      String fileName = 'profile_$userId.jpg';
      String filePath = 'users/$userId/$fileName';

      // رفع الصورة
      Reference ref = _storage.ref().child(filePath);
      UploadTask uploadTask = ref.putData(
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

      // انتظار اكتمال الرفع
      TaskSnapshot snapshot = await uploadTask;

      // الحصول على رابط التحميل
      String downloadUrl = await snapshot.ref.getDownloadURL();

      print('✅ تم رفع الصورة الشخصية بنجاح: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('❌ خطأ في رفع الصورة الشخصية: $e');
      rethrow;
    }
  }

  /// رفع مرفق للبلاغ
  Future<String> uploadReportAttachment(File file, String reportId) async {
    try {
      print('📤 بدء رفع مرفق البلاغ...');

      String fileExtension = path.extension(file.path);
      String fileName =
          'report_${reportId}_${DateTime.now().millisecondsSinceEpoch}$fileExtension';
      String filePath = 'reports/$reportId/$fileName';

      // تحديد نوع المحتوى
      String contentType = _getContentType(fileExtension);

      Reference ref = _storage.ref().child(filePath);
      UploadTask uploadTask;

      if (contentType.startsWith('image/')) {
        // ضغط الصورة إذا كانت صورة
        Uint8List compressedImage = await _compressImage(file);
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

      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      print('✅ تم رفع مرفق البلاغ بنجاح: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('❌ خطأ في رفع مرفق البلاغ: $e');
      rethrow;
    }
  }

  /// حذف صورة من Storage
  Future<void> deleteImage(String imageUrl) async {
    try {
      Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      print('✅ تم حذف الصورة بنجاح');
    } catch (e) {
      print('❌ خطأ في حذف الصورة: $e');
      // لا نرمي الخطأ هنا لأن حذف الصورة قد يفشل إذا كانت محذوفة مسبقاً
    }
  }

  /// حذف جميع صور السيارة
  Future<void> deleteCarImages(String carId) async {
    try {
      print('🗑️ بدء حذف صور السيارة: $carId');

      Reference carRef = _storage.ref().child('cars/$carId');
      ListResult result = await carRef.listAll();

      int deletedCount = 0;
      for (Reference ref in result.items) {
        await ref.delete();
        deletedCount++;
        print('🗑️ تم حذف: ${ref.name}');
      }

      print('✅ تم حذف $deletedCount صورة للسيارة بنجاح');
    } catch (e) {
      print('❌ خطأ في حذف صور السيارة: $e');
    }
  }

  /// حذف الصورة الشخصية القديمة للمستخدم
  Future<void> deleteUserProfileImage(String userId) async {
    try {
      print('🗑️ بدء حذف الصورة الشخصية للمستخدم: $userId');

      String fileName = 'profile_$userId.jpg';
      String filePath = 'users/$userId/$fileName';

      Reference ref = _storage.ref().child(filePath);
      await ref.delete();

      print('✅ تم حذف الصورة الشخصية بنجاح');
    } catch (e) {
      print('❌ خطأ في حذف الصورة الشخصية: $e');
      // لا نرمي خطأ هنا لأن الصورة قد لا تكون موجودة
    }
  }

  /// الحصول على معلومات الملف
  Future<FullMetadata?> getFileMetadata(String imageUrl) async {
    try {
      Reference ref = _storage.refFromURL(imageUrl);
      return await ref.getMetadata();
    } catch (e) {
      print('❌ خطأ في الحصول على معلومات الملف: $e');
      return null;
    }
  }

  /// الحصول على حجم الملف بالبايت
  Future<int?> getFileSize(String imageUrl) async {
    try {
      final metadata = await getFileMetadata(imageUrl);
      return metadata?.size;
    } catch (e) {
      print('❌ خطأ في الحصول على حجم الملف: $e');
      return null;
    }
  }

  /// الحصول على إجمالي حجم صور السيارة
  Future<int> getCarImagesSize(String carId) async {
    try {
      Reference carRef = _storage.ref().child('cars/$carId');
      ListResult result = await carRef.listAll();

      int totalSize = 0;
      for (Reference ref in result.items) {
        final metadata = await ref.getMetadata();
        totalSize += metadata.size ?? 0;
      }

      return totalSize;
    } catch (e) {
      print('❌ خطأ في حساب حجم صور السيارة: $e');
      return 0;
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
      Uint8List imageBytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);

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
      Uint8List compressedBytes = Uint8List.fromList(
        img.encodeJpg(image, quality: quality),
      );

      print('📊 حجم الصورة الأصلي: ${imageBytes.length} bytes');
      print('📊 حجم الصورة المضغوطة: ${compressedBytes.length} bytes');
      print(
          '📊 نسبة الضغط: ${((1 - compressedBytes.length / imageBytes.length) * 100).toStringAsFixed(1)}%');

      return compressedBytes;
    } catch (e) {
      print('❌ خطأ في ضغط الصورة: $e');
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
      File imageFile, String carId, int imageIndex) async {
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

      print('💾 تم حفظ الصورة محلياً: $localImagePath');
      return localImagePath;
    } catch (e) {
      print('❌ خطأ في حفظ الصورة محلياً: $e');
      rethrow;
    }
  }
}
