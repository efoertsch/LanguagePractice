import 'package:flutter/material.dart';

class QuizWord extends StatelessWidget {
  final String word;

  QuizWord({Key? key, required this.word}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Flexible(
          child: Text(
            "Word:  ",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        SizedBox(width: 8),
        Flexible(
          child: Text(
            word,
            style: const TextStyle(
              fontSize: 22, // Increased size for better visibility
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.left,
            maxLines: 4,
          ),
        ),
      ],
    );
  }
}
