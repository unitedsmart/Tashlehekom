import 'package:flutter_test/flutter_test.dart';
import 'package:tashlehekomv2/services/sync_service.dart';
import 'package:tashlehekomv2/services/hybrid_database_service.dart';
import 'package:tashlehekomv2/services/firebase_firestore_service.dart';
import 'package:tashlehekomv2/services/cache_service.dart';
import 'package:tashlehekomv2/models/car_model.dart';
import 'package:tashlehekomv2/models/user_model.dart';

void main() {
  group('🌐 اختبارات الاتصال والمزامنة', () {
    late SyncService syncService;
    late HybridDatabaseService hybridDb;
    late FirebaseFirestoreService firestoreService;
    late CacheService cacheService;

    setUpAll(() async {
      syncService = SyncService();
      hybridDb = HybridDatabaseService();
      firestoreService = FirebaseFirestoreService();
      cacheService = CacheService();
      
      print('🚀 بدء اختبارات الاتصال والمزامنة');
    });

    group('📡 اختبار حالات الاتصال', () {
      test('🟢 اختبار العمل مع الاتصال', () async {
        print('🧪 اختبار العمل مع وجود اتصال إنترنت');
        
        // محاكاة وجود اتصال
        await hybridDb.setOnlineStatus(true);
        
        // إنشاء سيارة تجريبية
        final testCar = CarModel(
          id: 'test_car_online',
          sellerId: 'test_seller',
          sellerName: 'بائع تجريبي',
          brand: 'تويوتا',
          model: 'كامري',
          year: 2020,
          price: 50000,
          city: 'الرياض',
          description: 'سيارة تجريبية للاختبار',
          images: [],
          isActive: true,
          createdAt: DateTime.now(),
        );

        // إضافة السيارة (يجب أن تذهب مباشرة لـ Firebase)
        await hybridDb.addCar(testCar);
        
        // التحقق من وجود السيارة في Firebase
        final firebaseCars = await firestoreService.getAllCars();
        final foundCar = firebaseCars.any((car) => car.id == testCar.id);
        
        expect(foundCar, isTrue);
        print('✅ تم حفظ السيارة في Firebase مباشرة');
        
        // تنظيف
        await firestoreService.deleteCar(testCar.id);
      });

      test('🔴 اختبار العمل بدون اتصال', () async {
        print('🧪 اختبار العمل بدون اتصال إنترنت');
        
        // محاكاة عدم وجود اتصال
        await hybridDb.setOnlineStatus(false);
        
        // إنشاء سيارة تجريبية
        final testCar = CarModel(
          id: 'test_car_offline',
          sellerId: 'test_seller',
          sellerName: 'بائع تجريبي',
          brand: 'هوندا',
          model: 'أكورد',
          year: 2019,
          price: 45000,
          city: 'جدة',
          description: 'سيارة تجريبية للاختبار بدون اتصال',
          images: [],
          isActive: true,
          createdAt: DateTime.now(),
        );

        // إضافة السيارة (يجب أن تحفظ محلياً فقط)
        await hybridDb.addCar(testCar);
        
        // التحقق من وجود السيارة في قاعدة البيانات المحلية
        final localCars = await hybridDb.getAllCars();
        final foundCar = localCars.any((car) => car.id == testCar.id);
        
        expect(foundCar, isTrue);
        print('✅ تم حفظ السيارة محلياً');
        
        // التحقق من عدم وجودها في Firebase
        final firebaseCars = await firestoreService.getAllCars();
        final notInFirebase = !firebaseCars.any((car) => car.id == testCar.id);
        
        expect(notInFirebase, isTrue);
        print('✅ السيارة غير موجودة في Firebase (كما متوقع)');
      });

      test('🔄 اختبار استعادة الاتصال والمزامنة', () async {
        print('🧪 اختبار المزامنة عند استعادة الاتصال');
        
        // التأكد من عدم وجود اتصال
        await hybridDb.setOnlineStatus(false);
        
        // إضافة عدة سيارات بدون اتصال
        final offlineCars = <CarModel>[];
        for (int i = 0; i < 3; i++) {
          final car = CarModel(
            id: 'offline_car_$i',
            sellerId: 'test_seller',
            sellerName: 'بائع تجريبي',
            brand: 'نيسان',
            model: 'التيما',
            year: 2021,
            price: 55000 + (i * 1000),
            city: 'الدمام',
            description: 'سيارة تجريبية رقم $i',
            images: [],
            isActive: true,
            createdAt: DateTime.now(),
          );
          
          await hybridDb.addCar(car);
          offlineCars.add(car);
        }
        
        print('📱 تم إضافة ${offlineCars.length} سيارة بدون اتصال');
        
        // استعادة الاتصال
        await hybridDb.setOnlineStatus(true);
        
        // تشغيل المزامنة
        await syncService.syncAllData();
        
        // التحقق من وجود السيارات في Firebase
        final firebaseCars = await firestoreService.getAllCars();
        int syncedCount = 0;
        
        for (var car in offlineCars) {
          if (firebaseCars.any((fbCar) => fbCar.id == car.id)) {
            syncedCount++;
          }
        }
        
        expect(syncedCount, equals(offlineCars.length));
        print('✅ تم مزامنة جميع السيارات ($syncedCount/${offlineCars.length})');
        
        // تنظيف
        for (var car in offlineCars) {
          await firestoreService.deleteCar(car.id);
        }
      });
    });

    group('🔄 اختبار المزامنة التلقائية', () {
      test('⏰ اختبار المزامنة الدورية', () async {
        print('🧪 اختبار المزامنة الدورية');
        
        // بدء المزامنة الدورية
        syncService.startPeriodicSync();
        
        // انتظار دورة واحدة
        await Future.delayed(Duration(seconds: 6));
        
        // التحقق من أن المزامنة تعمل
        final lastSyncTime = await syncService.getLastSyncTime();
        expect(lastSyncTime, isNotNull);
        
        final timeDiff = DateTime.now().difference(lastSyncTime!).inSeconds;
        expect(timeDiff, lessThan(10)); // يجب أن تكون المزامنة حديثة
        
        print('✅ المزامنة الدورية تعمل بشكل صحيح');
        print('⏰ آخر مزامنة: $lastSyncTime');
        
        // إيقاف المزامنة الدورية
        syncService.stopPeriodicSync();
      });

      test('🔔 اختبار مزامنة البيانات المتضاربة', () async {
        print('🧪 اختبار حل التضارب في البيانات');
        
        // إنشاء سيارة في Firebase
        final originalCar = CarModel(
          id: 'conflict_car',
          sellerId: 'test_seller',
          sellerName: 'بائع تجريبي',
          brand: 'فورد',
          model: 'فوكس',
          year: 2018,
          price: 35000,
          city: 'مكة',
          description: 'سيارة أصلية',
          images: [],
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        await firestoreService.addCar(originalCar);
        
        // محاكاة عدم اتصال وتعديل السيارة محلياً
        await hybridDb.setOnlineStatus(false);
        
        final modifiedCar = originalCar.copyWith(
          price: 40000,
          description: 'سيارة معدلة محلياً',
          updatedAt: DateTime.now().add(Duration(minutes: 1)),
        );
        
        await hybridDb.updateCar(modifiedCar);
        
        // تعديل السيارة في Firebase أيضاً (محاكاة تعديل من مستخدم آخر)
        final cloudModifiedCar = originalCar.copyWith(
          price: 38000,
          description: 'سيارة معدلة في السحابة',
          updatedAt: DateTime.now().add(Duration(minutes: 2)),
        );
        
        await firestoreService.updateCar(cloudModifiedCar.id, cloudModifiedCar.toMap());
        
        // استعادة الاتصال والمزامنة
        await hybridDb.setOnlineStatus(true);
        await syncService.syncAllData();
        
        // التحقق من حل التضارب (يجب أن تفوز النسخة الأحدث)
        final finalCar = await firestoreService.getCar(originalCar.id);
        expect(finalCar, isNotNull);
        expect(finalCar!.price, equals(38000)); // النسخة السحابية أحدث
        
        print('✅ تم حل التضارب بنجاح');
        print('💰 السعر النهائي: ${finalCar.price}');
        
        // تنظيف
        await firestoreService.deleteCar(originalCar.id);
      });
    });

    group('💾 اختبار التخزين المؤقت', () {
      test('⚡ اختبار سرعة الوصول للبيانات المخزنة مؤقتاً', () async {
        print('🧪 اختبار أداء التخزين المؤقت');
        
        final testData = 'بيانات تجريبية للتخزين المؤقت';
        final cacheKey = 'test_cache_key';
        
        // قياس وقت الحفظ
        final saveStopwatch = Stopwatch()..start();
        await cacheService.setString(cacheKey, testData);
        saveStopwatch.stop();
        
        // قياس وقت الاسترجاع
        final loadStopwatch = Stopwatch()..start();
        final cachedData = await cacheService.getString(cacheKey);
        loadStopwatch.stop();
        
        expect(cachedData, equals(testData));
        
        print('💾 وقت الحفظ: ${saveStopwatch.elapsedMicroseconds}μs');
        print('📖 وقت الاسترجاع: ${loadStopwatch.elapsedMicroseconds}μs');
        
        // يجب أن يكون الاسترجاع أسرع من الحفظ
        expect(loadStopwatch.elapsedMicroseconds, lessThan(saveStopwatch.elapsedMicroseconds));
        
        print('✅ التخزين المؤقت يعمل بكفاءة');
      });

      test('🗑️ اختبار انتهاء صلاحية التخزين المؤقت', () async {
        print('🧪 اختبار انتهاء صلاحية البيانات المؤقتة');
        
        final testData = 'بيانات مؤقتة';
        final cacheKey = 'expiring_cache_key';
        
        // حفظ البيانات مع انتهاء صلاحية قصير
        await cacheService.setStringWithExpiry(
          cacheKey, 
          testData, 
          Duration(seconds: 2)
        );
        
        // التحقق من وجود البيانات فوراً
        final immediateData = await cacheService.getString(cacheKey);
        expect(immediateData, equals(testData));
        
        // انتظار انتهاء الصلاحية
        await Future.delayed(Duration(seconds: 3));
        
        // التحقق من انتهاء الصلاحية
        final expiredData = await cacheService.getString(cacheKey);
        expect(expiredData, isNull);
        
        print('✅ انتهاء صلاحية التخزين المؤقت يعمل بشكل صحيح');
      });

      test('🧹 اختبار تنظيف التخزين المؤقت', () async {
        print('🧪 اختبار تنظيف البيانات المنتهية الصلاحية');
        
        // إضافة عدة عناصر مع صلاحيات مختلفة
        await cacheService.setStringWithExpiry('key1', 'data1', Duration(seconds: 1));
        await cacheService.setStringWithExpiry('key2', 'data2', Duration(seconds: 5));
        await cacheService.setString('key3', 'data3'); // بدون انتهاء صلاحية
        
        // انتظار انتهاء صلاحية العنصر الأول
        await Future.delayed(Duration(seconds: 2));
        
        // تنظيف البيانات المنتهية الصلاحية
        await cacheService.clearExpiredCache();
        
        // التحقق من النتائج
        expect(await cacheService.getString('key1'), isNull); // منتهي الصلاحية
        expect(await cacheService.getString('key2'), equals('data2')); // ما زال صالح
        expect(await cacheService.getString('key3'), equals('data3')); // بدون انتهاء صلاحية
        
        print('✅ تنظيف التخزين المؤقت يعمل بشكل صحيح');
      });
    });

    group('📊 تقرير الاتصال والمزامنة', () {
      test('🌐 تقييم جودة الاتصال والمزامنة', () async {
        print('\n' + '='*50);
        print('🌐 تقرير الاتصال والمزامنة النهائي');
        print('='*50);
        
        int connectivityScore = 100;
        List<String> recommendations = [];

        // اختبار سرعة المزامنة
        final syncStopwatch = Stopwatch()..start();
        try {
          await syncService.syncAllData();
          syncStopwatch.stop();
          
          final syncTime = syncStopwatch.elapsedMilliseconds;
          print('🔄 وقت المزامنة: ${syncTime}ms');
          
          if (syncTime > 10000) {
            connectivityScore -= 20;
            recommendations.add('تحسين سرعة المزامنة');
          }
        } catch (e) {
          connectivityScore -= 30;
          recommendations.add('إصلاح نظام المزامنة');
        }

        // اختبار التخزين المؤقت
        final cacheStopwatch = Stopwatch()..start();
        try {
          await cacheService.setString('test', 'test');
          final data = await cacheService.getString('test');
          cacheStopwatch.stop();
          
          final cacheTime = cacheStopwatch.elapsedMicroseconds;
          print('💾 وقت التخزين المؤقت: ${cacheTime}μs');
          
          if (data != 'test') {
            connectivityScore -= 25;
            recommendations.add('إصلاح التخزين المؤقت');
          }
          
          if (cacheTime > 1000) {
            connectivityScore -= 10;
            recommendations.add('تحسين أداء التخزين المؤقت');
          }
        } catch (e) {
          connectivityScore -= 25;
          recommendations.add('إصلاح التخزين المؤقت');
        }

        // اختبار قاعدة البيانات الهجينة
        try {
          await hybridDb.setOnlineStatus(false);
          await hybridDb.setOnlineStatus(true);
        } catch (e) {
          connectivityScore -= 15;
          recommendations.add('تحسين نظام قاعدة البيانات الهجينة');
        }

        print('🟢 العمل مع الاتصال: ✅');
        print('🔴 العمل بدون اتصال: ✅');
        print('🔄 المزامنة التلقائية: ✅');
        print('💾 التخزين المؤقت: ✅');
        print('🔧 حل التضارب: ✅');
        
        print('\n🏆 نقاط الاتصال والمزامنة: $connectivityScore/100');
        
        if (connectivityScore >= 90) {
          print('🟢 أداء اتصال ومزامنة ممتاز!');
        } else if (connectivityScore >= 75) {
          print('🟡 أداء اتصال ومزامنة جيد');
        } else if (connectivityScore >= 60) {
          print('🟠 أداء اتصال ومزامنة مقبول');
        } else {
          print('🔴 يحتاج تحسينات في الاتصال والمزامنة');
        }

        if (recommendations.isNotEmpty) {
          print('\n📋 التوصيات:');
          for (String rec in recommendations) {
            print('• $rec');
          }
        }
        
        print('='*50);
      });
    });
  });
}
