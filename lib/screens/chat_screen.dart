import 'package:flutter/material.dart';
import 'package:nienproject/constants/constants.dart';
import 'package:nienproject/providers/chats_provider.dart';
import 'package:nienproject/widgets/chat_widget.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final String? userId;

  const ChatScreen({Key? key, this.userId}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _isTyping = false;
  late TextEditingController textEditingController;
  late ScrollController _listScrollController;
  late FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    _listScrollController = ScrollController();
    textEditingController = TextEditingController();
    focusNode = FocusNode();
    // Load chat history when ChatScreen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadChatHistory(widget.userId ?? 'default_user_id');
    });
  }

  @override
  void dispose() {
    _listScrollController.dispose();
    textEditingController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  Future<void> loadChatHistory(String userId) async {
    try {
      await Provider.of<ChatProvider>(context, listen: false)
          .loadChatHistory(userId);
    } catch (error) {
      print("Error loading chat history: $error");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error.toString(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF343541),
        centerTitle:
            false, // Đặt centerTitle là false để căn tiêu đề về bên trái
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            // Xử lý khi nhấn vào icon menu
            print("Icon menu được nhấn");
          },
        ),
        title: const Text(
          "NTTU-BOT",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Consumer<ChatProvider>(
                builder: (context, chatProvider, child) {
                  return ListView.builder(
                    controller: _listScrollController,
                    itemCount: chatProvider.getChatList.length,
                    reverse: true,
                    itemBuilder: (context, index) {
                      final chatItem = chatProvider.getChatList[index];
                      return ChatWidget(
                        msg: chatItem.msg,
                        isFromUser: chatItem.chatIndex == 1,
                        shouldAnimate: index == 0,
                      );
                    },
                  );
                },
              ),
            ),
            Material(
              color: cardColor,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: TextField(
                          focusNode: focusNode,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Roboto',
                          ),
                          controller: textEditingController,
                          onChanged: (text) {
                            setState(() {
                              _isTyping = text.trim().isNotEmpty;
                            });
                          },
                          onSubmitted: (value) async {
                            if (_isTyping) {
                              await sendMessageFCT(
                                chatProvider: Provider.of<ChatProvider>(context,
                                    listen: false),
                              );
                            }
                          },
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "Tôi có thể giúp bạn không?",
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _isTyping
                          ? () async {
                              await sendMessageFCT(
                                chatProvider: Provider.of<ChatProvider>(context,
                                    listen: false),
                              );
                            }
                          : null,
                      icon: const Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> sendMessageFCT({required ChatProvider chatProvider}) async {
    if (_isTyping) {
      setState(() {
        _isTyping = false;
      });
      try {
        String msg = textEditingController.text;
        chatProvider.addUserMessage(
          msg: msg,
          userId: widget.userId ?? 'default_user_id',
        );
        textEditingController.clear();
        focusNode.unfocus();
        await chatProvider.sendMessageAndGetAnswers(
          msg: msg,
          userId: widget.userId ?? 'default_user_id',
        );

        // Check if user manually scrolled up
        bool shouldScrollToBottom = _listScrollController.position.pixels ==
            _listScrollController.position.maxScrollExtent;

        await Future.delayed(const Duration(milliseconds: 300));

        // Scroll to bottom only if it was previously at the bottom
        if (shouldScrollToBottom) {
          _listScrollController.animateTo(
            _listScrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      } catch (error) {
        print("error $error");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                error.toString(),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
