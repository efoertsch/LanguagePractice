import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:language_practice/quiz_widgets/quiz_bloc/quiz_cubit.dart';
import 'package:language_practice/quiz_widgets/quiz_bloc/quiz_state.dart';
import 'package:language_practice/quiz_widgets/quiz_phrase.dart';
import 'package:language_practice/quiz_widgets/quiz_phrase_info_display.dart';
import 'package:language_practice/quiz_widgets/quiz_word.dart';
import 'package:language_practice/quiz_widgets/quiz_wordinfo_display.dart';
import 'package:language_practice/repository/language_classes/phrase.dart';
import 'package:language_practice/repository/language_classes/rule.dart';
import 'package:language_practice/repository/language_classes/word_info.dart';
import 'package:language_practice/rule/rule_widgets/rule_layout_widget.dart';
import 'package:language_practice/word_screen/word_bloc/word_cubit.dart';
import 'package:language_practice/word_screen/word_widgets/word_type_mixin.dart';

import '../app/dialog_widgets.dart' show CommonWidgets;
import '../phrase/phrase_bloc/phrase_cubit.dart';
import '../phrase/phrase_widgets/phrase_layout_widget.dart';
import '../rule/rule_bloc/rule_cubit.dart';

class MasterQuizViewer extends StatefulWidget {
  const MasterQuizViewer({super.key});

  @override
  State<MasterQuizViewer> createState() => _MasterQuizViewerState();
}

class _MasterQuizViewerState extends State<MasterQuizViewer>
    with WordTypeMixin {
  final getIt = GetIt.instance;

  // Can be List<WordInfo>, List<Phrase>, or List<Rule>
  List<dynamic> _quizItems = [];
  dynamic _selectedQuizItem;
  List<String> _selectedTypes = [];

  // Change individual bools to a single selection type
  String _category = "Word"; //
  String _displayField = "Primary";

  bool _showDetails = false;

  @override
  void initState() {
    super.initState();
    //context.read<QuizCubit>().getQuizItemsUsingFilter(_category);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Quiz Time"),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: _getBody(context),
    );
  }

  Widget _getBody(BuildContext context) {
    // Filter items based on the single radio selection
    // final filteredItems = _quizItems.where((item) {
    //   if (_category == "Word") return item is WordInfo;
    //   if (_category == "Phrase") return item is Phrase;
    //   if (_category == "Rule") return item is Rule;
    //   return false;
    // }).toList();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // COLUMN 1: Sidebar (25% of width)
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Radio Button Header
                _getQuizFields(),
                const Divider(height: 1),
                //Expanded(child: _buildListOfQuizItems(filteredItems)),
              ],
            ),
          ),
        ),
        VerticalDivider(
          color: Colors.grey,
          // Line color
          thickness: 1,
          // Line thickness
          width: 20,
          // Total horizontal space allocated for the divider
          indent: 5,
          // Top spacing/padding
          endIndent: 5, // Bottom spacing/padding
        ),

        // COLUMN 2: Details (75% of width)
        Expanded(
          flex: 3,
          child: _selectedQuizItem == null
              ? const Center(child: Text("Click Load Quiz Items"))
              : _buildDetailArea(_selectedQuizItem),
        ),
      ],
    );
  }

  Widget _getQuizListener() {
    return BlocListener<QuizCubit, QuizState>(
      listener: (context, state) {
        if (state is ListOfQuizItemsState) {
          setState(() {
            _quizItems = state.listOfQuizStuff;
            if (_quizItems.isNotEmpty) {
              _selectedQuizItem = _quizItems.first;
            } else {
              _selectedQuizItem = null;
            }
          });
        }
        if (state is ErrorQuizState) {
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

  Widget _displayQuizItem() {
    return Center(
      child: Text(
        _getDisplayName(_selectedQuizItem),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  ListView _buildListOfQuizItems(List<dynamic> filteredItems) {
    return ListView.separated(
      itemCount: filteredItems.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        bool isSelected = _selectedQuizItem == item;

        return ListTile(
          selected: isSelected,
          selectedTileColor: Colors.blue.withOpacity(0.1),
          title: Text(
            _getDisplayName(item),
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.blue : Colors.black87,
            ),
          ),
          onTap: () {
            setState(() {
              _selectedQuizItem = item;
            });
          },
        );
      },
    );
  }

  Widget _getQuizFields() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        // Changed to stretch for full-width button
        mainAxisSize: MainAxisSize.min,
        children: [
          _getQuizListener(),
          _getQuizCategoryText(),
          const SizedBox(height: 4),
          // First Dropdown: Category
          _getCategoryFormField(),
          const SizedBox(height: 12),
          _getDisplayListByText(),
          const SizedBox(height: 4),
          // Second Dropdown: Specific Field
          _getQuizDisplayOptions(),
          const SizedBox(height: 12),
          Flexible(child: _getBuildTypeChips(context)),
          const SizedBox(height: 16),
          // NEW BUTTON
          _getLoadQuizButton(),
        ],
      ),
    );
  }

  ElevatedButton _getLoadQuizButton() {
    return ElevatedButton.icon(
      onPressed: () {
        context.read<QuizCubit>().getQuizItemsUsingFilter(
          category: _category,
          filterTypes: _selectedTypes,
        );
      },
      icon: const Icon(Icons.refresh, size: 18),
      label: const Text("Load Quiz Items"),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade50,
        foregroundColor: Colors.blue.shade900,
      ),
    );
  }

  DropdownButtonFormField<String> _getQuizDisplayOptions() {
    return DropdownButtonFormField<String>(
      value: _displayField,
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        border: OutlineInputBorder(),
      ),
      items: _getDisplayOptions(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            _displayField = newValue;
          });
        }
      },
    );
  }

  Text _getDisplayListByText() {
    return const Text(
      "Display List By:",
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
    );
  }

  DropdownButtonFormField<String> _getCategoryFormField() {
    return DropdownButtonFormField<String>(
      value: _category,
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: "Word", child: Text("Words")),
        DropdownMenuItem(value: "Phrase", child: Text("Phrases")),
        DropdownMenuItem(value: "Rule", child: Text("Rules")),
      ],
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            _category = newValue;
            _displayField = "Primary"; // Reset display field on category change
            _selectedQuizItem = null;
            // Removed automatic cubit call to rely on the button below
          });
        }
      },
    );
  }

  Text _getQuizCategoryText() {
    return const Text(
      "Quiz Category:",
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
    );
  }

  /// Helper to generate options for the second dropdown based on the first
  List<DropdownMenuItem<String>> _getDisplayOptions() {
    if (_category == "Word") {
      return const [
        DropdownMenuItem(value: "Primary", child: Text("Word")),
        DropdownMenuItem(value: "Secondary", child: Text("English")),
      ];
    } else if (_category == "Phrase") {
      return const [
        DropdownMenuItem(value: "Primary", child: Text("Phrase")),
        DropdownMenuItem(value: "Secondary", child: Text("English")),
      ];
    } else {
      // Rule
      return const [
        DropdownMenuItem(value: "Primary", child: Text("Rule Name")),
        DropdownMenuItem(value: "Secondary", child: Text("Explanation")),
      ];
    }
  }

  String _getDisplayName(dynamic item) {
    bool showPrimary = _displayField == "Primary";

    if (item is WordInfo) {
      return showPrimary ? (item.word ?? "") : (item.english?.join(", ") ?? "");
    }
    if (item is Phrase) {
      return showPrimary ? (item.phrase ?? "") : (item.english ?? "");
    }
    if (item is Rule) {
      return showPrimary ? (item.rule ?? "") : (item.explanation ?? "");
    }
    return "Unknown";
  }

  /// Helper to label the object type
  String _getTypeLabel(dynamic item) {
    if (item is WordInfo) return "WORD";
    if (item is Phrase) return "PHRASE";
    if (item is Rule) return "RULE";
    return "";
  }

  Widget _getBuildTypeChips(BuildContext context) {
    return buildTypeChips(
      context: context,
      types: _selectedTypes,
      multipleSelectionAllowed: true,
      onTypesChanged: _handleTypesChanged,
    );
  }

  /// Builds the detail column with the layout and quiz buttons
  Widget _buildDetailArea(dynamic item) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(child: _buildDetailView(item)),
        if (item is WordInfo) _getBottomControls(item),
        if (item is Phrase) _getBottomControls(item),
        if (item is Rule) _getBottomControls(item),
      ],
    );
  }

  void _handleTypesChanged(List<String> newTypes) {
    setState(() {
      _selectedTypes = newTypes;
    });
  }

  /// Dynamic Switcher to load the correct Detail Widget
  Widget _buildDetailView(dynamic item) {
    if (item is WordInfo) {
      return SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: QuizWord(word: _getDisplayName(item)),
            ),
            _showDetails
                ? QuizWordinfoDisplay(
                    wordInfo: item,
                    quizLanguage: _getQuizLanguage(),
                  )
                : SizedBox.shrink(),
          ],
        ),
      );
    }
    if (item is Phrase) {
      return SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: QuizPhrase(phrase: _getDisplayName(item)),
            ),
            _showDetails
                ? QuizPhraseInfoDisplay(
                    key: ValueKey(item.id),
                    phrase: item,
                    quizLanguage: _getQuizLanguage(),
                  )
                : SizedBox.shrink(),
          ],
        ),
      );
    }
    if (item is Rule) {
      return RuleLayoutWidget(
        key: ValueKey(item.id),
        rule: item,
        readOnly: true,
      );
    }
    return const Center(child: Text("Invalid Item Type"));
  }

  String _getQuizLanguage() {
    return _displayField == "Primary" ? "german" : "english";
  }

  Widget _getBottomControls(dynamic item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: _showDetails
          ? _getCorrectIncorrectButtons(item) // Returns the Yes/No Row
          : _getCheckButton(), // Returns the single Check button
    );
  }

  Widget _getCheckButton() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: ElevatedButton.icon(
        onPressed: () => setState(() => _showDetails = true),
        icon: const Icon(Icons.check),
        label: const Text("Check"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade100,
          foregroundColor: Colors.red.shade900,
        ),
      ),
    );
  }

  /// Returns the button row similar to word_quiz_screen.dart
  Widget _getCorrectIncorrectButtons(dynamic item) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            onPressed: () => _handleAnswer(item, false),
            icon: const Icon(Icons.close),
            label: const Text("Incorrect"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade100,
              foregroundColor: Colors.red.shade900,
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _handleSkip(),
            icon: const Icon(Icons.arrow_forward),
            label: const Text("Skip"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade100,
              foregroundColor: Colors.blue.shade900,
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _handleAnswer(item, true),
            icon: const Icon(Icons.check),
            label: const Text("Correct"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade100,
              foregroundColor: Colors.green.shade900,
            ),
          ),
        ],
      ),
    );
  }

  void _handleAnswer(dynamic item, bool isCorrect) {
    if (item.id != null) {
      if (item is WordInfo) {
        context.read<WordCubit>().updateWordScore(item.id!, isCorrect);
      } else if (item is Phrase) {
        context.read<PhraseCubit>().updatePhraseScore(item.id!, isCorrect);
      } else if (item is Rule) {
        context.read<RuleCubit>().updateRuleScore(item.id!, isCorrect);
      }
      setState(() {
        _showDetails = false;
        _quizItems.remove(_selectedQuizItem);
        if (!isCorrect) {
          _quizItems.add(_selectedQuizItem);
        }
        _selectedQuizItem = _quizItems.isNotEmpty ? _quizItems.first : null;
      });
    }
  }

  void _handleSkip() {
    setState(() {
      _showDetails = false;
      _quizItems.remove(_selectedQuizItem);
      _quizItems.add(_selectedQuizItem);
      _selectedQuizItem = _quizItems.isNotEmpty ? _quizItems.first : null;
    });
  }
}
