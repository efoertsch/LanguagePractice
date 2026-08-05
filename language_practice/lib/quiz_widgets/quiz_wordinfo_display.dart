import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:language_practice/repository/language_classes/word_info.dart';
import 'package:language_practice/word_screen/word_widgets/verb_tenses_widget.dart';
import 'package:language_practice/word_screen/word_widgets/word_rules.dart';
import 'package:language_practice/word_screen/word_widgets/word_type_mixin.dart';

import '../word_screen/word_bloc/word_cubit.dart';
import '../word_screen/word_info_widget.dart';

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
        _getAnswerRow(context),
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

  Row _getAnswerRow(BuildContext context) { // Added BuildContext parameter
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
              fontSize: 16,
            ),
            minLines: 1,
            maxLines: 4,
            decoration: const InputDecoration(
              border: InputBorder.none,
            ),
          ),
        ),
        // ADDED PENCIL ICON BUTTON
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.blueGrey),
          tooltip: 'Edit Word',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (routeContext) => BlocProvider.value(
                  value: BlocProvider.of<WordCubit>(context),
                  child: WordInfoWidget(wordInfo: wordInfo),
                ),
              ),
            );
          },
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
