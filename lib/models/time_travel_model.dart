// نماذج السفر عبر الزمن والتلاعب الزمني
// Time Travel and Temporal Manipulation Models

import 'package:flutter/foundation.dart';

// نموذج آلة الزمن للسيارات
class TimeTravelCar {
  final String id;
  final String name;
  final String model;
  final TimeMachineType type;
  final List<String> capabilities;
  final Map<String, dynamic> specifications;
  final TemporalEngine engine;
  final List<TimeDestination> destinations;
  final TimeTravelStatus status;
  final DateTime currentTime;
  final DateTime originalTime;
  final List<String> passengers;
  final Map<String, double> temporalCoordinates;
  final double chronotonLevel;

  const TimeTravelCar({
    required this.id,
    required this.name,
    required this.model,
    required this.type,
    required this.capabilities,
    required this.specifications,
    required this.engine,
    required this.destinations,
    required this.status,
    required this.currentTime,
    required this.originalTime,
    required this.passengers,
    required this.temporalCoordinates,
    required this.chronotonLevel,
  });

  factory TimeTravelCar.fromJson(Map<String, dynamic> json) {
    return TimeTravelCar(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      model: json['model'] ?? '',
      type: TimeMachineType.values.firstWhere(
        (e) => e.toString() == 'TimeMachineType.${json['type']}',
        orElse: () => TimeMachineType.delorean,
      ),
      capabilities: List<String>.from(json['capabilities'] ?? []),
      specifications: json['specifications'] ?? {},
      engine: TemporalEngine.values.firstWhere(
        (e) => e.toString() == 'TemporalEngine.${json['engine']}',
        orElse: () => TemporalEngine.flux,
      ),
      destinations: (json['destinations'] as List?)
          ?.map((e) => TimeDestination.fromJson(e))
          .toList() ?? [],
      status: TimeTravelStatus.values.firstWhere(
        (e) => e.toString() == 'TimeTravelStatus.${json['status']}',
        orElse: () => TimeTravelStatus.present,
      ),
      currentTime: DateTime.parse(json['currentTime'] ?? DateTime.now().toIso8601String()),
      originalTime: DateTime.parse(json['originalTime'] ?? DateTime.now().toIso8601String()),
      passengers: List<String>.from(json['passengers'] ?? []),
      temporalCoordinates: Map<String, double>.from(json['temporalCoordinates'] ?? {}),
      chronotonLevel: json['chronotonLevel']?.toDouble() ?? 0.0,
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
      'engine': engine.toString().split('.').last,
      'destinations': destinations.map((e) => e.toJson()).toList(),
      'status': status.toString().split('.').last,
      'currentTime': currentTime.toIso8601String(),
      'originalTime': originalTime.toIso8601String(),
      'passengers': passengers,
      'temporalCoordinates': temporalCoordinates,
      'chronotonLevel': chronotonLevel,
    };
  }
}

// أنواع آلات الزمن
enum TimeMachineType {
  delorean,       // ديلوريان
  tardis,         // تارديس
  portal,         // بوابة
  wormhole,       // ثقب دودي
  quantum,        // كمي
  tachyon,        // تاكيون
  chronosphere,   // كرونوسفير
  temporal,       // زمني
  paradox,        // مفارقة
  infinity        // لا نهائي
}

// محركات زمنية
enum TemporalEngine {
  flux,           // تدفق
  tachyon,        // تاكيون
  quantum,        // كمي
  warp,           // انحناء
  chronoton,      // كرونوتون
  temporal,       // زمني
  paradox,        // مفارقة
  causality,      // سببية
  entropy,        // إنتروبيا
  infinity        // لا نهائي
}

// حالات السفر عبر الزمن
enum TimeTravelStatus {
  present,        // الحاضر
  past,           // الماضي
  future,         // المستقبل
  traveling,      // يسافر
  stuck,          // عالق
  paradox,        // مفارقة
  loop,           // حلقة
  branching,      // متفرع
  merging,        // مندمج
  lost            // ضائع
}

// وجهات زمنية
class TimeDestination {
  final String id;
  final String name;
  final TimeEra era;
  final DateTime targetTime;
  final Map<String, double> coordinates;
  final List<String> events;
  final bool changeable;
  final Map<String, dynamic> conditions;
  final List<String> hazards;
  final TemporalStability stability;
  final List<String> paradoxes;

  const TimeDestination({
    required this.id,
    required this.name,
    required this.era,
    required this.targetTime,
    required this.coordinates,
    required this.events,
    required this.changeable,
    required this.conditions,
    required this.hazards,
    required this.stability,
    required this.paradoxes,
  });

  factory TimeDestination.fromJson(Map<String, dynamic> json) {
    return TimeDestination(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      era: TimeEra.values.firstWhere(
        (e) => e.toString() == 'TimeEra.${json['era']}',
        orElse: () => TimeEra.present,
      ),
      targetTime: DateTime.parse(json['targetTime'] ?? DateTime.now().toIso8601String()),
      coordinates: Map<String, double>.from(json['coordinates'] ?? {}),
      events: List<String>.from(json['events'] ?? []),
      changeable: json['changeable'] ?? false,
      conditions: json['conditions'] ?? {},
      hazards: List<String>.from(json['hazards'] ?? []),
      stability: TemporalStability.values.firstWhere(
        (e) => e.toString() == 'TemporalStability.${json['stability']}',
        orElse: () => TemporalStability.stable,
      ),
      paradoxes: List<String>.from(json['paradoxes'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'era': era.toString().split('.').last,
      'targetTime': targetTime.toIso8601String(),
      'coordinates': coordinates,
      'events': events,
      'changeable': changeable,
      'conditions': conditions,
      'hazards': hazards,
      'stability': stability.toString().split('.').last,
      'paradoxes': paradoxes,
    };
  }
}

// العصور الزمنية
enum TimeEra {
  prehistoric,    // ما قبل التاريخ
  ancient,        // قديم
  medieval,       // العصور الوسطى
  renaissance,    // النهضة
  industrial,     // الصناعي
  modern,         // الحديث
  present,        // الحاضر
  nearFuture,     // المستقبل القريب
  farFuture,      // المستقبل البعيد
  endOfTime       // نهاية الزمن
}

// الاستقرار الزمني
enum TemporalStability {
  stable,         // مستقر
  unstable,       // غير مستقر
  fluctuating,    // متذبذب
  collapsing,     // منهار
  paradoxical,    // مفارق
  branching,      // متفرع
  merging,        // مندمج
  looping,        // متكرر
  chaotic,        // فوضوي
  unknown         // غير معروف
}

// نموذج المفارقة الزمنية
class TemporalParadox {
  final String id;
  final String name;
  final ParadoxType type;
  final String description;
  final List<String> causes;
  final List<String> effects;
  final ParadoxSeverity severity;
  final Map<String, dynamic> timeline;
  final List<String> affectedEvents;
  final ParadoxStatus status;
  final DateTime created;
  final List<String> resolutionMethods;

  const TemporalParadox({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.causes,
    required this.effects,
    required this.severity,
    required this.timeline,
    required this.affectedEvents,
    required this.status,
    required this.created,
    required this.resolutionMethods,
  });

  factory TemporalParadox.fromJson(Map<String, dynamic> json) {
    return TemporalParadox(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: ParadoxType.values.firstWhere(
        (e) => e.toString() == 'ParadoxType.${json['type']}',
        orElse: () => ParadoxType.grandfather,
      ),
      description: json['description'] ?? '',
      causes: List<String>.from(json['causes'] ?? []),
      effects: List<String>.from(json['effects'] ?? []),
      severity: ParadoxSeverity.values.firstWhere(
        (e) => e.toString() == 'ParadoxSeverity.${json['severity']}',
        orElse: () => ParadoxSeverity.minor,
      ),
      timeline: json['timeline'] ?? {},
      affectedEvents: List<String>.from(json['affectedEvents'] ?? []),
      status: ParadoxStatus.values.firstWhere(
        (e) => e.toString() == 'ParadoxStatus.${json['status']}',
        orElse: () => ParadoxStatus.active,
      ),
      created: DateTime.parse(json['created'] ?? DateTime.now().toIso8601String()),
      resolutionMethods: List<String>.from(json['resolutionMethods'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString().split('.').last,
      'description': description,
      'causes': causes,
      'effects': effects,
      'severity': severity.toString().split('.').last,
      'timeline': timeline,
      'affectedEvents': affectedEvents,
      'status': status.toString().split('.').last,
      'created': created.toIso8601String(),
      'resolutionMethods': resolutionMethods,
    };
  }
}

// أنواع المفارقات
enum ParadoxType {
  grandfather,    // الجد
  bootstrap,      // البوتستراب
  predestination, // القدر المحتوم
  causal,         // السببي
  temporal,       // الزمني
  ontological,    // الوجودي
  information,    // المعلوماتي
  quantum,        // الكمي
  butterfly,      // الفراشة
  novikov         // نوفيكوف
}

// شدة المفارقة
enum ParadoxSeverity {
  minor,          // طفيف
  moderate,       // متوسط
  major,          // كبير
  critical,       // حرج
  catastrophic,   // كارثي
  universal,      // كوني
  multiversal,    // متعدد الأكوان
  temporal,       // زمني
  existential,    // وجودي
  infinite        // لا نهائي
}

// حالة المفارقة
enum ParadoxStatus {
  active,         // نشط
  resolved,       // محلول
  contained,      // محتوى
  spreading,      // منتشر
  stabilizing,    // يستقر
  collapsing,     // ينهار
  merging,        // يندمج
  branching,      // يتفرع
  looping,        // يتكرر
  unknown         // غير معروف
}

// نموذج الخط الزمني
class Timeline {
  final String id;
  final String name;
  final TimelineType type;
  final List<HistoricalEvent> events;
  final Map<String, dynamic> properties;
  final TimelineStatus status;
  final DateTime created;
  final List<String> branches;
  final List<String> merges;
  final double stability;
  final List<String> paradoxes;

  const Timeline({
    required this.id,
    required this.name,
    required this.type,
    required this.events,
    required this.properties,
    required this.status,
    required this.created,
    required this.branches,
    required this.merges,
    required this.stability,
    required this.paradoxes,
  });

  factory Timeline.fromJson(Map<String, dynamic> json) {
    return Timeline(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: TimelineType.values.firstWhere(
        (e) => e.toString() == 'TimelineType.${json['type']}',
        orElse: () => TimelineType.linear,
      ),
      events: (json['events'] as List?)
          ?.map((e) => HistoricalEvent.fromJson(e))
          .toList() ?? [],
      properties: json['properties'] ?? {},
      status: TimelineStatus.values.firstWhere(
        (e) => e.toString() == 'TimelineStatus.${json['status']}',
        orElse: () => TimelineStatus.stable,
      ),
      created: DateTime.parse(json['created'] ?? DateTime.now().toIso8601String()),
      branches: List<String>.from(json['branches'] ?? []),
      merges: List<String>.from(json['merges'] ?? []),
      stability: json['stability']?.toDouble() ?? 0.0,
      paradoxes: List<String>.from(json['paradoxes'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString().split('.').last,
      'events': events.map((e) => e.toJson()).toList(),
      'properties': properties,
      'status': status.toString().split('.').last,
      'created': created.toIso8601String(),
      'branches': branches,
      'merges': merges,
      'stability': stability,
      'paradoxes': paradoxes,
    };
  }
}

// أنواع الخطوط الزمنية
enum TimelineType {
  linear,         // خطي
  branching,      // متفرع
  circular,       // دائري
  spiral,         // حلزوني
  quantum,        // كمي
  parallel,       // متوازي
  convergent,     // متقارب
  divergent,      // متباعد
  chaotic,        // فوضوي
  infinite        // لا نهائي
}

// حالة الخط الزمني
enum TimelineStatus {
  stable,         // مستقر
  unstable,       // غير مستقر
  branching,      // يتفرع
  merging,        // يندمج
  collapsing,     // ينهار
  reforming,      // يعيد تشكيل
  paradoxical,    // مفارق
  quantum,        // كمي
  destroyed,      // مدمر
  unknown         // غير معروف
}

// الأحداث التاريخية
class HistoricalEvent {
  final String id;
  final String name;
  final String description;
  final DateTime timestamp;
  final EventImportance importance;
  final List<String> participants;
  final Map<String, dynamic> details;
  final bool changeable;
  final List<String> consequences;
  final EventStatus status;

  const HistoricalEvent({
    required this.id,
    required this.name,
    required this.description,
    required this.timestamp,
    required this.importance,
    required this.participants,
    required this.details,
    required this.changeable,
    required this.consequences,
    required this.status,
  });

  factory HistoricalEvent.fromJson(Map<String, dynamic> json) {
    return HistoricalEvent(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      importance: EventImportance.values.firstWhere(
        (e) => e.toString() == 'EventImportance.${json['importance']}',
        orElse: () => EventImportance.minor,
      ),
      participants: List<String>.from(json['participants'] ?? []),
      details: json['details'] ?? {},
      changeable: json['changeable'] ?? false,
      consequences: List<String>.from(json['consequences'] ?? []),
      status: EventStatus.values.firstWhere(
        (e) => e.toString() == 'EventStatus.${json['status']}',
        orElse: () => EventStatus.occurred,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'importance': importance.toString().split('.').last,
      'participants': participants,
      'details': details,
      'changeable': changeable,
      'consequences': consequences,
      'status': status.toString().split('.').last,
    };
  }
}

// أهمية الأحداث
enum EventImportance {
  trivial,        // تافه
  minor,          // طفيف
  moderate,       // متوسط
  major,          // كبير
  critical,       // حرج
  pivotal,        // محوري
  worldChanging,  // يغير العالم
  universal,      // كوني
  temporal,       // زمني
  infinite        // لا نهائي
}

// حالة الأحداث
enum EventStatus {
  occurred,       // حدث
  prevented,      // منع
  altered,        // تغير
  enhanced,       // تحسن
  delayed,        // تأخر
  accelerated,    // تسارع
  duplicated,     // تكرر
  erased,         // محي
  paradoxical,    // مفارق
  unknown         // غير معروف
}
