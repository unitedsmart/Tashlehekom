import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tashlehekomv2/models/car_model.dart';
import 'package:tashlehekomv2/models/user_model.dart';

class SampleDataService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// إضافة بيانات تجريبية للسيارات
  static Future<void> addSampleCars() async {
    try {
      // التحقق من وجود سيارات مسبقاً
      final existingCars = await _firestore.collection('cars').limit(1).get();
      if (existingCars.docs.isNotEmpty) {
        print('توجد سيارات مسبقاً في قاعدة البيانات');
        return;
      }

      // إنشاء مستخدم تجريبي
      final sampleUser = UserModel(
        id: 'sample_user_1',
        username: 'أحمد محمد',
        name: 'أحمد محمد علي',
        phoneNumber: '+966501234567',
        userType: UserType.individual,
        isApproved: true,
        createdAt: DateTime.now(),
      );

      // حفظ المستخدم التجريبي
      await _firestore
          .collection('users')
          .doc(sampleUser.id)
          .set(sampleUser.toMap());

      // قائمة السيارات التجريبية
      final sampleCars = [
        CarModel(
          id: 'car_1',
          sellerId: sampleUser.id,
          sellerName: sampleUser.username,
          brand: 'تويوتا',
          model: 'كامري',
          manufacturingYears: [2020, 2021],
          year: 2020,
          price: 45000,
          city: 'الرياض',
          color: 'أبيض',
          images: [
            'https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?w=500',
            'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=500',
          ],
          createdAt: DateTime.now(),
          isActive: true,
        ),
        CarModel(
          id: 'car_2',
          sellerId: sampleUser.id,
          sellerName: sampleUser.username,
          brand: 'هوندا',
          model: 'أكورد',
          manufacturingYears: [2019],
          year: 2019,
          price: 38000,
          city: 'جدة',
          color: 'أسود',
          images: [
            'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=500',
            'https://images.unsplash.com/photo-1494976688153-ca3ce0140f49?w=500',
          ],
          createdAt: DateTime.now(),
          isActive: true,
        ),
        CarModel(
          id: 'car_3',
          sellerId: sampleUser.id,
          sellerName: sampleUser.username,
          brand: 'نيسان',
          model: 'التيما',
          manufacturingYears: [2018, 2019],
          year: 2018,
          price: 32000,
          city: 'الدمام',
          color: 'فضي',
          vinNumber: '1N4AL3AP8JC123456',
          images: [
            'https://images.unsplash.com/photo-1555215695-3004980ad54e?w=500',
            'https://images.unsplash.com/photo-1502877338535-766e1452684a?w=500',
          ],
          createdAt: DateTime.now(),
          isActive: true,
        ),
        CarModel(
          id: 'car_4',
          sellerId: sampleUser.id,
          sellerName: sampleUser.username,
          brand: 'هيونداي',
          model: 'إلنترا',
          manufacturingYears: [2021],
          year: 2021,
          price: 42000,
          city: 'مكة المكرمة',
          color: 'أحمر',
          images: [
            'https://images.unsplash.com/photo-1583121274602-3e2820c69888?w=500',
            'https://images.unsplash.com/photo-1571607388263-1044f9ea01dd?w=500',
          ],
          createdAt: DateTime.now(),
          isActive: true,
        ),
        CarModel(
          id: 'car_5',
          sellerId: sampleUser.id,
          sellerName: sampleUser.username,
          brand: 'كيا',
          model: 'أوبتيما',
          manufacturingYears: [2020],
          year: 2020,
          price: 39000,
          city: 'المدينة المنورة',
          color: 'أزرق',
          images: [
            'https://images.unsplash.com/photo-1542362567-b07e54358753?w=500',
            'https://images.unsplash.com/photo-1550355291-bbee04a92027?w=500',
          ],
          createdAt: DateTime.now(),
          isActive: true,
        ),
      ];

      // حفظ السيارات في قاعدة البيانات
      final batch = _firestore.batch();

      for (final car in sampleCars) {
        final docRef = _firestore.collection('cars').doc(car.id);
        batch.set(docRef, car.toMap());
      }

      await batch.commit();
      print('تم إضافة ${sampleCars.length} سيارات تجريبية بنجاح');
    } catch (e) {
      print('خطأ في إضافة البيانات التجريبية: $e');
      rethrow;
    }
  }

  /// إضافة مستخدمين تجريبيين
  static Future<void> addSampleUsers() async {
    try {
      final sampleUsers = [
        UserModel(
          id: 'user_individual_1',
          username: 'سارة أحمد',
          name: 'سارة أحمد محمد',
          phoneNumber: '+966502345678',
          userType: UserType.individual,
          isApproved: true,
          city: 'الرياض',
          createdAt: DateTime.now(),
        ),
        UserModel(
          id: 'user_worker_1',
          username: 'محمد علي',
          name: 'محمد علي حسن',
          phoneNumber: '+966503456789',
          userType: UserType.worker,
          isApproved: true,
          city: 'جدة',
          junkyard: 'تشليح الأمانة',
          createdAt: DateTime.now(),
        ),
        UserModel(
          id: 'user_junkyard_1',
          username: 'عبدالله سالم',
          name: 'عبدالله سالم أحمد',
          phoneNumber: '+966504567890',
          userType: UserType.junkyardOwner,
          isApproved: false, // يحتاج موافقة
          city: 'الدمام',
          junkyard: 'تشليح النور',
          createdAt: DateTime.now(),
        ),
      ];

      final batch = _firestore.batch();

      for (final user in sampleUsers) {
        final docRef = _firestore.collection('users').doc(user.id);
        batch.set(docRef, user.toMap());
      }

      await batch.commit();
      print('تم إضافة ${sampleUsers.length} مستخدمين تجريبيين بنجاح');
    } catch (e) {
      print('خطأ في إضافة المستخدمين التجريبيين: $e');
      rethrow;
    }
  }

  /// حذف جميع البيانات التجريبية
  static Future<void> clearSampleData() async {
    try {
      // حذف السيارات التجريبية
      final carsQuery = await _firestore
          .collection('cars')
          .where('seller_id', isEqualTo: 'sample_user_1')
          .get();
      final batch = _firestore.batch();

      for (final doc in carsQuery.docs) {
        batch.delete(doc.reference);
      }

      // حذف المستخدمين التجريبيين
      final sampleUserIds = [
        'sample_user_1',
        'user_individual_1',
        'user_worker_1',
        'user_junkyard_1'
      ];
      for (final userId in sampleUserIds) {
        final userDoc = _firestore.collection('users').doc(userId);
        batch.delete(userDoc);
      }

      await batch.commit();
      print('تم حذف البيانات التجريبية بنجاح');
    } catch (e) {
      print('خطأ في حذف البيانات التجريبية: $e');
      rethrow;
    }
  }

  /// إضافة جميع البيانات التجريبية
  static Future<void> initializeSampleData() async {
    try {
      await addSampleUsers();
      await addSampleCars();
      print('تم تهيئة جميع البيانات التجريبية بنجاح');
    } catch (e) {
      print('خطأ في تهيئة البيانات التجريبية: $e');
      rethrow;
    }
  }
}
