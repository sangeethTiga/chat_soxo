class ApiEndpoints {
  ApiEndpoints._();
  static String chatList(int userId) => 'chat/with-unread/$userId';
  static String chatEntry(int chatId, int userId) =>
      'ChatEntry?chatid=$chatId&userid=$userId&offset=0&limit=200';
  // 'ChatEntry?chatid=1&userid=2&offset=0&limit=2'

  static String addChatENtry = 'ChatEntry';
  static String userList = 'ChatUser';
  static String createChat = 'chat';
  static String mediaType(String mediaId) => 'ChatEntry/$mediaId';

  static String deleteCHat(String chatId, String chatEntryId, String mode) =>
      'ChatEntry?chatid=$chatId&chatentryid=$chatEntryId&mode=$mode';

  static String pinnedChats(String chatEntryId, String pinned) =>
      'ChatEntry/pin?chatentryid=$chatEntryId&pinned=$pinned';
}
