// Preprocessing function for Entry JSON (PascalCase -> camelCase)
import 'dart:developer';

import 'package:soxo_chat/feature/chat/domain/models/chat_entry/chat_entry_response.dart';

Map<String, dynamic> preprocessEntryJson(Map<String, dynamic> json) {
  final processed = <String, dynamic>{};

  // Entry field mappings
  final keyMappings = {
    'Id': 'id',
    'Type': 'type',
    'TypeValue': 'typeValue',
    'ChatId': 'chatId',
    'SenderId': 'senderId',
    'MessageType': 'messageType',
    'Thread': 'thread',
    'Content': 'content',
    'MediaIds': 'mediaIds',
    'CreatedAt': 'createdAt',
    'Pinned': 'pinned',
    'UserStatus': 'userStatus',
    'Direction': 'direction',
    'Sender': 'sender',
    'ChatMedias': 'chatMedias',
    'UserChats': 'userChats',
  };

  // Copy existing camelCase keys first
  json.forEach((key, value) {
    if (keyMappings.containsValue(key)) {
      processed[key] = value;
    }
  });

  // Map PascalCase to camelCase if camelCase doesn't exist
  keyMappings.forEach((pascalKey, camelKey) {
    if (json.containsKey(pascalKey) && !processed.containsKey(camelKey)) {
      processed[camelKey] = json[pascalKey];
    }
  });

  return processed;
}

// Preprocessing function for ChatMedias JSON
Map<String, dynamic> _preprocessChatMediasJson(Map<String, dynamic> json) {
  final processed = <String, dynamic>{};

  // ChatMedias field mappings
  final keyMappings = {
    'Id': 'id',
    'ChatId': 'chatId',
    'MediaType': 'mediaType',
    'MediaUrl': 'mediaUrl',
    'MediaSize': 'mediaSize',
    'FileName': 'fileName',
    'EncryptionKey': 'encryptionKey',
    'EncryptionLevel': 'encryptionLevel',
    'Encryption': 'encryption',
    'Status': 'status',
    'BranchPtr': 'branchPtr',
    'FirmPtr': 'firmPtr',
    'UploadedAt': 'uploadedAt',
  };

  // Copy existing camelCase keys first
  json.forEach((key, value) {
    if (keyMappings.containsValue(key)) {
      processed[key] = value;
    }
  });

  // Map PascalCase to camelCase if camelCase doesn't exist
  keyMappings.forEach((pascalKey, camelKey) {
    if (json.containsKey(pascalKey) && !processed.containsKey(camelKey)) {
      processed[camelKey] = json[pascalKey];
    }
  });

  return processed;
}

// Preprocessing function for Sender JSON
Map<String, dynamic> _preprocessSenderJson(Map<String, dynamic> json) {
  final processed = <String, dynamic>{};

  // Sender field mappings
  final keyMappings = {
    'Id': 'id',
    'Name': 'name',
    'OtherDetails': 'otherDetails',
    'SentMessages': 'sentMessages',
  };

  // Copy existing camelCase keys first
  json.forEach((key, value) {
    if (keyMappings.containsValue(key)) {
      processed[key] = value;
    }
  });

  // Map PascalCase to camelCase if camelCase doesn't exist
  keyMappings.forEach((pascalKey, camelKey) {
    if (json.containsKey(pascalKey) && !processed.containsKey(camelKey)) {
      processed[camelKey] = json[pascalKey];
    }
  });

  return processed;
}

// Preprocessing function for UserChat JSON
Map<String, dynamic> preprocessUserChatJson(Map<String, dynamic> json) {
  final processed = <String, dynamic>{};

  // UserChat field mappings
  final keyMappings = {
    'Id': 'id',
    'ChatId': 'chatId',
    'UserId': 'userId',
    'Type': 'type',
    'Role': 'role',
    'LastSeenMsgId': 'lastSeenMsgId',
    'CreatedAt': 'createdAt',
    'User': 'user',
  };

  // Copy existing camelCase keys first
  json.forEach((key, value) {
    if (keyMappings.containsValue(key)) {
      processed[key] = value;
    }
  });

  // Map PascalCase to camelCase if camelCase doesn't exist
  keyMappings.forEach((pascalKey, camelKey) {
    if (json.containsKey(pascalKey) && !processed.containsKey(camelKey)) {
      processed[camelKey] = json[pascalKey];
    }
  });

  return processed;
}

// Preprocessing function for User JSON
Map<String, dynamic> preprocessUserJson(Map<String, dynamic> json) {
  final processed = <String, dynamic>{};

  // User field mappings
  final keyMappings = {'Id': 'id', 'Name': 'name', 'UserChats': 'userChats'};

  // Copy existing camelCase keys first
  json.forEach((key, value) {
    if (keyMappings.containsValue(key)) {
      processed[key] = value;
    }
  });

  // Map PascalCase to camelCase if camelCase doesn't exist
  keyMappings.forEach((pascalKey, camelKey) {
    if (json.containsKey(pascalKey) && !processed.containsKey(camelKey)) {
      processed[camelKey] = json[pascalKey];
    }
  });

  return processed;
}

// Parse ChatMedias list with preprocessing
List<ChatMedias>? parseChatMedias(Map<String, dynamic> messageData) {
  try {
    final mediaData = messageData['ChatMedias'] ?? messageData['chatMedias'];
    if (mediaData != null && mediaData is List) {
      return mediaData.where((m) => m != null).map((m) {
        final processedJson = _preprocessChatMediasJson(
          m as Map<String, dynamic>,
        );
        return ChatMedias.fromJson(processedJson);
      }).toList();
    }
  } catch (e) {
    log('⚠️ Error parsing chat medias: $e');
  }
  return null;
}

// Parse Sender with preprocessing
Sender? parseSender(Map<String, dynamic> messageData) {
  try {
    final senderData = messageData['Sender'] ?? messageData['sender'];
    if (senderData != null && senderData is Map<String, dynamic>) {
      final processedJson = _preprocessSenderJson(senderData);
      return Sender.fromJson(processedJson);
    }
  } catch (e) {
    log('⚠️ Error parsing sender: $e');
  }
  return null;
}

// Parse UserChats list with preprocessing
List<UserChat>? parseUserChats(Map<String, dynamic> messageData) {
  try {
    final userChatsData = messageData['UserChats'] ?? messageData['userChats'];
    if (userChatsData != null && userChatsData is List) {
      return userChatsData.where((uc) => uc != null).map((uc) {
        final processedJson = preprocessUserChatJson(
          uc as Map<String, dynamic>,
        );

        // Also preprocess nested User if it exists
        if (processedJson['user'] != null &&
            processedJson['user'] is Map<String, dynamic>) {
          processedJson['user'] = preprocessUserJson(processedJson['user']);
        }

        return UserChat.fromJson(processedJson);
      }).toList();
    }
  } catch (e) {
    log('⚠️ Error parsing user chats: $e');
  }
  return null;
}

// Main message conversion function

// Helper validation functions
bool hasRequiredFields(Map<String, dynamic> data) {
  return (data['Id'] != null || data['id'] != null) &&
      (data['ChatId'] != null || data['chatId'] != null);
}

bool isValidEntry(Entry entry) {
  return entry.id != null && entry.chatId != null && entry.messageType != null;
}

void reportError(String errorType, dynamic error, StackTrace stackTrace) {
  // Implement your error reporting here
  print('$errorType: $error');
}

// Extensions for computed properties
extension ChatMediasExtension on ChatMedias {
  bool get isImage => mediaType?.toLowerCase() == 'image';
  bool get isVideo => mediaType?.toLowerCase() == 'video';
  bool get isAudio => mediaType?.toLowerCase() == 'audio';
  bool get hasValidUrl => mediaUrl?.isNotEmpty == true;
  String get displayName => fileName ?? 'Unknown File';
  bool get isEncrypted => encryptionLevel?.isNotEmpty == true;

  String get formattedSize {
    if (mediaSize == null) return 'Unknown size';
    final size = mediaSize!;
    if (size < 1024) return '${size}B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)}KB';
    if (size < 1024 * 1024 * 1024)
      return '${(size / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }
}

extension EntryExtension on Entry {
  bool get hasMedia => chatMedias?.isNotEmpty == true;
  bool get isTextMessage => messageType?.toLowerCase() == 'text';
  String get senderName => sender?.name ?? 'Unknown';
  DateTime? get createdAtDateTime {
    if (createdAt == null) return null;
    return DateTime.tryParse(createdAt!);
  }
}
