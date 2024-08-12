class ChatModel {
  final String msg;
  final int chatIndex;
  final String output;

  ChatModel({required this.msg, required this.chatIndex, required this.output});

  factory ChatModel.fromJson(Map<String, dynamic> json) => ChatModel(
        msg: json["msg"],
        chatIndex: json["chatIndex"],
        output: json["output"]["output"], // Lấy nội dung output từ JSON
      );

  Map<String, dynamic> toJson() => {
        "msg": msg,
        "chatIndex": chatIndex,
        "output": output,
      };
}
