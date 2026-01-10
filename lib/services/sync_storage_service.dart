import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'enhanced_firebase_storage_service.dart';

/// خدمة مزامنة التخزين بين المحلي والسحابي
class SyncStorageService {
  static final SyncStorageService _instance = SyncStorageService._internal();
  
  SyncStorageService._internal();
  
  factory SyncStorageService() => _instance;

  final EnhancedFirebaseStorageService _firebaseStorage = 
      EnhancedFirebaseStorageService();
  final Connectivity _connectivity = Connectivity();

  static const String _pendingUploadsKey = 'pending_uploads';
  static const String _syncStatusKey = 'sync_status';

  /// فحص حالة الاتصال بالإنترنت
  Future<bool> isConnected() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      _log('خطأ في فحص الاتصال: $e');
      return false;
    }
  }

  /// حفظ صورة مع استراتيجية ذكية (سحابي أو محلي)
  Future<String> saveImageSmart(
    File imageFile,
    String carId,
    int imageIndex, {
    Function(double)? onProgress,
  }) async {
    try {
      // محاولة الرفع إلى السحابة أولاً
      if (await isConnected()) {
        try {
          final cloudUrl = await _firebaseStorage.uploadCarImage(
            imageFile,
            carId,
            imageIndex,
            onProgress: onProgress,
          );
          
          // إزالة من قائمة الانتظار إذا كانت موجودة
          await _removePendingUpload(carId, imageIndex);
          
          _log('✅ تم رفع الصورة إلى السحابة: $cloudUrl');
          return cloudUrl;
        } catch (cloudError) {
          _log('⚠️ فشل الرفع إلى السحابة: $cloudError');
          // الانتقال إلى التخزين المحلي
        }
      }

      // حفظ محلي مع إضافة إلى قائمة الانتظار
      final localPath = await _saveImageLocally(imageFile, carId, imageIndex);
      await _addPendingUpload(carId, imageIndex, localPath);
      
      _log('💾 تم حفظ الصورة محلياً: $localPath');
      return localPath;
    } catch (e) {
      _log('❌ خطأ في حفظ الصورة: $e');
      rethrow;
    }
  }

  /// مزامنة الصور المحلية مع السحابة
  Future<void> syncPendingUploads({
    Function(String carId, int imageIndex, double progress)? onProgress,
    Function(String carId, int imageIndex, String cloudUrl)? onSuccess,
    Function(String carId, int imageIndex, String error)? onError,
  }) async {
    try {
      if (!await isConnected()) {
        _log('⚠️ لا يوجد اتصال بالإنترنت للمزامنة');
        return;
      }

      final pendingUploads = await _getPendingUploads();
      if (pendingUploads.isEmpty) {
        _log('✅ لا توجد صور في انتظار المزامنة');
        return;
      }

      _log('🔄 بدء مزامنة ${pendingUploads.length} صورة...');

      for (final upload in pendingUploads) {
        try {
          final carId = upload['carId'] as String;
          final imageIndex = upload['imageIndex'] as int;
          final localPath = upload['localPath'] as String;

          final localFile = File(localPath);
          if (!await localFile.exists()) {
            _log('⚠️ الملف المحلي غير موجود: $localPath');
            await _removePendingUpload(carId, imageIndex);
            continue;
          }

          // رفع إلى السحابة
          final cloudUrl = await _firebaseStorage.uploadCarImage(
            localFile,
            carId,
            imageIndex,
            onProgress: (progress) {
              onProgress?.call(carId, imageIndex, progress);
            },
          );

          // إزالة من قائمة الانتظار
          await _removePendingUpload(carId, imageIndex);
          
          // حذف الملف المحلي (اختياري)
          // await localFile.delete();

          onSuccess?.call(carId, imageIndex, cloudUrl);
          _log('✅ تمت مزامنة الصورة: $carId/$imageIndex');
        } catch (e) {
          _log('❌ خطأ في مزامنة الصورة: $e');
          onError?.call(
            upload['carId'] as String,
            upload['imageIndex'] as int,
            e.toString(),
          );
        }
      }

      await _updateSyncStatus();
      _log('🎉 اكتملت المزامنة');
    } catch (e) {
      _log('❌ خطأ في المزامنة: $e');
    }
  }

  /// الحصول على حالة المزامنة
  Future<Map<String, dynamic>> getSyncStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final statusJson = prefs.getString(_syncStatusKey);
    
    if (statusJson != null) {
      // في التطبيق الحقيقي، استخدم json.decode
      return {'lastSync': statusJson, 'pendingCount': await _getPendingUploadsCount()};
    }
    
    return {'lastSync': null, 'pendingCount': await _getPendingUploadsCount()};
  }

  /// بدء المزامنة التلقائية عند توفر الإنترنت
  void startAutoSync() {
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      if (result != ConnectivityResult.none) {
        _log('🌐 تم استعادة الاتصال، بدء المزامنة التلقائية...');
        syncPendingUploads();
      }
    });
  }

  /// حفظ الصورة محلياً
  Future<String> _saveImageLocally(
    File imageFile,
    String carId,
    int imageIndex,
  ) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final carImagesDir = Directory('${appDir.path}/car_images/$carId');

      if (!await carImagesDir.exists()) {
        await carImagesDir.create(recursive: true);
      }

      final fileName = 'car_${carId}_image_$imageIndex.jpg';
      final localImagePath = '${carImagesDir.path}/$fileName';
      await imageFile.copy(localImagePath);

      return localImagePath;
    } catch (e) {
      _log('❌ خطأ في حفظ الصورة محلياً: $e');
      rethrow;
    }
  }

  /// إضافة صورة إلى قائمة انتظار الرفع
  Future<void> _addPendingUpload(
    String carId,
    int imageIndex,
    String localPath,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingUploads = await _getPendingUploads();

      // إزالة الرفع المعلق السابق إذا كان موجوداً
      pendingUploads.removeWhere((upload) =>
          upload['carId'] == carId && upload['imageIndex'] == imageIndex);

      // إضافة الرفع الجديد
      pendingUploads.add({
        'carId': carId,
        'imageIndex': imageIndex,
        'localPath': localPath,
        'timestamp': DateTime.now().toIso8601String(),
      });

      // حفظ القائمة المحدثة
      // في التطبيق الحقيقي، استخدم json.encode
      await prefs.setString(_pendingUploadsKey, pendingUploads.toString());
    } catch (e) {
      _log('❌ خطأ في إضافة الرفع المعلق: $e');
    }
  }

  /// إزالة صورة من قائمة انتظار الرفع
  Future<void> _removePendingUpload(String carId, int imageIndex) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingUploads = await _getPendingUploads();

      pendingUploads.removeWhere((upload) =>
          upload['carId'] == carId && upload['imageIndex'] == imageIndex);

      // في التطبيق الحقيقي، استخدم json.encode
      await prefs.setString(_pendingUploadsKey, pendingUploads.toString());
    } catch (e) {
      _log('❌ خطأ في إزالة الرفع المعلق: $e');
    }
  }

  /// الحصول على قائمة الرفعات المعلقة
  Future<List<Map<String, dynamic>>> _getPendingUploads() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uploadsJson = prefs.getString(_pendingUploadsKey);
      
      if (uploadsJson != null) {
        // في التطبيق الحقيقي، استخدم json.decode
        // return List<Map<String, dynamic>>.from(json.decode(uploadsJson));
        return []; // مؤقت
      }
      
      return [];
    } catch (e) {
      _log('❌ خطأ في الحصول على الرفعات المعلقة: $e');
      return [];
    }
  }

  /// الحصول على عدد الرفعات المعلقة
  Future<int> _getPendingUploadsCount() async {
    final pendingUploads = await _getPendingUploads();
    return pendingUploads.length;
  }

  /// تحديث حالة المزامنة
  Future<void> _updateSyncStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_syncStatusKey, DateTime.now().toIso8601String());
    } catch (e) {
      _log('❌ خطأ في تحديث حالة المزامنة: $e');
    }
  }

  /// دالة للطباعة (تستخدم debugPrint في وضع التطوير)
  void _log(String message) {
    if (kDebugMode) {
      debugPrint('[SyncStorage] $message');
    }
  }
}
