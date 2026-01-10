/// نماذج التوصيل واللوجستيات

/// نطاق التاريخ
class DateRange {
  final DateTime start;
  final DateTime end;

  const DateRange({required this.start, required this.end});

  factory DateRange.fromMap(Map<String, dynamic> map) {
    return DateRange(
      start: DateTime.parse(map['start'] ?? DateTime.now().toIso8601String()),
      end: DateTime.parse(map['end'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
    };
  }

  int get days => end.difference(start).inDays;
}

/// بيانات التوصيل الشهرية
class MonthlyDeliveryData {
  final DateTime month;
  final int orders;
  final double cost;

  const MonthlyDeliveryData({
    required this.month,
    required this.orders,
    required this.cost,
  });

  factory MonthlyDeliveryData.fromMap(Map<String, dynamic> map) {
    return MonthlyDeliveryData(
      month: DateTime.parse(map['month'] ?? DateTime.now().toIso8601String()),
      orders: map['orders'] ?? 0,
      cost: (map['cost'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'month': month.toIso8601String(),
      'orders': orders,
      'cost': cost,
    };
  }
}

/// أداء السائق
class DriverPerformance {
  final String driverId;
  final String name;
  final int deliveries;
  final double rating;
  final double onTimeRate;

  const DriverPerformance({
    required this.driverId,
    required this.name,
    required this.deliveries,
    required this.rating,
    required this.onTimeRate,
  });

  factory DriverPerformance.fromMap(Map<String, dynamic> map) {
    return DriverPerformance(
      driverId: map['driverId'] ?? '',
      name: map['name'] ?? '',
      deliveries: map['deliveries'] ?? 0,
      rating: (map['rating'] ?? 0.0).toDouble(),
      onTimeRate: (map['onTimeRate'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'driverId': driverId,
      'name': name,
      'deliveries': deliveries,
      'rating': rating,
      'onTimeRate': onTimeRate,
    };
  }
}

/// طلب التوصيل
class DeliveryOrder {
  final String id;
  final String carId;
  final String buyerId;
  final String sellerId;
  final String? driverId;
  final DeliveryAddress pickupAddress;
  final DeliveryAddress deliveryAddress;
  final DeliveryType deliveryType;
  final DeliveryStatus status;
  final String? specialInstructions;
  final double estimatedCost;
  final Duration estimatedTime;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? scheduledPickupTime;
  final DateTime? actualPickupTime;
  final DateTime? actualDeliveryTime;

  const DeliveryOrder({
    required this.id,
    required this.carId,
    required this.buyerId,
    required this.sellerId,
    this.driverId,
    required this.pickupAddress,
    required this.deliveryAddress,
    required this.deliveryType,
    required this.status,
    this.specialInstructions,
    required this.estimatedCost,
    required this.estimatedTime,
    required this.createdAt,
    required this.updatedAt,
    this.scheduledPickupTime,
    this.actualPickupTime,
    this.actualDeliveryTime,
  });

  factory DeliveryOrder.empty() {
    return DeliveryOrder(
      id: '',
      carId: '',
      buyerId: '',
      sellerId: '',
      pickupAddress: DeliveryAddress.empty(),
      deliveryAddress: DeliveryAddress.empty(),
      deliveryType: DeliveryType.standard,
      status: DeliveryStatus.pending,
      estimatedCost: 0.0,
      estimatedTime: Duration.zero,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  factory DeliveryOrder.fromMap(Map<String, dynamic> map) {
    return DeliveryOrder(
      id: map['id'] ?? '',
      carId: map['carId'] ?? '',
      buyerId: map['buyerId'] ?? '',
      sellerId: map['sellerId'] ?? '',
      driverId: map['driverId'],
      pickupAddress: DeliveryAddress.fromMap(map['pickupAddress'] ?? {}),
      deliveryAddress: DeliveryAddress.fromMap(map['deliveryAddress'] ?? {}),
      deliveryType: DeliveryType.values.firstWhere(
        (e) => e.name == map['deliveryType'],
        orElse: () => DeliveryType.standard,
      ),
      status: DeliveryStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => DeliveryStatus.pending,
      ),
      specialInstructions: map['specialInstructions'],
      estimatedCost: (map['estimatedCost'] ?? 0.0).toDouble(),
      estimatedTime: Duration(minutes: map['estimatedTime'] ?? 0),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      scheduledPickupTime: map['scheduledPickupTime'] != null
          ? DateTime.parse(map['scheduledPickupTime'])
          : null,
      actualPickupTime: map['actualPickupTime'] != null
          ? DateTime.parse(map['actualPickupTime'])
          : null,
      actualDeliveryTime: map['actualDeliveryTime'] != null
          ? DateTime.parse(map['actualDeliveryTime'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'carId': carId,
      'buyerId': buyerId,
      'sellerId': sellerId,
      'driverId': driverId,
      'pickupAddress': pickupAddress.toMap(),
      'deliveryAddress': deliveryAddress.toMap(),
      'deliveryType': deliveryType.name,
      'status': status.name,
      'specialInstructions': specialInstructions,
      'estimatedCost': estimatedCost,
      'estimatedTime': estimatedTime.inMinutes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'scheduledPickupTime': scheduledPickupTime?.toIso8601String(),
      'actualPickupTime': actualPickupTime?.toIso8601String(),
      'actualDeliveryTime': actualDeliveryTime?.toIso8601String(),
    };
  }

  String get statusText => status.displayName;
  String get deliveryTypeText => deliveryType.displayName;
  String get estimatedCostText => '${estimatedCost.toStringAsFixed(2)} ريال';
  String get estimatedTimeText =>
      '${estimatedTime.inHours}س ${estimatedTime.inMinutes % 60}د';
  bool get isCompleted => status == DeliveryStatus.delivered;
  bool get canCancel =>
      status == DeliveryStatus.pending || status == DeliveryStatus.assigned;
}

/// عنوان التوصيل
class DeliveryAddress {
  final String street;
  final String city;
  final String district;
  final String postalCode;
  final String country;
  final double latitude;
  final double longitude;
  final String? buildingNumber;
  final String? apartmentNumber;
  final String? landmark;
  final String? contactName;
  final String? contactPhone;

  const DeliveryAddress({
    required this.street,
    required this.city,
    required this.district,
    required this.postalCode,
    required this.country,
    required this.latitude,
    required this.longitude,
    this.buildingNumber,
    this.apartmentNumber,
    this.landmark,
    this.contactName,
    this.contactPhone,
  });

  factory DeliveryAddress.empty() {
    return const DeliveryAddress(
      street: '',
      city: '',
      district: '',
      postalCode: '',
      country: 'السعودية',
      latitude: 0.0,
      longitude: 0.0,
    );
  }

  factory DeliveryAddress.fromMap(Map<String, dynamic> map) {
    return DeliveryAddress(
      street: map['street'] ?? '',
      city: map['city'] ?? '',
      district: map['district'] ?? '',
      postalCode: map['postalCode'] ?? '',
      country: map['country'] ?? 'السعودية',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      buildingNumber: map['buildingNumber'],
      apartmentNumber: map['apartmentNumber'],
      landmark: map['landmark'],
      contactName: map['contactName'],
      contactPhone: map['contactPhone'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'street': street,
      'city': city,
      'district': district,
      'postalCode': postalCode,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'buildingNumber': buildingNumber,
      'apartmentNumber': apartmentNumber,
      'landmark': landmark,
      'contactName': contactName,
      'contactPhone': contactPhone,
    };
  }

  String get fullAddress {
    final parts = <String>[];
    if (buildingNumber != null) parts.add('مبنى $buildingNumber');
    parts.add(street);
    parts.add(district);
    parts.add(city);
    if (postalCode.isNotEmpty) parts.add(postalCode);
    return parts.join(', ');
  }

  String get coordinates =>
      '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
}

/// نوع التوصيل
enum DeliveryType {
  standard('عادي'),
  express('سريع'),
  premium('مميز'),
  overnight('ليلي');

  const DeliveryType(this.displayName);
  final String displayName;
}

/// حالة التوصيل
enum DeliveryStatus {
  pending('في الانتظار'),
  assigned('تم التعيين'),
  pickedUp('تم الاستلام'),
  inTransit('في الطريق'),
  delivered('تم التسليم'),
  cancelled('ملغي'),
  failed('فشل');

  const DeliveryStatus(this.displayName);
  final String displayName;
}

/// تتبع التوصيل
class DeliveryTracking {
  final String orderId;
  final DeliveryStatus currentStatus;
  final List<TrackingEvent> trackingEvents;
  final DateTime? estimatedDeliveryTime;
  final DeliveryLocation? currentLocation;
  final DriverInfo? driverInfo;
  final DateTime lastUpdated;

  const DeliveryTracking({
    required this.orderId,
    required this.currentStatus,
    required this.trackingEvents,
    this.estimatedDeliveryTime,
    this.currentLocation,
    this.driverInfo,
    required this.lastUpdated,
  });

  factory DeliveryTracking.empty() {
    return DeliveryTracking(
      orderId: '',
      currentStatus: DeliveryStatus.pending,
      trackingEvents: [],
      lastUpdated: DateTime.now(),
    );
  }

  factory DeliveryTracking.fromMap(Map<String, dynamic> map) {
    return DeliveryTracking(
      orderId: map['orderId'] ?? '',
      currentStatus: DeliveryStatus.values.firstWhere(
        (e) => e.name == map['currentStatus'],
        orElse: () => DeliveryStatus.pending,
      ),
      trackingEvents: (map['trackingEvents'] as List<dynamic>?)
              ?.map((item) => TrackingEvent.fromMap(item))
              .toList() ??
          [],
      estimatedDeliveryTime: map['estimatedDeliveryTime'] != null
          ? DateTime.parse(map['estimatedDeliveryTime'])
          : null,
      currentLocation: map['currentLocation'] != null
          ? DeliveryLocation.fromMap(map['currentLocation'])
          : null,
      driverInfo: map['driverInfo'] != null
          ? DriverInfo.fromMap(map['driverInfo'])
          : null,
      lastUpdated: DateTime.parse(map['lastUpdated']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'currentStatus': currentStatus.name,
      'trackingEvents': trackingEvents.map((event) => event.toMap()).toList(),
      'estimatedDeliveryTime': estimatedDeliveryTime?.toIso8601String(),
      'currentLocation': currentLocation?.toMap(),
      'driverInfo': driverInfo?.toMap(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  String get statusText => currentStatus.displayName;
  bool get hasDriver => driverInfo != null;
  bool get isInProgress =>
      currentStatus == DeliveryStatus.inTransit ||
      currentStatus == DeliveryStatus.pickedUp;
  int get completionPercentage {
    final statusOrder = [
      DeliveryStatus.pending,
      DeliveryStatus.assigned,
      DeliveryStatus.pickedUp,
      DeliveryStatus.inTransit,
      DeliveryStatus.delivered,
    ];
    final currentIndex = statusOrder.indexOf(currentStatus);
    return currentIndex >= 0
        ? ((currentIndex + 1) / statusOrder.length * 100).round()
        : 0;
  }
}

/// حدث التتبع
class TrackingEvent {
  final DeliveryStatus status;
  final DateTime timestamp;
  final String location;
  final String description;

  const TrackingEvent({
    required this.status,
    required this.timestamp,
    required this.location,
    required this.description,
  });

  factory TrackingEvent.fromMap(Map<String, dynamic> map) {
    return TrackingEvent(
      status: DeliveryStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => DeliveryStatus.pending,
      ),
      timestamp: DateTime.parse(map['timestamp']),
      location: map['location'] ?? '',
      description: map['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status.name,
      'timestamp': timestamp.toIso8601String(),
      'location': location,
      'description': description,
    };
  }

  String get statusText => status.displayName;
  String get timeText =>
      '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
}

/// موقع التوصيل
class DeliveryLocation {
  final double latitude;
  final double longitude;
  final String address;
  final DateTime timestamp;

  const DeliveryLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.timestamp,
  });

  factory DeliveryLocation.fromMap(Map<String, dynamic> map) {
    return DeliveryLocation(
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      address: map['address'] ?? '',
      timestamp: DateTime.parse(map['timestamp']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  String get coordinates =>
      '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
}

/// معلومات السائق
class DriverInfo {
  final String id;
  final String name;
  final String phone;
  final double rating;
  final String vehicleInfo;

  const DriverInfo({
    required this.id,
    required this.name,
    required this.phone,
    required this.rating,
    required this.vehicleInfo,
  });

  factory DriverInfo.fromMap(Map<String, dynamic> map) {
    return DriverInfo(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      vehicleInfo: map['vehicleInfo'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'rating': rating,
      'vehicleInfo': vehicleInfo,
    };
  }

  String get ratingText => rating.toStringAsFixed(1);
  String get ratingStars => '★' * rating.round() + '☆' * (5 - rating.round());
}

/// سائق التوصيل
class DeliveryDriver {
  final String id;
  final String name;
  final String phone;
  final double rating;
  final DriverStatus status;
  final DeliveryLocation currentLocation;
  final VehicleInfo vehicleInfo;
  final List<DeliveryType> specializations;
  final int completedDeliveries;
  final DateTime joinDate;
  final bool isVerified;
  final DateTime lastActive;
  final String? currentOrderId;

  const DeliveryDriver({
    required this.id,
    required this.name,
    required this.phone,
    required this.rating,
    required this.status,
    required this.currentLocation,
    required this.vehicleInfo,
    required this.specializations,
    required this.completedDeliveries,
    required this.joinDate,
    required this.isVerified,
    required this.lastActive,
    this.currentOrderId,
  });

  factory DeliveryDriver.fromMap(Map<String, dynamic> map) {
    return DeliveryDriver(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      status: DriverStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => DriverStatus.offline,
      ),
      currentLocation: DeliveryLocation.fromMap(map['currentLocation'] ?? {}),
      vehicleInfo: VehicleInfo.fromMap(map['vehicleInfo'] ?? {}),
      specializations: (map['specializations'] as List<dynamic>?)
              ?.map((item) => DeliveryType.values.firstWhere(
                    (e) => e.name == item,
                    orElse: () => DeliveryType.standard,
                  ))
              .toList() ??
          [],
      completedDeliveries: map['completedDeliveries'] ?? 0,
      joinDate: DateTime.parse(map['joinDate']),
      isVerified: map['isVerified'] ?? false,
      lastActive: DateTime.parse(map['lastActive']),
      currentOrderId: map['currentOrderId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'rating': rating,
      'status': status.name,
      'currentLocation': currentLocation.toMap(),
      'vehicleInfo': vehicleInfo.toMap(),
      'specializations': specializations.map((s) => s.name).toList(),
      'completedDeliveries': completedDeliveries,
      'joinDate': joinDate.toIso8601String(),
      'isVerified': isVerified,
      'lastActive': lastActive.toIso8601String(),
      'currentOrderId': currentOrderId,
    };
  }

  String get statusText => status.displayName;
  String get ratingText => rating.toStringAsFixed(1);
  String get experienceText => '$completedDeliveries توصيلة مكتملة';
  bool get isAvailable => status == DriverStatus.available;
  bool get isOnline => status != DriverStatus.offline;
  String get specializationsText =>
      specializations.map((s) => s.displayName).join(', ');
}

/// حالة السائق
enum DriverStatus {
  available('متاح'),
  busy('مشغول'),
  offline('غير متصل'),
  onBreak('في استراحة');

  const DriverStatus(this.displayName);
  final String displayName;
}

/// معلومات المركبة
class VehicleInfo {
  final VehicleType type;
  final String model;
  final String plateNumber;
  final String color;

  const VehicleInfo({
    required this.type,
    required this.model,
    required this.plateNumber,
    required this.color,
  });

  factory VehicleInfo.fromMap(Map<String, dynamic> map) {
    return VehicleInfo(
      type: VehicleType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => VehicleType.car,
      ),
      model: map['model'] ?? '',
      plateNumber: map['plateNumber'] ?? '',
      color: map['color'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'model': model,
      'plateNumber': plateNumber,
      'color': color,
    };
  }

  String get typeText => type.displayName;
  String get fullDescription => '$color $model - $plateNumber';
}

/// نوع المركبة
enum VehicleType {
  car('سيارة'),
  truck('شاحنة'),
  van('فان'),
  motorcycle('دراجة نارية');

  const VehicleType(this.displayName);
  final String displayName;
}

/// تفصيل تكلفة التوصيل
class DeliveryCostBreakdown {
  final double baseCost;
  final double distanceCost;
  final double insuranceCost;
  final double serviceFee;
  final double vat;
  final double totalCost;
  final double distance;
  final DeliveryType deliveryType;

  const DeliveryCostBreakdown({
    required this.baseCost,
    required this.distanceCost,
    required this.insuranceCost,
    required this.serviceFee,
    required this.vat,
    required this.totalCost,
    required this.distance,
    required this.deliveryType,
  });

  factory DeliveryCostBreakdown.empty() {
    return const DeliveryCostBreakdown(
      baseCost: 0.0,
      distanceCost: 0.0,
      insuranceCost: 0.0,
      serviceFee: 0.0,
      vat: 0.0,
      totalCost: 0.0,
      distance: 0.0,
      deliveryType: DeliveryType.standard,
    );
  }

  factory DeliveryCostBreakdown.fromMap(Map<String, dynamic> map) {
    return DeliveryCostBreakdown(
      baseCost: (map['baseCost'] ?? 0.0).toDouble(),
      distanceCost: (map['distanceCost'] ?? 0.0).toDouble(),
      insuranceCost: (map['insuranceCost'] ?? 0.0).toDouble(),
      serviceFee: (map['serviceFee'] ?? 0.0).toDouble(),
      vat: (map['vat'] ?? 0.0).toDouble(),
      totalCost: (map['totalCost'] ?? 0.0).toDouble(),
      distance: (map['distance'] ?? 0.0).toDouble(),
      deliveryType: DeliveryType.values.firstWhere(
        (e) => e.name == map['deliveryType'],
        orElse: () => DeliveryType.standard,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'baseCost': baseCost,
      'distanceCost': distanceCost,
      'insuranceCost': insuranceCost,
      'serviceFee': serviceFee,
      'vat': vat,
      'totalCost': totalCost,
      'distance': distance,
      'deliveryType': deliveryType.name,
    };
  }

  String get baseCostText => '${baseCost.toStringAsFixed(2)} ريال';
  String get distanceCostText => '${distanceCost.toStringAsFixed(2)} ريال';
  String get totalCostText => '${totalCost.toStringAsFixed(2)} ريال';
  String get distanceText => '${distance.toStringAsFixed(1)} كم';
}

/// إحصائيات التوصيل
class DeliveryStatistics {
  final String userId;
  final DateRange period;
  final int totalOrders;
  final int completedOrders;
  final int cancelledOrders;
  final double totalCost;
  final Duration averageDeliveryTime;
  final double onTimeDeliveryRate;
  final double customerSatisfactionRate;
  final DeliveryType mostUsedDeliveryType;
  final Map<DeliveryType, int> deliveryTypeBreakdown;
  final List<MonthlyDeliveryData> monthlyTrend;
  final List<DriverPerformance> topDrivers;
  final DateTime lastUpdated;

  const DeliveryStatistics({
    required this.userId,
    required this.period,
    required this.totalOrders,
    required this.completedOrders,
    required this.cancelledOrders,
    required this.totalCost,
    required this.averageDeliveryTime,
    required this.onTimeDeliveryRate,
    required this.customerSatisfactionRate,
    required this.mostUsedDeliveryType,
    required this.deliveryTypeBreakdown,
    required this.monthlyTrend,
    required this.topDrivers,
    required this.lastUpdated,
  });

  factory DeliveryStatistics.empty() {
    return DeliveryStatistics(
      userId: '',
      period: DateRange(start: DateTime.now(), end: DateTime.now()),
      totalOrders: 0,
      completedOrders: 0,
      cancelledOrders: 0,
      totalCost: 0.0,
      averageDeliveryTime: Duration.zero,
      onTimeDeliveryRate: 0.0,
      customerSatisfactionRate: 0.0,
      mostUsedDeliveryType: DeliveryType.standard,
      deliveryTypeBreakdown: {},
      monthlyTrend: [],
      topDrivers: [],
      lastUpdated: DateTime.now(),
    );
  }

  factory DeliveryStatistics.fromMap(Map<String, dynamic> map) {
    return DeliveryStatistics(
      userId: map['userId'] ?? '',
      period: DateRange.fromMap(map['period'] ?? {}),
      totalOrders: map['totalOrders'] ?? 0,
      completedOrders: map['completedOrders'] ?? 0,
      cancelledOrders: map['cancelledOrders'] ?? 0,
      totalCost: (map['totalCost'] ?? 0.0).toDouble(),
      averageDeliveryTime: Duration(minutes: map['averageDeliveryTime'] ?? 0),
      onTimeDeliveryRate: (map['onTimeDeliveryRate'] ?? 0.0).toDouble(),
      customerSatisfactionRate:
          (map['customerSatisfactionRate'] ?? 0.0).toDouble(),
      mostUsedDeliveryType: DeliveryType.values.firstWhere(
        (e) => e.name == map['mostUsedDeliveryType'],
        orElse: () => DeliveryType.standard,
      ),
      deliveryTypeBreakdown: Map<DeliveryType, int>.from(
        (map['deliveryTypeBreakdown'] as Map<String, dynamic>?)?.map(
              (key, value) => MapEntry(
                DeliveryType.values.firstWhere((e) => e.name == key),
                value as int,
              ),
            ) ??
            {},
      ),
      monthlyTrend: (map['monthlyTrend'] as List<dynamic>?)
              ?.map((item) => MonthlyDeliveryData.fromMap(item))
              .toList() ??
          [],
      topDrivers: (map['topDrivers'] as List<dynamic>?)
              ?.map((item) => DriverPerformance.fromMap(item))
              .toList() ??
          [],
      lastUpdated: DateTime.parse(map['lastUpdated']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'period': period.toMap(),
      'totalOrders': totalOrders,
      'completedOrders': completedOrders,
      'cancelledOrders': cancelledOrders,
      'totalCost': totalCost,
      'averageDeliveryTime': averageDeliveryTime.inMinutes,
      'onTimeDeliveryRate': onTimeDeliveryRate,
      'customerSatisfactionRate': customerSatisfactionRate,
      'mostUsedDeliveryType': mostUsedDeliveryType.name,
      'deliveryTypeBreakdown':
          deliveryTypeBreakdown.map((key, value) => MapEntry(key.name, value)),
      'monthlyTrend': monthlyTrend.map((data) => data.toMap()).toList(),
      'topDrivers': topDrivers.map((driver) => driver.toMap()).toList(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  double get completionRate =>
      totalOrders > 0 ? (completedOrders / totalOrders) * 100 : 0.0;
  double get cancellationRate =>
      totalOrders > 0 ? (cancelledOrders / totalOrders) * 100 : 0.0;
  String get totalCostText => '${totalCost.toStringAsFixed(2)} ريال';
  String get averageDeliveryTimeText =>
      '${averageDeliveryTime.inHours}س ${averageDeliveryTime.inMinutes % 60}د';
  String get onTimeRateText => '${(onTimeDeliveryRate * 100).toInt()}%';
  String get satisfactionRateText =>
      '${(customerSatisfactionRate * 100).toInt()}%';
}
