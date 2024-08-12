import 'package:flutter/material.dart';

class TextWidget extends StatelessWidget {
  const TextWidget({
    Key? key,
    required this.label,
    this.fontSize = 19,
    this.color,
    this.fontWeight,
    this.wordSpacing = 0.0,
    this.lineHeight = 1.0,
    this.textAlign = TextAlign.justify,
  }) : super(key: key);

  final String label;
  final double fontSize;
  final Color? color;
  final FontWeight? fontWeight;
  final double wordSpacing;
  final double lineHeight;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.fitWidth,
      child: RichText(
        textAlign: textAlign,
        text: TextSpan(
          style: TextStyle(
            color: color ?? Colors.white,
            fontSize: fontSize,
            fontWeight: fontWeight ?? FontWeight.w700,
            wordSpacing: wordSpacing,
            height: lineHeight,
          ),
          children: _buildTextSpans(label),
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
