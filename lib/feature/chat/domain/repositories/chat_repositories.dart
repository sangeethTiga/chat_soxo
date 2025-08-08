import 'dart:io';

import 'package:soxo_chat/feature/chat/domain/models/add_chat/add_chatentry_request.dart';
import 'package:soxo_chat/feature/chat/domain/models/chat_entry/chat_entry_response.dart'
    hide ChatMedia;
import 'package:soxo_chat/feature/chat/domain/models/chat_res/chat_list_response.dart';
import 'package:soxo_chat/shared/utils/result.dart';

abstract class ChatRepositories {
  Future<ResponseResult<List<ChatListResponse>>> chatList();
  Future<ResponseResult<ChatEntryResponse>> chatEntry(int chatId, int userId);

  Future<ResponseResult<Entry>> addChatEntry({
    AddChatEntryRequest req,
    List<File>? files,
  });

  Future<Map<String, dynamic>> getFileFromApi(String media);
}
