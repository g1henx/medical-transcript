class ChatData {
  final String sender;
  String message;
  final int time;

  ChatData({required this.sender, required this.message, required this.time});
}

class MessageSender {
  static String ai = "Assistant";
  static String user = "Human";
}