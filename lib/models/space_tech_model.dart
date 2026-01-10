// نماذج تقنيات الفضاء والاستكشاف الكوني
// Space Technology and Cosmic Exploration Models

import 'package:flutter/foundation.dart';

// نموذج السيارة الفضائية
class SpaceCar {
  final String id;
  final String name;
  final String model;
  final SpaceCarType type;
  final List<String> capabilities;
  final Map<String, dynamic> specifications;
  final SpacePropulsion propulsion;
  final List<SpaceDestination> destinations;
  final SpaceCarStatus status;
  final DateTime lastMission;
  final double fuelLevel;
  final List<String> crew;
  final Map<String, double> coordinates;

  const SpaceCar({
    required this.id,
    required this.name,
    required this.model,
    required this.type,
    required this.capabilities,
    required this.specifications,
    required this.propulsion,
    required this.destinations,
    required this.status,
    required this.lastMission,
    required this.fuelLevel,
    required this.crew,
    required this.coordinates,
  });

  factory SpaceCar.fromJson(Map<String, dynamic> json) {
    return SpaceCar(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      model: json['model'] ?? '',
      type: SpaceCarType.values.firstWhere(
        (e) => e.toString() == 'SpaceCarType.${json['type']}',
        orElse: () => SpaceCarType.shuttle,
      ),
      capabilities: List<String>.from(json['capabilities'] ?? []),
      specifications: json['specifications'] ?? {},
      propulsion: SpacePropulsion.values.firstWhere(
        (e) => e.toString() == 'SpacePropulsion.${json['propulsion']}',
        orElse: () => SpacePropulsion.chemical,
      ),
      destinations: (json['destinations'] as List?)
          ?.map((e) => SpaceDestination.fromJson(e))
          .toList() ?? [],
      status: SpaceCarStatus.values.firstWhere(
        (e) => e.toString() == 'SpaceCarStatus.${json['status']}',
        orElse: () => SpaceCarStatus.docked,
      ),
      lastMission: DateTime.parse(json['lastMission'] ?? DateTime.now().toIso8601String()),
      fuelLevel: json['fuelLevel']?.toDouble() ?? 0.0,
      crew: List<String>.from(json['crew'] ?? []),
      coordinates: Map<String, double>.from(json['coordinates'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'model': model,
      'type': type.toString().split('.').last,
      'capabilities': capabilities,
      'specifications': specifications,
      'propulsion': propulsion.toString().split('.').last,
      'destinations': destinations.map((e) => e.toJson()).toList(),
      'status': status.toString().split('.').last,
      'lastMission': lastMission.toIso8601String(),
      'fuelLevel': fuelLevel,
      'crew': crew,
      'coordinates': coordinates,
    };
  }
}

// أنواع السيارات الفضائية
enum SpaceCarType {
  shuttle,        // مكوك
  cruiser,        // طراد
  explorer,       // مستكشف
  transport,      // نقل
  mining,         // تعدين
  research,       // بحث
  military,       // عسكري
  luxury,         // فاخر
  racing,         // سباق
  colony         // استعمار
}

// أنواع الدفع الفضائي
enum SpacePropulsion {
  chemical,       // كيميائي
  ion,           // أيوني
  nuclear,       // نووي
  fusion,        // اندماج
  antimatter,    // مضاد المادة
  warp,          // انحناء
  quantum,       // كمي
  gravity,       // جاذبية
  solar,         // شمسي
  hybrid         // هجين
}

// حالات السيارة الفضائية
enum SpaceCarStatus {
  docked,        // راسية
  launching,     // إطلاق
  inTransit,     // في الطريق
  exploring,     // استكشاف
  mining,        // تعدين
  maintenance,   // صيانة
  emergency,     // طوارئ
  returning,     // عائدة
  lost,          // مفقودة
  destroyed      // مدمرة
}

// وجهات الفضاء
class SpaceDestination {
  final String id;
  final String name;
  final DestinationType type;
  final Map<String, double> coordinates;
  final double distance;
  final List<String> resources;
  final bool habitable;
  final Map<String, dynamic> conditions;
  final List<String> hazards;
  final ExplorationStatus status;

  const SpaceDestination({
    required this.id,
    required this.name,
    required this.type,
    required this.coordinates,
    required this.distance,
    required this.resources,
    required this.habitable,
    required this.conditions,
    required this.hazards,
    required this.status,
  });

  factory SpaceDestination.fromJson(Map<String, dynamic> json) {
    return SpaceDestination(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: DestinationType.values.firstWhere(
        (e) => e.toString() == 'DestinationType.${json['type']}',
        orElse: () => DestinationType.planet,
      ),
      coordinates: Map<String, double>.from(json['coordinates'] ?? {}),
      distance: json['distance']?.toDouble() ?? 0.0,
      resources: List<String>.from(json['resources'] ?? []),
      habitable: json['habitable'] ?? false,
      conditions: json['conditions'] ?? {},
      hazards: List<String>.from(json['hazards'] ?? []),
      status: ExplorationStatus.values.firstWhere(
        (e) => e.toString() == 'ExplorationStatus.${json['status']}',
        orElse: () => ExplorationStatus.unknown,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString().split('.').last,
      'coordinates': coordinates,
      'distance': distance,
      'resources': resources,
      'habitable': habitable,
      'conditions': conditions,
      'hazards': hazards,
      'status': status.toString().split('.').last,
    };
  }
}

// أنواع الوجهات
enum DestinationType {
  planet,        // كوكب
  moon,          // قمر
  asteroid,      // كويكب
  comet,         // مذنب
  station,       // محطة
  nebula,        // سديم
  blackhole,     // ثقب أسود
  wormhole,      // ثقب دودي
  galaxy,        // مجرة
  dimension      // بُعد
}

// حالة الاستكشاف
enum ExplorationStatus {
  unknown,       // غير معروف
  discovered,    // مكتشف
  explored,      // مستكشف
  colonized,     // مستعمر
  mining,        // تعدين
  abandoned,     // مهجور
  dangerous,     // خطير
  restricted,    // محظور
  quarantined,   // محجور
  destroyed      // مدمر
}

// نموذج التكنولوجيا الكمية المتقدمة
class QuantumTechnology {
  final String id;
  final String name;
  final QuantumTechType type;
  final List<String> applications;
  final Map<String, dynamic> specifications;
  final double efficiency;
  final QuantumState state;
  final List<String> requirements;
  final Map<String, double> performance;
  final DateTime developed;
  final TechLevel level;

  const QuantumTechnology({
    required this.id,
    required this.name,
    required this.type,
    required this.applications,
    required this.specifications,
    required this.efficiency,
    required this.state,
    required this.requirements,
    required this.performance,
    required this.developed,
    required this.level,
  });

  factory QuantumTechnology.fromJson(Map<String, dynamic> json) {
    return QuantumTechnology(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: QuantumTechType.values.firstWhere(
        (e) => e.toString() == 'QuantumTechType.${json['type']}',
        orElse: () => QuantumTechType.computing,
      ),
      applications: List<String>.from(json['applications'] ?? []),
      specifications: json['specifications'] ?? {},
      efficiency: json['efficiency']?.toDouble() ?? 0.0,
      state: QuantumState.values.firstWhere(
        (e) => e.toString() == 'QuantumState.${json['state']}',
        orElse: () => QuantumState.superposition,
      ),
      requirements: List<String>.from(json['requirements'] ?? []),
      performance: Map<String, double>.from(json['performance'] ?? {}),
      developed: DateTime.parse(json['developed'] ?? DateTime.now().toIso8601String()),
      level: TechLevel.values.firstWhere(
        (e) => e.toString() == 'TechLevel.${json['level']}',
        orElse: () => TechLevel.experimental,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString().split('.').last,
      'applications': applications,
      'specifications': specifications,
      'efficiency': efficiency,
      'state': state.toString().split('.').last,
      'requirements': requirements,
      'performance': performance,
      'developed': developed.toIso8601String(),
      'level': level.toString().split('.').last,
    };
  }
}

// أنواع التكنولوجيا الكمية
enum QuantumTechType {
  computing,      // حوسبة
  communication,  // اتصالات
  teleportation,  // نقل فوري
  encryption,     // تشفير
  sensing,        // استشعار
  navigation,     // ملاحة
  propulsion,     // دفع
  energy,         // طاقة
  healing,        // شفاء
  consciousness   // وعي
}

// مستويات التكنولوجيا
enum TechLevel {
  primitive,      // بدائي
  basic,          // أساسي
  advanced,       // متقدم
  experimental,   // تجريبي
  prototype,      // نموذج أولي
  production,     // إنتاج
  mature,         // ناضج
  revolutionary,  // ثوري
  transcendent,   // متسامي
  godlike         // إلهي
}

// نموذج الحضارة الفضائية
class SpaceCivilization {
  final String id;
  final String name;
  final CivilizationType type;
  final KardashevScale scale;
  final List<String> territories;
  final Map<String, dynamic> technology;
  final List<String> species;
  final CivilizationStatus status;
  final Map<String, double> resources;
  final List<String> allies;
  final List<String> enemies;
  final DateTime firstContact;

  const SpaceCivilization({
    required this.id,
    required this.name,
    required this.type,
    required this.scale,
    required this.territories,
    required this.technology,
    required this.species,
    required this.status,
    required this.resources,
    required this.allies,
    required this.enemies,
    required this.firstContact,
  });

  factory SpaceCivilization.fromJson(Map<String, dynamic> json) {
    return SpaceCivilization(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: CivilizationType.values.firstWhere(
        (e) => e.toString() == 'CivilizationType.${json['type']}',
        orElse: () => CivilizationType.planetary,
      ),
      scale: KardashevScale.values.firstWhere(
        (e) => e.toString() == 'KardashevScale.${json['scale']}',
        orElse: () => KardashevScale.typeI,
      ),
      territories: List<String>.from(json['territories'] ?? []),
      technology: json['technology'] ?? {},
      species: List<String>.from(json['species'] ?? []),
      status: CivilizationStatus.values.firstWhere(
        (e) => e.toString() == 'CivilizationStatus.${json['status']}',
        orElse: () => CivilizationStatus.active,
      ),
      resources: Map<String, double>.from(json['resources'] ?? {}),
      allies: List<String>.from(json['allies'] ?? []),
      enemies: List<String>.from(json['enemies'] ?? []),
      firstContact: DateTime.parse(json['firstContact'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString().split('.').last,
      'scale': scale.toString().split('.').last,
      'territories': territories,
      'technology': technology,
      'species': species,
      'status': status.toString().split('.').last,
      'resources': resources,
      'allies': allies,
      'enemies': enemies,
      'firstContact': firstContact.toIso8601String(),
    };
  }
}

// أنواع الحضارات
enum CivilizationType {
  planetary,      // كوكبية
  stellar,        // نجمية
  galactic,       // مجرية
  intergalactic,  // بين المجرات
  dimensional,    // بُعدية
  quantum,        // كمية
  digital,        // رقمية
  hybrid,         // هجينة
  transcendent,   // متسامية
  omnipresent     // كلية الوجود
}

// مقياس كارداشيف
enum KardashevScale {
  typeI,          // النوع الأول
  typeII,         // النوع الثاني
  typeIII,        // النوع الثالث
  typeIV,         // النوع الرابع
  typeV,          // النوع الخامس
  omega           // أوميغا
}

// حالة الحضارة
enum CivilizationStatus {
  emerging,       // ناشئة
  developing,     // نامية
  active,         // نشطة
  advanced,       // متقدمة
  declining,      // متراجعة
  extinct,        // منقرضة
  ascended,       // صاعدة
  dormant,        // خاملة
  hostile,        // عدائية
  unknown         // غير معروفة
}

// نموذج البُعد المتعدد
class Multiverse {
  final String id;
  final String name;
  final List<Universe> universes;
  final MultiverseType type;
  final Map<String, dynamic> properties;
  final List<String> laws;
  final DimensionCount dimensions;
  final MultiverseStatus status;
  final DateTime discovered;
  final List<String> explorers;

  const Multiverse({
    required this.id,
    required this.name,
    required this.universes,
    required this.type,
    required this.properties,
    required this.laws,
    required this.dimensions,
    required this.status,
    required this.discovered,
    required this.explorers,
  });

  factory Multiverse.fromJson(Map<String, dynamic> json) {
    return Multiverse(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      universes: (json['universes'] as List?)
          ?.map((e) => Universe.fromJson(e))
          .toList() ?? [],
      type: MultiverseType.values.firstWhere(
        (e) => e.toString() == 'MultiverseType.${json['type']}',
        orElse: () => MultiverseType.infinite,
      ),
      properties: json['properties'] ?? {},
      laws: List<String>.from(json['laws'] ?? []),
      dimensions: DimensionCount.values.firstWhere(
        (e) => e.toString() == 'DimensionCount.${json['dimensions']}',
        orElse: () => DimensionCount.eleven,
      ),
      status: MultiverseStatus.values.firstWhere(
        (e) => e.toString() == 'MultiverseStatus.${json['status']}',
        orElse: () => MultiverseStatus.stable,
      ),
      discovered: DateTime.parse(json['discovered'] ?? DateTime.now().toIso8601String()),
      explorers: List<String>.from(json['explorers'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'universes': universes.map((e) => e.toJson()).toList(),
      'type': type.toString().split('.').last,
      'properties': properties,
      'laws': laws,
      'dimensions': dimensions.toString().split('.').last,
      'status': status.toString().split('.').last,
      'discovered': discovered.toIso8601String(),
      'explorers': explorers,
    };
  }
}

// أنواع الكون المتعدد
enum MultiverseType {
  infinite,       // لا نهائي
  cyclic,         // دوري
  bubble,         // فقاعي
  quantum,        // كمي
  string,         // خيطي
  holographic,    // هولوغرافي
  simulation,     // محاكاة
  fractal,        // كسيري
  conscious,      // واعي
  mathematical    // رياضي
}

// عدد الأبعاد
enum DimensionCount {
  three,          // ثلاثة
  four,           // أربعة
  five,           // خمسة
  six,            // ستة
  seven,          // سبعة
  eight,          // ثمانية
  nine,           // تسعة
  ten,            // عشرة
  eleven,         // أحد عشر
  infinite        // لا نهائي
}

// حالة الكون المتعدد
enum MultiverseStatus {
  stable,         // مستقر
  expanding,      // متوسع
  contracting,    // متقلص
  oscillating,    // متذبذب
  collapsing,     // منهار
  merging,        // مندمج
  splitting,      // منقسم
  evolving,       // متطور
  transcending,   // متسامي
  unknown         // غير معروف
}

// نموذج الكون
class Universe {
  final String id;
  final String name;
  final UniverseType type;
  final Map<String, dynamic> constants;
  final List<String> galaxies;
  final double age;
  final UniverseStatus status;
  final Map<String, double> composition;

  const Universe({
    required this.id,
    required this.name,
    required this.type,
    required this.constants,
    required this.galaxies,
    required this.age,
    required this.status,
    required this.composition,
  });

  factory Universe.fromJson(Map<String, dynamic> json) {
    return Universe(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: UniverseType.values.firstWhere(
        (e) => e.toString() == 'UniverseType.${json['type']}',
        orElse: () => UniverseType.physical,
      ),
      constants: json['constants'] ?? {},
      galaxies: List<String>.from(json['galaxies'] ?? []),
      age: json['age']?.toDouble() ?? 0.0,
      status: UniverseStatus.values.firstWhere(
        (e) => e.toString() == 'UniverseStatus.${json['status']}',
        orElse: () => UniverseStatus.expanding,
      ),
      composition: Map<String, double>.from(json['composition'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString().split('.').last,
      'constants': constants,
      'galaxies': galaxies,
      'age': age,
      'status': status.toString().split('.').last,
      'composition': composition,
    };
  }
}

// أنواع الأكوان
enum UniverseType {
  physical,       // فيزيائي
  quantum,        // كمي
  digital,        // رقمي
  consciousness,  // وعي
  mathematical,   // رياضي
  information,    // معلوماتي
  energy,         // طاقة
  void,           // فراغ
  mirror,         // مرآة
  shadow          // ظل
}

// حالة الكون
enum UniverseStatus {
  expanding,      // متوسع
  contracting,    // متقلص
  stable,         // مستقر
  oscillating,    // متذبذب
  dying,          // يموت
  reborn,         // يولد من جديد
  merging,        // مندمج
  splitting,      // منقسم
  transforming,   // متحول
  transcendent    // متسامي
}
