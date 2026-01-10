import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tashlehekomv2/models/enhanced_chat_model.dart';
import 'package:tashlehekomv2/services/enhanced_chat_service.dart';
import 'package:tashlehekomv2/providers/firebase_auth_provider.dart';
import 'package:tashlehekomv2/widgets/enhanced_message_bubble.dart';
import 'package:tashlehekomv2/widgets/chat_input_widget.dart';

/// شاشة الدردشة المحسنة
class EnhancedChatScreen extends StatefulWidget {
  final String chatId;
  final String otherUserName;
  final String carTitle;

  const EnhancedChatScreen({
    super.key,
    required this.chatId,
    required this.otherUserName,
    required this.carTitle,
  });

  @override
  State<EnhancedChatScreen> createState() => _EnhancedChatScreenState();
}

class _EnhancedChatScreenState extends State<EnhancedChatScreen> {
  final EnhancedChatService _chatService = EnhancedChatService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  
  bool _isLoading = false;
  ChatMessage? _replyToMessage;

  @override
  void initState() {
    super.initState();
    _markMessagesAsRead();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _markMessagesAsRead() {
    final userId = context.read<FirebaseAuthProvider>().currentUser?.id;
    if (userId != null) {
      _chatService.markMessagesAsRead(widget.chatId, userId);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage(String content, MessageType type) async {
    if (content.trim().isEmpty) return;

    final authProvider = context.read<FirebaseAuthProvider>();
    final currentUser = authProvider.currentUser;
    
    if (currentUser == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _chatService.sendMessage(
        chatId: widget.chatId,
        senderId: currentUser.id,
        senderName: currentUser.name,
        content: content.trim(),
        type: type,
        replyToMessageId: _replyToMessage?.id,
      );

      _messageController.clear();
      _replyToMessage = null;
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في إرسال الرسالة: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _setReplyMessage(ChatMessage message) {
    setState(() {
      _replyToMessage = message;
    });
  }

  void _cancelReply() {
    setState(() {
      _replyToMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.otherUserName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.carTitle,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: () {
              // TODO: إضافة وظيفة الاتصال
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _showChatOptions();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // منطقة الرسائل
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: _chatService.getChatMessages(widget.chatId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('خطأ في تحميل الرسائل: ${snapshot.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {});
                          },
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  );
                }

                final messages = snapshot.data ?? [];

                if (messages.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'لا توجد رسائل بعد\nابدأ المحادثة!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final currentUserId = context.read<FirebaseAuthProvider>().currentUser?.id;
                    final isMe = message.senderId == currentUserId;

                    return EnhancedMessageBubble(
                      message: message,
                      isMe: isMe,
                      onReply: () => _setReplyMessage(message),
                      onLongPress: () => _showMessageOptions(message),
                    );
                  },
                );
              },
            ),
          ),

          // منطقة الرد
          if (_replyToMessage != null)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.grey[100],
              child: Row(
                children: [
                  const Icon(Icons.reply, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'الرد على ${_replyToMessage!.senderName}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.blue,
                          ),
                        ),
                        Text(
                          _replyToMessage!.content,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: _cancelReply,
                  ),
                ],
              ),
            ),

          // منطقة إدخال الرسالة
          ChatInputWidget(
            controller: _messageController,
            isLoading: _isLoading,
            onSendMessage: (content) => _sendMessage(content, MessageType.text),
            onSendImage: () {
              // TODO: إضافة وظيفة إرسال الصور
            },
            onSendVoice: () {
              // TODO: إضافة وظيفة إرسال الصوت
            },
            onSendLocation: () {
              // TODO: إضافة وظيفة إرسال الموقع
            },
          ),
        ],
      ),
    );
  }

  void _showChatOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.archive),
            title: const Text('أرشفة المحادثة'),
            onTap: () {
              Navigator.pop(context);
              // TODO: أرشفة المحادثة
            },
          ),
          ListTile(
            leading: const Icon(Icons.block),
            title: const Text('حظر المستخدم'),
            onTap: () {
              Navigator.pop(context);
              // TODO: حظر المستخدم
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('حذف المحادثة', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _confirmDeleteChat();
            },
          ),
        ],
      ),
    );
  }

  void _showMessageOptions(ChatMessage message) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.reply),
            title: const Text('رد'),
            onTap: () {
              Navigator.pop(context);
              _setReplyMessage(message);
            },
          ),
          ListTile(
            leading: const Icon(Icons.copy),
            title: const Text('نسخ'),
            onTap: () {
              Navigator.pop(context);
              // TODO: نسخ النص
            },
          ),
          if (message.senderId == context.read<FirebaseAuthProvider>().currentUser?.id)
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('حذف', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                // TODO: حذف الرسالة
              },
            ),
        ],
      ),
    );
  }

  void _confirmDeleteChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المحادثة'),
        content: const Text('هل أنت متأكد من حذف هذه المحادثة؟ لا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _chatService.deleteChat(widget.chatId);
                if (mounted) {
                  Navigator.pop(context);
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('خطأ في حذف المحادثة: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
