import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:nienproject/constants/api_consts.dart';
import 'package:nienproject/controllers/userController.dart';
import 'package:nienproject/models/chat_model.dart';

class ApiService {
  static Future<ChatModel> sendMessage(String message) async {
    try {
      String? uuid = await UserController.getGoogleUUID();

      var requestBody = {
        "input": {"input": message},
        "config": {}
      };

      if (uuid != null) {
        requestBody["config"] = {
          "configurable": {"session_id": uuid}
        };
      }

      var response = await http.post(
        Uri.parse(BASE_URL),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse =
            json.decode(utf8.decode(response.bodyBytes));

        if (jsonResponse['error'] != null) {
          throw HttpException(jsonResponse['error']["message"]);
        }

        if (jsonResponse.containsKey('output') &&
            jsonResponse['output'].containsKey('output')) {
          String output = jsonResponse['output']['output'];
          // Bot's message has chatIndex 0
          return ChatModel(msg: output, chatIndex: 0, output: '');
        } else {
          // If the expected 'output' field is missing, log the issue and throw an exception
          log('Unexpected JSON structure: $jsonResponse');
          throw const FormatException('Invalid response structure');
        }
      } else {
        log('Request failed with status: ${response.statusCode}.');
        log('Response body: ${response.body}');
        throw HttpException('Error calling API: ${response.statusCode}');
      }
    } catch (error) {
      log("error $error");
      rethrow;
    }
  }
}
