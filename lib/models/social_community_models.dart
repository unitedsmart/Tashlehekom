import 'package:cloud_firestore/cloud_firestore.dart';

/// نماذج المجتمع الاجتماعي

/// المنتدى
class Forum {
  final String id;
  final String title;
  final String description;
  final String creatorId;
  final ForumCategory category;
  final List<String> tags;
  final String? imageUrl;
  final int membersCount;
  final int postsCount;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Forum({
    required this.id,
    required this.title,
    required this.description,
    required this.creatorId,
    required this.category,
    required this.tags,
    this.imageUrl,
    required this.membersCount,
    required this.postsCount,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Forum.fromMap(Map<String, dynamic> map) {
    return Forum(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      creatorId: map['creatorId'],
      category: ForumCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => ForumCategory.general,
      ),
      tags: List<String>.from(map['tags'] ?? []),
      imageUrl: map['imageUrl'],
      membersCount: map['membersCount'] ?? 0,
      postsCount: map['postsCount'] ?? 0,
      isActive: map['isActive'] ?? true,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'creatorId': creatorId,
      'category': category.name,
      'tags': tags,
      'imageUrl': imageUrl,
      'membersCount': membersCount,
      'postsCount': postsCount,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

/// فئات المنتديات
enum ForumCategory {
  general('عام'),
  carReviews('تقييمات السيارات'),
  maintenance('الصيانة'),
  buying('الشراء'),
  selling('البيع'),
  modifications('التعديلات'),
  insurance('التأمين'),
  driving('القيادة');

  const ForumCategory(this.displayName);
  final String displayName;
}

/// أدوار المنتدى
enum ForumRole {
  admin('مدير'),
  moderator('مشرف'),
  member('عضو');

  const ForumRole(this.displayName);
  final String displayName;
}

/// منشور المنتدى
class ForumPost {
  final String id;
  final String forumId;
  final String authorId;
  final String title;
  final String content;
  final List<String> imageUrls;
  final List<String> tags;
  final int likesCount;
  final int repliesCount;
  final int viewsCount;
  final bool isPinned;
  final bool isLocked;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ForumPost({
    required this.id,
    required this.forumId,
    required this.authorId,
    required this.title,
    required this.content,
    required this.imageUrls,
    required this.tags,
    required this.likesCount,
    required this.repliesCount,
    required this.viewsCount,
    required this.isPinned,
    required this.isLocked,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ForumPost.fromMap(Map<String, dynamic> map) {
    return ForumPost(
      id: map['id'],
      forumId: map['forumId'],
      authorId: map['authorId'],
      title: map['title'],
      content: map['content'],
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      tags: List<String>.from(map['tags'] ?? []),
      likesCount: map['likesCount'] ?? 0,
      repliesCount: map['repliesCount'] ?? 0,
      viewsCount: map['viewsCount'] ?? 0,
      isPinned: map['isPinned'] ?? false,
      isLocked: map['isLocked'] ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'forumId': forumId,
      'authorId': authorId,
      'title': title,
      'content': content,
      'imageUrls': imageUrls,
      'tags': tags,
      'likesCount': likesCount,
      'repliesCount': repliesCount,
      'viewsCount': viewsCount,
      'isPinned': isPinned,
      'isLocked': isLocked,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

/// رد على منشور
class PostReply {
  final String id;
  final String postId;
  final String authorId;
  final String content;
  final String? parentReplyId;
  final int likesCount;
  final DateTime createdAt;

  const PostReply({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.content,
    this.parentReplyId,
    required this.likesCount,
    required this.createdAt,
  });

  factory PostReply.fromMap(Map<String, dynamic> map) {
    return PostReply(
      id: map['id'],
      postId: map['postId'],
      authorId: map['authorId'],
      content: map['content'],
      parentReplyId: map['parentReplyId'],
      likesCount: map['likesCount'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'postId': postId,
      'authorId': authorId,
      'content': content,
      'parentReplyId': parentReplyId,
      'likesCount': likesCount,
      'createdAt': createdAt,
    };
  }
}

/// مجموعة النقاش
class DiscussionGroup {
  final String id;
  final String name;
  final String description;
  final String creatorId;
  final GroupType type;
  final List<String> tags;
  final String? imageUrl;
  final int? maxMembers;
  final int membersCount;
  final int messagesCount;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DiscussionGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.creatorId,
    required this.type,
    required this.tags,
    this.imageUrl,
    this.maxMembers,
    required this.membersCount,
    required this.messagesCount,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DiscussionGroup.fromMap(Map<String, dynamic> map) {
    return DiscussionGroup(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      creatorId: map['creatorId'],
      type: GroupType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => GroupType.public,
      ),
      tags: List<String>.from(map['tags'] ?? []),
      imageUrl: map['imageUrl'],
      maxMembers: map['maxMembers'],
      membersCount: map['membersCount'] ?? 0,
      messagesCount: map['messagesCount'] ?? 0,
      isActive: map['isActive'] ?? true,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'creatorId': creatorId,
      'type': type.name,
      'tags': tags,
      'imageUrl': imageUrl,
      'maxMembers': maxMembers,
      'membersCount': membersCount,
      'messagesCount': messagesCount,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  bool get isFull => maxMembers != null && membersCount >= maxMembers!;
}

/// نوع المجموعة
enum GroupType {
  public('عامة'),
  private('خاصة'),
  secret('سرية');

  const GroupType(this.displayName);
  final String displayName;
}

/// دور المجموعة
enum GroupRole {
  admin('مدير'),
  moderator('مشرف'),
  member('عضو');

  const GroupRole(this.displayName);
  final String displayName;
}

/// تجربة المستخدم
class UserExperience {
  final String id;
  final String authorId;
  final String title;
  final String content;
  final ExperienceType type;
  final List<String> imageUrls;
  final Map<String, dynamic> metadata;
  final List<String> tags;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final int viewsCount;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserExperience({
    required this.id,
    required this.authorId,
    required this.title,
    required this.content,
    required this.type,
    required this.imageUrls,
    required this.metadata,
    required this.tags,
    required this.likesCount,
    required this.commentsCount,
    required this.sharesCount,
    required this.viewsCount,
    required this.isVerified,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserExperience.fromMap(Map<String, dynamic> map) {
    return UserExperience(
      id: map['id'],
      authorId: map['authorId'],
      title: map['title'],
      content: map['content'],
      type: ExperienceType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => ExperienceType.general,
      ),
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
      tags: List<String>.from(map['tags'] ?? []),
      likesCount: map['likesCount'] ?? 0,
      commentsCount: map['commentsCount'] ?? 0,
      sharesCount: map['sharesCount'] ?? 0,
      viewsCount: map['viewsCount'] ?? 0,
      isVerified: map['isVerified'] ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'authorId': authorId,
      'title': title,
      'content': content,
      'type': type.name,
      'imageUrls': imageUrls,
      'metadata': metadata,
      'tags': tags,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'sharesCount': sharesCount,
      'viewsCount': viewsCount,
      'isVerified': isVerified,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

/// نوع التجربة
enum ExperienceType {
  general('عام'),
  carReview('تقييم سيارة'),
  buyingExperience('تجربة شراء'),
  sellingExperience('تجربة بيع'),
  maintenanceStory('قصة صيانة'),
  accidentReport('تقرير حادث'),
  roadTrip('رحلة برية');

  const ExperienceType(this.displayName);
  final String displayName;
}

/// نتائج البحث الاجتماعي
class SocialSearchResults {
  List<Forum> forums;
  List<ForumPost> posts;
  List<DiscussionGroup> groups;
  List<UserExperience> experiences;

  SocialSearchResults({
    required this.forums,
    required this.posts,
    required this.groups,
    required this.experiences,
  });

  factory SocialSearchResults.empty() {
    return SocialSearchResults(
      forums: [],
      posts: [],
      groups: [],
      experiences: [],
    );
  }

  bool get isEmpty =>
      forums.isEmpty && posts.isEmpty && groups.isEmpty && experiences.isEmpty;

  int get totalResults =>
      forums.length + posts.length + groups.length + experiences.length;
}

/// نوع المحتوى الاجتماعي
enum SocialContentType {
  forums('المنتديات'),
  posts('المنشورات'),
  groups('المجموعات'),
  experiences('التجارب');

  const SocialContentType(this.displayName);
  final String displayName;
}

/// إحصائيات المجتمع
class CommunityStats {
  final int totalForums;
  final int totalPosts;
  final int totalGroups;
  final int totalExperiences;
  final int totalMembers;
  final DateTime lastUpdated;

  const CommunityStats({
    required this.totalForums,
    required this.totalPosts,
    required this.totalGroups,
    required this.totalExperiences,
    required this.totalMembers,
    required this.lastUpdated,
  });

  factory CommunityStats.empty() {
    return CommunityStats(
      totalForums: 0,
      totalPosts: 0,
      totalGroups: 0,
      totalExperiences: 0,
      totalMembers: 0,
      lastUpdated: DateTime.now(),
    );
  }

  factory CommunityStats.fromMap(Map<String, dynamic> map) {
    return CommunityStats(
      totalForums: map['totalForums'] ?? 0,
      totalPosts: map['totalPosts'] ?? 0,
      totalGroups: map['totalGroups'] ?? 0,
      totalExperiences: map['totalExperiences'] ?? 0,
      totalMembers: map['totalMembers'] ?? 0,
      lastUpdated: DateTime.parse(map['lastUpdated']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalForums': totalForums,
      'totalPosts': totalPosts,
      'totalGroups': totalGroups,
      'totalExperiences': totalExperiences,
      'totalMembers': totalMembers,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}
