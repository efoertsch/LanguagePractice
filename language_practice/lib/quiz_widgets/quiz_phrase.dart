import 'package:flutter/material.dart';

class QuizPhrase extends StatelessWidget {
  final String phrase;

  const QuizPhrase({Key? key, required this.phrase}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start, // Align to top for multi-line phrases
      children: [

        const Text(
          "Phrase:  ",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        //const SizedBox(width: 8),
        Expanded( // Changed from Flexible to Expanded to handle longer phrase wrapping
          child: Text(
            phrase,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.left,
            softWrap: true,
            maxLines: 5, // Increased slightly for very long phrases
          ),
        ),
      ],
    );
  }
}
