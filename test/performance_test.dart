import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tashlehekomv2/main.dart' as app;
import 'package:tashlehekomv2/services/firebase_firestore_service.dart';
import 'package:tashlehekomv2/services/cache_service.dart';
import 'package:tashlehekomv2/services/sync_service.dart';
import 'dart:io';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('⚡ اختبارات الأداء والاستجابة', () {
    late FirebaseFirestoreService firestoreService;
    late CacheService cacheService;
    late SyncService syncService;

    setUpAll(() async {
      firestoreService = FirebaseFirestoreService();
      cacheService = CacheService();
      syncService = SyncService();
      
      print('🚀 بدء اختبارات الأداء');
    });

    group('📊 قياس الأداء', () {
      testWidgets('🚀 اختبار سرعة بدء التطبيق', (WidgetTester tester) async {
        final stopwatch = Stopwatch()..start();
        
        app.main();
        await tester.pumpAndSettle();
        
        stopwatch.stop();
        final startupTime = stopwatch.elapsedMilliseconds;
        
        print('⏱️ وقت بدء التطبيق: ${startupTime}ms');
        
        // يجب أن يبدأ التطبيق في أقل من 3 ثوانٍ
        expect(startupTime, lessThan(3000));
        
        if (startupTime < 1000) {
          print('🟢 أداء ممتاز: أقل من ثانية واحدة');
        } else if (startupTime < 2000) {
          print('🟡 أداء جيد: أقل من ثانيتين');
        } else {
          print('🟠 أداء مقبول: أقل من 3 ثوانٍ');
        }
      });

      testWidgets('📱 اختبار استجابة واجهة المستخدم', (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();

        // قياس وقت الاستجابة للضغط على الأزرار
        final stopwatch = Stopwatch();
        
        // اختبار الانتقال بين الشاشات
        final tabs = ['الرئيسية', 'البحث', 'المفضلة', 'الملف الشخصي'];
        
        for (String tabName in tabs) {
          final tab = find.text(tabName);
          if (tab.evaluate().isNotEmpty) {
            stopwatch.reset();
            stopwatch.start();
            
            await tester.tap(tab);
            await tester.pumpAndSettle();
            
            stopwatch.stop();
            final responseTime = stopwatch.elapsedMilliseconds;
            
            print('⏱️ وقت الانتقال إلى $tabName: ${responseTime}ms');
            
            // يجب أن تكون الاستجابة أقل من 500ms
            expect(responseTime, lessThan(500));
          }
        }
      });

      testWidgets('💾 اختبار أداء التخزين المؤقت', (WidgetTester tester) async {
        print('🧪 اختبار أداء Cache Service');
        
        final stopwatch = Stopwatch();
        
        // اختبار سرعة الكتابة
        stopwatch.start();
        await cacheService.setString('test_key', 'test_value');
        stopwatch.stop();
        
        final writeTime = stopwatch.elapsedMicroseconds;
        print('✍️ وقت الكتابة في Cache: ${writeTime}μs');
        
        // اختبار سرعة القراءة
        stopwatch.reset();
        stopwatch.start();
        final value = await cacheService.getString('test_key');
        stopwatch.stop();
        
        final readTime = stopwatch.elapsedMicroseconds;
        print('📖 وقت القراءة من Cache: ${readTime}μs');
        
        expect(value, equals('test_value'));
        expect(writeTime, lessThan(1000)); // أقل من 1ms
        expect(readTime, lessThan(500));   // أقل من 0.5ms
      });

      testWidgets('🔄 اختبار أداء المزامنة', (WidgetTester tester) async {
        print('🧪 اختبار أداء Sync Service');
        
        final stopwatch = Stopwatch();
        
        // اختبار سرعة المزامنة
        stopwatch.start();
        await syncService.syncAllData();
        stopwatch.stop();
        
        final syncTime = stopwatch.elapsedMilliseconds;
        print('🔄 وقت المزامنة الكاملة: ${syncTime}ms');
        
        // يجب أن تكتمل المزامنة في أقل من 10 ثوانٍ
        expect(syncTime, lessThan(10000));
        
        if (syncTime < 2000) {
          print('🟢 مزامنة سريعة جداً');
        } else if (syncTime < 5000) {
          print('🟡 مزامنة سريعة');
        } else {
          print('🟠 مزامنة مقبولة');
        }
      });

      testWidgets('🔥 اختبار أداء Firebase', (WidgetTester tester) async {
        print('🧪 اختبار أداء Firebase Services');
        
        final stopwatch = Stopwatch();
        
        // اختبار سرعة جلب البيانات
        stopwatch.start();
        final cars = await firestoreService.getAllCars();
        stopwatch.stop();
        
        final fetchTime = stopwatch.elapsedMilliseconds;
        print('📥 وقت جلب السيارات من Firebase: ${fetchTime}ms');
        print('📊 عدد السيارات المجلبة: ${cars.length}');
        
        // يجب أن يكتمل الجلب في أقل من 5 ثوانٍ
        expect(fetchTime, lessThan(5000));
        
        // اختبار سرعة جلب المستخدمين
        stopwatch.reset();
        stopwatch.start();
        final users = await firestoreService.getAllUsers();
        stopwatch.stop();
        
        final usersFetchTime = stopwatch.elapsedMilliseconds;
        print('👥 وقت جلب المستخدمين من Firebase: ${usersFetchTime}ms');
        print('📊 عدد المستخدمين المجلبين: ${users.length}');
        
        expect(usersFetchTime, lessThan(5000));
      });
    });

    group('🧠 اختبار استهلاك الذاكرة', () {
      testWidgets('💾 مراقبة استهلاك الذاكرة', (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();

        // قياس استهلاك الذاكرة في البداية
        final initialMemory = _getMemoryUsage();
        print('🏁 استهلاك الذاكرة الأولي: ${initialMemory}MB');

        // تحميل بيانات كثيرة لاختبار الذاكرة
        for (int i = 0; i < 10; i++) {
          await firestoreService.getAllCars();
          await tester.pump();
        }

        final afterLoadMemory = _getMemoryUsage();
        print('📈 استهلاك الذاكرة بعد التحميل: ${afterLoadMemory}MB');

        // الانتقال بين الشاشات عدة مرات
        final tabs = ['البحث', 'المفضلة', 'الملف الشخصي', 'الرئيسية'];
        for (int i = 0; i < 5; i++) {
          for (String tabName in tabs) {
            final tab = find.text(tabName);
            if (tab.evaluate().isNotEmpty) {
              await tester.tap(tab);
              await tester.pumpAndSettle();
            }
          }
        }

        final finalMemory = _getMemoryUsage();
        print('🏁 استهلاك الذاكرة النهائي: ${finalMemory}MB');

        // التحقق من عدم وجود تسريب في الذاكرة
        final memoryIncrease = finalMemory - initialMemory;
        print('📊 زيادة استهلاك الذاكرة: ${memoryIncrease}MB');

        // يجب ألا تزيد الذاكرة بأكثر من 50MB
        expect(memoryIncrease, lessThan(50));

        if (memoryIncrease < 10) {
          print('🟢 استهلاك ذاكرة ممتاز');
        } else if (memoryIncrease < 25) {
          print('🟡 استهلاك ذاكرة جيد');
        } else {
          print('🟠 استهلاك ذاكرة مقبول');
        }
      });

      testWidgets('🗑️ اختبار تنظيف الذاكرة', (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();

        // تحميل بيانات كثيرة
        final initialMemory = _getMemoryUsage();
        print('🏁 الذاكرة قبل التحميل: ${initialMemory}MB');

        // تحميل بيانات كبيرة
        for (int i = 0; i < 20; i++) {
          await firestoreService.getAllCars();
          await firestoreService.getAllUsers();
        }

        final peakMemory = _getMemoryUsage();
        print('📈 ذروة استهلاك الذاكرة: ${peakMemory}MB');

        // انتظار لتنظيف الذاكرة
        await Future.delayed(Duration(seconds: 5));
        await tester.pumpAndSettle();

        // إجبار تنظيف الذاكرة
        await cacheService.clearExpiredCache();

        final cleanedMemory = _getMemoryUsage();
        print('🧹 الذاكرة بعد التنظيف: ${cleanedMemory}MB');

        // يجب أن تنخفض الذاكرة بعد التنظيف
        expect(cleanedMemory, lessThan(peakMemory));

        final memoryReduction = peakMemory - cleanedMemory;
        print('📉 انخفاض الذاكرة: ${memoryReduction}MB');

        if (memoryReduction > 10) {
          print('🟢 تنظيف ذاكرة فعال');
        } else {
          print('🟡 تنظيف ذاكرة محدود');
        }
      });
    });

    group('📊 تقرير الأداء النهائي', () {
      test('📋 إنشاء تقرير الأداء', () async {
        print('\n' + '='*50);
        print('📊 تقرير الأداء النهائي');
        print('='*50);
        
        // اختبار سرعة الخدمات
        final stopwatch = Stopwatch();
        
        // Firebase
        stopwatch.start();
        await firestoreService.getAllCars();
        stopwatch.stop();
        final firebaseTime = stopwatch.elapsedMilliseconds;
        
        // Cache
        stopwatch.reset();
        stopwatch.start();
        await cacheService.getString('test');
        stopwatch.stop();
        final cacheTime = stopwatch.elapsedMicroseconds;
        
        // Sync
        stopwatch.reset();
        stopwatch.start();
        await syncService.syncAllData();
        stopwatch.stop();
        final syncTime = stopwatch.elapsedMilliseconds;
        
        print('🔥 Firebase: ${firebaseTime}ms');
        print('💾 Cache: ${cacheTime}μs');
        print('🔄 Sync: ${syncTime}ms');
        print('🧠 Memory: ${_getMemoryUsage()}MB');
        
        // تقييم الأداء العام
        int score = 100;
        if (firebaseTime > 3000) score -= 20;
        if (cacheTime > 1000) score -= 10;
        if (syncTime > 8000) score -= 20;
        if (_getMemoryUsage() > 100) score -= 15;
        
        print('\n🏆 نقاط الأداء: $score/100');
        
        if (score >= 90) {
          print('🟢 أداء ممتاز!');
        } else if (score >= 75) {
          print('🟡 أداء جيد');
        } else if (score >= 60) {
          print('🟠 أداء مقبول');
        } else {
          print('🔴 يحتاج تحسين');
        }
        
        print('='*50);
      });
    });
  });
}

// دالة مساعدة لقياس استهلاك الذاكرة
double _getMemoryUsage() {
  try {
    final info = ProcessInfo.currentRss;
    return info / (1024 * 1024); // تحويل إلى MB
  } catch (e) {
    // في حالة عدم توفر معلومات الذاكرة
    return 0.0;
  }
}
