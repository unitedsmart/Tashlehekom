import 'package:flutter/foundation.dart';

/// نموذج المساعد الصوتي الذكي
class VoiceAIAssistant {
  final String id;
  final String name;
  final String language;
  final VoiceType voiceType;
  final bool isActive;
  final List<String> supportedCommands;
  final Map<String, dynamic> personalityTraits;
  final DateTime lastInteraction;
  final double confidenceLevel;
  final String currentContext;

  const VoiceAIAssistant({
    required this.id,
    required this.name,
    required this.language,
    required this.voiceType,
    required this.isActive,
    required this.supportedCommands,
    required this.personalityTraits,
    required this.lastInteraction,
    required this.confidenceLevel,
    required this.currentContext,
  });

  factory VoiceAIAssistant.fromJson(Map<String, dynamic> json) {
    return VoiceAIAssistant(
      id: json['id'],
      name: json['name'],
      language: json['language'],
      voiceType: VoiceType.values[json['voiceType']],
      isActive: json['isActive'],
      supportedCommands: List<String>.from(json['supportedCommands']),
      personalityTraits: json['personalityTraits'],
      lastInteraction: DateTime.parse(json['lastInteraction']),
      confidenceLevel: json['confidenceLevel'],
      currentContext: json['currentContext'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'language': language,
      'voiceType': voiceType.index,
      'isActive': isActive,
      'supportedCommands': supportedCommands,
      'personalityTraits': personalityTraits,
      'lastInteraction': lastInteraction.toIso8601String(),
      'confidenceLevel': confidenceLevel,
      'currentContext': currentContext,
    };
  }
}

/// أنواع الأصوات المتاحة
enum VoiceType {
  maleArabic,
  femaleArabic,
  maleEnglish,
  femaleEnglish,
  childFriendly,
  professional,
  casual,
  robotic
}

/// نموذج التفاعل الصوتي
class VoiceInteraction {
  final String id;
  final String userId;
  final String assistantId;
  final String userInput;
  final String assistantResponse;
  final VoiceCommand command;
  final DateTime timestamp;
  final double confidence;
  final String audioPath;
  final int duration;
  final InteractionResult result;
  final Map<String, dynamic> context;

  const VoiceInteraction({
    required this.id,
    required this.userId,
    required this.assistantId,
    required this.userInput,
    required this.assistantResponse,
    required this.command,
    required this.timestamp,
    required this.confidence,
    required this.audioPath,
    required this.duration,
    required this.result,
    required this.context,
  });

  factory VoiceInteraction.fromJson(Map<String, dynamic> json) {
    return VoiceInteraction(
      id: json['id'],
      userId: json['userId'],
      assistantId: json['assistantId'],
      userInput: json['userInput'],
      assistantResponse: json['assistantResponse'],
      command: VoiceCommand.values[json['command']],
      timestamp: DateTime.parse(json['timestamp']),
      confidence: json['confidence'],
      audioPath: json['audioPath'],
      duration: json['duration'],
      result: InteractionResult.values[json['result']],
      context: json['context'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'assistantId': assistantId,
      'userInput': userInput,
      'assistantResponse': assistantResponse,
      'command': command.index,
      'timestamp': timestamp.toIso8601String(),
      'confidence': confidence,
      'audioPath': audioPath,
      'duration': duration,
      'result': result.index,
      'context': context,
    };
  }
}

/// أنواع الأوامر الصوتية
enum VoiceCommand {
  search,
  filter,
  navigate,
  call,
  message,
  bookmark,
  compare,
  calculate,
  translate,
  weather,
  news,
  help,
  settings,
  unknown
}

/// نتائج التفاعل
enum InteractionResult {
  success,
  partialSuccess,
  failed,
  misunderstood,
  timeout,
  cancelled
}

/// نموذج معالجة اللغة الطبيعية
class NLPProcessor {
  final String id;
  final String modelVersion;
  final List<String> supportedLanguages;
  final Map<String, double> languageConfidence;
  final List<String> entities;
  final List<String> intents;
  final Map<String, dynamic> processingStats;
  final DateTime lastUpdate;

  const NLPProcessor({
    required this.id,
    required this.modelVersion,
    required this.supportedLanguages,
    required this.languageConfidence,
    required this.entities,
    required this.intents,
    required this.processingStats,
    required this.lastUpdate,
  });

  factory NLPProcessor.fromJson(Map<String, dynamic> json) {
    return NLPProcessor(
      id: json['id'],
      modelVersion: json['modelVersion'],
      supportedLanguages: List<String>.from(json['supportedLanguages']),
      languageConfidence: Map<String, double>.from(json['languageConfidence']),
      entities: List<String>.from(json['entities']),
      intents: List<String>.from(json['intents']),
      processingStats: json['processingStats'],
      lastUpdate: DateTime.parse(json['lastUpdate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'modelVersion': modelVersion,
      'supportedLanguages': supportedLanguages,
      'languageConfidence': languageConfidence,
      'entities': entities,
      'intents': intents,
      'processingStats': processingStats,
      'lastUpdate': lastUpdate.toIso8601String(),
    };
  }
}

/// نموذج التعرف على الكلام
class SpeechRecognition {
  final String id;
  final String audioPath;
  final String transcription;
  final double confidence;
  final String language;
  final int duration;
  final List<String> alternatives;
  final Map<String, dynamic> metadata;
  final DateTime processedAt;
  final RecognitionStatus status;

  const SpeechRecognition({
    required this.id,
    required this.audioPath,
    required this.transcription,
    required this.confidence,
    required this.language,
    required this.duration,
    required this.alternatives,
    required this.metadata,
    required this.processedAt,
    required this.status,
  });

  factory SpeechRecognition.fromJson(Map<String, dynamic> json) {
    return SpeechRecognition(
      id: json['id'],
      audioPath: json['audioPath'],
      transcription: json['transcription'],
      confidence: json['confidence'],
      language: json['language'],
      duration: json['duration'],
      alternatives: List<String>.from(json['alternatives']),
      metadata: json['metadata'],
      processedAt: DateTime.parse(json['processedAt']),
      status: RecognitionStatus.values[json['status']],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'audioPath': audioPath,
      'transcription': transcription,
      'confidence': confidence,
      'language': language,
      'duration': duration,
      'alternatives': alternatives,
      'metadata': metadata,
      'processedAt': processedAt.toIso8601String(),
      'status': status.index,
    };
  }
}

/// حالة التعرف على الكلام
enum RecognitionStatus {
  processing,
  completed,
  failed,
  timeout,
  cancelled,
  lowQuality
}

/// نموذج تحويل النص إلى كلام
class TextToSpeech {
  final String id;
  final String text;
  final String audioPath;
  final VoiceType voiceType;
  final double speed;
  final double pitch;
  final String language;
  final int duration;
  final DateTime generatedAt;
  final TTSStatus status;

  const TextToSpeech({
    required this.id,
    required this.text,
    required this.audioPath,
    required this.voiceType,
    required this.speed,
    required this.pitch,
    required this.language,
    required this.duration,
    required this.generatedAt,
    required this.status,
  });

  factory TextToSpeech.fromJson(Map<String, dynamic> json) {
    return TextToSpeech(
      id: json['id'],
      text: json['text'],
      audioPath: json['audioPath'],
      voiceType: VoiceType.values[json['voiceType']],
      speed: json['speed'],
      pitch: json['pitch'],
      language: json['language'],
      duration: json['duration'],
      generatedAt: DateTime.parse(json['generatedAt']),
      status: TTSStatus.values[json['status']],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'audioPath': audioPath,
      'voiceType': voiceType.index,
      'speed': speed,
      'pitch': pitch,
      'language': language,
      'duration': duration,
      'generatedAt': generatedAt.toIso8601String(),
      'status': status.index,
    };
  }
}

/// حالة تحويل النص إلى كلام
enum TTSStatus {
  generating,
  completed,
  failed,
  cancelled
}
