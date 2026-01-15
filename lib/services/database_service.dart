import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../models/car_model.dart';
import '../models/rating_model.dart';
import '../models/admin_approval_model.dart';
import '../models/favorite_model.dart';
import '../models/report_model.dart';
import '../models/notification_model.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tashlehekomv2.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // إضافة جدول البلاغات
      await db.execute('''
        CREATE TABLE reports (
          id TEXT PRIMARY KEY,
          reporter_id TEXT NOT NULL,
          reported_user_id TEXT,
          reported_car_id TEXT,
          type INTEGER NOT NULL,
          reason TEXT NOT NULL,
          description TEXT,
          attachments TEXT,
          status INTEGER DEFAULT 0,
          admin_response TEXT,
          created_at TEXT NOT NULL,
          resolved_at TEXT,
          FOREIGN KEY (reporter_id) REFERENCES users (id),
          FOREIGN KEY (reported_user_id) REFERENCES users (id),
          FOREIGN KEY (reported_car_id) REFERENCES cars (id)
        )
      ''');

      // إضافة جدول الإشعارات
      await db.execute('''
        CREATE TABLE notifications (
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL,
          title TEXT NOT NULL,
          body TEXT NOT NULL,
          type INTEGER NOT NULL,
          related_id TEXT,
          data TEXT,
          is_read INTEGER DEFAULT 0,
          created_at TEXT NOT NULL,
          read_at TEXT,
          FOREIGN KEY (user_id) REFERENCES users (id)
        )
      ''');
    }
  }

  Future _createDB(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        username TEXT NOT NULL,
        phone_number TEXT NOT NULL UNIQUE,
        user_type INTEGER NOT NULL,
        city TEXT,
        is_active INTEGER DEFAULT 1,
        is_approved INTEGER DEFAULT 0,
        junkyard TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT
      )
    ''');

    // Insert Super Admin account
    await db.execute('''
      INSERT INTO users (id, username, phone_number, user_type, city, is_active, is_approved, created_at)
      VALUES ('super_admin_001', 'superadmin', '+966508423246', 3, 'خميس مشيط', 1, 1, '${DateTime.now().toIso8601String()}')
    ''');

    // Admin users table
    await db.execute('''
      CREATE TABLE admin_users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        phone TEXT UNIQUE NOT NULL,
        email TEXT NOT NULL,
        role TEXT NOT NULL,
        permissions TEXT NOT NULL,
        isActive INTEGER NOT NULL DEFAULT 1,
        createdAt TEXT NOT NULL,
        lastLoginAt TEXT
      )
    ''');

    // Insert default admin
    await db.execute('''
      INSERT INTO admin_users (id, name, phone, email, role, permissions, isActive, createdAt)
      VALUES (
        'admin_001',
        'المدير العام',
        '+966508423246',
        'acc.ibrahim.arboud@gmail.com',
        'superAdmin',
        'viewCars,approveCars,rejectCars,editCars,deleteCars,manageUsers,viewReports,manageSettings,viewAnalytics,manageAdmins',
        1,
        '${DateTime.now().toIso8601String()}'
      )
    ''');

    // Pending cars table (للسيارات المعلقة للموافقة)
    await db.execute('''
      CREATE TABLE pending_cars (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        userName TEXT NOT NULL,
        userPhone TEXT NOT NULL,
        brand TEXT NOT NULL,
        model TEXT NOT NULL,
        year INTEGER NOT NULL,
        city TEXT NOT NULL,
        price REAL NOT NULL,
        condition TEXT NOT NULL,
        description TEXT NOT NULL,
        images TEXT NOT NULL,
        submittedAt TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending',
        adminNotes TEXT,
        rejectionReason TEXT,
        reviewedAt TEXT,
        reviewedBy TEXT
      )
    ''');

    // Approval actions table (تاريخ إجراءات الموافقة)
    await db.execute('''
      CREATE TABLE approval_actions (
        id TEXT PRIMARY KEY,
        pendingCarId TEXT NOT NULL,
        adminId TEXT NOT NULL,
        adminName TEXT NOT NULL,
        action TEXT NOT NULL,
        notes TEXT,
        rejectionReason TEXT,
        actionDate TEXT NOT NULL,
        FOREIGN KEY (pendingCarId) REFERENCES pending_cars (id),
        FOREIGN KEY (adminId) REFERENCES admin_users (id)
      )
    ''');

    // Cars table
    await db.execute('''
      CREATE TABLE cars (
        id TEXT PRIMARY KEY,
        seller_id TEXT NOT NULL,
        seller_name TEXT NOT NULL,
        brand TEXT NOT NULL,
        model TEXT NOT NULL,
        manufacturing_years TEXT NOT NULL,
        color TEXT,
        city TEXT NOT NULL,
        vin_number TEXT UNIQUE,
        vin_image TEXT,
        images TEXT NOT NULL,
        latitude REAL,
        longitude REAL,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        is_active INTEGER DEFAULT 1,
        FOREIGN KEY (seller_id) REFERENCES users (id)
      )
    ''');

    // Ratings table
    await db.execute('''
      CREATE TABLE ratings (
        id TEXT PRIMARY KEY,
        seller_id TEXT NOT NULL,
        buyer_id TEXT NOT NULL,
        response_speed REAL NOT NULL,
        cleanliness REAL NOT NULL,
        comment TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (seller_id) REFERENCES users (id),
        FOREIGN KEY (buyer_id) REFERENCES users (id)
      )
    ''');

    // Car brands table
    await db.execute('''
      CREATE TABLE car_brands (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      )
    ''');

    // Car models table
    await db.execute('''
      CREATE TABLE car_models (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        brand_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        FOREIGN KEY (brand_id) REFERENCES car_brands (id)
      )
    ''');

    // Cities table
    await db.execute('''
      CREATE TABLE cities (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      )
    ''');

    // Favorites table
    await db.execute('''
      CREATE TABLE favorites (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        car_id TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (car_id) REFERENCES cars (id),
        UNIQUE(user_id, car_id)
      )
    ''');

    // Reports table
    await db.execute('''
      CREATE TABLE reports (
        id TEXT PRIMARY KEY,
        reporter_id TEXT NOT NULL,
        reported_user_id TEXT,
        reported_car_id TEXT,
        type INTEGER NOT NULL,
        reason TEXT NOT NULL,
        description TEXT,
        attachments TEXT,
        status INTEGER DEFAULT 0,
        admin_response TEXT,
        created_at TEXT NOT NULL,
        resolved_at TEXT,
        FOREIGN KEY (reporter_id) REFERENCES users (id),
        FOREIGN KEY (reported_user_id) REFERENCES users (id),
        FOREIGN KEY (reported_car_id) REFERENCES cars (id)
      )
    ''');

    // Notifications table
    await db.execute('''
      CREATE TABLE notifications (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        type INTEGER NOT NULL,
        related_id TEXT,
        data TEXT,
        is_read INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        read_at TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Insert default data
    await _insertDefaultData(db);
  }

  Future _insertDefaultData(Database db) async {
    // Insert car brands
    final brands = [
      'تويوتا',
      'نيسان',
      'هوندا',
      'هيونداي',
      'كيا',
      'مازدا',
      'سوزوكي',
      'ميتسوبيشي',
      'فورد',
      'شيفروليه',
      'جي إم سي',
      'بي إم دبليو',
      'مرسيدس',
      'أودي',
      'فولكس واجن',
      'لكزس',
      'إنفينيتي',
      'أكورا',
      'جاكوار',
      'لاند روفر'
    ];

    for (String brand in brands) {
      await db.insert('car_brands', {'name': brand});
    }

    // Insert cities - جميع المدن السعودية الرئيسية
    final cities = [
      // المنطقة الوسطى
      'الرياض',
      'الخرج',
      'الدوادمي',
      'المجمعة',
      'الزلفي',
      'وادي الدواسر',
      'الأفلاج',
      'حوطة بني تميم',
      'عفيف',
      'السليل',
      'ضرما',
      'المزاحمية',
      'رماح',
      'ثادق',
      'حريملاء',
      'الحريق',
      'الغاط',
      'الدرعية',
      // المنطقة الغربية
      'جدة',
      'مكة المكرمة',
      'المدينة المنورة',
      'الطائف',
      'ينبع',
      'رابغ',
      'القنفذة',
      'الليث',
      'خليص',
      'الجموم',
      'بحرة',
      // المنطقة الشرقية
      'الدمام',
      'الخبر',
      'الظهران',
      'الأحساء',
      'الهفوف',
      'المبرز',
      'الجبيل',
      'القطيف',
      'رأس تنورة',
      'بقيق',
      'الخفجي',
      'النعيرية',
      'قرية العليا',
      'حفر الباطن',
      // المنطقة الشمالية
      'حائل',
      'بريدة',
      'عنيزة',
      'الرس',
      'البكيرية',
      'البدائع',
      'المذنب',
      'رياض الخبراء',
      'عيون الجواء',
      'الشماسية',
      // منطقة تبوك
      'تبوك',
      'الوجه',
      'ضباء',
      'تيماء',
      'أملج',
      'حقل',
      'البدع',
      // منطقة الجوف
      'سكاكا',
      'القريات',
      'دومة الجندل',
      'طبرجل',
      // منطقة الحدود الشمالية
      'عرعر',
      'رفحاء',
      'طريف',
      'العويقيلة',
      // منطقة عسير
      'أبها',
      'خميس مشيط',
      'بيشة',
      'النماص',
      'محايل عسير',
      'سراة عبيدة',
      'أحد رفيدة',
      'ظهران الجنوب',
      'تثليث',
      'رجال ألمع',
      'بلقرن',
      // منطقة جازان
      'جازان',
      'صبيا',
      'أبو عريش',
      'صامطة',
      'الدرب',
      'فرسان',
      'الريث',
      'فيفا',
      // منطقة نجران
      'نجران',
      'شرورة',
      'حبونا',
      'بدر الجنوب',
      // منطقة الباحة
      'الباحة',
      'بلجرشي',
      'المندق',
      'المخواة',
      'قلوة',
      'العقيق',
    ];

    for (String city in cities) {
      await db.insert('cities', {'name': city});
    }
  }

  // User operations
  Future<String> createUser(UserModel user) async {
    final db = await instance.database;
    await db.insert('users', user.toMap());
    return user.id;
  }

  Future<UserModel?> getUser(String id) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  Future<UserModel?> getUserByPhone(String phoneNumber) async {
    final db = await instance.database;

    // تنسيق رقم الهاتف للبحث
    final normalizedPhone = phoneNumber;
    var alternativePhone = phoneNumber;

    // إذا كان الرقم يبدأ بـ 0، أضف رمز البلد
    if (phoneNumber.startsWith('0')) {
      alternativePhone = '+966${phoneNumber.substring(1)}';
    }
    // إذا كان الرقم يبدأ بـ +966، أنشئ النسخة بدون رمز البلد
    else if (phoneNumber.startsWith('+966')) {
      alternativePhone = '0${phoneNumber.substring(4)}';
    }

    // البحث بكلا الصيغتين
    final maps = await db.query(
      'users',
      where: 'phone_number = ? OR phone_number = ?',
      whereArgs: [normalizedPhone, alternativePhone],
    );

    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  Future<UserModel?> getUserById(String userId) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  Future<List<UserModel>> getAllUsers() async {
    final db = await instance.database;
    final result = await db.query('users');
    return result.map((json) => UserModel.fromMap(json)).toList();
  }

  Future<int> updateUser(UserModel user) async {
    final db = await instance.database;
    return db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // إضافة سيارة للموافقة (بدلاً من الإضافة المباشرة)
  Future<String> submitCarForApproval({
    required String userId,
    required String userName,
    required String userPhone,
    required String brand,
    required String model,
    required int year,
    required String city,
    required double price,
    required String condition,
    required String description,
    required List<String> images,
  }) async {
    final db = await instance.database;
    const uuid = Uuid();
    final carId = uuid.v4();

    final pendingCar = {
      'id': carId,
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'brand': brand,
      'model': model,
      'year': year,
      'city': city,
      'price': price,
      'condition': condition,
      'description': description,
      'images': images.join(','),
      'submittedAt': DateTime.now().toIso8601String(),
      'status': 'pending',
    };

    await db.insert('pending_cars', pendingCar);
    return carId;
  }

  // الحصول على السيارات المعلقة للموافقة
  Future<List<Map<String, dynamic>>> getPendingCars({String? status}) async {
    final db = await instance.database;

    if (status != null) {
      return await db.query(
        'pending_cars',
        where: 'status = ?',
        whereArgs: [status],
        orderBy: 'submittedAt DESC',
      );
    } else {
      return await db.query(
        'pending_cars',
        orderBy: 'submittedAt DESC',
      );
    }
  }

  // الموافقة على السيارة ونقلها لقاعدة البيانات الرئيسية
  Future<bool> approveCar(String pendingCarId, String adminId, String adminName,
      {String? notes}) async {
    final db = await instance.database;
    const uuid = Uuid();

    try {
      return await db.transaction((txn) async {
        // الحصول على بيانات السيارة المعلقة
        final pendingResult = await txn.query(
          'pending_cars',
          where: 'id = ?',
          whereArgs: [pendingCarId],
        );

        if (pendingResult.isEmpty) return false;

        final pendingCar = pendingResult.first;

        // إضافة السيارة لقاعدة البيانات الرئيسية
        final approvedCar = {
          'id': uuid.v4(),
          'seller_id': pendingCar['userId'],
          'seller_name': pendingCar['userName'],
          'brand': pendingCar['brand'],
          'model': pendingCar['model'],
          'manufacturing_years': pendingCar['year'].toString(),
          'city': pendingCar['city'],
          'images': pendingCar['images'],
          'created_at': DateTime.now().toIso8601String(),
          'is_active': 1,
        };

        await txn.insert('cars', approvedCar);

        // تحديث حالة السيارة المعلقة
        await txn.update(
          'pending_cars',
          {
            'status': 'approved',
            'adminNotes': notes,
            'reviewedAt': DateTime.now().toIso8601String(),
            'reviewedBy': adminName,
          },
          where: 'id = ?',
          whereArgs: [pendingCarId],
        );

        // تسجيل الإجراء
        await txn.insert('approval_actions', {
          'id': uuid.v4(),
          'pendingCarId': pendingCarId,
          'adminId': adminId,
          'adminName': adminName,
          'action': 'approved',
          'notes': notes,
          'actionDate': DateTime.now().toIso8601String(),
        });

        return true;
      });
    } catch (e) {
      print('خطأ في الموافقة على السيارة: $e');
      return false;
    }
  }

  // رفض السيارة
  Future<bool> rejectCar(String pendingCarId, String adminId, String adminName,
      String rejectionReason,
      {String? notes}) async {
    final db = await instance.database;
    const uuid = Uuid();

    try {
      return await db.transaction((txn) async {
        // تحديث حالة السيارة المعلقة
        await txn.update(
          'pending_cars',
          {
            'status': 'rejected',
            'rejectionReason': rejectionReason,
            'adminNotes': notes,
            'reviewedAt': DateTime.now().toIso8601String(),
            'reviewedBy': adminName,
          },
          where: 'id = ?',
          whereArgs: [pendingCarId],
        );

        // تسجيل الإجراء
        await txn.insert('approval_actions', {
          'id': uuid.v4(),
          'pendingCarId': pendingCarId,
          'adminId': adminId,
          'adminName': adminName,
          'action': 'rejected',
          'rejectionReason': rejectionReason,
          'notes': notes,
          'actionDate': DateTime.now().toIso8601String(),
        });

        return true;
      });
    } catch (e) {
      print('خطأ في رفض السيارة: $e');
      return false;
    }
  }

  // طلب تعديل السيارة
  Future<bool> requestRevision(
      String pendingCarId, String adminId, String adminName,
      {String? notes}) async {
    final db = await instance.database;
    const uuid = Uuid();

    try {
      return await db.transaction((txn) async {
        // تحديث حالة السيارة المعلقة
        await txn.update(
          'pending_cars',
          {
            'status': 'needsRevision',
            'adminNotes': notes,
            'reviewedAt': DateTime.now().toIso8601String(),
            'reviewedBy': adminName,
          },
          where: 'id = ?',
          whereArgs: [pendingCarId],
        );

        // تسجيل الإجراء
        await txn.insert('approval_actions', {
          'id': uuid.v4(),
          'pendingCarId': pendingCarId,
          'adminId': adminId,
          'adminName': adminName,
          'action': 'needsRevision',
          'notes': notes,
          'actionDate': DateTime.now().toIso8601String(),
        });

        return true;
      });
    } catch (e) {
      print('خطأ في طلب التعديل: $e');
      return false;
    }
  }

  // Car operations
  Future<String> createCar(CarModel car) async {
    final db = await instance.database;
    await db.insert('cars', car.toMap());
    return car.id;
  }

  Future<List<CarModel>> getAllCars() async {
    final db = await instance.database;
    final result = await db.query('cars', where: 'is_active = 1');
    return result.map((json) => CarModel.fromMap(json)).toList();
  }

  Future<List<CarModel>> getCarsBySeller(String sellerId) async {
    final db = await instance.database;
    final result = await db.query(
      'cars',
      where: 'seller_id = ? AND is_active = 1',
      whereArgs: [sellerId],
    );
    return result.map((json) => CarModel.fromMap(json)).toList();
  }

  // Rating operations
  Future<String> createRating(RatingModel rating) async {
    final db = await instance.database;
    await db.insert('ratings', rating.toMap());
    return rating.id;
  }

  Future<List<RatingModel>> getRatingsBySeller(String sellerId) async {
    final db = await instance.database;
    final result = await db.query(
      'ratings',
      where: 'seller_id = ?',
      whereArgs: [sellerId],
    );
    return result.map((json) => RatingModel.fromMap(json)).toList();
  }

  // Utility methods
  Future<List<String>> getCarBrands() async {
    final db = await instance.database;
    final result = await db.query('car_brands');
    return result.map((e) => e['name'] as String).toList();
  }

  Future<List<String>> getCities() async {
    final db = await instance.database;
    final result = await db.query('cities');
    return result.map((e) => e['name'] as String).toList();
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  // إضافة بيانات تجريبية للسيارات وقطع الغيار
  Future<void> addSampleData() async {
    final db = await database;

    // إضافة مستخدمين تجريبيين
    await _addSampleUsers(db);

    // إضافة سيارات تجريبية
    await _addSampleCars(db);

    // إضافة قطع غيار تجريبية
    await _addSampleParts(db);
  }

  Future<void> _addSampleUsers(Database db) async {
    final users = [
      {
        'id': 'user_001',
        'username': 'أحمد محمد',
        'phone_number': '0501234567',
        'user_type': 1, // بائع
        'city': 'الرياض',
        'is_active': 1,
        'is_approved': 1,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'user_002',
        'username': 'سارة أحمد',
        'phone_number': '0507654321',
        'user_type': 1,
        'city': 'جدة',
        'is_active': 1,
        'is_approved': 1,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'user_003',
        'username': 'محمد علي',
        'phone_number': '0509876543',
        'user_type': 2, // تشليح
        'city': 'الدمام',
        'junkyard': 'تشليح الشرق',
        'is_active': 1,
        'is_approved': 1,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'user_004',
        'username': 'فاطمة خالد',
        'phone_number': '0502468135',
        'user_type': 1,
        'city': 'مكة المكرمة',
        'is_active': 1,
        'is_approved': 1,
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'id': 'user_005',
        'username': 'عبدالله سعد',
        'phone_number': '0508642097',
        'user_type': 2,
        'city': 'المدينة المنورة',
        'junkyard': 'تشليح المدينة',
        'is_active': 1,
        'is_approved': 1,
        'created_at': DateTime.now().toIso8601String(),
      },
    ];

    for (var user in users) {
      try {
        await db.insert('users', user,
            conflictAlgorithm: ConflictAlgorithm.ignore);
      } catch (e) {
        print('خطأ في إضافة المستخدم: $e');
      }
    }
  }

  Future<void> _addSampleCars(Database db) async {
    final cars = [
      {
        'id': 'car_001',
        'seller_id': 'user_001',
        'seller_name': 'أحمد محمد',
        'brand': 'تويوتا',
        'model': 'كامري',
        'manufacturing_years': '2020',
        'color': 'أبيض',
        'city': 'الرياض',
        'vin_number': 'JTDKN3DU5L0123456',
        'images': '["car_placeholder_white", "car_placeholder_white"]',
        'created_at': DateTime.now().toIso8601String(),
        'is_active': 1,
      },
      {
        'id': 'car_002',
        'seller_id': 'user_002',
        'seller_name': 'سارة أحمد',
        'brand': 'هوندا',
        'model': 'أكورد',
        'manufacturing_years': '2019',
        'color': 'أسود',
        'city': 'جدة',
        'vin_number': 'JHMCV6F16KC123456',
        'images': '["car_placeholder_black", "car_placeholder_black"]',
        'created_at': DateTime.now().toIso8601String(),
        'is_active': 1,
      },
      {
        'id': 'car_003',
        'seller_id': 'user_001',
        'seller_name': 'أحمد محمد',
        'brand': 'نيسان',
        'model': 'التيما',
        'manufacturing_years': '2021',
        'color': 'فضي',
        'city': 'الرياض',
        'vin_number': 'JNKCV51E53M123456',
        'images': '["car_placeholder_silver", "car_placeholder_silver"]',
        'created_at': DateTime.now().toIso8601String(),
        'is_active': 1,
      },
      {
        'id': 'car_004',
        'seller_id': 'user_004',
        'seller_name': 'فاطمة خالد',
        'brand': 'هيونداي',
        'model': 'إلنترا',
        'manufacturing_years': '2018',
        'color': 'أحمر',
        'city': 'مكة المكرمة',
        'vin_number': 'KMHD14JA5JA123456',
        'images': '["car_placeholder_red", "car_placeholder_red"]',
        'created_at': DateTime.now().toIso8601String(),
        'is_active': 1,
      },
      {
        'id': 'car_005',
        'seller_id': 'user_002',
        'seller_name': 'سارة أحمد',
        'brand': 'لكزس',
        'model': 'ES',
        'manufacturing_years': '2022',
        'color': 'أبيض لؤلؤي',
        'city': 'جدة',
        'vin_number': 'JTHBK1GG5N2123456',
        'images': '["car_placeholder_pearl", "car_placeholder_pearl"]',
        'created_at': DateTime.now().toIso8601String(),
        'is_active': 1,
      },
    ];

    for (var car in cars) {
      try {
        await db.insert('cars', car,
            conflictAlgorithm: ConflictAlgorithm.ignore);
      } catch (e) {
        print('خطأ في إضافة السيارة: $e');
      }
    }
  }

  Future<void> _addSampleParts(Database db) async {
    // التحقق من وجود جدول قطع الغيار
    final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='parts'");

    if (tables.isEmpty) {
      // إنشاء جدول قطع الغيار إذا لم يكن موجوداً
      await db.execute('''
        CREATE TABLE parts (
          id TEXT PRIMARY KEY,
          seller_id TEXT NOT NULL,
          seller_name TEXT NOT NULL,
          part_name TEXT NOT NULL,
          part_number TEXT,
          compatible_cars TEXT NOT NULL,
          condition TEXT NOT NULL,
          price REAL NOT NULL,
          description TEXT,
          images TEXT NOT NULL,
          city TEXT NOT NULL,
          created_at TEXT NOT NULL,
          updated_at TEXT,
          is_active INTEGER DEFAULT 1,
          FOREIGN KEY (seller_id) REFERENCES users (id)
        )
      ''');
    }

    final parts = [
      {
        'id': 'part_001',
        'seller_id': 'user_003',
        'seller_name': 'محمد علي - تشليح الشرق',
        'part_name': 'محرك كامل',
        'part_number': '2AR-FE',
        'compatible_cars': 'تويوتا كامري 2018-2022',
        'condition': 'مستعمل - حالة ممتازة',
        'price': 8500.0,
        'description':
            'محرك تويوتا كامري 2.5 لتر، تم فحصه بالكامل، يعمل بكفاءة عالية',
        'images': '["part_placeholder_engine", "part_placeholder_engine"]',
        'city': 'الدمام',
        'created_at': DateTime.now().toIso8601String(),
        'is_active': 1,
      },
      {
        'id': 'part_002',
        'seller_id': 'user_005',
        'seller_name': 'عبدالله سعد - تشليح المدينة',
        'part_name': 'علبة فتيس أوتوماتيك',
        'part_number': 'CVT-7',
        'compatible_cars': 'نيسان التيما 2019-2023',
        'condition': 'مستعمل - حالة جيدة جداً',
        'price': 4200.0,
        'description': 'علبة فتيس CVT نيسان، تم صيانتها وتغيير الزيت',
        'images':
            '["part_placeholder_transmission", "part_placeholder_transmission"]',
        'city': 'المدينة المنورة',
        'created_at': DateTime.now().toIso8601String(),
        'is_active': 1,
      },
      {
        'id': 'part_003',
        'seller_id': 'user_003',
        'seller_name': 'محمد علي - تشليح الشرق',
        'part_name': 'مقاعد جلد كاملة',
        'part_number': 'SEAT-SET-01',
        'compatible_cars': 'لكزس ES 2019-2023',
        'condition': 'مستعمل - حالة ممتازة',
        'price': 3800.0,
        'description': 'طقم مقاعد جلد لكزس ES، لون بيج، بحالة ممتازة بدون تمزق',
        'images': '["part_placeholder_seats", "part_placeholder_seats"]',
        'city': 'الدمام',
        'created_at': DateTime.now().toIso8601String(),
        'is_active': 1,
      },
      {
        'id': 'part_004',
        'seller_id': 'user_005',
        'seller_name': 'عبدالله سعد - تشليح المدينة',
        'part_name': 'شاشة نافيجيشن',
        'part_number': 'NAV-HONDA-2020',
        'compatible_cars': 'هوندا أكورد 2018-2022',
        'condition': 'مستعمل - حالة ممتازة',
        'price': 1850.0,
        'description': 'شاشة نافيجيشن هوندا أكورد الأصلية، تعمل بكفاءة عالية',
        'images': '["part_placeholder_screen", "part_placeholder_screen"]',
        'city': 'المدينة المنورة',
        'created_at': DateTime.now().toIso8601String(),
        'is_active': 1,
      },
      {
        'id': 'part_005',
        'seller_id': 'user_003',
        'seller_name': 'محمد علي - تشليح الشرق',
        'part_name': 'كمبروسر مكيف',
        'part_number': 'AC-COMP-HY',
        'compatible_cars': 'هيونداي إلنترا 2017-2021',
        'condition': 'مستعمل - حالة جيدة',
        'price': 950.0,
        'description': 'كمبروسر مكيف هيونداي إلنترا، تم فحصه وهو يعمل بكفاءة',
        'images': '["part_placeholder_ac", "part_placeholder_ac"]',
        'city': 'الدمام',
        'created_at': DateTime.now().toIso8601String(),
        'is_active': 1,
      },
      {
        'id': 'part_006',
        'seller_id': 'user_005',
        'seller_name': 'عبدالله سعد - تشليح المدينة',
        'part_name': 'جنوط أصلية',
        'part_number': 'WHEEL-TOY-18',
        'compatible_cars': 'تويوتا كامري 2018-2023',
        'condition': 'مستعمل - حالة جيدة جداً',
        'price': 1200.0,
        'description': 'طقم جنوط تويوتا كامري الأصلية مقاس 18 بوصة، بدون خدوش',
        'images': '["part_placeholder_wheels", "part_placeholder_wheels"]',
        'city': 'المدينة المنورة',
        'created_at': DateTime.now().toIso8601String(),
        'is_active': 1,
      },
    ];

    for (var part in parts) {
      try {
        await db.insert('parts', part,
            conflictAlgorithm: ConflictAlgorithm.ignore);
      } catch (e) {
        print('خطأ في إضافة قطعة الغيار: $e');
      }
    }
  }

  // دالة للحصول على جميع قطع الغيار
  Future<List<Map<String, dynamic>>> getAllParts() async {
    final db = await database;
    return await db.query('parts', where: 'is_active = ?', whereArgs: [1]);
  }

  // دالة للبحث في قطع الغيار
  Future<List<Map<String, dynamic>>> searchParts(String query) async {
    final db = await database;
    return await db.query(
      'parts',
      where:
          'is_active = ? AND (part_name LIKE ? OR compatible_cars LIKE ? OR description LIKE ?)',
      whereArgs: [1, '%$query%', '%$query%', '%$query%'],
    );
  }

  // دالة لفلترة قطع الغيار حسب المدينة
  Future<List<Map<String, dynamic>>> getPartsByCity(String city) async {
    final db = await database;
    return await db.query(
      'parts',
      where: 'is_active = ? AND city = ?',
      whereArgs: [1, city],
    );
  }

  // ===== دوال المفضلة =====

  // إضافة سيارة للمفضلة
  Future<void> insertFavorite(FavoriteModel favorite) async {
    final db = await database;
    await db.insert('favorites', favorite.toMap());
  }

  // الحصول على مفضلة معينة
  Future<FavoriteModel?> getFavorite(String userId, String carId) async {
    final db = await database;
    final maps = await db.query(
      'favorites',
      where: 'user_id = ? AND car_id = ?',
      whereArgs: [userId, carId],
    );
    if (maps.isNotEmpty) {
      return FavoriteModel.fromMap(maps.first);
    }
    return null;
  }

  // إزالة سيارة من المفضلة
  Future<void> removeFavorite(String userId, String carId) async {
    final db = await database;
    await db.delete(
      'favorites',
      where: 'user_id = ? AND car_id = ?',
      whereArgs: [userId, carId],
    );
  }

  // الحصول على جميع السيارات المفضلة للمستخدم
  Future<List<CarModel>> getUserFavorites(String userId) async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT c.* FROM cars c
      INNER JOIN favorites f ON c.id = f.car_id
      WHERE f.user_id = ?
      ORDER BY f.created_at DESC
    ''', [userId]);
    return maps.map((map) => CarModel.fromMap(map)).toList();
  }

  // ===== دوال البلاغات =====

  // إضافة بلاغ جديد
  Future<void> insertReport(ReportModel report) async {
    final db = await database;
    final map = report.toMap();
    if (map['attachments'] != null) {
      map['attachments'] = map['attachments'].toString();
    }
    await db.insert('reports', map);
  }

  // الحصول على جميع البلاغات (للإدارة)
  Future<List<ReportModel>> getAllReports(ReportStatus? status) async {
    final db = await database;
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (status != null) {
      whereClause = 'WHERE status = ?';
      whereArgs.add(status.index);
    }

    final maps = await db.rawQuery('''
      SELECT * FROM reports
      $whereClause
      ORDER BY created_at DESC
    ''', whereArgs);

    return maps.map((map) => ReportModel.fromMap(map)).toList();
  }

  // تحديث حالة البلاغ
  Future<void> updateReportStatus(String reportId, ReportStatus status) async {
    final db = await database;
    final updateData = <String, dynamic>{'status': status.index};

    if (status == ReportStatus.resolved || status == ReportStatus.closed) {
      updateData['resolved_at'] = DateTime.now().toIso8601String();
    }

    await db.update(
      'reports',
      updateData,
      where: 'id = ?',
      whereArgs: [reportId],
    );
  }

  // الحصول على بلاغات مستخدم معين
  Future<List<ReportModel>> getUserReports(String userId) async {
    final db = await database;
    final maps = await db.query(
      'reports',
      where: 'reporter_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => ReportModel.fromMap(map)).toList();
  }

  // ===== دوال الإشعارات =====

  // إضافة إشعار جديد
  Future<void> insertNotification(NotificationModel notification) async {
    final db = await database;
    final map = notification.toMap();
    if (map['data'] != null) {
      map['data'] = map['data'].toString();
    }
    await db.insert('notifications', map);
  }

  // الحصول على الإشعارات غير المقروءة
  Future<List<NotificationModel>> getUnreadNotifications(String userId) async {
    final db = await database;
    final maps = await db.query(
      'notifications',
      where: 'user_id = ? AND is_read = 0',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => NotificationModel.fromMap(map)).toList();
  }

  // الحصول على جميع إشعارات المستخدم
  Future<List<NotificationModel>> getAllUserNotifications(String userId) async {
    final db = await database;
    final maps = await db.query(
      'notifications',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => NotificationModel.fromMap(map)).toList();
  }

  // الحصول على إشعارات المستخدم (alias للطريقة أعلاه)
  Future<List<NotificationModel>> getUserNotifications(String userId) async {
    return getAllUserNotifications(userId);
  }

  // تحديد إشعار كمقروء
  Future<void> markNotificationAsRead(String notificationId) async {
    final db = await database;
    await db.update(
      'notifications',
      {
        'is_read': 1,
        'read_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [notificationId],
    );
  }

  // تحديث إشعار
  Future<void> updateNotification(NotificationModel notification) async {
    final db = await database;
    final map = notification.toMap();
    if (map['data'] != null) {
      map['data'] = map['data'].toString();
    }
    await db.update(
      'notifications',
      map,
      where: 'id = ?',
      whereArgs: [notification.id],
    );
  }

  // حذف إشعار
  Future<void> deleteNotification(String notificationId) async {
    final db = await database;
    await db.delete(
      'notifications',
      where: 'id = ?',
      whereArgs: [notificationId],
    );
  }

  // مسح جميع الإشعارات لمستخدم
  Future<void> clearAllNotifications(String userId) async {
    final db = await database;
    await db.delete(
      'notifications',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  // ==================== دوال إضافية للنقل ====================

  /// الحصول على جميع ماركات السيارات
  Future<List<Map<String, dynamic>>> getAllCarBrands() async {
    final db = await database;
    return await db.query('car_brands');
  }

  /// الحصول على جميع المدن
  Future<List<Map<String, dynamic>>> getAllCities() async {
    final db = await database;
    return await db.query('cities');
  }

  /// الحصول على جميع المفضلة
  Future<List<FavoriteModel>> getAllFavorites() async {
    final db = await database;
    final result = await db.query('favorites');
    return result.map((json) => FavoriteModel.fromMap(json)).toList();
  }

  /// الحصول على جميع التقييمات
  Future<List<RatingModel>> getAllRatings() async {
    final db = await database;
    final result = await db.query('ratings');
    return result.map((json) => RatingModel.fromMap(json)).toList();
  }

  /// الحصول على جميع الإشعارات
  Future<List<NotificationModel>> getAllNotifications() async {
    final db = await database;
    final result = await db.query('notifications');
    return result.map((json) => NotificationModel.fromMap(json)).toList();
  }

  // ==================== دوال إضافية مفقودة ====================

  /// إدراج مستخدم جديد
  Future<void> insertUser(UserModel user) async {
    final db = await database;
    await db.insert('users', user.toMap());
  }

  /// إدراج سيارة جديدة
  Future<void> insertCar(CarModel car) async {
    final db = await database;
    await db.insert('cars', car.toMap());
  }

  /// البحث في السيارات
  Future<List<CarModel>> searchCars({
    String? brand,
    String? model,
    String? city,
    double? minPrice,
    double? maxPrice,
    int? minYear,
    int? maxYear,
  }) async {
    final db = await database;
    String whereClause = 'is_active = 1';
    List<dynamic> whereArgs = [];

    if (brand != null && brand.isNotEmpty) {
      whereClause += ' AND brand = ?';
      whereArgs.add(brand);
    }

    if (model != null && model.isNotEmpty) {
      whereClause += ' AND model = ?';
      whereArgs.add(model);
    }

    if (city != null && city.isNotEmpty) {
      whereClause += ' AND city = ?';
      whereArgs.add(city);
    }

    final result = await db.query(
      'cars',
      where: whereClause,
      whereArgs: whereArgs,
    );

    List<CarModel> cars = result.map((json) => CarModel.fromMap(json)).toList();

    // تطبيق فلاتر إضافية
    if (minPrice != null) {
      cars = cars.where((car) => car.price >= minPrice).toList();
    }
    if (maxPrice != null) {
      cars = cars.where((car) => car.price <= maxPrice).toList();
    }
    if (minYear != null) {
      cars = cars.where((car) => car.year >= minYear).toList();
    }
    if (maxYear != null) {
      cars = cars.where((car) => car.year <= maxYear).toList();
    }

    return cars;
  }

  /// إضافة للمفضلة
  Future<void> addToFavorites(String userId, String carId) async {
    final db = await database;
    await db.insert('favorites', {
      'id': const Uuid().v4(),
      'user_id': userId,
      'car_id': carId,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  /// إزالة من المفضلة
  Future<void> removeFromFavorites(String userId, String carId) async {
    final db = await database;
    await db.delete(
      'favorites',
      where: 'user_id = ? AND car_id = ?',
      whereArgs: [userId, carId],
    );
  }
}
