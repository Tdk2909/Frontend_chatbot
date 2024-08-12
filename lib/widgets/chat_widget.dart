import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:nienproject/constants/constants.dart';
import 'package:nienproject/services/assets_manager.dart';

class ChatWidget extends StatelessWidget {
  const ChatWidget({
    Key? key,
    required this.msg,
    required this.isFromUser,
    this.shouldAnimate = false,
  }) : super(key: key);

  final String msg;
  final bool isFromUser;
  final bool shouldAnimate;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isFromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          color: isFromUser ? cardColor : scaffoldBackgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: isFromUser ? Radius.circular(20.0) : Radius.circular(0.0),
            topRight: isFromUser ? Radius.circular(0.0) : Radius.circular(20.0),
            bottomLeft: Radius.circular(20.0),
            bottomRight: Radius.circular(20.0),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Wrap(
                crossAxisAlignment: WrapCrossAlignment.start,
                children: [
                  if (!isFromUser)
                    Image.asset(
                      AssetsManager.logochatbotNTTU,
                      height: 60,
                      width: 60,
                    ),
                  if (!isFromUser) const SizedBox(width: 8),
                  Container(
                      constraints: BoxConstraints(
                        maxWidth: constraints.maxWidth * 1,
                      ),
                      decoration: BoxDecoration(
                        color: isFromUser ? cardColor : scaffoldBackgroundColor,
                        borderRadius: BorderRadius.only(
                          topLeft: isFromUser
                              ? Radius.circular(20.0)
                              : Radius.circular(0.0),
                          topRight: isFromUser
                              ? Radius.circular(0.0)
                              : Radius.circular(20.0),
                          bottomLeft: Radius.circular(20.0),
                          bottomRight: Radius.circular(20.0),
                        ),
                      ),
                      padding: const EdgeInsets.all(12.0),
                      child: isFromUser
                          ? Text(
                              msg.trim(),
                              textAlign: TextAlign.justify,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 22,
                                  wordSpacing: 0.5,
                                  height: 1.5),
                            )
                          : shouldAnimate
                              ? DefaultTextStyle(
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 22,
                                      wordSpacing: 0.5,
                                      height: 1.5),
                                  child: AnimatedTextKit(
                                    isRepeatingAnimation: false,
                                    totalRepeatCount: 1,
                                    animatedTexts: [
                                      TyperAnimatedText(
                                        msg.trim(),
                                        textStyle: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 22,
                                            wordSpacing: 1,
                                            height: 1.5),
                                        speed: const Duration(milliseconds: 10),
                                      ),
                                    ],
                                  ),
                                )
                              : RichText(
                                  textAlign: isFromUser
                                      ? TextAlign.justify
                                      : TextAlign.left,
                                  text: TextSpan(
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        wordSpacing: -1,
                                        fontSize: 22,
                                        height: 2),
                                    children: _buildTextSpans(msg.trim()),
                                  ),
                                )),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  List<TextSpan> _buildTextSpans(String message) {
    List<TextSpan> spans = [];
    RegExp regex = RegExp(r'\*\*(.*?)\*\*');
    Iterable<Match> matches = regex.allMatches(message);
    int lastMatchEnd = 0;

    for (Match match in matches) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: message.substring(lastMatchEnd, match.start),
        ));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ));
      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < message.length) {
      spans.add(TextSpan(
        text: message.substring(lastMatchEnd),
      ));
    }

    return spans;
  }
}
