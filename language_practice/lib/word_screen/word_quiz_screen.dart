import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:language_practice/repository/language_classes/word_info.dart';
import 'package:language_practice/word_screen/word_bloc/word_cubit.dart';
import 'package:language_practice/word_screen/word_bloc/word_state.dart';
import 'package:language_practice/word_screen/word_widgets/verb_tenses_widget.dart'
    show WordTensesWidget;
import 'package:language_practice/word_screen/word_widgets/word_rules.dart'
    show WordRulesSection;
import 'package:language_practice/word_screen/word_widgets/word_type_mixin.dart'
    show WordTypeMixin;

import '../app/dialog_widgets.dart';

class WordQuiz extends StatefulWidget {
  final String quizLanguage;

  const WordQuiz({super.key, required this.quizLanguage});

  @override
  State<WordQuiz> createState() => _WordQuizState();
}

class _WordQuizState extends State<WordQuiz> with WordTypeMixin {
  final TextEditingController _quizAnswerController = TextEditingController();
  final TextEditingController _quizWordController = TextEditingController();
  List<String> _selectedTypes = [];
  List<WordInfo> _wordList = [];
  int _currentIndex = 0;
  bool _showDetails = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // 3. Dispose the controller when finished
    _quizAnswerController.dispose();
    _quizWordController.dispose();
    super.dispose();
  }

  void _handleTypesChanged(List<String> newTypes) {
    setState(() {
      _selectedTypes = newTypes;
    });
  }

  Future<void> _startQuiz() async {
    if (_selectedTypes.isNotEmpty) {
      context.read<WordCubit>().getQuizWordsForTypes(_selectedTypes);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Vocabulary Quiz")),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _getWordListListener(),
            if (_wordList.isEmpty) _getQuizPrompt(),
            Row(
              children: [
                _getBuildTypeChips(context),
                const SizedBox(width: 12),
                _getStartButton(),
              ],
            ),
            const SizedBox(height: 16),
            if (_wordList.isNotEmpty) ...[
              _getQuizWordWidget(),
              const SizedBox(height: 10),
              if (_showDetails)
                _getAnswerWordWidget(_wordList[_currentIndex])
              else
                const Spacer(),
              _getBottomControls(),
            ],
          ],
        ),
      ),
    );
  }

  ElevatedButton _getStartButton() {
    return ElevatedButton.icon(
      onPressed: _selectedTypes.isNotEmpty ? _startQuiz : null,
      icon: const Icon(Icons.play_arrow),
      label: const Text("Start"),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green.shade100,
        foregroundColor: Colors.green.shade900,
      ),
    );
  }

  Expanded _getBuildTypeChips(BuildContext context) {
    return Expanded(
      child: buildTypeChips(
        context: context,
        types: _selectedTypes,
        multipleSelectionAllowed: true,
        onTypesChanged: _handleTypesChanged,
      ),
    );
  }

  Widget _getQuizPrompt() {
    return Text(
      "Select types and press Start",
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  Widget _getQuizWordWidget() {
    _quizWordController.text = _wordList.isNotEmpty
        ? _getQuizWord(
            wordInfo: _wordList[_currentIndex],
            quizLanguage: widget.quizLanguage,
          )
        : "Select types and press Start";
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
          child: TextField(
            controller: _quizWordController,
            style: const TextStyle(
              fontSize: 22, // Increased size for better visibility
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.left,
            minLines: 1,
            maxLines: 3,
          ),
        ),
      ],
    );
  }

  String _getQuizWord({
    required WordInfo wordInfo,
    required String quizLanguage,
  }) {
    return (quizLanguage == 'german'
        ? _getGermanWord(wordInfo)
        : wordInfo.english?.join(", ") ?? "");
  }

  String _getAnswerWord({
    required WordInfo wordInfo,
    required String quizLanguage,
  }) {
    return (quizLanguage == 'german'
        ? (wordInfo.english?.join(", ") ?? "")
        : _getGermanWord(wordInfo));
  }

  Widget _getAnswerWordWidget(WordInfo wordInfo) {
    _quizAnswerController.text = _getAnswerWord(
      wordInfo: _wordList[_currentIndex],
      quizLanguage: widget.quizLanguage,
    );
    return Expanded(
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
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
                    Flexible(
                      child: TextField(
                        controller: _quizAnswerController,
                        readOnly: true,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(border: OutlineInputBorder()),
                        minLines: 1,
                        maxLines: 4,
                      ),
                    ),
                  ],
                ),
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
            ),
          ),
        ],
      ),
    );
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

  _getWordTensesSection(List<Tense> tenses) {
    return WordTensesWidget(tenses: tenses);
  }

  _getRulesWidget(List<Rules> rules) {
    return WordRulesSection(rules: rules, defaultWordType: "");
  }

  Widget _getWordListListener() {
    return BlocListener<WordCubit, WordState>(
      listener: (context, state) {
        if (state is ListOfWordsState) {
          setState(() {
            _wordList = state.listOfWords;
            _currentIndex = 0;
          });
        }
        if (state is ErrorWordState) {
          CommonWidgets.showInfoDialog(
            context: context,
            title: 'Oops',
            msg: "An error occurred: ${state.message}",
            button1Text: 'OK',
            button1Function: (() => Navigator.pop(context)),
          );
        }
      },
      child: SizedBox.shrink(),
    );
  }

  Widget _getBottomControls() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: _showDetails
          ? _getBottomButtons() // Returns the Yes/No Row
          : _getCheckButton(), // Returns the single Check button
    );
  }

  Widget _getCheckButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: () => setState(() => _showDetails = true),
        icon: const Icon(Icons.visibility),
        label: const Text("Check"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade100,
          foregroundColor: Colors.blue.shade900,
        ),
      ),
    );
  }

  Widget _getBottomButtons() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // NO BUTTON (Incorrect/Don't Know)
          ElevatedButton.icon(
            onPressed: () => _handleAnswer(false),
            icon: const Icon(Icons.close),
            label: const Text("Incorrect"),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(120, 45),
              backgroundColor: Colors.red.shade100,
              foregroundColor: Colors.red.shade900,
            ),
          ),
          // YES BUTTON (Correct/Know)
          ElevatedButton.icon(
            onPressed: () => _handleAnswer(true),
            icon: const Icon(Icons.check),
            label: const Text("Correct"),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(120, 45),
              backgroundColor: Colors.green.shade100,
              foregroundColor: Colors.green.shade900,
            ),
          ),
        ],
      ),
    );
  }

  void _handleAnswer(bool isCorrect) {
    final currentWord = _wordList[_currentIndex];
    // Update the score in the database
    if (currentWord.id != null) {
      context.read<WordCubit>().updateWordScore(
        currentWord.id!,
        isCorrect ? 1 : -1,
      );
    }

    setState(() {
      _showDetails = false;
      if (_currentIndex < _wordList.length - 1) {
        _currentIndex++;
      } else {
        // Handle end of quiz
        _wordList = [];
        _currentIndex = 0;
        CommonWidgets.showInfoDialog(
          context: context,
          title: "Quiz Finished",
          msg: "You have completed all selected words!",
          button1Text: "OK",
          button1Function: () => Navigator.pop(context),
        );
      }
    });
  }

  String _getGermanWord(WordInfo wordInfo) {
    if (wordInfo.type != null && wordInfo.type!.contains("noun")) {
      if (wordInfo.gender != null) {
        return "${wordInfo.gender} ${wordInfo.word}";
      }
    }
    return wordInfo.word ?? "";
  }
}
