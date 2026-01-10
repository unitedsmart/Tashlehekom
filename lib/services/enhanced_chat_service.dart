import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tashlehekomv2/models/enhanced_chat_model.dart';
import 'package:tashlehekomv2/services/logging_service.dart';
import 'package:tashlehekomv2/services/enhanced_error_handler.dart';
import 'package:tashlehekomv2/services/performance_service.dart';
import 'package:tashlehekomv2/services/enhanced_cache_service.dart';

/// خدمة الدردشة المحسنة
class EnhancedChatService {
  static final EnhancedChatService _instance = EnhancedChatService._internal();
  factory EnhancedChatService() => _instance;
  EnhancedChatService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final EnhancedCacheService _cache = EnhancedCacheService();

  static const String _chatsCollection = 'chats';
  static const String _messagesCollection = 'messages';
  static const String _offersCollection = 'offers';

  /// إنشاء محادثة جديدة
  Future<EnhancedChat?> createChat({
    required String carId,
    required String buyerId,
    required String sellerId,
    required String buyerName,
    required String sellerName,
    required String carTitle,
    String? carImage,
    String? initialMessage,
  }) async {
    return EnhancedErrorHandler.executeWithErrorHandling(
      () async {
        return PerformanceService.measureAsync('create_chat', () async {
          // التحقق من وجود محادثة سابقة
          final existingChat =
              await _findExistingChat(carId, buyerId, sellerId);
          if (existingChat != null) {
            LoggingService.info(
                'تم العثور على محادثة موجودة: ${existingChat.id}');
            return existingChat;
          }

          final chatId = _firestore.collection(_chatsCollection).doc().id;
          final now = DateTime.now();

          final chat = EnhancedChat(
            id: chatId,
            carId: carId,
            buyerId: buyerId,
            sellerId: sellerId,
            buyerName: buyerName,
            sellerName: sellerName,
            carTitle: carTitle,
            carImage: carImage,
            messages: [],
            createdAt: now,
            lastMessageAt: now,
            status: ChatStatus.active,
            isReadByBuyer: true,
            isReadBySeller: false,
          );

          // حفظ المحادثة في Firestore
          await _firestore
              .collection(_chatsCollection)
              .doc(chatId)
              .set(chat.toMap());

          // إرسال رسالة ترحيبية إذا تم تحديدها
          if (initialMessage != null && initialMessage.isNotEmpty) {
            await sendMessage(
              chatId: chatId,
              senderId: buyerId,
              senderName: buyerName,
              content: initialMessage,
              type: MessageType.text,
            );
          }

          LoggingService.success('تم إنشاء محادثة جديدة: $chatId');
          return chat;
        });
      },
      'إنشاء محادثة جديدة',
    );
  }

  /// إرسال رسالة
  Future<ChatMessage?> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String content,
    required MessageType type,
    String? senderAvatar,
    Map<String, dynamic>? attachments,
    String? replyToMessageId,
  }) async {
    return EnhancedErrorHandler.executeWithErrorHandling(
      () async {
        return PerformanceService.measureAsync('send_message', () async {
          final messageId = _firestore.collection(_messagesCollection).doc().id;
          final now = DateTime.now();

          final message = ChatMessage(
            id: messageId,
            senderId: senderId,
            senderName: senderName,
            senderAvatar: senderAvatar,
            type: type,
            content: content,
            attachments: attachments,
            timestamp: now,
            status: MessageStatus.sent,
            replyToMessageId: replyToMessageId,
          );

          // حفظ الرسالة
          await _firestore
              .collection(_chatsCollection)
              .doc(chatId)
              .collection(_messagesCollection)
              .doc(messageId)
              .set(message.toMap());

          // تحديث آخر رسالة في المحادثة
          await _updateLastMessage(chatId, message);

          LoggingService.success('تم إرسال رسالة: $messageId');
          return message;
        });
      },
      'إرسال رسالة',
    );
  }

  /// رفع ملف مرفق
  Future<String?> uploadAttachment(
      String chatId, File file, String fileName) async {
    return EnhancedErrorHandler.executeWithErrorHandling(
      () async {
        return PerformanceService.measureAsync('upload_attachment', () async {
          final ref =
              _storage.ref().child('chat_attachments/$chatId/$fileName');
          final uploadTask = ref.putFile(file);
          final snapshot = await uploadTask;
          final downloadUrl = await snapshot.ref.getDownloadURL();

          LoggingService.success('تم رفع المرفق: $fileName');
          return downloadUrl;
        });
      },
      'رفع مرفق',
    );
  }

  /// الحصول على المحادثات للمستخدم
  Stream<List<EnhancedChat>> getUserChats(String userId) {
    return _firestore
        .collection(_chatsCollection)
        .where(Filter.or(
          Filter('buyerId', isEqualTo: userId),
          Filter('sellerId', isEqualTo: userId),
        ))
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) {
            try {
              return EnhancedChat.fromMap({...doc.data(), 'id': doc.id});
            } catch (e) {
              LoggingService.error('خطأ في تحويل بيانات المحادثة', error: e);
              return null;
            }
          })
          .where((chat) => chat != null)
          .cast<EnhancedChat>()
          .toList();
    });
  }

  /// الحصول على رسائل المحادثة
  Stream<List<ChatMessage>> getChatMessages(String chatId) {
    return _firestore
        .collection(_chatsCollection)
        .doc(chatId)
        .collection(_messagesCollection)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) {
            try {
              return ChatMessage.fromMap({...doc.data(), 'id': doc.id});
            } catch (e) {
              LoggingService.error('خطأ في تحويل بيانات الرسالة', error: e);
              return null;
            }
          })
          .where((message) => message != null)
          .cast<ChatMessage>()
          .toList();
    });
  }

  /// تحديد الرسائل كمقروءة
  Future<void> markMessagesAsRead(String chatId, String userId) async {
    return EnhancedErrorHandler.executeWithErrorHandling(
      () async {
        return PerformanceService.measureAsync('mark_messages_read', () async {
          final chatRef = _firestore.collection(_chatsCollection).doc(chatId);
          final chatDoc = await chatRef.get();

          if (!chatDoc.exists) return;

          final chat =
              EnhancedChat.fromMap({...chatDoc.data()!, 'id': chatDoc.id});

          Map<String, dynamic> updates = {};
          if (chat.buyerId == userId) {
            updates['isReadByBuyer'] = true;
          } else if (chat.sellerId == userId) {
            updates['isReadBySeller'] = true;
          }

          if (updates.isNotEmpty) {
            await chatRef.update(updates);
            LoggingService.info('تم تحديد الرسائل كمقروءة للمستخدم: $userId');
          }
        });
      },
      'تحديد الرسائل كمقروءة',
    );
  }

  /// إرسال عرض سعر
  Future<PriceOffer?> sendPriceOffer({
    required String chatId,
    required String senderId,
    required double originalPrice,
    required double offeredPrice,
    String? message,
  }) async {
    return EnhancedErrorHandler.executeWithErrorHandling(
      () async {
        return PerformanceService.measureAsync('send_price_offer', () async {
          final offerId = _firestore.collection(_offersCollection).doc().id;
          final now = DateTime.now();

          final offer = PriceOffer(
            id: offerId,
            chatId: chatId,
            senderId: senderId,
            originalPrice: originalPrice,
            offeredPrice: offeredPrice,
            message: message,
            createdAt: now,
            status: OfferStatus.pending,
          );

          // حفظ العرض
          await _firestore
              .collection(_offersCollection)
              .doc(offerId)
              .set(offer.toMap());

          // إرسال رسالة نظام بالعرض
          await sendMessage(
            chatId: chatId,
            senderId: senderId,
            senderName: 'النظام',
            content:
                'تم إرسال عرض سعر: ${offeredPrice.toStringAsFixed(0)} ريال',
            type: MessageType.offer,
            attachments: {'offerId': offerId},
          );

          LoggingService.success('تم إرسال عرض سعر: $offerId');
          return offer;
        });
      },
      'إرسال عرض سعر',
    );
  }

  /// البحث عن محادثة موجودة
  Future<EnhancedChat?> _findExistingChat(
      String carId, String buyerId, String sellerId) async {
    final query = await _firestore
        .collection(_chatsCollection)
        .where('carId', isEqualTo: carId)
        .where('buyerId', isEqualTo: buyerId)
        .where('sellerId', isEqualTo: sellerId)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      final doc = query.docs.first;
      return EnhancedChat.fromMap({...doc.data(), 'id': doc.id});
    }

    return null;
  }

  /// تحديث آخر رسالة في المحادثة
  Future<void> _updateLastMessage(String chatId, ChatMessage message) async {
    await _firestore.collection(_chatsCollection).doc(chatId).update({
      'lastMessageAt': message.timestamp.millisecondsSinceEpoch,
      'lastMessage': message.content,
      'lastMessageType': message.type.name,
      'lastMessageSender': message.senderId,
    });
  }

  /// حذف محادثة
  Future<void> deleteChat(String chatId) async {
    return EnhancedErrorHandler.executeWithErrorHandling(
      () async {
        return PerformanceService.measureAsync('delete_chat', () async {
          // حذف جميع الرسائل
          final messagesQuery = await _firestore
              .collection(_chatsCollection)
              .doc(chatId)
              .collection(_messagesCollection)
              .get();

          final batch = _firestore.batch();
          for (final doc in messagesQuery.docs) {
            batch.delete(doc.reference);
          }

          // حذف المحادثة
          batch.delete(_firestore.collection(_chatsCollection).doc(chatId));

          await batch.commit();
          LoggingService.success('تم حذف المحادثة: $chatId');
        });
      },
      'حذف محادثة',
    );
  }
}
