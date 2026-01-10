import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tashlehekomv2/models/notification_model.dart';
import 'package:tashlehekomv2/models/favorite_model.dart';
import 'package:tashlehekomv2/models/chat_model.dart';
import 'package:tashlehekomv2/models/report_model.dart';
import 'package:tashlehekomv2/models/car_model.dart';

class DatabaseServiceExtended {
  static final DatabaseServiceExtended instance = DatabaseServiceExtended._init();
  static Database? _database;

  DatabaseServiceExtended._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tashlehekomv2_extended.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
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
        read_at TEXT
      )
    ''');

    // Favorites table
    await db.execute('''
      CREATE TABLE favorites (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        car_id TEXT NOT NULL,
        created_at TEXT NOT NULL,
        UNIQUE(user_id, car_id)
      )
    ''');

    // Saved searches table
    await db.execute('''
      CREATE TABLE saved_searches (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL,
        search_criteria TEXT NOT NULL,
        is_active INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        last_notified TEXT
      )
    ''');

    // Chats table
    await db.execute('''
      CREATE TABLE chats (
        id TEXT PRIMARY KEY,
        sender_id TEXT NOT NULL,
        receiver_id TEXT NOT NULL,
        car_id TEXT,
        created_at TEXT NOT NULL,
        last_message_at TEXT,
        is_active INTEGER DEFAULT 1
      )
    ''');

    // Messages table
    await db.execute('''
      CREATE TABLE messages (
        id TEXT PRIMARY KEY,
        chat_id TEXT NOT NULL,
        sender_id TEXT NOT NULL,
        content TEXT NOT NULL,
        type INTEGER DEFAULT 0,
        attachment_url TEXT,
        is_read INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        read_at TEXT,
        FOREIGN KEY (chat_id) REFERENCES chats (id)
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
        resolved_at TEXT
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_notifications_user_id ON notifications(user_id)');
    await db.execute('CREATE INDEX idx_favorites_user_id ON favorites(user_id)');
    await db.execute('CREATE INDEX idx_messages_chat_id ON messages(chat_id)');
    await db.execute('CREATE INDEX idx_reports_status ON reports(status)');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
    if (oldVersion < 2) {
      // Add new tables or columns
    }
  }

  // Notification methods
  Future<void> insertNotification(NotificationModel notification) async {
    final db = await database;
    await db.insert('notifications', notification.toMap());
  }

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

  Future<void> deleteNotification(String notificationId) async {
    final db = await database;
    await db.delete(
      'notifications',
      where: 'id = ?',
      whereArgs: [notificationId],
    );
  }

  Future<void> clearAllNotifications(String userId) async {
    final db = await database;
    await db.delete(
      'notifications',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  // Favorites methods
  Future<void> insertFavorite(FavoriteModel favorite) async {
    final db = await database;
    await db.insert('favorites', favorite.toMap());
  }

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

  Future<void> removeFavorite(String userId, String carId) async {
    final db = await database;
    await db.delete(
      'favorites',
      where: 'user_id = ? AND car_id = ?',
      whereArgs: [userId, carId],
    );
  }

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

  // Saved searches methods
  Future<void> insertSavedSearch(SavedSearchModel savedSearch) async {
    final db = await database;
    final map = savedSearch.toMap();
    map['search_criteria'] = map['search_criteria'].toString();
    await db.insert('saved_searches', map);
  }

  Future<List<SavedSearchModel>> getUserSavedSearches(String userId) async {
    final db = await database;
    final maps = await db.query(
      'saved_searches',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => SavedSearchModel.fromMap(map)).toList();
  }

  Future<void> deleteSavedSearch(String searchId) async {
    final db = await database;
    await db.delete(
      'saved_searches',
      where: 'id = ?',
      whereArgs: [searchId],
    );
  }

  Future<void> updateSavedSearchStatus(String searchId, bool isActive) async {
    final db = await database;
    await db.update(
      'saved_searches',
      {'is_active': isActive ? 1 : 0},
      where: 'id = ?',
      whereArgs: [searchId],
    );
  }

  Future<List<SavedSearchModel>> getActiveSavedSearches() async {
    final db = await database;
    final maps = await db.query(
      'saved_searches',
      where: 'is_active = 1',
    );
    return maps.map((map) => SavedSearchModel.fromMap(map)).toList();
  }

  Future<void> updateSavedSearchLastNotified(String searchId, DateTime lastNotified) async {
    final db = await database;
    await db.update(
      'saved_searches',
      {'last_notified': lastNotified.toIso8601String()},
      where: 'id = ?',
      whereArgs: [searchId],
    );
  }

  Future<List<CarModel>> searchCarsWithCriteria(
    Map<String, dynamic> criteria,
    DateTime since,
  ) async {
    final db = await database;
    
    String whereClause = 'created_at > ?';
    List<dynamic> whereArgs = [since.toIso8601String()];
    
    if (criteria['brand'] != null) {
      whereClause += ' AND brand = ?';
      whereArgs.add(criteria['brand']);
    }
    
    if (criteria['city'] != null) {
      whereClause += ' AND city = ?';
      whereArgs.add(criteria['city']);
    }
    
    if (criteria['minYear'] != null) {
      whereClause += ' AND manufacturing_years LIKE ?';
      whereArgs.add('%${criteria['minYear']}%');
    }
    
    final maps = await db.query(
      'cars',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'created_at DESC',
    );
    
    return maps.map((map) => CarModel.fromMap(map)).toList();
  }

  Future<void> cleanupFavorites() async {
    final db = await database;
    await db.execute('''
      DELETE FROM favorites 
      WHERE car_id NOT IN (SELECT id FROM cars)
    ''');
  }

  // Reports methods
  Future<void> insertReport(ReportModel report) async {
    final db = await database;
    final map = report.toMap();
    if (map['attachments'] != null) {
      map['attachments'] = map['attachments'].toString();
    }
    await db.insert('reports', map);
  }

  Future<List<ReportModel>> getAllReports(ReportStatus? status) async {
    final db = await database;
    String? whereClause;
    List<dynamic>? whereArgs;
    
    if (status != null) {
      whereClause = 'status = ?';
      whereArgs = [status.index];
    }
    
    final maps = await db.query(
      'reports',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'created_at DESC',
    );
    
    return maps.map((map) => ReportModel.fromMap(map)).toList();
  }

  Future<void> updateReportStatus(String reportId, ReportStatus status) async {
    final db = await database;
    final updateData = {'status': status.index};
    
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

  // Chat methods
  Future<void> insertChat(ChatModel chat) async {
    final db = await database;
    await db.insert('chats', chat.toMap());
  }

  Future<void> insertMessage(MessageModel message) async {
    final db = await database;
    await db.insert('messages', message.toMap());
    
    // Update chat's last message time
    await db.update(
      'chats',
      {'last_message_at': message.createdAt.toIso8601String()},
      where: 'id = ?',
      whereArgs: [message.chatId],
    );
  }

  Future<List<ChatModel>> getUserChats(String userId) async {
    final db = await database;
    final maps = await db.query(
      'chats',
      where: 'sender_id = ? OR receiver_id = ?',
      whereArgs: [userId, userId],
      orderBy: 'last_message_at DESC',
    );
    return maps.map((map) => ChatModel.fromMap(map)).toList();
  }

  Future<List<MessageModel>> getChatMessages(String chatId) async {
    final db = await database;
    final maps = await db.query(
      'messages',
      where: 'chat_id = ?',
      whereArgs: [chatId],
      orderBy: 'created_at ASC',
    );
    return maps.map((map) => MessageModel.fromMap(map)).toList();
  }

  Future<void> markMessagesAsRead(String chatId, String userId) async {
    final db = await database;
    await db.update(
      'messages',
      {
        'is_read': 1,
        'read_at': DateTime.now().toIso8601String(),
      },
      where: 'chat_id = ? AND sender_id != ? AND is_read = 0',
      whereArgs: [chatId, userId],
    );
  }
}
