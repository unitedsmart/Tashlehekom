import 'package:uuid/uuid.dart';
import '../models/car_model.dart';
import '../models/favorite_model.dart';
import 'database_service.dart';

class FavoritesService {
  static final FavoritesService _instance = FavoritesService._internal();
  factory FavoritesService() => _instance;
  FavoritesService._internal();

  final DatabaseService _db = DatabaseService.instance;

  // إضافة سيارة للمفضلة
  Future<bool> addToFavorites(String userId, String carId) async {
    try {
      // التحقق من عدم وجود السيارة في المفضلة مسبقاً
      final existingFavorite = await _db.getFavorite(userId, carId);
      if (existingFavorite != null) {
        return false; // السيارة موجودة مسبقاً
      }

      final favorite = FavoriteModel(
        id: const Uuid().v4(),
        userId: userId,
        carId: carId,
        createdAt: DateTime.now(),
      );

      await _db.insertFavorite(favorite);
      return true;
    } catch (e) {
      print('Error adding to favorites: $e');
      return false;
    }
  }

  // إزالة سيارة من المفضلة
  Future<bool> removeFromFavorites(String userId, String carId) async {
    try {
      await _db.removeFavorite(userId, carId);
      return true;
    } catch (e) {
      print('Error removing from favorites: $e');
      return false;
    }
  }

  // التحقق من وجود السيارة في المفضلة
  Future<bool> isFavorite(String userId, String carId) async {
    try {
      final favorite = await _db.getFavorite(userId, carId);
      return favorite != null;
    } catch (e) {
      print('Error checking favorite: $e');
      return false;
    }
  }

  // الحصول على جميع السيارات المفضلة للمستخدم
  Future<List<CarModel>> getUserFavorites(String userId) async {
    try {
      return await _db.getUserFavorites(userId);
    } catch (e) {
      print('Error getting user favorites: $e');
      return [];
    }
  }

  // الحصول على إحصائيات المفضلة (مبسطة)
  Future<Map<String, int>> getFavoritesStats(String userId) async {
    try {
      final favorites = await getUserFavorites(userId);
      
      // تجميع الإحصائيات حسب الماركة
      final brandStats = <String, int>{};
      for (final car in favorites) {
        brandStats[car.brand] = (brandStats[car.brand] ?? 0) + 1;
      }

      return {
        'total_favorites': favorites.length,
        ...brandStats,
      };
    } catch (e) {
      print('Error getting favorites stats: $e');
      return {};
    }
  }
}
