import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tashlehekomv2/models/enhanced_chat_model.dart';

/// فقاعة الرسالة المحسنة
class EnhancedMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final VoidCallback? onReply;
  final VoidCallback? onLongPress;

  const EnhancedMessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.onReply,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe) _buildAvatar(),
            if (!isMe) const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  _buildMessageBubble(context),
                  const SizedBox(height: 2),
                  _buildMessageInfo(),
                ],
              ),
            ),
            if (isMe) const SizedBox(width: 8),
            if (isMe) _buildAvatar(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 16,
      backgroundColor: Colors.grey[300],
      backgroundImage: message.senderAvatar != null
          ? NetworkImage(message.senderAvatar!)
          : null,
      child: message.senderAvatar == null
          ? Text(
              message.senderName.isNotEmpty ? message.senderName[0].toUpperCase() : '?',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            )
          : null,
    );
  }

  Widget _buildMessageBubble(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      decoration: BoxDecoration(
        color: _getBubbleColor(),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(isMe ? 16 : 4),
          bottomRight: Radius.circular(isMe ? 4 : 16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.replyToMessageId != null) _buildReplyPreview(),
          _buildMessageContent(context),
        ],
      ),
    );
  }

  Widget _buildReplyPreview() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 20,
            color: isMe ? Colors.white : Colors.blue,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'رد على رسالة',
                  style: TextStyle(
                    fontSize: 10,
                    color: isMe ? Colors.white70 : Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'الرسالة الأصلية...',
                  style: TextStyle(
                    fontSize: 12,
                    color: isMe ? Colors.white70 : Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) _buildSenderName(),
          _buildContentByType(context),
          if (message.isEdited) _buildEditedIndicator(),
        ],
      ),
    );
  }

  Widget _buildSenderName() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        message.senderName,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildContentByType(BuildContext context) {
    switch (message.type) {
      case MessageType.text:
        return _buildTextContent();
      case MessageType.image:
        return _buildImageContent();
      case MessageType.voice:
        return _buildVoiceContent();
      case MessageType.location:
        return _buildLocationContent();
      case MessageType.contact:
        return _buildContactContent();
      case MessageType.file:
        return _buildFileContent();
      case MessageType.offer:
        return _buildOfferContent();
      case MessageType.system:
        return _buildSystemContent();
      default:
        return _buildTextContent();
    }
  }

  Widget _buildTextContent() {
    return SelectableText(
      message.content,
      style: TextStyle(
        fontSize: 14,
        color: isMe ? Colors.white : Colors.black87,
      ),
    );
  }

  Widget _buildImageContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            message.content,
            width: 200,
            height: 150,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 200,
                height: 150,
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image, size: 50),
              );
            },
          ),
        ),
        if (message.attachments?['caption'] != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              message.attachments!['caption'],
              style: TextStyle(
                fontSize: 14,
                color: isMe ? Colors.white : Colors.black87,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildVoiceContent() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.play_arrow,
          color: isMe ? Colors.white : Colors.blue,
        ),
        const SizedBox(width: 8),
        Text(
          'رسالة صوتية',
          style: TextStyle(
            fontSize: 14,
            color: isMe ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          message.attachments?['duration'] ?? '0:00',
          style: TextStyle(
            fontSize: 12,
            color: isMe ? Colors.white70 : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationContent() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.location_on,
          color: isMe ? Colors.white : Colors.red,
        ),
        const SizedBox(width: 8),
        Text(
          'موقع جغرافي',
          style: TextStyle(
            fontSize: 14,
            color: isMe ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildContactContent() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.contact_phone,
          color: isMe ? Colors.white : Colors.green,
        ),
        const SizedBox(width: 8),
        Text(
          'جهة اتصال',
          style: TextStyle(
            fontSize: 14,
            color: isMe ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildFileContent() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.attach_file,
          color: isMe ? Colors.white : Colors.orange,
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            message.attachments?['fileName'] ?? 'ملف',
            style: TextStyle(
              fontSize: 14,
              color: isMe ? Colors.white : Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildOfferContent() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_offer, color: Colors.green),
          const SizedBox(width: 8),
          Text(
            message.content,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemContent() {
    return Text(
      message.content,
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey[600],
        fontStyle: FontStyle.italic,
      ),
    );
  }

  Widget _buildEditedIndicator() {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        'تم التعديل',
        style: TextStyle(
          fontSize: 10,
          color: isMe ? Colors.white70 : Colors.grey[500],
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildMessageInfo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          DateFormat('HH:mm').format(message.timestamp),
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
        if (isMe) ...[
          const SizedBox(width: 4),
          _buildMessageStatusIcon(),
        ],
      ],
    );
  }

  Widget _buildMessageStatusIcon() {
    switch (message.status) {
      case MessageStatus.sending:
        return const SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(strokeWidth: 1),
        );
      case MessageStatus.sent:
        return Icon(Icons.check, size: 12, color: Colors.grey[600]);
      case MessageStatus.delivered:
        return Icon(Icons.done_all, size: 12, color: Colors.grey[600]);
      case MessageStatus.read:
        return const Icon(Icons.done_all, size: 12, color: Colors.blue);
      case MessageStatus.failed:
        return const Icon(Icons.error, size: 12, color: Colors.red);
      default:
        return const SizedBox.shrink();
    }
  }

  Color _getBubbleColor() {
    if (message.type == MessageType.system) {
      return Colors.grey[200]!;
    }
    return isMe ? Colors.blue[600]! : Colors.grey[200]!;
  }
}
