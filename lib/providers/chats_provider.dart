import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nienproject/models/chat_model.dart';
import 'package:nienproject/services/api_service.dart';

class ChatProvider with ChangeNotifier {
  List<ChatModel> chatList = [];
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  List<ChatModel> get getChatList => chatList;

  Future<void> loadChatHistory(String userId) async {
    try {
      // Clear current chat history before loading new one
      chatList.clear();
      notifyListeners();

      // Query Firestore for chat history of the specified user ID
      QuerySnapshot querySnapshot = await firestore
          .collection('chat_history')
          .doc(userId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .get();

      // Process retrieved documents into ChatModel objects
      for (var doc in querySnapshot.docs) {
        chatList.add(ChatModel(
          msg: doc['msg'],
          chatIndex: doc['chatIndex'],
          output: doc['output'],
        ));
      }

      // Notify listeners after updating chatList
      notifyListeners();
    } catch (error) {
      print("Error loading chat history: $error");
    }
  }

  void clearChatHistory() {
    chatList.clear();
    notifyListeners();
  }

  void addUserMessage({required String msg, required String userId}) async {
    final newMessage = ChatModel(msg: msg, chatIndex: 1, output: '');
    chatList.insert(0, newMessage);
    await _saveMessageToFirestore(newMessage, userId);
    notifyListeners();
  }

  Future<void> sendMessageAndGetAnswers(
      {required String msg, required String userId}) async {
    try {
      ChatModel response = await ApiService.sendMessage(msg);
      chatList.insert(0, response);
      await _saveMessageToFirestore(response, userId);
      notifyListeners();
    } catch (error) {
      print("Error sending message: $error");
    }
  }

  Future<void> _saveMessageToFirestore(
      ChatModel chatModel, String userId) async {
    try {
      await firestore
          .collection('chat_history')
          .doc(userId)
          .collection('messages')
          .add({
        'msg': chatModel.msg,
        'chatIndex': chatModel.chatIndex,
        'output': chatModel.output,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (error) {
      print("Error saving message to Firestore: $error");
    }
  }
}
