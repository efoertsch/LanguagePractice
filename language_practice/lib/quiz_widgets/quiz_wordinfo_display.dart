import 'package:flutter/material.dart';
import 'package:language_practice/repository/language_classes/word_info.dart';
import 'package:language_practice/word_screen/word_widgets/verb_tenses_widget.dart';
import 'package:language_practice/word_screen/word_widgets/word_rules.dart';
import 'package:language_practice/word_screen/word_widgets/word_type_mixin.dart';

class QuizWordinfoDisplay extends StatelessWidget with WordTypeMixin {
  final WordInfo wordInfo;
  final String quizLanguage;
  final TextEditingController _quizAnswerController = TextEditingController();

  QuizWordinfoDisplay({
    super.key,
    required this.wordInfo,
    required this.quizLanguage,
  });

  @override
  Widget build(BuildContext context) {
    _quizAnswerController.text = _getAnswerWord(
      wordInfo: wordInfo,
      quizLanguage: quizLanguage,
    );
    return Column(
     // mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _getAnswerRow(),
        const SizedBox(height: 8),
        buildTypeChips(context: context, types: wordInfo.type),
        const SizedBox(height: 8),
        if (wordInfo.type != null && wordInfo.type!.contains("noun"))
          // Update this section in your _displayWord method:
          if (wordInfo.type != null && wordInfo.type!.contains("noun"))
            _getPluralWidget(wordInfo.plural),

        if (wordInfo.type != null && wordInfo.type!.contains("verb"))
          _getWordTensesSection(wordInfo.tenses ?? []),
        const SizedBox(height: 8),
        _getRulesWidget(wordInfo.rules ?? []),
        const SizedBox(height: 100),
      ],
    );
  }

  Row _getAnswerRow() {
    return Row(
        //mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              "Answer :",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _quizAnswerController,
              readOnly: true,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              // decoration: InputDecoration(
              //   border: OutlineInputBorder(),
              // ),
              minLines: 1,
              maxLines: 4,
            ),
          ),
        ],
      );
  }

  String _getAnswerWord({
    required WordInfo wordInfo,
    required String quizLanguage,
  }) {
    return (quizLanguage == 'german'
        ? (wordInfo.english?.join(", ") ?? "")
        : _getGermanWord(wordInfo));
  }

  String _getGermanWord(WordInfo wordInfo) {
    if (wordInfo.type != null && wordInfo.type!.contains("noun")) {
      if (wordInfo.gender != null) {
        return "${wordInfo.gender} ${wordInfo.word}";
      }
    }
    return wordInfo.word ?? "";
  }

  Widget _getPluralWidget(String? plural) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Text(
            "Plural: ",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(plural ?? "N/A", style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _getWordTensesSection(List<Tense> tenses) {
    return WordTensesWidget(tenses: tenses);
  }

  Widget _getRulesWidget(List<Rules> rules) {
    return WordRulesSection(rules: rules, defaultWordType: "");
  }
}
