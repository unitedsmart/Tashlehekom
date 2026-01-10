import 'package:uuid/uuid.dart';

/// نموذج طلب التوصيل
class DeliveryRequest {
  final String id;
  final String carId;
  final String buyerId;
  final String sellerId;
  final String? driverId;
  final DeliveryAddress pickupAddress;
  final DeliveryAddress deliveryAddress;
  final DeliveryStatus status;
  final DeliveryType type;
  final double distance;
  final double cost;
  final DateTime requestedAt;
  final DateTime? scheduledAt;
  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;
  final List<DeliveryUpdate> updates;
  final Map<String, dynamic> metadata;

  DeliveryRequest({
    required this.id,
    required this.carId,
    required this.buyerId,
    required this.sellerId,
    this.driverId,
    required this.pickupAddress,
    required this.deliveryAddress,
    required this.status,
    required this.type,
    required this.distance,
    required this.cost,
    required this.requestedAt,
    this.scheduledAt,
    this.pickedUpAt,
    this.deliveredAt,
    required this.updates,
    required this.metadata,
  });

  factory DeliveryRequest.fromJson(Map<String, dynamic> json) {
    return DeliveryRequest(
      id: json['id'],
      carId: json['carId'],
      buyerId: json['buyerId'],
      sellerId: json['sellerId'],
      driverId: json['driverId'],
      pickupAddress: DeliveryAddress.fromJson(json['pickupAddress']),
      deliveryAddress: DeliveryAddress.fromJson(json['deliveryAddress']),
      status: DeliveryStatus.values[json['status']],
      type: DeliveryType.values[json['type']],
      distance: json['distance'].toDouble(),
      cost: json['cost'].toDouble(),
      requestedAt: DateTime.parse(json['requestedAt']),
      scheduledAt: json['scheduledAt'] != null ? DateTime.parse(json['scheduledAt']) : null,
      pickedUpAt: json['pickedUpAt'] != null ? DateTime.parse(json['pickedUpAt']) : null,
      deliveredAt: json['deliveredAt'] != null ? DateTime.parse(json['deliveredAt']) : null,
      updates: (json['updates'] as List)
          .map((e) => DeliveryUpdate.fromJson(e))
          .toList(),
      metadata: Map<String, dynamic>.from(json['metadata']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'carId': carId,
      'buyerId': buyerId,
      'sellerId': sellerId,
      'driverId': driverId,
      'pickupAddress': pickupAddress.toJson(),
      'deliveryAddress': deliveryAddress.toJson(),
      'status': status.index,
      'type': type.index,
      'distance': distance,
      'cost': cost,
      'requestedAt': requestedAt.toIso8601String(),
      'scheduledAt': scheduledAt?.toIso8601String(),
      'pickedUpAt': pickedUpAt?.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'updates': updates.map((e) => e.toJson()).toList(),
      'metadata': metadata,
    };
  }
}

enum DeliveryStatus {
  requested,
  assigned,
  enRoute,
  pickedUp,
  inTransit,
  delivered,
  cancelled,
  failed,
}

enum DeliveryType {
  standard,
  express,
  scheduled,
  premium,
}

class DeliveryAddress {
  final String id;
  final String street;
  final String city;
  final String district;
  final String postalCode;
  final double latitude;
  final double longitude;
  final String? landmark;
  final String contactName;
  final String contactPhone;

  DeliveryAddress({
    required this.id,
    required this.street,
    required this.city,
    required this.district,
    required this.postalCode,
    required this.latitude,
    required this.longitude,
    this.landmark,
    required this.contactName,
    required this.contactPhone,
  });

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) {
    return DeliveryAddress(
      id: json['id'],
      street: json['street'],
      city: json['city'],
      district: json['district'],
      postalCode: json['postalCode'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      landmark: json['landmark'],
      contactName: json['contactName'],
      contactPhone: json['contactPhone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'street': street,
      'city': city,
      'district': district,
      'postalCode': postalCode,
      'latitude': latitude,
      'longitude': longitude,
      'landmark': landmark,
      'contactName': contactName,
      'contactPhone': contactPhone,
    };
  }
}

class DeliveryUpdate {
  final String id;
  final String deliveryId;
  final DeliveryStatus status;
  final String message;
  final double? latitude;
  final double? longitude;
  final DateTime timestamp;
  final List<String>? imageUrls;

  DeliveryUpdate({
    required this.id,
    required this.deliveryId,
    required this.status,
    required this.message,
    this.latitude,
    this.longitude,
    required this.timestamp,
    this.imageUrls,
  });

  factory DeliveryUpdate.fromJson(Map<String, dynamic> json) {
    return DeliveryUpdate(
      id: json['id'],
      deliveryId: json['deliveryId'],
      status: DeliveryStatus.values[json['status']],
      message: json['message'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      imageUrls: json['imageUrls'] != null ? List<String>.from(json['imageUrls']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deliveryId': deliveryId,
      'status': status.index,
      'message': message,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
      'imageUrls': imageUrls,
    };
  }
}

/// نموذج السائق
class DeliveryDriver {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String licenseNumber;
  final String vehicleType;
  final String vehiclePlate;
  final double rating;
  final int totalDeliveries;
  final DriverStatus status;
  final double? currentLatitude;
  final double? currentLongitude;
  final DateTime lastActive;
  final List<String> serviceAreas;

  DeliveryDriver({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.licenseNumber,
    required this.vehicleType,
    required this.vehiclePlate,
    required this.rating,
    required this.totalDeliveries,
    required this.status,
    this.currentLatitude,
    this.currentLongitude,
    required this.lastActive,
    required this.serviceAreas,
  });
}

enum DriverStatus {
  available,
  busy,
  offline,
  suspended,
}

/// نموذج تتبع الشحنة
class ShipmentTracking {
  final String id;
  final String deliveryId;
  final String trackingNumber;
  final List<TrackingEvent> events;
  final double? currentLatitude;
  final double? currentLongitude;
  final double estimatedArrivalTime;
  final DateTime lastUpdated;

  ShipmentTracking({
    required this.id,
    required this.deliveryId,
    required this.trackingNumber,
    required this.events,
    this.currentLatitude,
    this.currentLongitude,
    required this.estimatedArrivalTime,
    required this.lastUpdated,
  });
}

class TrackingEvent {
  final String id;
  final String description;
  final String location;
  final DateTime timestamp;
  final TrackingEventType type;

  TrackingEvent({
    required this.id,
    required this.description,
    required this.location,
    required this.timestamp,
    required this.type,
  });
}

enum TrackingEventType {
  created,
  assigned,
  pickedUp,
  inTransit,
  outForDelivery,
  delivered,
  exception,
}

/// نموذج خدمة الفحص قبل التسليم
class PreDeliveryInspection {
  final String id;
  final String deliveryId;
  final String inspectorId;
  final List<InspectionItem> items;
  final double overallScore;
  final List<String> imageUrls;
  final String? notes;
  final DateTime inspectedAt;
  final bool approved;

  PreDeliveryInspection({
    required this.id,
    required this.deliveryId,
    required this.inspectorId,
    required this.items,
    required this.overallScore,
    required this.imageUrls,
    this.notes,
    required this.inspectedAt,
    required this.approved,
  });
}

class InspectionItem {
  final String id;
  final String name;
  final InspectionResult result;
  final String? notes;
  final List<String>? imageUrls;

  InspectionItem({
    required this.id,
    required this.name,
    required this.result,
    this.notes,
    this.imageUrls,
  });
}

enum InspectionResult {
  pass,
  fail,
  warning,
  notApplicable,
}
