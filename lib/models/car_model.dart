class CarModel {
  final String id;
  final String sellerId;
  final String sellerName;
  final String brand;
  final String model;
  final List<int> manufacturingYears;
  final int year; // إضافة year للتوافق مع Firebase
  final double price; // إضافة price للتوافق مع Firebase
  final String? color;
  final String city;
  final String? vinNumber; // رقم الهيكل
  final String? vinImage; // صورة رقم الهيكل
  final List<String> images;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  CarModel({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    required this.brand,
    required this.model,
    required this.manufacturingYears,
    required this.year,
    required this.price,
    required this.city,
    required this.images,
    required this.createdAt,
    this.color,
    this.vinNumber,
    this.vinImage,
    this.latitude,
    this.longitude,
    this.updatedAt,
    this.isActive = true,
  });

  factory CarModel.fromMap(Map<String, dynamic> map) {
    return CarModel(
      id: map['id'],
      sellerId: map['seller_id'],
      sellerName: map['seller_name'],
      brand: map['brand'],
      model: map['model'],
      manufacturingYears: (map['manufacturing_years'] as String)
          .split(',')
          .map((e) => int.parse(e))
          .toList(),
      year: map['year'] ??
          (map['manufacturing_years'] as String).split(',').first,
      price: (map['price'] ?? 0.0).toDouble(),
      city: map['city'],
      images: (map['images'] as String).split(','),
      createdAt: DateTime.parse(map['created_at']),
      color: map['color'],
      vinNumber: map['vin_number'],
      vinImage: map['vin_image'],
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      updatedAt:
          map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
      isActive: map['is_active'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'seller_id': sellerId,
      'seller_name': sellerName,
      'brand': brand,
      'model': model,
      'manufacturing_years': manufacturingYears.join(','),
      'year': year,
      'price': price,
      'color': color,
      'city': city,
      'vin_number': vinNumber,
      'vin_image': vinImage,
      'images': images.join(','),
      'latitude': latitude,
      'longitude': longitude,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_active': isActive ? 1 : 0,
    };
  }

  CarModel copyWith({
    String? id,
    String? sellerId,
    String? sellerName,
    String? brand,
    String? model,
    List<int>? manufacturingYears,
    int? year,
    double? price,
    String? color,
    String? city,
    String? vinNumber,
    String? vinImage,
    List<String>? images,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return CarModel(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      manufacturingYears: manufacturingYears ?? this.manufacturingYears,
      year: year ?? this.year,
      price: price ?? this.price,
      city: city ?? this.city,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      color: color ?? this.color,
      vinNumber: vinNumber ?? this.vinNumber,
      vinImage: vinImage ?? this.vinImage,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
