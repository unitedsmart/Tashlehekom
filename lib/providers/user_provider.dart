import 'package:flutter/material.dart';
import 'package:tashlehekomv2/models/user_model.dart';
import 'package:tashlehekomv2/models/rating_model.dart';
import 'package:tashlehekomv2/services/database_service.dart';

class UserProvider with ChangeNotifier {
  List<UserModel> _users = [];
  List<RatingModel> _ratings = [];
  bool _isLoading = false;

  List<UserModel> get users => _users;
  List<RatingModel> get ratings => _ratings;
  bool get isLoading => _isLoading;

  List<UserModel> get pendingApprovalUsers => _users
      .where((user) => 
          user.userType == UserType.junkyardOwner && !user.isApproved)
      .toList();

  List<UserModel> get workers => _users
      .where((user) => user.userType == UserType.worker)
      .toList();

  List<UserModel> get unlinkedWorkers => workers
      .where((worker) => worker.junkyard == null || worker.junkyard!.isEmpty)
      .toList();

  List<UserModel> get linkedWorkers => workers
      .where((worker) => worker.junkyard != null && worker.junkyard!.isNotEmpty)
      .toList();

  Future<void> loadUsers() async {
    _isLoading = true;
    notifyListeners();

    try {
      _users = await DatabaseService.instance.getAllUsers();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> approveUser(String userId) async {
    try {
      final user = _users.firstWhere((u) => u.id == userId);
      final updatedUser = user.copyWith(
        isApproved: true,
        updatedAt: DateTime.now(),
      );
      
      await DatabaseService.instance.updateUser(updatedUser);
      
      final index = _users.indexWhere((u) => u.id == userId);
      if (index != -1) {
        _users[index] = updatedUser;
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> rejectUser(String userId) async {
    try {
      final user = _users.firstWhere((u) => u.id == userId);
      final updatedUser = user.copyWith(
        isActive: false,
        updatedAt: DateTime.now(),
      );
      
      await DatabaseService.instance.updateUser(updatedUser);
      
      final index = _users.indexWhere((u) => u.id == userId);
      if (index != -1) {
        _users[index] = updatedUser;
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> linkWorkerToJunkyard(String workerId, String junkyardName) async {
    try {
      final worker = _users.firstWhere((u) => u.id == workerId);
      final updatedWorker = worker.copyWith(
        junkyard: junkyardName,
        updatedAt: DateTime.now(),
      );
      
      await DatabaseService.instance.updateUser(updatedWorker);
      
      final index = _users.indexWhere((u) => u.id == workerId);
      if (index != -1) {
        _users[index] = updatedWorker;
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> toggleUserStatus(String userId) async {
    try {
      final user = _users.firstWhere((u) => u.id == userId);
      final updatedUser = user.copyWith(
        isActive: !user.isActive,
        updatedAt: DateTime.now(),
      );
      
      await DatabaseService.instance.updateUser(updatedUser);
      
      final index = _users.indexWhere((u) => u.id == userId);
      if (index != -1) {
        _users[index] = updatedUser;
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> loadRatingsForSeller(String sellerId) async {
    try {
      _ratings = await DatabaseService.instance.getRatingsBySeller(sellerId);
      notifyListeners();
    } catch (e) {
      // Handle error
    }
  }

  double getAverageRating(String sellerId) {
    final sellerRatings = _ratings.where((r) => r.sellerId == sellerId).toList();
    
    if (sellerRatings.isEmpty) return 0.0;
    
    double totalRating = 0.0;
    for (var rating in sellerRatings) {
      totalRating += rating.averageRating;
    }
    
    return totalRating / sellerRatings.length;
  }

  Map<String, int> getStatistics() {
    final stats = <String, int>{};
    
    stats['totalUsers'] = _users.length;
    stats['individuals'] = _users.where((u) => u.userType == UserType.individual).length;
    stats['workers'] = _users.where((u) => u.userType == UserType.worker).length;
    stats['junkyardOwners'] = _users.where((u) => u.userType == UserType.junkyardOwner).length;
    stats['pendingApproval'] = pendingApprovalUsers.length;
    stats['linkedWorkers'] = linkedWorkers.length;
    stats['unlinkedWorkers'] = unlinkedWorkers.length;
    
    return stats;
  }
}
