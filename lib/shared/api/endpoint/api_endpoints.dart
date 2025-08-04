class ApiEndpoints {
  ApiEndpoints._();
  static String chatList = 'chat';
  static String chatEntry(int chatId, int userId) =>
      'ChatEntry/$chatId/$userId?offset=0&limit=50';

  static String addChatENtry = 'ChatEntry';
}
