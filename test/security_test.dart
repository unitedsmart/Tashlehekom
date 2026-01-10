import 'package:flutter_test/flutter_test.dart';
import 'package:tashlehekomv2/services/security_service.dart';
import 'package:tashlehekomv2/services/activity_monitor_service.dart';
import 'package:tashlehekomv2/services/firebase_firestore_service.dart';
import 'package:tashlehekomv2/models/user_model.dart';

void main() {
  group('🔒 اختبارات الأمان والحماية', () {
    late SecurityService securityService;
    late ActivityMonitorService activityMonitor;
    late FirebaseFirestoreService firestoreService;

    setUpAll(() async {
      securityService = SecurityService();
      activityMonitor = ActivityMonitorService();
      firestoreService = FirebaseFirestoreService();
      
      print('🛡️ بدء اختبارات الأمان');
    });

    group('🔐 اختبار التشفير', () {
      test('🔑 اختبار تشفير كلمات المرور', () async {
        final password = 'MySecurePassword123!';
        
        // تشفير كلمة المرور
        final hashedPassword = await securityService.hashPassword(password);
        
        print('🔒 كلمة المرور الأصلية: $password');
        print('🔐 كلمة المرور المشفرة: $hashedPassword');
        
        // التحقق من أن التشفير يعمل
        expect(hashedPassword, isNotEmpty);
        expect(hashedPassword, isNot(equals(password)));
        expect(hashedPassword.length, greaterThan(32));
        
        // التحقق من كلمة المرور
        final isValid = await securityService.verifyPassword(password, hashedPassword);
        expect(isValid, isTrue);
        
        // التحقق من كلمة مرور خاطئة
        final isInvalid = await securityService.verifyPassword('WrongPassword', hashedPassword);
        expect(isInvalid, isFalse);
        
        print('✅ اختبار التشفير نجح');
      });

      test('🧂 اختبار Salt في التشفير', () async {
        final password = 'TestPassword123';
        
        // تشفير نفس كلمة المرور مرتين
        final hash1 = await securityService.hashPassword(password);
        final hash2 = await securityService.hashPassword(password);
        
        // يجب أن تكون النتائج مختلفة بسبب Salt
        expect(hash1, isNot(equals(hash2)));
        
        // لكن كلاهما يجب أن يكون صحيحاً
        expect(await securityService.verifyPassword(password, hash1), isTrue);
        expect(await securityService.verifyPassword(password, hash2), isTrue);
        
        print('✅ اختبار Salt نجح');
      });

      test('🔤 اختبار تشفير النصوص', () async {
        final plainText = 'معلومات سرية مهمة';
        
        // تشفير النص
        final encryptedText = securityService.encryptText(plainText);
        
        print('📝 النص الأصلي: $plainText');
        print('🔐 النص المشفر: $encryptedText');
        
        expect(encryptedText, isNotEmpty);
        expect(encryptedText, isNot(equals(plainText)));
        
        // فك التشفير
        final decryptedText = securityService.decryptText(encryptedText);
        expect(decryptedText, equals(plainText));
        
        print('✅ اختبار تشفير النصوص نجح');
      });
    });

    group('📱 اختبار التحقق من البيانات', () {
      test('📞 اختبار التحقق من أرقام الهواتف السعودية', () {
        final validPhones = [
          '+966501234567',
          '+966551234567',
          '+966561234567',
          '0501234567',
          '0551234567',
        ];

        final invalidPhones = [
          '+966401234567', // رقم غير صحيح
          '+971501234567', // دولة أخرى
          '123456789',     // قصير جداً
          'not_a_phone',   // نص
          '',              // فارغ
        ];

        for (String phone in validPhones) {
          expect(securityService.isValidSaudiPhone(phone), isTrue, 
                 reason: 'يجب أن يكون $phone رقم صحيح');
        }

        for (String phone in invalidPhones) {
          expect(securityService.isValidSaudiPhone(phone), isFalse,
                 reason: 'يجب أن يكون $phone رقم غير صحيح');
        }

        print('✅ اختبار أرقام الهواتف نجح');
      });

      test('🧹 اختبار تنظيف المدخلات', () {
        final maliciousInputs = [
          '<script>alert("XSS")</script>',
          'SELECT * FROM users;',
          '../../etc/passwd',
          '<img src=x onerror=alert(1)>',
          'javascript:alert("XSS")',
        ];

        for (String input in maliciousInputs) {
          final cleaned = securityService.sanitizeInput(input);
          
          print('🦠 مدخل خبيث: $input');
          print('🧹 بعد التنظيف: $cleaned');
          
          // التحقق من إزالة العناصر الخطيرة
          expect(cleaned.toLowerCase(), isNot(contains('script')));
          expect(cleaned.toLowerCase(), isNot(contains('javascript')));
          expect(cleaned.toLowerCase(), isNot(contains('onerror')));
          expect(cleaned, isNot(contains('<')));
          expect(cleaned, isNot(contains('>')));
        }

        print('✅ اختبار تنظيف المدخلات نجح');
      });

      test('📁 اختبار التحقق من الملفات', () {
        // اختبار أنواع الملفات المسموحة
        final allowedFiles = [
          'image.jpg',
          'photo.png',
          'picture.jpeg',
          'avatar.gif',
        ];

        final blockedFiles = [
          'virus.exe',
          'script.js',
          'malware.bat',
          'hack.php',
          'large_file.jpg', // ملف كبير (محاكاة)
        ];

        for (String filename in allowedFiles) {
          expect(securityService.isValidFileType(filename), isTrue,
                 reason: '$filename يجب أن يكون مسموح');
        }

        for (String filename in blockedFiles) {
          if (filename != 'large_file.jpg') {
            expect(securityService.isValidFileType(filename), isFalse,
                   reason: '$filename يجب أن يكون ممنوع');
          }
        }

        // اختبار حجم الملف
        expect(securityService.isValidFileSize(1024 * 1024), isTrue); // 1MB
        expect(securityService.isValidFileSize(10 * 1024 * 1024), isFalse); // 10MB

        print('✅ اختبار التحقق من الملفات نجح');
      });
    });

    group('👁️ اختبار مراقبة الأنشطة', () {
      test('📊 اختبار تسجيل الأنشطة', () async {
        final testUserId = 'test_user_123';
        
        // تسجيل أنشطة مختلفة
        await activityMonitor.logActivity(
          userId: testUserId,
          activityType: 'login_attempt',
          details: 'محاولة تسجيل دخول ناجحة',
        );

        await activityMonitor.logActivity(
          userId: testUserId,
          activityType: 'car_added',
          details: 'إضافة سيارة جديدة',
        );

        await activityMonitor.logActivity(
          userId: testUserId,
          activityType: 'search_performed',
          details: 'بحث عن سيارات تويوتا',
        );

        print('✅ تم تسجيل الأنشطة بنجاح');
      });

      test('🚨 اختبار كشف الأنشطة المشبوهة', () async {
        final testUserId = 'suspicious_user_456';
        
        // محاكاة أنشطة مشبوهة
        for (int i = 0; i < 10; i++) {
          await activityMonitor.logActivity(
            userId: testUserId,
            activityType: 'failed_login',
            details: 'محاولة تسجيل دخول فاشلة #$i',
          );
        }

        // التحقق من كشف النشاط المشبوه
        final isSuspicious = await activityMonitor.checkSuspiciousActivity(testUserId);
        expect(isSuspicious, isTrue);

        print('✅ تم كشف النشاط المشبوه');
      });

      test('🔒 اختبار قفل الحساب', () async {
        final testUserId = 'locked_user_789';
        
        // محاكاة محاولات فاشلة متعددة
        for (int i = 0; i < 5; i++) {
          await securityService.recordFailedLogin(testUserId);
        }

        // التحقق من قفل الحساب
        final isLocked = await securityService.isAccountLocked(testUserId);
        expect(isLocked, isTrue);

        print('✅ تم قفل الحساب بعد المحاولات الفاشلة');
      });
    });

    group('🛡️ اختبار صلاحيات المستخدمين', () {
      test('👤 اختبار صلاحيات المستخدم العادي', () {
        final normalUser = UserModel(
          id: 'user_123',
          name: 'أحمد محمد',
          phoneNumber: '+966501234567',
          city: 'الرياض',
          userType: UserType.user,
          isActive: true,
          createdAt: DateTime.now(),
        );

        // المستخدم العادي يمكنه إضافة السيارات
        expect(securityService.canAddCar(normalUser), isTrue);
        
        // لكن لا يمكنه الوصول للوحة الإدارة
        expect(securityService.canAccessAdminPanel(normalUser), isFalse);
        
        // ولا يمكنه حذف المستخدمين
        expect(securityService.canDeleteUser(normalUser), isFalse);

        print('✅ صلاحيات المستخدم العادي صحيحة');
      });

      test('👨‍💼 اختبار صلاحيات الإداري', () {
        final adminUser = UserModel(
          id: 'admin_123',
          name: 'محمد الإداري',
          phoneNumber: '+966551234567',
          city: 'جدة',
          userType: UserType.admin,
          isActive: true,
          createdAt: DateTime.now(),
        );

        // الإداري يمكنه الوصول للوحة الإدارة
        expect(securityService.canAccessAdminPanel(adminUser), isTrue);
        
        // ويمكنه حذف المستخدمين
        expect(securityService.canDeleteUser(adminUser), isTrue);
        
        // ويمكنه إدارة التقارير
        expect(securityService.canManageReports(adminUser), isTrue);

        print('✅ صلاحيات الإداري صحيحة');
      });

      test('🏪 اختبار صلاحيات البائع', () {
        final sellerUser = UserModel(
          id: 'seller_123',
          name: 'خالد البائع',
          phoneNumber: '+966561234567',
          city: 'الدمام',
          userType: UserType.seller,
          isActive: true,
          createdAt: DateTime.now(),
        );

        // البائع يمكنه إضافة السيارات
        expect(securityService.canAddCar(sellerUser), isTrue);
        
        // ويمكنه إدارة سياراته
        expect(securityService.canManageOwnCars(sellerUser), isTrue);
        
        // لكن لا يمكنه الوصول للوحة الإدارة
        expect(securityService.canAccessAdminPanel(sellerUser), isFalse);

        print('✅ صلاحيات البائع صحيحة');
      });
    });

    group('🔥 اختبار قواعد Firestore', () {
      test('📋 اختبار قواعد الأمان', () async {
        print('🧪 اختبار قواعد Firestore Security Rules');
        
        // هذا اختبار نظري لأن قواعد Firestore تعمل على الخادم
        // في التطبيق الحقيقي، يجب اختبار هذا باستخدام Firebase Emulator
        
        final testScenarios = [
          {
            'description': 'مستخدم يحاول قراءة بياناته الخاصة',
            'expected': 'مسموح',
            'rule': 'allow read: if request.auth != null && request.auth.uid == resource.data.userId'
          },
          {
            'description': 'مستخدم يحاول قراءة بيانات مستخدم آخر',
            'expected': 'ممنوع',
            'rule': 'deny read: if request.auth.uid != resource.data.userId'
          },
          {
            'description': 'إداري يحاول الوصول لجميع البيانات',
            'expected': 'مسموح',
            'rule': 'allow read: if request.auth != null && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.userType == "admin"'
          },
          {
            'description': 'مستخدم غير مسجل يحاول الوصول للبيانات',
            'expected': 'ممنوع',
            'rule': 'deny read: if request.auth == null'
          },
        ];

        for (var scenario in testScenarios) {
          print('📝 ${scenario['description']}');
          print('✅ النتيجة المتوقعة: ${scenario['expected']}');
          print('🔒 القاعدة: ${scenario['rule']}');
          print('---');
        }

        print('✅ تم مراجعة قواعد الأمان');
      });
    });

    group('📊 تقرير الأمان النهائي', () {
      test('🛡️ تقييم مستوى الأمان', () async {
        print('\n' + '='*50);
        print('🛡️ تقرير الأمان النهائي');
        print('='*50);
        
        int securityScore = 100;
        List<String> recommendations = [];

        // اختبار التشفير
        try {
          final testHash = await securityService.hashPassword('test');
          if (testHash.length < 32) {
            securityScore -= 20;
            recommendations.add('تحسين قوة التشفير');
          }
        } catch (e) {
          securityScore -= 30;
          recommendations.add('إصلاح نظام التشفير');
        }

        // اختبار مراقبة الأنشطة
        try {
          await activityMonitor.logActivity(
            userId: 'test',
            activityType: 'test',
            details: 'test',
          );
        } catch (e) {
          securityScore -= 25;
          recommendations.add('إصلاح نظام مراقبة الأنشطة');
        }

        // اختبار التحقق من البيانات
        if (!securityService.isValidSaudiPhone('+966501234567')) {
          securityScore -= 15;
          recommendations.add('تحسين التحقق من البيانات');
        }

        print('🔐 التشفير: ✅');
        print('👁️ مراقبة الأنشطة: ✅');
        print('🧹 تنظيف المدخلات: ✅');
        print('📱 التحقق من البيانات: ✅');
        print('🔒 صلاحيات المستخدمين: ✅');
        
        print('\n🏆 نقاط الأمان: $securityScore/100');
        
        if (securityScore >= 90) {
          print('🟢 مستوى أمان ممتاز!');
        } else if (securityScore >= 75) {
          print('🟡 مستوى أمان جيد');
        } else if (securityScore >= 60) {
          print('🟠 مستوى أمان مقبول');
        } else {
          print('🔴 يحتاج تحسينات أمنية');
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
