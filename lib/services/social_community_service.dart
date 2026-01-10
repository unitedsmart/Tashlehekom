import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tashlehekomv2/services/logging_service.dart';
import 'package:tashlehekomv2/services/enhanced_error_handler.dart';
import 'package:tashlehekomv2/services/performance_service.dart';
import 'package:tashlehekomv2/services/enhanced_cache_service.dart';
import 'package:tashlehekomv2/models/social_community_models.dart';

/// خدمة المجتمع الاجتماعي
class SocialCommunityService {
  static final SocialCommunityService _instance =
      SocialCommunityService._internal();
  factory SocialCommunityService() => _instance;
  SocialCommunityService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final EnhancedCacheService _cache = EnhancedCacheService();

  /// إنشاء منتدى جديد
  Future<String?> createForum({
    required String title,
    required String description,
    required String creatorId,
    required ForumCategory category,
    List<String>? tags,
    String? imageUrl,
  }) async {
    return EnhancedErrorHandler.executeWithErrorHandling(
      () async {
        return PerformanceService.measureAsync('create_forum', () async {
          final forumData = {
            'title': title,
            'description': description,
            'creatorId': creatorId,
            'category': category.name,
            'tags': tags ?? [],
            'imageUrl': imageUrl,
            'membersCount': 1,
            'postsCount': 0,
            'isActive': true,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          };

          final docRef = await _firestore.collection('forums').add(forumData);

          // إضافة المنشئ كعضو
          await _firestore.collection('forum_members').add({
            'forumId': docRef.id,
            'userId': creatorId,
            'role': ForumRole.admin.name,
            'joinedAt': FieldValue.serverTimestamp(),
          });

          LoggingService.success('تم إنشاء منتدى جديد: $title');
          return docRef.id;
        });
      },
      'إنشاء منتدى',
    );
  }

  /// الحصول على قائمة المنتديات
  Future<List<Forum>> getForums({
    ForumCategory? category,
    int limit = 20,
    String? lastDocumentId,
  }) async {
    final result =
        await EnhancedErrorHandler.executeWithErrorHandling<List<Forum>>(
      () async {
        return PerformanceService.measureAsync('get_forums', () async {
          final cacheKey = 'forums_${category?.name ?? 'all'}_$limit';

          // التحقق من التخزين المؤقت
          if (lastDocumentId == null) {
            final cachedForums = await _cache.get<List<dynamic>>(cacheKey);
            if (cachedForums != null) {
              return cachedForums.map((item) => Forum.fromMap(item)).toList();
            }
          }

          // بناء الاستعلام
          Query query = _firestore
              .collection('forums')
              .where('isActive', isEqualTo: true)
              .orderBy('updatedAt', descending: true);

          if (category != null) {
            query = query.where('category', isEqualTo: category.name);
          }

          if (lastDocumentId != null) {
            final lastDoc =
                await _firestore.collection('forums').doc(lastDocumentId).get();
            query = query.startAfterDocument(lastDoc);
          }

          final snapshot = await query.limit(limit).get();

          final forums = snapshot.docs.map((doc) {
            return Forum.fromMap(
                {...doc.data() as Map<String, dynamic>, 'id': doc.id});
          }).toList();

          // حفظ في التخزين المؤقت إذا كانت الصفحة الأولى
          if (lastDocumentId == null) {
            await _cache.set(
              cacheKey,
              forums.map((forum) => forum.toMap()).toList(),
              expiration: const Duration(minutes: 10),
            );
          }

          return forums;
        });
      },
      'جلب المنتديات',
    );
    return result ?? [];
  }

  /// الانضمام إلى منتدى
  Future<bool> joinForum(String forumId, String userId) async {
    final result = await EnhancedErrorHandler.executeWithErrorHandling<bool>(
      () async {
        return PerformanceService.measureAsync('join_forum', () async {
          // التحقق من عدم الانضمام مسبقاً
          final existingMember = await _firestore
              .collection('forum_members')
              .where('forumId', isEqualTo: forumId)
              .where('userId', isEqualTo: userId)
              .get();

          if (existingMember.docs.isNotEmpty) {
            LoggingService.warning(
                'المستخدم $userId عضو بالفعل في المنتدى $forumId');
            return false;
          }

          // إضافة العضوية
          await _firestore.collection('forum_members').add({
            'forumId': forumId,
            'userId': userId,
            'role': ForumRole.member.name,
            'joinedAt': FieldValue.serverTimestamp(),
          });

          // تحديث عدد الأعضاء
          await _firestore.collection('forums').doc(forumId).update({
            'membersCount': FieldValue.increment(1),
          });

          // إزالة من التخزين المؤقت
          await _cache.removePattern('forums_');

          LoggingService.success('انضم المستخدم $userId إلى المنتدى $forumId');
          return true;
        });
      },
      'الانضمام إلى منتدى',
    );
    return result ?? false;
  }

  /// إنشاء منشور في منتدى
  Future<String?> createForumPost({
    required String forumId,
    required String authorId,
    required String title,
    required String content,
    List<String>? imageUrls,
    List<String>? tags,
  }) async {
    return EnhancedErrorHandler.executeWithErrorHandling(
      () async {
        return PerformanceService.measureAsync('create_forum_post', () async {
          final postData = {
            'forumId': forumId,
            'authorId': authorId,
            'title': title,
            'content': content,
            'imageUrls': imageUrls ?? [],
            'tags': tags ?? [],
            'likesCount': 0,
            'repliesCount': 0,
            'viewsCount': 0,
            'isPinned': false,
            'isLocked': false,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          };

          final docRef =
              await _firestore.collection('forum_posts').add(postData);

          // تحديث عدد المنشورات في المنتدى
          await _firestore.collection('forums').doc(forumId).update({
            'postsCount': FieldValue.increment(1),
            'updatedAt': FieldValue.serverTimestamp(),
          });

          LoggingService.success('تم إنشاء منشور جديد في المنتدى $forumId');
          return docRef.id;
        });
      },
      'إنشاء منشور',
    );
  }

  /// الحصول على منشورات المنتدى
  Future<List<ForumPost>> getForumPosts({
    required String forumId,
    int limit = 20,
    String? lastDocumentId,
  }) async {
    final result =
        await EnhancedErrorHandler.executeWithErrorHandling<List<ForumPost>>(
      () async {
        return PerformanceService.measureAsync('get_forum_posts', () async {
          Query query = _firestore
              .collection('forum_posts')
              .where('forumId', isEqualTo: forumId)
              .orderBy('isPinned', descending: true)
              .orderBy('createdAt', descending: true);

          if (lastDocumentId != null) {
            final lastDoc = await _firestore
                .collection('forum_posts')
                .doc(lastDocumentId)
                .get();
            query = query.startAfterDocument(lastDoc);
          }

          final snapshot = await query.limit(limit).get();

          return snapshot.docs.map((doc) {
            return ForumPost.fromMap(
                {...doc.data() as Map<String, dynamic>, 'id': doc.id});
          }).toList();
        });
      },
      'جلب منشورات المنتدى',
    );
    return result ?? [];
  }

  /// إضافة رد على منشور
  Future<String?> addPostReply({
    required String postId,
    required String authorId,
    required String content,
    String? parentReplyId,
  }) async {
    return EnhancedErrorHandler.executeWithErrorHandling(
      () async {
        return PerformanceService.measureAsync('add_post_reply', () async {
          final replyData = {
            'postId': postId,
            'authorId': authorId,
            'content': content,
            'parentReplyId': parentReplyId,
            'likesCount': 0,
            'createdAt': FieldValue.serverTimestamp(),
          };

          final docRef =
              await _firestore.collection('post_replies').add(replyData);

          // تحديث عدد الردود
          await _firestore.collection('forum_posts').doc(postId).update({
            'repliesCount': FieldValue.increment(1),
            'updatedAt': FieldValue.serverTimestamp(),
          });

          LoggingService.success('تم إضافة رد على المنشور $postId');
          return docRef.id;
        });
      },
      'إضافة رد',
    );
  }

  /// إعجاب بمنشور
  Future<bool> likePost(String postId, String userId) async {
    final result = await EnhancedErrorHandler.executeWithErrorHandling<bool>(
      () async {
        return PerformanceService.measureAsync('like_post', () async {
          final likeId = '${postId}_$userId';

          // التحقق من وجود الإعجاب
          final existingLike =
              await _firestore.collection('post_likes').doc(likeId).get();

          if (existingLike.exists) {
            // إلغاء الإعجاب
            await _firestore.collection('post_likes').doc(likeId).delete();
            await _firestore.collection('forum_posts').doc(postId).update({
              'likesCount': FieldValue.increment(-1),
            });
            return false;
          } else {
            // إضافة الإعجاب
            await _firestore.collection('post_likes').doc(likeId).set({
              'postId': postId,
              'userId': userId,
              'createdAt': FieldValue.serverTimestamp(),
            });
            await _firestore.collection('forum_posts').doc(postId).update({
              'likesCount': FieldValue.increment(1),
            });
            return true;
          }
        });
      },
      'إعجاب بمنشور',
    );
    return result ?? false;
  }

  /// إنشاء مجموعة نقاش
  Future<String?> createDiscussionGroup({
    required String name,
    required String description,
    required String creatorId,
    required GroupType type,
    List<String>? tags,
    String? imageUrl,
    int? maxMembers,
  }) async {
    return EnhancedErrorHandler.executeWithErrorHandling(
      () async {
        return PerformanceService.measureAsync('create_discussion_group',
            () async {
          final groupData = {
            'name': name,
            'description': description,
            'creatorId': creatorId,
            'type': type.name,
            'tags': tags ?? [],
            'imageUrl': imageUrl,
            'maxMembers': maxMembers,
            'membersCount': 1,
            'messagesCount': 0,
            'isActive': true,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          };

          final docRef =
              await _firestore.collection('discussion_groups').add(groupData);

          // إضافة المنشئ كعضو
          await _firestore.collection('group_members').add({
            'groupId': docRef.id,
            'userId': creatorId,
            'role': GroupRole.admin.name,
            'joinedAt': FieldValue.serverTimestamp(),
          });

          LoggingService.success('تم إنشاء مجموعة نقاش جديدة: $name');
          return docRef.id;
        });
      },
      'إنشاء مجموعة نقاش',
    );
  }

  /// الحصول على مجموعات النقاش
  Future<List<DiscussionGroup>> getDiscussionGroups({
    GroupType? type,
    int limit = 20,
  }) async {
    final result = await EnhancedErrorHandler.executeWithErrorHandling<
        List<DiscussionGroup>>(
      () async {
        return PerformanceService.measureAsync('get_discussion_groups',
            () async {
          final cacheKey = 'discussion_groups_${type?.name ?? 'all'}_$limit';

          // التحقق من التخزين المؤقت
          final cachedGroups = await _cache.get<List<dynamic>>(cacheKey);
          if (cachedGroups != null) {
            return cachedGroups
                .map((item) => DiscussionGroup.fromMap(item))
                .toList();
          }

          // بناء الاستعلام
          Query query = _firestore
              .collection('discussion_groups')
              .where('isActive', isEqualTo: true)
              .orderBy('updatedAt', descending: true);

          if (type != null) {
            query = query.where('type', isEqualTo: type.name);
          }

          final snapshot = await query.limit(limit).get();

          final groups = snapshot.docs.map((doc) {
            return DiscussionGroup.fromMap(
                {...doc.data() as Map<String, dynamic>, 'id': doc.id});
          }).toList();

          // حفظ في التخزين المؤقت
          await _cache.set(
            cacheKey,
            groups.map((group) => group.toMap()).toList(),
            expiration: const Duration(minutes: 10),
          );

          return groups;
        });
      },
      'جلب مجموعات النقاش',
    );
    return result ?? [];
  }

  /// مشاركة تجربة
  Future<String?> shareExperience({
    required String authorId,
    required String title,
    required String content,
    required ExperienceType type,
    List<String>? imageUrls,
    Map<String, dynamic>? metadata,
    List<String>? tags,
  }) async {
    return EnhancedErrorHandler.executeWithErrorHandling(
      () async {
        return PerformanceService.measureAsync('share_experience', () async {
          final experienceData = {
            'authorId': authorId,
            'title': title,
            'content': content,
            'type': type.name,
            'imageUrls': imageUrls ?? [],
            'metadata': metadata ?? {},
            'tags': tags ?? [],
            'likesCount': 0,
            'commentsCount': 0,
            'sharesCount': 0,
            'viewsCount': 0,
            'isVerified': false,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          };

          final docRef = await _firestore
              .collection('user_experiences')
              .add(experienceData);

          LoggingService.success('تم مشاركة تجربة جديدة: $title');
          return docRef.id;
        });
      },
      'مشاركة تجربة',
    );
  }

  /// الحصول على التجارب المشاركة
  Future<List<UserExperience>> getUserExperiences({
    ExperienceType? type,
    String? authorId,
    int limit = 20,
  }) async {
    final result = await EnhancedErrorHandler.executeWithErrorHandling<
        List<UserExperience>>(
      () async {
        return PerformanceService.measureAsync('get_user_experiences',
            () async {
          Query query = _firestore
              .collection('user_experiences')
              .orderBy('createdAt', descending: true);

          if (type != null) {
            query = query.where('type', isEqualTo: type.name);
          }

          if (authorId != null) {
            query = query.where('authorId', isEqualTo: authorId);
          }

          final snapshot = await query.limit(limit).get();

          return snapshot.docs.map((doc) {
            return UserExperience.fromMap(
                {...doc.data() as Map<String, dynamic>, 'id': doc.id});
          }).toList();
        });
      },
      'جلب التجارب المشاركة',
    );
    return result ?? [];
  }

  /// البحث في المحتوى الاجتماعي
  Future<SocialSearchResults> searchSocialContent({
    required String query,
    List<SocialContentType>? contentTypes,
    int limit = 20,
  }) async {
    final result = await EnhancedErrorHandler.executeWithErrorHandling<
        SocialSearchResults>(
      () async {
        return PerformanceService.measureAsync('search_social_content',
            () async {
          final results = SocialSearchResults(
            forums: [],
            posts: [],
            groups: [],
            experiences: [],
          );

          final searchTypes = contentTypes ?? SocialContentType.values;

          // البحث في المنتديات
          if (searchTypes.contains(SocialContentType.forums)) {
            final forumsSnapshot = await _firestore
                .collection('forums')
                .where('title', isGreaterThanOrEqualTo: query)
                .where('title', isLessThan: query + 'z')
                .limit(limit ~/ searchTypes.length)
                .get();

            results.forums = forumsSnapshot.docs.map((doc) {
              return Forum.fromMap({...doc.data(), 'id': doc.id});
            }).toList();
          }

          // البحث في المنشورات
          if (searchTypes.contains(SocialContentType.posts)) {
            final postsSnapshot = await _firestore
                .collection('forum_posts')
                .where('title', isGreaterThanOrEqualTo: query)
                .where('title', isLessThan: query + 'z')
                .limit(limit ~/ searchTypes.length)
                .get();

            results.posts = postsSnapshot.docs.map((doc) {
              return ForumPost.fromMap({...doc.data(), 'id': doc.id});
            }).toList();
          }

          // البحث في المجموعات
          if (searchTypes.contains(SocialContentType.groups)) {
            final groupsSnapshot = await _firestore
                .collection('discussion_groups')
                .where('name', isGreaterThanOrEqualTo: query)
                .where('name', isLessThan: query + 'z')
                .limit(limit ~/ searchTypes.length)
                .get();

            results.groups = groupsSnapshot.docs.map((doc) {
              return DiscussionGroup.fromMap({...doc.data(), 'id': doc.id});
            }).toList();
          }

          // البحث في التجارب
          if (searchTypes.contains(SocialContentType.experiences)) {
            final experiencesSnapshot = await _firestore
                .collection('user_experiences')
                .where('title', isGreaterThanOrEqualTo: query)
                .where('title', isLessThan: query + 'z')
                .limit(limit ~/ searchTypes.length)
                .get();

            results.experiences = experiencesSnapshot.docs.map((doc) {
              return UserExperience.fromMap({...doc.data(), 'id': doc.id});
            }).toList();
          }

          return results;
        });
      },
      'البحث في المحتوى الاجتماعي',
    );
    return result ?? SocialSearchResults.empty();
  }

  /// الحصول على إحصائيات المجتمع
  Future<CommunityStats> getCommunityStats() async {
    final result =
        await EnhancedErrorHandler.executeWithErrorHandling<CommunityStats>(
      () async {
        return PerformanceService.measureAsync('get_community_stats', () async {
          const cacheKey = 'community_stats';

          // التحقق من التخزين المؤقت
          final cachedStats = await _cache.get<Map<String, dynamic>>(cacheKey);
          if (cachedStats != null) {
            return CommunityStats.fromMap(cachedStats);
          }

          // جمع الإحصائيات
          final futures = await Future.wait([
            _firestore.collection('forums').count().get(),
            _firestore.collection('forum_posts').count().get(),
            _firestore.collection('discussion_groups').count().get(),
            _firestore.collection('user_experiences').count().get(),
            _firestore.collection('forum_members').count().get(),
          ]);

          final stats = CommunityStats(
            totalForums: futures[0].count ?? 0,
            totalPosts: futures[1].count ?? 0,
            totalGroups: futures[2].count ?? 0,
            totalExperiences: futures[3].count ?? 0,
            totalMembers: futures[4].count ?? 0,
            lastUpdated: DateTime.now(),
          );

          // حفظ في التخزين المؤقت
          await _cache.set(
            cacheKey,
            stats.toMap(),
            expiration: const Duration(hours: 1),
          );

          return stats;
        });
      },
      'جلب إحصائيات المجتمع',
    );
    return result ?? CommunityStats.empty();
  }
}
