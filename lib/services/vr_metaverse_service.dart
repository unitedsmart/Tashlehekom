import 'dart:async';
import 'dart:math';
import '../models/vr_metaverse_model.dart';

/// خدمة الواقع الافتراضي والميتافيرس
class VRMetaverseService {
  static final VRMetaverseService _instance = VRMetaverseService._internal();
  factory VRMetaverseService() => _instance;
  VRMetaverseService._internal();

  final List<VRExperience> _vrExperiences = [];
  final List<MetaverseSpace> _metaverseSpaces = [];
  final List<ThreeDExperience> _threeDExperiences = [];
  VirtualAvatar? _currentAvatar;

  /// تهيئة الخدمة
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 2));
    await _loadSampleData();
  }

  /// إنشاء تجربة واقع افتراضي للسيارة
  Future<VRExperience> createVRExperience({
    required String carId,
    required String title,
    required VRType type,
    VRQuality quality = VRQuality.high,
  }) async {
    await Future.delayed(const Duration(seconds: 3));

    final experience = VRExperience(
      id: 'vr_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: _generateVRDescription(type),
      type: type,
      carId: carId,
      thumbnailUrl: 'https://example.com/vr_thumbnail_$carId.jpg',
      vrContentUrl: 'https://example.com/vr_content_$carId.vrx',
      duration: _getVRDuration(type),
      quality: quality,
      supportedDevices: _getSupportedDevices(),
      metadata: _generateVRMetadata(type),
      createdAt: DateTime.now(),
      viewCount: 0,
      rating: 0.0,
      isInteractive: type != VRType.carTour,
    );

    _vrExperiences.add(experience);
    return experience;
  }

  /// الحصول على تجارب الواقع الافتراضي
  Future<List<VRExperience>> getVRExperiences({
    VRType? type,
    VRQuality? minQuality,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    var experiences = List<VRExperience>.from(_vrExperiences);

    if (type != null) {
      experiences = experiences.where((e) => e.type == type).toList();
    }

    if (minQuality != null) {
      experiences = experiences
          .where((e) => e.quality.index >= minQuality.index)
          .toList();
    }

    return experiences;
  }

  /// إنشاء مساحة ميتافيرس
  Future<MetaverseSpace> createMetaverseSpace({
    required String name,
    required String description,
    required SpaceType type,
    int maxCapacity = 50,
    bool isPublic = true,
  }) async {
    await Future.delayed(const Duration(seconds: 4));

    final space = MetaverseSpace(
      id: 'space_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: description,
      type: type,
      worldUrl: 'https://metaverse.tashlehekom.com/world_${DateTime.now().millisecondsSinceEpoch}',
      participants: [],
      maxCapacity: maxCapacity,
      settings: _generateSpaceSettings(type),
      objects: _generateVirtualObjects(type),
      createdAt: DateTime.now(),
      ownerId: 'current_user',
      isPublic: isPublic,
      tags: _generateSpaceTags(type),
    );

    _metaverseSpaces.add(space);
    return space;
  }

  /// الانضمام إلى مساحة ميتافيرس
  Future<bool> joinMetaverseSpace(String spaceId, String userId) async {
    await Future.delayed(const Duration(seconds: 1));

    final spaceIndex = _metaverseSpaces.indexWhere((s) => s.id == spaceId);
    if (spaceIndex == -1) return false;

    final space = _metaverseSpaces[spaceIndex];
    if (space.participants.length >= space.maxCapacity) return false;

    final updatedParticipants = List<String>.from(space.participants);
    if (!updatedParticipants.contains(userId)) {
      updatedParticipants.add(userId);
    }

    _metaverseSpaces[spaceIndex] = MetaverseSpace(
      id: space.id,
      name: space.name,
      description: space.description,
      type: space.type,
      worldUrl: space.worldUrl,
      participants: updatedParticipants,
      maxCapacity: space.maxCapacity,
      settings: space.settings,
      objects: space.objects,
      createdAt: space.createdAt,
      ownerId: space.ownerId,
      isPublic: space.isPublic,
      tags: space.tags,
    );

    return true;
  }

  /// إنشاء أفاتار افتراضي
  Future<VirtualAvatar> createAvatar({
    required String userId,
    required String name,
    Map<String, dynamic>? appearance,
  }) async {
    await Future.delayed(const Duration(seconds: 2));

    final avatar = VirtualAvatar(
      id: 'avatar_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      name: name,
      modelUrl: 'https://avatars.tashlehekom.com/model_${DateTime.now().millisecondsSinceEpoch}.glb',
      appearance: appearance ?? _generateDefaultAppearance(),
      accessories: [],
      position: {'x': 0.0, 'y': 0.0, 'z': 0.0},
      status: AvatarStatus.online,
      lastActive: DateTime.now(),
      stats: _generateAvatarStats(),
    );

    _currentAvatar = avatar;
    return avatar;
  }

  /// إنشاء تجربة ثلاثية الأبعاد
  Future<ThreeDExperience> create3DExperience({
    required String carId,
    required String title,
  }) async {
    await Future.delayed(const Duration(seconds: 3));

    final experience = ThreeDExperience(
      id: '3d_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      carId: carId,
      modelUrl: 'https://models.tashlehekom.com/car_$carId.glb',
      textureUrls: [
        'https://textures.tashlehekom.com/car_${carId}_diffuse.jpg',
        'https://textures.tashlehekom.com/car_${carId}_normal.jpg',
        'https://textures.tashlehekom.com/car_${carId}_metallic.jpg',
      ],
      lighting: _generate3DLighting(),
      animations: ['rotate', 'doors_open', 'hood_open', 'trunk_open'],
      hasAudio: true,
      audioUrl: 'https://audio.tashlehekom.com/car_${carId}_engine.mp3',
      controls: _generate3DControls(),
      createdAt: DateTime.now(),
      viewCount: 0,
    );

    _threeDExperiences.add(experience);
    return experience;
  }

  /// بدء جلسة VR
  Future<Map<String, dynamic>> startVRSession(String experienceId) async {
    await Future.delayed(const Duration(seconds: 2));

    final experience = _vrExperiences.firstWhere(
      (e) => e.id == experienceId,
      orElse: () => throw Exception('تجربة VR غير موجودة'),
    );

    return {
      'sessionId': 'vr_session_${DateTime.now().millisecondsSinceEpoch}',
      'experienceId': experienceId,
      'startTime': DateTime.now().toIso8601String(),
      'streamUrl': experience.vrContentUrl,
      'controls': _generateVRControls(experience.type),
      'settings': {
        'quality': experience.quality.toString(),
        'audio': true,
        'hapticFeedback': true,
        'eyeTracking': false,
      },
    };
  }

  /// الحصول على إحصائيات الاستخدام
  Future<Map<String, dynamic>> getUsageStats() async {
    await Future.delayed(const Duration(milliseconds: 300));

    return {
      'totalVRExperiences': _vrExperiences.length,
      'totalMetaverseSpaces': _metaverseSpaces.length,
      'total3DExperiences': _threeDExperiences.length,
      'activeUsers': _metaverseSpaces
          .fold<int>(0, (sum, space) => sum + space.participants.length),
      'popularVRType': _getMostPopularVRType(),
      'averageSessionDuration': '12:34',
      'totalViewTime': '1,234 ساعة',
    };
  }

  /// تحميل البيانات النموذجية
  Future<void> _loadSampleData() async {
    // إنشاء تجارب VR نموذجية
    _vrExperiences.addAll([
      VRExperience(
        id: 'vr_sample_1',
        title: 'جولة افتراضية - تويوتا كامري 2023',
        description: 'استكشف السيارة من الداخل والخارج',
        type: VRType.carTour,
        carId: 'car_123',
        thumbnailUrl: 'https://example.com/vr_camry.jpg',
        vrContentUrl: 'https://example.com/vr_camry.vrx',
        duration: 300,
        quality: VRQuality.high,
        supportedDevices: ['Oculus Quest', 'HTC Vive', 'PlayStation VR'],
        metadata: {'brand': 'Toyota', 'model': 'Camry', 'year': 2023},
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        viewCount: 1250,
        rating: 4.7,
        isInteractive: true,
      ),
      VRExperience(
        id: 'vr_sample_2',
        title: 'معرض السيارات الافتراضي',
        description: 'تجول في معرض السيارات من منزلك',
        type: VRType.showroom,
        carId: 'showroom_1',
        thumbnailUrl: 'https://example.com/vr_showroom.jpg',
        vrContentUrl: 'https://example.com/vr_showroom.vrx',
        duration: 600,
        quality: VRQuality.ultra,
        supportedDevices: ['Oculus Quest 2', 'HTC Vive Pro'],
        metadata: {'location': 'الرياض', 'cars_count': 50},
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        viewCount: 890,
        rating: 4.9,
        isInteractive: true,
      ),
    ]);

    // إنشاء مساحات ميتافيرس نموذجية
    _metaverseSpaces.addAll([
      MetaverseSpace(
        id: 'space_sample_1',
        name: 'معرض تشليحكم الافتراضي',
        description: 'معرض تفاعلي للسيارات في الميتافيرس',
        type: SpaceType.showroom,
        worldUrl: 'https://metaverse.tashlehekom.com/showroom',
        participants: ['user_1', 'user_2', 'user_3'],
        maxCapacity: 100,
        settings: {'lighting': 'dynamic', 'weather': 'sunny'},
        objects: _generateVirtualObjects(SpaceType.showroom),
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        ownerId: 'admin',
        isPublic: true,
        tags: ['معرض', 'سيارات', 'تفاعلي'],
      ),
    ]);
  }

  /// توليد وصف VR
  String _generateVRDescription(VRType type) {
    switch (type) {
      case VRType.carTour:
        return 'جولة تفاعلية شاملة داخل وخارج السيارة مع إمكانية فتح الأبواب والغطاء';
      case VRType.showroom:
        return 'معرض افتراضي يضم مجموعة متنوعة من السيارات مع إمكانية التفاعل';
      case VRType.testDrive:
        return 'تجربة قيادة افتراضية واقعية مع محاكاة الطرق السعودية';
      case VRType.maintenance:
        return 'دليل صيانة تفاعلي يوضح خطوات الصيانة بالواقع الافتراضي';
      default:
        return 'تجربة واقع افتراضي مميزة ومتطورة';
    }
  }

  /// الحصول على مدة VR
  int _getVRDuration(VRType type) {
    switch (type) {
      case VRType.carTour:
        return 300; // 5 دقائق
      case VRType.showroom:
        return 600; // 10 دقائق
      case VRType.testDrive:
        return 900; // 15 دقيقة
      case VRType.maintenance:
        return 1200; // 20 دقيقة
      default:
        return 300;
    }
  }

  /// الحصول على الأجهزة المدعومة
  List<String> _getSupportedDevices() {
    return [
      'Oculus Quest 2',
      'Oculus Quest 3',
      'HTC Vive',
      'HTC Vive Pro',
      'PlayStation VR',
      'Valve Index',
      'Pico 4',
      'Meta Quest Pro',
    ];
  }

  /// توليد بيانات VR الوصفية
  Map<String, dynamic> _generateVRMetadata(VRType type) {
    return {
      'resolution': '4K',
      'frameRate': 90,
      'audioChannels': 'Spatial 3D',
      'hapticSupport': true,
      'eyeTracking': type == VRType.testDrive,
      'handTracking': true,
      'roomScale': type != VRType.testDrive,
    };
  }

  /// توليد إعدادات المساحة
  Map<String, dynamic> _generateSpaceSettings(SpaceType type) {
    return {
      'lighting': type == SpaceType.showroom ? 'professional' : 'natural',
      'weather': 'clear',
      'timeOfDay': 'day',
      'physics': true,
      'collision': true,
      'voiceChat': true,
      'textChat': true,
      'privateMessages': true,
    };
  }

  /// توليد الكائنات الافتراضية
  List<VirtualObject> _generateVirtualObjects(SpaceType type) {
    final objects = <VirtualObject>[];
    final random = Random();

    for (int i = 0; i < 10; i++) {
      objects.add(VirtualObject(
        id: 'obj_${DateTime.now().millisecondsSinceEpoch}_$i',
        name: 'كائن افتراضي $i',
        type: ObjectType.values[random.nextInt(ObjectType.values.length)],
        modelUrl: 'https://models.tashlehekom.com/object_$i.glb',
        position: {
          'x': random.nextDouble() * 100 - 50,
          'y': 0.0,
          'z': random.nextDouble() * 100 - 50,
        },
        rotation: {
          'x': 0.0,
          'y': random.nextDouble() * 360,
          'z': 0.0,
        },
        scale: {
          'x': 1.0,
          'y': 1.0,
          'z': 1.0,
        },
        properties: {'interactive': true, 'physics': true},
        isInteractive: random.nextBool(),
        animations: ['idle', 'highlight'],
        textureUrl: 'https://textures.tashlehekom.com/object_$i.jpg',
      ));
    }

    return objects;
  }

  /// توليد علامات المساحة
  List<String> _generateSpaceTags(SpaceType type) {
    switch (type) {
      case SpaceType.showroom:
        return ['معرض', 'سيارات', 'تسوق', 'تفاعلي'];
      case SpaceType.marketplace:
        return ['سوق', 'بيع', 'شراء', 'تجارة'];
      case SpaceType.socialHub:
        return ['اجتماعي', 'دردشة', 'مجتمع', 'تواصل'];
      default:
        return ['ميتافيرس', 'افتراضي', 'تفاعلي'];
    }
  }

  /// توليد المظهر الافتراضي
  Map<String, dynamic> _generateDefaultAppearance() {
    return {
      'gender': 'male',
      'skinColor': '#D4A574',
      'hairColor': '#2C1810',
      'eyeColor': '#8B4513',
      'height': 175,
      'build': 'average',
      'clothing': {
        'shirt': 'casual_blue',
        'pants': 'jeans_dark',
        'shoes': 'sneakers_white',
      },
    };
  }

  /// توليد إحصائيات الأفاتار
  Map<String, dynamic> _generateAvatarStats() {
    return {
      'totalTimeSpent': 0,
      'spacesVisited': 0,
      'friendsCount': 0,
      'achievementsUnlocked': 0,
      'level': 1,
      'experience': 0,
    };
  }

  /// توليد إضاءة ثلاثية الأبعاد
  Map<String, dynamic> _generate3DLighting() {
    return {
      'ambient': {'r': 0.3, 'g': 0.3, 'b': 0.3},
      'directional': {
        'color': {'r': 1.0, 'g': 1.0, 'b': 1.0},
        'intensity': 1.0,
        'direction': {'x': -1.0, 'y': -1.0, 'z': -1.0},
      },
      'shadows': true,
      'reflections': true,
    };
  }

  /// توليد عناصر التحكم ثلاثية الأبعاد
  Map<String, dynamic> _generate3DControls() {
    return {
      'rotation': true,
      'zoom': true,
      'pan': true,
      'animations': true,
      'hotspots': true,
      'measurements': true,
      'xray': false,
      'exploded': false,
    };
  }

  /// توليد عناصر تحكم VR
  Map<String, dynamic> _generateVRControls(VRType type) {
    return {
      'teleport': true,
      'grab': type == VRType.carTour,
      'point': true,
      'menu': true,
      'voice': true,
      'gesture': type == VRType.testDrive,
    };
  }

  /// الحصول على أكثر أنواع VR شعبية
  String _getMostPopularVRType() {
    if (_vrExperiences.isEmpty) return 'غير متاح';
    
    final typeCount = <VRType, int>{};
    for (final experience in _vrExperiences) {
      typeCount[experience.type] = (typeCount[experience.type] ?? 0) + 1;
    }
    
    final mostPopular = typeCount.entries
        .reduce((a, b) => a.value > b.value ? a : b);
    
    return mostPopular.key.toString().split('.').last;
  }
}
