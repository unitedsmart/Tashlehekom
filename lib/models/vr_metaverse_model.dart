import 'package:flutter/foundation.dart';

/// نموذج الواقع الافتراضي
class VRExperience {
  final String id;
  final String title;
  final String description;
  final VRType type;
  final String carId;
  final String thumbnailUrl;
  final String vrContentUrl;
  final int duration;
  final VRQuality quality;
  final List<String> supportedDevices;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final int viewCount;
  final double rating;
  final bool isInteractive;

  const VRExperience({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.carId,
    required this.thumbnailUrl,
    required this.vrContentUrl,
    required this.duration,
    required this.quality,
    required this.supportedDevices,
    required this.metadata,
    required this.createdAt,
    required this.viewCount,
    required this.rating,
    required this.isInteractive,
  });

  factory VRExperience.fromJson(Map<String, dynamic> json) {
    return VRExperience(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: VRType.values[json['type']],
      carId: json['carId'],
      thumbnailUrl: json['thumbnailUrl'],
      vrContentUrl: json['vrContentUrl'],
      duration: json['duration'],
      quality: VRQuality.values[json['quality']],
      supportedDevices: List<String>.from(json['supportedDevices']),
      metadata: json['metadata'],
      createdAt: DateTime.parse(json['createdAt']),
      viewCount: json['viewCount'],
      rating: json['rating'],
      isInteractive: json['isInteractive'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.index,
      'carId': carId,
      'thumbnailUrl': thumbnailUrl,
      'vrContentUrl': vrContentUrl,
      'duration': duration,
      'quality': quality.index,
      'supportedDevices': supportedDevices,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'viewCount': viewCount,
      'rating': rating,
      'isInteractive': isInteractive,
    };
  }
}

/// أنواع تجارب الواقع الافتراضي
enum VRType {
  carTour,
  showroom,
  testDrive,
  maintenance,
  comparison,
  auction,
  educational,
  entertainment
}

/// جودة الواقع الافتراضي
enum VRQuality {
  low,
  medium,
  high,
  ultra,
  eightK
}

/// نموذج الميتافيرس
class MetaverseSpace {
  final String id;
  final String name;
  final String description;
  final SpaceType type;
  final String worldUrl;
  final List<String> participants;
  final int maxCapacity;
  final Map<String, dynamic> settings;
  final List<VirtualObject> objects;
  final DateTime createdAt;
  final String ownerId;
  final bool isPublic;
  final List<String> tags;

  const MetaverseSpace({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.worldUrl,
    required this.participants,
    required this.maxCapacity,
    required this.settings,
    required this.objects,
    required this.createdAt,
    required this.ownerId,
    required this.isPublic,
    required this.tags,
  });

  factory MetaverseSpace.fromJson(Map<String, dynamic> json) {
    return MetaverseSpace(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: SpaceType.values[json['type']],
      worldUrl: json['worldUrl'],
      participants: List<String>.from(json['participants']),
      maxCapacity: json['maxCapacity'],
      settings: json['settings'],
      objects: (json['objects'] as List)
          .map((obj) => VirtualObject.fromJson(obj))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      ownerId: json['ownerId'],
      isPublic: json['isPublic'],
      tags: List<String>.from(json['tags']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.index,
      'worldUrl': worldUrl,
      'participants': participants,
      'maxCapacity': maxCapacity,
      'settings': settings,
      'objects': objects.map((obj) => obj.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'ownerId': ownerId,
      'isPublic': isPublic,
      'tags': tags,
    };
  }
}

/// أنواع المساحات في الميتافيرس
enum SpaceType {
  showroom,
  marketplace,
  socialHub,
  testTrack,
  workshop,
  auction,
  museum,
  conference
}

/// نموذج الكائن الافتراضي
class VirtualObject {
  final String id;
  final String name;
  final ObjectType type;
  final String modelUrl;
  final Map<String, double> position;
  final Map<String, double> rotation;
  final Map<String, double> scale;
  final Map<String, dynamic> properties;
  final bool isInteractive;
  final List<String> animations;
  final String textureUrl;

  const VirtualObject({
    required this.id,
    required this.name,
    required this.type,
    required this.modelUrl,
    required this.position,
    required this.rotation,
    required this.scale,
    required this.properties,
    required this.isInteractive,
    required this.animations,
    required this.textureUrl,
  });

  factory VirtualObject.fromJson(Map<String, dynamic> json) {
    return VirtualObject(
      id: json['id'],
      name: json['name'],
      type: ObjectType.values[json['type']],
      modelUrl: json['modelUrl'],
      position: Map<String, double>.from(json['position']),
      rotation: Map<String, double>.from(json['rotation']),
      scale: Map<String, double>.from(json['scale']),
      properties: json['properties'],
      isInteractive: json['isInteractive'],
      animations: List<String>.from(json['animations']),
      textureUrl: json['textureUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.index,
      'modelUrl': modelUrl,
      'position': position,
      'rotation': rotation,
      'scale': scale,
      'properties': properties,
      'isInteractive': isInteractive,
      'animations': animations,
      'textureUrl': textureUrl,
    };
  }
}

/// أنواع الكائنات الافتراضية
enum ObjectType {
  car,
  building,
  furniture,
  decoration,
  interactive,
  npc,
  portal,
  screen
}

/// نموذج الأفاتار
class VirtualAvatar {
  final String id;
  final String userId;
  final String name;
  final String modelUrl;
  final Map<String, dynamic> appearance;
  final List<String> accessories;
  final Map<String, double> position;
  final AvatarStatus status;
  final DateTime lastActive;
  final Map<String, dynamic> stats;

  const VirtualAvatar({
    required this.id,
    required this.userId,
    required this.name,
    required this.modelUrl,
    required this.appearance,
    required this.accessories,
    required this.position,
    required this.status,
    required this.lastActive,
    required this.stats,
  });

  factory VirtualAvatar.fromJson(Map<String, dynamic> json) {
    return VirtualAvatar(
      id: json['id'],
      userId: json['userId'],
      name: json['name'],
      modelUrl: json['modelUrl'],
      appearance: json['appearance'],
      accessories: List<String>.from(json['accessories']),
      position: Map<String, double>.from(json['position']),
      status: AvatarStatus.values[json['status']],
      lastActive: DateTime.parse(json['lastActive']),
      stats: json['stats'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'modelUrl': modelUrl,
      'appearance': appearance,
      'accessories': accessories,
      'position': position,
      'status': status.index,
      'lastActive': lastActive.toIso8601String(),
      'stats': stats,
    };
  }
}

/// حالة الأفاتار
enum AvatarStatus {
  online,
  away,
  busy,
  invisible,
  offline
}

/// نموذج التجربة ثلاثية الأبعاد
class ThreeDExperience {
  final String id;
  final String title;
  final String carId;
  final String modelUrl;
  final List<String> textureUrls;
  final Map<String, dynamic> lighting;
  final List<String> animations;
  final bool hasAudio;
  final String audioUrl;
  final Map<String, dynamic> controls;
  final DateTime createdAt;
  final int viewCount;

  const ThreeDExperience({
    required this.id,
    required this.title,
    required this.carId,
    required this.modelUrl,
    required this.textureUrls,
    required this.lighting,
    required this.animations,
    required this.hasAudio,
    required this.audioUrl,
    required this.controls,
    required this.createdAt,
    required this.viewCount,
  });

  factory ThreeDExperience.fromJson(Map<String, dynamic> json) {
    return ThreeDExperience(
      id: json['id'],
      title: json['title'],
      carId: json['carId'],
      modelUrl: json['modelUrl'],
      textureUrls: List<String>.from(json['textureUrls']),
      lighting: json['lighting'],
      animations: List<String>.from(json['animations']),
      hasAudio: json['hasAudio'],
      audioUrl: json['audioUrl'],
      controls: json['controls'],
      createdAt: DateTime.parse(json['createdAt']),
      viewCount: json['viewCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'carId': carId,
      'modelUrl': modelUrl,
      'textureUrls': textureUrls,
      'lighting': lighting,
      'animations': animations,
      'hasAudio': hasAudio,
      'audioUrl': audioUrl,
      'controls': controls,
      'createdAt': createdAt.toIso8601String(),
      'viewCount': viewCount,
    };
  }
}
