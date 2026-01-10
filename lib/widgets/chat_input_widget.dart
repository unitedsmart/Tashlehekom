import 'package:flutter/material.dart';

/// ويدجت إدخال رسائل الدردشة
class ChatInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final bool isLoading;
  final Function(String) onSendMessage;
  final VoidCallback? onSendImage;
  final VoidCallback? onSendVoice;
  final VoidCallback? onSendLocation;
  final VoidCallback? onSendFile;

  const ChatInputWidget({
    super.key,
    required this.controller,
    required this.isLoading,
    required this.onSendMessage,
    this.onSendImage,
    this.onSendVoice,
    this.onSendLocation,
    this.onSendFile,
  });

  @override
  State<ChatInputWidget> createState() => _ChatInputWidgetState();
}

class _ChatInputWidgetState extends State<ChatInputWidget> {
  bool _showAttachmentOptions = false;
  bool _isRecording = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          if (_showAttachmentOptions) _buildAttachmentOptions(),
          Row(
            children: [
              // زر المرفقات
              IconButton(
                icon: Icon(
                  _showAttachmentOptions ? Icons.close : Icons.attach_file,
                  color: Colors.blue,
                ),
                onPressed: () {
                  setState(() {
                    _showAttachmentOptions = !_showAttachmentOptions;
                  });
                },
              ),
              
              // حقل النص
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextField(
                    controller: widget.controller,
                    maxLines: null,
                    textInputAction: TextInputAction.newline,
                    decoration: const InputDecoration(
                      hintText: 'اكتب رسالة...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    onChanged: (text) {
                      setState(() {});
                    },
                  ),
                ),
              ),
              
              const SizedBox(width: 8),
              
              // زر الإرسال أو التسجيل الصوتي
              _buildSendButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentOptions() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildAttachmentOption(
            icon: Icons.photo_camera,
            label: 'كاميرا',
            color: Colors.green,
            onTap: widget.onSendImage,
          ),
          _buildAttachmentOption(
            icon: Icons.photo_library,
            label: 'معرض',
            color: Colors.blue,
            onTap: widget.onSendImage,
          ),
          _buildAttachmentOption(
            icon: Icons.location_on,
            label: 'موقع',
            color: Colors.red,
            onTap: widget.onSendLocation,
          ),
          _buildAttachmentOption(
            icon: Icons.attach_file,
            label: 'ملف',
            color: Colors.orange,
            onTap: widget.onSendFile,
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showAttachmentOptions = false;
        });
        onTap?.call();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSendButton() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    
    if (widget.isLoading) {
      return Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          ),
        ),
      );
    }

    if (hasText) {
      return GestureDetector(
        onTap: () {
          final text = widget.controller.text.trim();
          if (text.isNotEmpty) {
            widget.onSendMessage(text);
          }
        },
        child: Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.send,
            color: Colors.white,
            size: 20,
          ),
        ),
      );
    }

    // زر التسجيل الصوتي
    return GestureDetector(
      onLongPressStart: (_) {
        setState(() {
          _isRecording = true;
        });
        _startVoiceRecording();
      },
      onLongPressEnd: (_) {
        setState(() {
          _isRecording = false;
        });
        _stopVoiceRecording();
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _isRecording ? Colors.red : Colors.blue,
          shape: BoxShape.circle,
        ),
        child: Icon(
          _isRecording ? Icons.stop : Icons.mic,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  void _startVoiceRecording() {
    // TODO: بدء تسجيل الصوت
    widget.onSendVoice?.call();
  }

  void _stopVoiceRecording() {
    // TODO: إيقاف تسجيل الصوت وإرساله
  }
}

/// ويدجت خيارات الرسالة
class MessageOptionsWidget extends StatelessWidget {
  final VoidCallback? onReply;
  final VoidCallback? onCopy;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool canEdit;
  final bool canDelete;

  const MessageOptionsWidget({
    super.key,
    this.onReply,
    this.onCopy,
    this.onEdit,
    this.onDelete,
    this.canEdit = false,
    this.canDelete = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onReply != null)
            ListTile(
              leading: const Icon(Icons.reply),
              title: const Text('رد'),
              onTap: () {
                Navigator.pop(context);
                onReply?.call();
              },
            ),
          if (onCopy != null)
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('نسخ'),
              onTap: () {
                Navigator.pop(context);
                onCopy?.call();
              },
            ),
          if (canEdit && onEdit != null)
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('تعديل'),
              onTap: () {
                Navigator.pop(context);
                onEdit?.call();
              },
            ),
          if (canDelete && onDelete != null)
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('حذف', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                onDelete?.call();
              },
            ),
        ],
      ),
    );
  }
}

/// ويدجت معاينة الرد
class ReplyPreviewWidget extends StatelessWidget {
  final String senderName;
  final String messageContent;
  final VoidCallback onCancel;

  const ReplyPreviewWidget({
    super.key,
    required this.senderName,
    required this.messageContent,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.grey[100],
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            color: Colors.blue,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الرد على $senderName',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  messageContent,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: onCancel,
          ),
        ],
      ),
    );
  }
}
