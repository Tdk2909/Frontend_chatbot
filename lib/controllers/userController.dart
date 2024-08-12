import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:nienproject/providers/chats_provider.dart';
import 'package:provider/provider.dart';

class UserController {
  static User? get user => FirebaseAuth.instance.currentUser;
  static String? currentUserID; // Assume this is the UUID or current user ID
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Đăng nhập bằng tài khoản Google và lưu thông tin người dùng vào Firestore
  static Future<User?> loginWithGoogle() async {
    try {
      final googleAccount = await GoogleSignIn().signIn();
      if (googleAccount != null) {
        final googleAuth = await googleAccount.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);
        currentUserID = userCredential.user?.uid; // Assign the UID here

        // Lưu session ID và thông tin người dùng vào Firestore
        await saveSessionToFirestore(
            userCredential.user, googleAuth.accessToken);

        return userCredential.user;
      } else {
        // Handle case where googleAccount is null
        print('User did not select a Google account.');
        return null;
      }
    } catch (error) {
      print(error.toString());
      throw error;
    }
  }

  // Lưu session ID và thông tin người dùng vào Firestore
  static Future<void> saveSessionToFirestore(
      User? user, String? accessToken) async {
    if (user != null && accessToken != null) {
      final sessionData = {
        'sessionId': accessToken,
        'email': user.email,
        'name': user.displayName,
        'photoUrl': user.photoURL,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('chatadmin').doc(user.uid).set(sessionData);
    }
  }

  // Tạo tài liệu chatroom user trong Firestore
  static Future<void> createChatroomUserDocument(
      String sessionId, String message) async {
    final chatData = {
      'chatIndex': 1,
      'msg': message,
      'output': "",
      'timestamp': FieldValue.serverTimestamp(),
    };

    await _firestore
        .collection('chatadmin')
        .doc(sessionId)
        .collection('chatroom_user')
        .add(chatData);
  }

  // Gửi tin nhắn
  static Future<void> sendMessage(String message) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final sessionId =
          user.uid; // Assuming sessionId is the same as user's UID
      await createChatroomUserDocument(sessionId, message);
    }
  }

  // Lấy UUID từ tài khoản Google
  static Future<String?> getGoogleUUID() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await GoogleSignIn().signInSilently();

      if (googleSignInAccount != null) {
        String? uuid = googleSignInAccount.id;
        return uuid;
      } else {
        // Handle case where googleSignIn.signInSilently() returns null
        return null;
      }
    } catch (error) {
      print("Error retrieving Google UUID: $error");
      return null;
    }
  }

  // Lấy UUID từ Firebase
  static Future<String?> getFirebaseUUID() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        return user.uid;
      } else {
        return null;
      }
    } catch (error) {
      print("Error retrieving Firebase UUID: $error");
      return null;
    }
  }

  // Lấy email từ UID của người dùng Firebase
  static Future<String?> getEmailFromUid(String uid) async {
    try {
      DocumentSnapshot snapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (snapshot.exists) {
        return snapshot['email'];
      } else {
        print('User with UID $uid does not exist');
        return null;
      }
    } catch (e) {
      print('Error retrieving email: $e');
      return null;
    }
  }

  // Lấy ngày sinh của người dùng từ Google
  static Future<DateTime?> getBirthday() async {
    try {
      final googleAccount = await GoogleSignIn().signIn();
      if (googleAccount != null) {
        final googleAuth = await googleAccount.authentication;
        if (googleAuth != null) {
          final headers = {
            'Authorization': 'Bearer ${googleAuth.accessToken}',
          };
          final response = await GoogleSignInApi.getRequest(
            'https://people.googleapis.com/v1/people/me?personFields=birthdays',
            headers: headers,
          );
          final birthday = response['birthdays']?[0]['date'];
          if (birthday != null) {
            final date = DateTime.parse(birthday);
            return date;
          } else {
            print('User did not provide birthday information.');
            return null;
          }
        } else {
          print('User did not select a Google account.');
          return null;
        }
      } else {
        print('User did not select a Google account.');
        return null;
      }
    } catch (error) {
      print(error.toString());
      throw error;
    }
  }

  // Đăng xuất tài khoản
  static Future<void> signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    clearChatHistory(context); // Clear chat history when signing out
    currentUserID = null; // Clear the current user ID (or UUID)
    print('User signed out and local data cleared successfully.');
  }

  // Xóa lịch sử chat khi đăng xuất
  static void clearChatHistory(BuildContext context) {
    try {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      chatProvider.clearChatHistory();
      print('Chat history cleared successfully.');
    } catch (error) {
      print('Error clearing chat history: $error');
    }
  }
}

class GoogleSignInApi {
  static Future<Map<String, dynamic>> getRequest(String url,
      {Map<String, String>? headers}) async {
    final response = await http.get(Uri.parse(url), headers: headers);
    final parsedResponse = json.decode(response.body) as Map<String, dynamic>;
    return parsedResponse;
  }
}

final GoogleSignIn googleSignIn = GoogleSignIn();
