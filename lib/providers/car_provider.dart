import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:tashlehekomv2/models/car_model.dart';
import 'package:tashlehekomv2/services/database_service.dart';
import 'package:tashlehekomv2/services/firebase_firestore_service.dart';
import 'package:tashlehekomv2/services/sync_service.dart';

class CarProvider with ChangeNotifier {
  List<CarModel> _cars = [];
  List<String> _carBrands = [];
  List<String> _cities = [];
  bool _isLoading = false;
  String? _searchQuery;
  String? _selectedCity;
  String? _selectedBrand;
  String? _selectedModel;

  // Advanced filters
  Map<String, dynamic> _advancedFilters = {};

  final FirebaseFirestoreService _firestoreService = FirebaseFirestoreService();
  final SyncService _syncService = SyncService();

  List<CarModel> get cars => _filteredCars();
  List<String> get carBrands => _carBrands;
  List<String> get cities => _cities;
  List<String> get models {
    final list = _cars
        .where((c) => _selectedBrand == null || c.brand == _selectedBrand)
        .map((c) => c.model)
        .toSet()
        .toList();
    list.sort();
    return list;
  }

  bool get isLoading => _isLoading;
  String? get searchQuery => _searchQuery;
  String? get selectedCity => _selectedCity;
  String? get selectedBrand => _selectedBrand;
  String? get selectedModel => _selectedModel;
  Map<String, dynamic> get currentFilters => {
        'searchQuery': _searchQuery,
        'selectedCity': _selectedCity,
        'selectedBrand': _selectedBrand,
        'selectedModel': _selectedModel,
        ..._advancedFilters,
      };

  List<CarModel> _filteredCars() {
    List<CarModel> filtered = List.from(_cars);

    if (_searchQuery != null && _searchQuery!.isNotEmpty) {
      filtered = filtered
          .where((car) =>
              car.brand.toLowerCase().contains(_searchQuery!.toLowerCase()) ||
              car.model.toLowerCase().contains(_searchQuery!.toLowerCase()) ||
              car.sellerName
                  .toLowerCase()
                  .contains(_searchQuery!.toLowerCase()))
          .toList();
    }

    if (_selectedCity != null && _selectedCity!.isNotEmpty) {
      filtered = filtered.where((car) => car.city == _selectedCity).toList();
    }

    if (_selectedBrand != null && _selectedBrand!.isNotEmpty) {
      filtered = filtered.where((car) => car.brand == _selectedBrand).toList();
    }

    if (_selectedModel != null && _selectedModel!.isNotEmpty) {
      filtered = filtered.where((car) => car.model == _selectedModel).toList();
    }

    // Apply advanced filters
    filtered = _applyAdvancedFilters(filtered);

    return filtered;
  }

  List<CarModel> _applyAdvancedFilters(List<CarModel> cars) {
    var filtered = cars;

    // Model filter
    if (_advancedFilters['model'] != null &&
        _advancedFilters['model'].isNotEmpty) {
      filtered = filtered
          .where((car) => car.model
              .toLowerCase()
              .contains(_advancedFilters['model'].toLowerCase()))
          .toList();
    }

    // Color filter
    if (_advancedFilters['color'] != null) {
      filtered = filtered
          .where((car) => car.color == _advancedFilters['color'])
          .toList();
    }

    // Years filter
    if (_advancedFilters['years'] != null &&
        (_advancedFilters['years'] as List).isNotEmpty) {
      final selectedYears = _advancedFilters['years'] as List<String>;
      filtered = filtered.where((car) {
        return car.manufacturingYears
            .any((year) => selectedYears.contains(year.toString()));
      }).toList();
    }

    // Price range filter
    if (_advancedFilters['priceRange'] != null) {
      final priceRange = _advancedFilters['priceRange'] as RangeValues;
      filtered = filtered.where((car) {
        final price = car.price;
        return price >= priceRange.start && price <= priceRange.end;
      }).toList();
    }

    // VIN number filters
    if (_advancedFilters['hasVinNumber'] == true) {
      filtered = filtered
          .where((car) => car.vinNumber != null && car.vinNumber!.isNotEmpty)
          .toList();
    }

    if (_advancedFilters['showVinOnly'] == true) {
      filtered = filtered
          .where((car) => car.vinNumber != null && car.vinNumber!.isNotEmpty)
          .toList();
    }

    return filtered;
  }

  Future<void> loadCars() async {
    _isLoading = true;
    notifyListeners();

    try {
      // تحميل من Firebase مع fallback للقاعدة المحلية
      try {
        _cars = await _firestoreService.getAllCars();
      } catch (e) {
        // في حالة فشل Firebase، استخدم القاعدة المحلية
        _cars = await DatabaseService.instance.getAllCars();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCarBrands() async {
    try {
      _carBrands = await DatabaseService.instance.getCarBrands();
      notifyListeners();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> loadCities() async {
    try {
      _cities = await DatabaseService.instance.getCities();
      notifyListeners();
    } catch (e) {
      // Handle error
    }
  }

  Future<bool> addCar({
    required String sellerId,
    required String sellerName,
    required String brand,
    required String model,
    required List<int> manufacturingYears,
    String? color,
    required String city,
    String? vinNumber,
    String? vinImage,
    required List<String> images,
    double? latitude,
    double? longitude,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final car = CarModel(
        id: const Uuid().v4(),
        sellerId: sellerId,
        sellerName: sellerName,
        brand: brand,
        model: model,
        manufacturingYears: manufacturingYears,
        year: manufacturingYears.isNotEmpty
            ? manufacturingYears.first
            : DateTime.now().year,
        price: 0.0, // سعر افتراضي
        city: city,
        images: images,
        createdAt: DateTime.now(),
        color: color,
        vinNumber: vinNumber,
        vinImage: vinImage,
        latitude: latitude,
        longitude: longitude,
      );

      // حفظ في Firebase أولاً
      await _firestoreService.createCar(car);

      // حفظ في القاعدة المحلية كـ backup
      try {
        await DatabaseService.instance.createCar(car);
      } catch (e) {
        // تجاهل أخطاء القاعدة المحلية
      }

      // مزامنة فورية
      await _syncService.syncSingleCar(car);

      _cars.add(car);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<List<CarModel>> getCarsBySeller(String sellerId) async {
    try {
      // محاولة جلب من Firebase أولاً
      return await _firestoreService.getUserCars(sellerId);
    } catch (e) {
      // في حالة الفشل، استخدم القاعدة المحلية
      return await DatabaseService.instance.getCarsBySeller(sellerId);
    }
  }

  void setSearchQuery(String? query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCity(String? city) {
    _selectedCity = city;
    notifyListeners();
  }

  void setSelectedBrand(String? brand) {
    _selectedBrand = brand;
    // Reset model if brand changed and model not in list
    if (_selectedModel != null && !models.contains(_selectedModel)) {
      _selectedModel = null;
    }
    notifyListeners();
  }

  void setSelectedModel(String? model) {
    _selectedModel = model;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = null;
    _selectedCity = null;
    _selectedBrand = null;
    _selectedModel = null;
    _advancedFilters.clear();
    notifyListeners();
  }

  void applyAdvancedFilters(Map<String, dynamic> filters) {
    _advancedFilters = Map.from(filters);

    // Apply basic filters from advanced filter
    if (filters['brand'] != null) {
      _selectedBrand = filters['brand'];
    }
    if (filters['model'] != null) {
      _selectedModel = filters['model'];
    }
    if (filters['city'] != null) {
      _selectedCity = filters['city'];
    }

    notifyListeners();
  }

  CarModel? getCarById(String id) {
    try {
      return _cars.firstWhere((car) => car.id == id);
    } catch (e) {
      return null;
    }
  }
}
