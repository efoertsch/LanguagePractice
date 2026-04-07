import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Assuming you use provider/bloc
import '../language_classes/word_info.dart';
import '../word_bloc/word_cubit.dart';
import '../word_widgets/word_type_mixin.dart';

class WordQuiz extends StatefulWidget {
  final String quizLanguage;

  const WordQuiz({super.key, required this.quizLanguage});

  @override
  State<WordQuiz> createState() => _WordQuizState();
}

class _WordQuizState extends State<WordQuiz> with WordTypeMixin {
  List<String> _selectedTypes = [];
  List<WordInfo> _wordList = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  void _handleTypesChanged(List<String> newTypes) {
    setState(() {
      _selectedTypes = newTypes;
    });
  }

  Future<void> _startQuiz() async {
    if (_selectedTypes.isNotEmpty){
     context.read<WordCubit>().getListOfWordsFromType(_selectedTypes);
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
          children: [
            // Row containing the Type Chips and the Start Button
            Row(
              children: [
                Expanded(
                  child: buildTypeChips(
                    context: context,
                    types: _selectedTypes,
                    multipleSelectionAllowed: true,
                    onTypesChanged: _handleTypesChanged,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _selectedTypes.isNotEmpty ? _startQuiz : null,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text("Start"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade100,
                    foregroundColor: Colors.green.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Row containing the word display and translation
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _wordList.isNotEmpty
                          ? (widget.quizLanguage == 'german'
                                ? _wordList[_currentIndex].word ??
                                      "" // Show German
                                : _wordList[_currentIndex].english?.join(", " ) ??
                                      "") // Show English
                          : "Select types and press Start",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _getQuizWordRow(),
              ],
            ),
            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: _wordList.isEmpty
                  ? null
                  : () {
                      // Logic for next word or checking answer
                    },
              icon: const Icon(Icons.check),
              label: const Text("Next Word"),
            ),
          ],
        ),
      ),
    );
  }

  Expanded _getQuizWordRow() {
    // Determine what to show as the "Answer" based on the quiz mode
    String displayText = "Answer";

    if (_wordList.isNotEmpty) {
      final currentWord = _wordList[_currentIndex];
      // If quizLanguage is german, we are guessing English (translation)
      // If quizLanguage is english, we are guessing German (word)
      displayText = (widget.quizLanguage == 'german')
          ? (currentWord.english?.join(", ") ?? "")
          : (currentWord.word ?? "");
    }

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          displayText,
          style: TextStyle(
            fontSize: 18,
            color: _wordList.isNotEmpty ? Colors.black : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _displayWord(WordInfo wordInfo){
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              buildTypeChips(
                context: context,
                types: wordInfo.type
              ),

              const SizedBox(height: 8),
              if ( wordInfo.type != null &&
                   wordInfo.type!.contains("noun"))
              // Update this section in your _displayWord method:
                if (wordInfo.type != null && wordInfo.type!.contains("noun"))
                  _getPluralWidget(wordInfo.plural),

              if ( wordInfo.type != null &&
                   wordInfo.type!.contains("verb"))
                _getWordTensesSection(),
              const SizedBox(height: 8),
              _getRulesWidget(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ],
    )
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
            Text(
              plural ?? "N/A",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }
  }
}
