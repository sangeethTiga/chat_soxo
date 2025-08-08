class ApiEndpoints {
  ApiEndpoints._();
  static String chatList = 'chat';
  static String chatEntry(int chatId, int userId) =>
      'ChatEntry?chatid=$chatId&userid=$userId&offset=0&limit=2';
  // 'ChatEntry?chatid=1&userid=2&offset=0&limit=2'

  static String addChatENtry = 'ChatEntry';
  static String userList = 'ChatUser';
  static String createChat = 'chat';
}
