import 'package:flutter/material.dart';
import 'package:language_practice/repository/language_classes/phrase.dart';
import 'package:language_practice/word_screen/word_widgets/word_type_mixin.dart';

class QuizPhraseInfoDisplay extends StatelessWidget with WordTypeMixin {
  final Phrase phrase;
  final String quizLanguage;
  final TextEditingController _quizAnswerController = TextEditingController();

  QuizPhraseInfoDisplay({
    super.key,
    required this.phrase,
    required this.quizLanguage,
  });

  @override
  Widget build(BuildContext context) {
    _quizAnswerController.text = _getAnswerPhrase(
      phrase: phrase,
      quizLanguage: quizLanguage,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _getAnswerRow(),
        const SizedBox(height: 16),
        // Phrases typically have usage/context instead of tenses or plurals
        if (phrase.usage != null && phrase.usage!.isNotEmpty)
          _getUsageSection(phrase.usage!),

        const SizedBox(height: 100), // Match the bottom padding from WordInfo
      ],
    );
  }

  Row _getAnswerRow() {
    return Row(
      children: [
        const Flexible(
          child: Text(
            "Answer :",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: _quizAnswerController,
            readOnly: true,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            minLines: 1,
            maxLines: 4,
            decoration: const InputDecoration(
              border: InputBorder.none, // Match the style of WordInfo display
            ),
          ),
        ),
      ],
    );
  }

  String _getAnswerPhrase({
    required Phrase phrase,
    required String quizLanguage,
  }) {
    // If we are quizing on German, the question was German, so the answer is English.
    // Otherwise, the question was English, so the answer is the German phrase.
    return (quizLanguage == 'german'
        ? (phrase.english ?? "")
        : (phrase.phrase ?? ""));
  }

  Widget _getUsageSection(String usage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Usage / Context:",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blueGrey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blueGrey.shade100),
          ),
          child: Text(
            usage,
            style: const TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}