import 'package:uuid/uuid.dart';

/// نموذج الواقع المعزز للسيارات
class ARCarScan {
  final String id;
  final String carId;
  final String userId;
  final List<ARDetection> detections;
  final Map<String, dynamic> carInfo;
  final List<String> imageUrls;
  final DateTime scannedAt;
  final double accuracy;

  ARCarScan({
    required this.id,
    required this.carId,
    required this.userId,
    required this.detections,
    required this.carInfo,
    required this.imageUrls,
    required this.scannedAt,
    required this.accuracy,
  });

  factory ARCarScan.fromJson(Map<String, dynamic> json) {
    return ARCarScan(
      id: json['id'],
      carId: json['carId'],
      userId: json['userId'],
      detections: (json['detections'] as List)
          .map((e) => ARDetection.fromJson(e))
          .toList(),
      carInfo: Map<String, dynamic>.from(json['carInfo']),
      imageUrls: List<String>.from(json['imageUrls']),
      scannedAt: DateTime.parse(json['scannedAt']),
      accuracy: json['accuracy'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'carId': carId,
      'userId': userId,
      'detections': detections.map((e) => e.toJson()).toList(),
      'carInfo': carInfo,
      'imageUrls': imageUrls,
      'scannedAt': scannedAt.toIso8601String(),
      'accuracy': accuracy,
    };
  }
}

/// نموذج الكشف بالواقع المعزز
class ARDetection {
  final String id;
  final ARDetectionType type;
  final String label;
  final String description;
  final List<double> position;
  final List<double> boundingBox;
  final double confidence;
  final Map<String, dynamic> properties;

  ARDetection({
    required this.id,
    required this.type,
    required this.label,
    required this.description,
    required this.position,
    required this.boundingBox,
    required this.confidence,
    required this.properties,
  });

  factory ARDetection.fromJson(Map<String, dynamic> json) {
    return ARDetection(
      id: json['id'],
      type: ARDetectionType.values[json['type']],
      label: json['label'],
      description: json['description'],
      position: List<double>.from(json['position']),
      boundingBox: List<double>.from(json['boundingBox']),
      confidence: json['confidence'].toDouble(),
      properties: Map<String, dynamic>.from(json['properties']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.index,
      'label': label,
      'description': description,
      'position': position,
      'boundingBox': boundingBox,
      'confidence': confidence,
      'properties': properties,
    };
  }
}

enum ARDetectionType {
  damage,
  part,
  feature,
  defect,
  modification,
  wear,
}

/// نموذج فحص الأضرار بالواقع المعزز
class ARDamageAssessment {
  final String id;
  final String carId;
  final List<DamagePoint> damages;
  final double totalDamageScore;
  final double estimatedRepairCost;
  final List<RepairRecommendation> recommendations;
  final DateTime assessedAt;

  ARDamageAssessment({
    required this.id,
    required this.carId,
    required this.damages,
    required this.totalDamageScore,
    required this.estimatedRepairCost,
    required this.recommendations,
    required this.assessedAt,
  });
}

class DamagePoint {
  final String id;
  final String type;
  final String location;
  final DamageSeverity severity;
  final String description;
  final List<double> coordinates;
  final List<String> imageUrls;
  final double repairCost;

  DamagePoint({
    required this.id,
    required this.type,
    required this.location,
    required this.severity,
    required this.description,
    required this.coordinates,
    required this.imageUrls,
    required this.repairCost,
  });
}

enum DamageSeverity {
  minor,
  moderate,
  major,
  severe,
}

class RepairRecommendation {
  final String id;
  final String damageId;
  final String recommendation;
  final double estimatedCost;
  final int estimatedDays;
  final RepairPriority priority;

  RepairRecommendation({
    required this.id,
    required this.damageId,
    required this.recommendation,
    required this.estimatedCost,
    required this.estimatedDays,
    required this.priority,
  });
}

enum RepairPriority {
  low,
  medium,
  high,
  urgent,
}

/// نموذج التعرف على السيارة بالواقع المعزز
class ARCarRecognition {
  final String id;
  final String brand;
  final String model;
  final int year;
  final String color;
  final String bodyType;
  final double confidence;
  final Map<String, String> specifications;
  final DateTime recognizedAt;

  ARCarRecognition({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.color,
    required this.bodyType,
    required this.confidence,
    required this.specifications,
    required this.recognizedAt,
  });
}

/// نموذج المعلومات التفاعلية للواقع المعزز
class ARInteractiveInfo {
  final String id;
  final String carId;
  final List<InfoPoint> infoPoints;
  final Map<String, dynamic> overlayData;
  final DateTime createdAt;

  ARInteractiveInfo({
    required this.id,
    required this.carId,
    required this.infoPoints,
    required this.overlayData,
    required this.createdAt,
  });
}

class InfoPoint {
  final String id;
  final String title;
  final String description;
  final InfoType type;
  final List<double> position;
  final String? mediaUrl;
  final Map<String, dynamic> data;

  InfoPoint({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.position,
    this.mediaUrl,
    required this.data,
  });
}

enum InfoType {
  specification,
  feature,
  history,
  maintenance,
  price,
  comparison,
}
