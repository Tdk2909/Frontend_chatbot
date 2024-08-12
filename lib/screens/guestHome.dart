import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:nienproject/constants/constants.dart';
import 'package:nienproject/controllers/userController.dart';
import 'package:nienproject/providers/chats_provider.dart';
import 'package:nienproject/screens/loginPage.dart';
import 'package:nienproject/services/assets_manager.dart';
import 'package:nienproject/widgets/chat_widget.dart';
import 'package:nienproject/widgets/text_widget.dart';
import 'package:provider/provider.dart';

class GuestHomePage extends StatefulWidget {
  const GuestHomePage({super.key});

  @override
  State<GuestHomePage> createState() => _GuestHomePageState();
}

class _GuestHomePageState extends State<GuestHomePage> {
  bool _isTyping = false;

  late TextEditingController textEditingController;
  late ScrollController _listScrollController;
  late FocusNode focusNode;
  bool _isDialogShown = false;

  @override
  void initState() {
    _listScrollController = ScrollController();
    textEditingController = TextEditingController();
    focusNode = FocusNode();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDialogShown) {
        _showDialogtwo();
        _isDialogShown = true;
      }

      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      // Load chat history for the current user
      if (UserController.user != null) {
        chatProvider.loadChatHistory(UserController.user!.uid);
      }
    });
  }

  void _showDialogtwo() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Thông báo'),
          content: Text(
              'Xin chào, ${UserController.user?.displayName ?? ''} bạn đang đăng nhập với tư cách khách, hãy trải nghiệm NTTU-BOT, chat bot hỗ trợ tư vấn tuyển sinh của trường ĐH NTT.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _listScrollController.dispose();
    textEditingController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () async {
              await UserController.signOut(context);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const LoginPage(),
                ),
              );
            },
          ),
        ],
        elevation: 2,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(AssetsManager.logochatbotNTTU),
        ),
        title: const Text("NTTU-BOT"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Flexible(
              child: ListView.builder(
                controller: _listScrollController,
                itemCount: chatProvider.getChatList.length,
                itemBuilder: (context, index) {
                  final chatMessage = chatProvider.getChatList[index];
                  return ChatWidget(
                    msg: chatMessage.msg,
                    isFromUser: chatMessage.chatIndex == 1,
                    shouldAnimate: index == 0,
                  );
                },
              ),
            ),
            if (_isTyping)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            Material(
              color: cardColor,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        focusNode: focusNode,
                        style: const TextStyle(color: Colors.white),
                        controller: textEditingController,
                        onSubmitted: (value) async {
                          await sendMessageFCT(chatProvider: chatProvider);
                        },
                        decoration: const InputDecoration.collapsed(
                          hintText: "Tôi có thể giúp bạn không?",
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        await sendMessageFCT(chatProvider: chatProvider);
                      },
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

  void scrollListToEND() {
    _listScrollController.animateTo(
      _listScrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 2),
      curve: Curves.easeOut,
    );
  }

  Future<void> sendMessageFCT({required ChatProvider chatProvider}) async {
    if (_isTyping) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: TextWidget(
            label: "You can't send multiple messages at a time",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (textEditingController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: TextWidget(
            label: "Please type a message",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    try {
      String msg = textEditingController.text;
      setState(() {
        _isTyping = true;
        chatProvider.addUserMessage(
            msg: msg,
            userId: UserController.user!.uid); // Sử dụng addUserMessage
        textEditingController.clear();
        focusNode.unfocus();
      });

      await chatProvider.sendMessageAndGetAnswers(
          msg: msg,
          userId: UserController.user!.uid); // Sử dụng sendMessageAndGetAnswers

      setState(() {
        scrollListToEND();
        _isTyping = false;
      });
    } catch (error) {
      log("error $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: TextWidget(
            label: error.toString(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
