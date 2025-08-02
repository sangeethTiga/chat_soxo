class ChatMessage {
  final String id;
  final String content;
  final ChatMessageType type;
  final bool isSent;
  final DateTime timestamp;
  final String? senderName;
  final Duration? audioDuration;

  ChatMessage({
    required this.id,
    required this.content,
    required this.type,
    required this.isSent,
    required this.timestamp,
    this.senderName,
    this.audioDuration,
  });
}

enum ChatMessageType { text, voice, image, document }
