import 'package:flutter/foundation.dart';

/// نموذج مجتمع السيارات
class CarCommunity {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final CommunityType type;
  final List<String> members;
  final List<String> moderators;
  final String ownerId;
  final DateTime createdAt;
  final CommunitySettings settings;
  final Map<String, dynamic> stats;
  final List<String> tags;
  final bool isPublic;

  const CarCommunity({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.type,
    required this.members,
    required this.moderators,
    required this.ownerId,
    required this.createdAt,
    required this.settings,
    required this.stats,
    required this.tags,
    required this.isPublic,
  });

  factory CarCommunity.fromJson(Map<String, dynamic> json) {
    return CarCommunity(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      type: CommunityType.values[json['type']],
      members: List<String>.from(json['members']),
      moderators: List<String>.from(json['moderators']),
      ownerId: json['ownerId'],
      createdAt: DateTime.parse(json['createdAt']),
      settings: CommunitySettings.fromJson(json['settings']),
      stats: json['stats'],
      tags: List<String>.from(json['tags']),
      isPublic: json['isPublic'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'type': type.index,
      'members': members,
      'moderators': moderators,
      'ownerId': ownerId,
      'createdAt': createdAt.toIso8601String(),
      'settings': settings.toJson(),
      'stats': stats,
      'tags': tags,
      'isPublic': isPublic,
    };
  }
}

/// أنواع المجتمعات
enum CommunityType {
  brand,
  model,
  region,
  interest,
  professional,
  enthusiast,
  technical,
  marketplace
}

/// إعدادات المجتمع
class CommunitySettings {
  final bool allowPosts;
  final bool allowComments;
  final bool requireApproval;
  final bool allowImages;
  final bool allowVideos;
  final int maxPostLength;
  final List<String> bannedWords;
  final ModerationLevel moderationLevel;

  const CommunitySettings({
    required this.allowPosts,
    required this.allowComments,
    required this.requireApproval,
    required this.allowImages,
    required this.allowVideos,
    required this.maxPostLength,
    required this.bannedWords,
    required this.moderationLevel,
  });

  factory CommunitySettings.fromJson(Map<String, dynamic> json) {
    return CommunitySettings(
      allowPosts: json['allowPosts'],
      allowComments: json['allowComments'],
      requireApproval: json['requireApproval'],
      allowImages: json['allowImages'],
      allowVideos: json['allowVideos'],
      maxPostLength: json['maxPostLength'],
      bannedWords: List<String>.from(json['bannedWords']),
      moderationLevel: ModerationLevel.values[json['moderationLevel']],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'allowPosts': allowPosts,
      'allowComments': allowComments,
      'requireApproval': requireApproval,
      'allowImages': allowImages,
      'allowVideos': allowVideos,
      'maxPostLength': maxPostLength,
      'bannedWords': bannedWords,
      'moderationLevel': moderationLevel.index,
    };
  }
}

/// مستوى الإشراف
enum ModerationLevel {
  none,
  basic,
  moderate,
  strict,
  maximum
}

/// نموذج المنتدى
class Forum {
  final String id;
  final String title;
  final String description;
  final String communityId;
  final List<ForumTopic> topics;
  final List<String> moderators;
  final ForumCategory category;
  final DateTime createdAt;
  final Map<String, dynamic> stats;
  final bool isPinned;
  final bool isLocked;

  const Forum({
    required this.id,
    required this.title,
    required this.description,
    required this.communityId,
    required this.topics,
    required this.moderators,
    required this.category,
    required this.createdAt,
    required this.stats,
    required this.isPinned,
    required this.isLocked,
  });

  factory Forum.fromJson(Map<String, dynamic> json) {
    return Forum(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      communityId: json['communityId'],
      topics: (json['topics'] as List)
          .map((t) => ForumTopic.fromJson(t))
          .toList(),
      moderators: List<String>.from(json['moderators']),
      category: ForumCategory.values[json['category']],
      createdAt: DateTime.parse(json['createdAt']),
      stats: json['stats'],
      isPinned: json['isPinned'],
      isLocked: json['isLocked'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'communityId': communityId,
      'topics': topics.map((t) => t.toJson()).toList(),
      'moderators': moderators,
      'category': category.index,
      'createdAt': createdAt.toIso8601String(),
      'stats': stats,
      'isPinned': isPinned,
      'isLocked': isLocked,
    };
  }
}

/// فئات المنتدى
enum ForumCategory {
  general,
  technical,
  marketplace,
  reviews,
  maintenance,
  modifications,
  events,
  news
}

/// موضوع المنتدى
class ForumTopic {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final String forumId;
  final List<ForumReply> replies;
  final DateTime createdAt;
  final DateTime lastActivity;
  final int views;
  final int likes;
  final bool isPinned;
  final bool isLocked;
  final List<String> tags;

  const ForumTopic({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.forumId,
    required this.replies,
    required this.createdAt,
    required this.lastActivity,
    required this.views,
    required this.likes,
    required this.isPinned,
    required this.isLocked,
    required this.tags,
  });

  factory ForumTopic.fromJson(Map<String, dynamic> json) {
    return ForumTopic(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      authorId: json['authorId'],
      forumId: json['forumId'],
      replies: (json['replies'] as List)
          .map((r) => ForumReply.fromJson(r))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      lastActivity: DateTime.parse(json['lastActivity']),
      views: json['views'],
      likes: json['likes'],
      isPinned: json['isPinned'],
      isLocked: json['isLocked'],
      tags: List<String>.from(json['tags']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'authorId': authorId,
      'forumId': forumId,
      'replies': replies.map((r) => r.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'lastActivity': lastActivity.toIso8601String(),
      'views': views,
      'likes': likes,
      'isPinned': isPinned,
      'isLocked': isLocked,
      'tags': tags,
    };
  }
}

/// رد المنتدى
class ForumReply {
  final String id;
  final String content;
  final String authorId;
  final String topicId;
  final DateTime createdAt;
  final int likes;
  final List<String> attachments;
  final String? parentReplyId;
  final bool isEdited;
  final DateTime? editedAt;

  const ForumReply({
    required this.id,
    required this.content,
    required this.authorId,
    required this.topicId,
    required this.createdAt,
    required this.likes,
    required this.attachments,
    this.parentReplyId,
    required this.isEdited,
    this.editedAt,
  });

  factory ForumReply.fromJson(Map<String, dynamic> json) {
    return ForumReply(
      id: json['id'],
      content: json['content'],
      authorId: json['authorId'],
      topicId: json['topicId'],
      createdAt: DateTime.parse(json['createdAt']),
      likes: json['likes'],
      attachments: List<String>.from(json['attachments']),
      parentReplyId: json['parentReplyId'],
      isEdited: json['isEdited'],
      editedAt: json['editedAt'] != null 
          ? DateTime.parse(json['editedAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'authorId': authorId,
      'topicId': topicId,
      'createdAt': createdAt.toIso8601String(),
      'likes': likes,
      'attachments': attachments,
      'parentReplyId': parentReplyId,
      'isEdited': isEdited,
      'editedAt': editedAt?.toIso8601String(),
    };
  }
}

/// نموذج مشاركة التجربة
class ExperienceShare {
  final String id;
  final String userId;
  final String title;
  final String content;
  final ExperienceType type;
  final String? carId;
  final List<String> images;
  final List<String> videos;
  final DateTime createdAt;
  final int likes;
  final int shares;
  final List<String> comments;
  final Map<String, dynamic> metadata;
  final List<String> tags;

  const ExperienceShare({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.type,
    this.carId,
    required this.images,
    required this.videos,
    required this.createdAt,
    required this.likes,
    required this.shares,
    required this.comments,
    required this.metadata,
    required this.tags,
  });

  factory ExperienceShare.fromJson(Map<String, dynamic> json) {
    return ExperienceShare(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      content: json['content'],
      type: ExperienceType.values[json['type']],
      carId: json['carId'],
      images: List<String>.from(json['images']),
      videos: List<String>.from(json['videos']),
      createdAt: DateTime.parse(json['createdAt']),
      likes: json['likes'],
      shares: json['shares'],
      comments: List<String>.from(json['comments']),
      metadata: json['metadata'],
      tags: List<String>.from(json['tags']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'content': content,
      'type': type.index,
      'carId': carId,
      'images': images,
      'videos': videos,
      'createdAt': createdAt.toIso8601String(),
      'likes': likes,
      'shares': shares,
      'comments': comments,
      'metadata': metadata,
      'tags': tags,
    };
  }
}

/// أنواع مشاركة التجربة
enum ExperienceType {
  purchase,
  maintenance,
  modification,
  review,
  trip,
  accident,
  tip,
  story
}
