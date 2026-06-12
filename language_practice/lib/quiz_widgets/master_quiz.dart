import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:language_practice/quiz_widgets/quiz_bloc/quiz_cubit.dart';
import 'package:language_practice/quiz_widgets/quiz_bloc/quiz_state.dart';
import 'package:language_practice/repository/language_classes/phrase.dart';
import 'package:language_practice/repository/language_classes/rule.dart';
import 'package:language_practice/repository/language_classes/word_info.dart';
import 'package:language_practice/rule/rule_widgets/rule_layout_widget.dart';
import 'package:language_practice/word_screen/word_bloc/word_cubit.dart';
import 'package:language_practice/word_screen/word_widgets/word_info_layout_widget.dart';

import '../app/dialog_widgets.dart' show CommonWidgets;
import '../phrase/phrase_bloc/phrase_cubit.dart';
import '../phrase/phrase_widgets/phrase_layout_widget.dart';
import '../rule/rule_bloc/rule_cubit.dart';

class MasterQuizViewer extends StatefulWidget {
  const MasterQuizViewer({super.key});

  @override
  State<MasterQuizViewer> createState() => _MasterQuizViewerState();
}

class _MasterQuizViewerState extends State<MasterQuizViewer> {
  final getIt = GetIt.instance;

  // Can be List<WordInfo>, List<Phrase>, or List<Rule>
  List<dynamic> _quizItems = [];
  dynamic _selectedQuizItem;

  // Change individual bools to a single selection type
  String _filterType = "Word"; //
  String _displayField = "Primary";

  @override
  void initState() {
    super.initState();
    context.read<QuizCubit>().getQuizItemsUsingFilter(_filterType);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Quiz Time"),
          backgroundColor: Colors.blue,
          centerTitle: true,
        ),
        body: _getBody(context));
  }


  Widget _getBody(BuildContext context) {
    // Filter items based on the single radio selection
    final filteredItems = _quizItems.where((item) {
      if (_filterType == "Word") return item is WordInfo;
      if (_filterType == "Phrase") return item is Phrase;
      if (_filterType == "Rule") return item is Rule;
      return false;
    }).toList();
    return  Row(
        children: [
          // COLUMN 1: Sidebar (25% of width)
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                border: Border(right: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _getQuizListener(),
                  // Radio Button Header
                  _getQuizButtons(),
                  const Divider(height: 1),
                  Expanded(child: _buildListOfQuizItems(filteredItems)),
                ],
              ),
            ),
          ),

          // COLUMN 2: Details (75% of width)
          Expanded(
            flex: 3,
            child: _selectedQuizItem == null
                ? const Center(child: Text("Select an item to view details"))
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
            _selectedQuizItem = null;
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

  Widget _getQuizButtons() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Quiz Category:",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          // First Dropdown: Category
          DropdownButtonFormField<String>(
            value: _filterType,
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
                  _filterType = newValue;
                  _displayField = "Primary"; // Reset display field on category change
                  _selectedQuizItem = null;
                  context.read<QuizCubit>().getQuizItemsUsingFilter(_filterType);
                });
              }
            },
          ),
          const SizedBox(height: 12),
          const Text(
            "Display List By:",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          // Second Dropdown: Specific Field
          DropdownButtonFormField<String>(
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
          ),
        ],
      ),
    );
  }

  /// Helper to generate options for the second dropdown based on the first
  List<DropdownMenuItem<String>> _getDisplayOptions() {
    if (_filterType == "Word") {
      return const [
        DropdownMenuItem(value: "Primary", child: Text("Word")),
        DropdownMenuItem(value: "Secondary", child: Text("English")),
      ];
    } else if (_filterType == "Phrase") {
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
      return showPrimary
          ? (item.word ?? "")
          : (item.english?.join(", ") ?? "");
    }
    if (item is Phrase) {
      return showPrimary
          ? (item.phrase ?? "")
          : (item.english ?? "");
    }
    if (item is Rule) {
      return showPrimary
          ? (item.rule ?? "")
          : (item.explanation ?? "");
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

  /// Builds the detail column with the layout and quiz buttons
  Widget _buildDetailArea(dynamic item) {
    return Column(
      children: [
        Expanded(
          child: _buildDetailView(item),
        ),
        if (item is WordInfo) _getQuizActionButtons(item),
        if (item is Phrase) _getQuizActionButtons(item),
        if (item is Rule) _getQuizActionButtons(item),
      ],
    );
  }

  /// Dynamic Switcher to load the correct Detail Widget
  Widget _buildDetailView(dynamic item) {
    // We use ValueKey to force the widget to rebuild entirely when a new item is tapped
    if (item is WordInfo) {
      return ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: WordInfoWidgetLayout(
              key: ValueKey(item.id),
              wordInfo: item,
              genders: [],
              editable: false,
            ),
          ),
        ],
      );
    }
    if (item is Phrase) {
      return PhraseLayoutWidget(key: ValueKey(item.id), phrase: item, readOnly: true);
    }
    if (item is Rule) {
      return RuleLayoutWidget(key: ValueKey(item.id), rule: item, readOnly: true);
    }
    return const Center(child: Text("Invalid Item Type"));
  }

  /// Returns the button row similar to word_quiz_screen.dart
  Widget _getQuizActionButtons(dynamic item) {
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
        context.read<WordCubit>().updateWordScore(
          item.id!,
          isCorrect ? 1 : -2,
        );
      } else if (item is Phrase) {
        context.read<PhraseCubit>().updatePhraseScore(
          item.id!,
          isCorrect ? 1 : -2,
        );
      } else if (item is Rule) {
        context.read<RuleCubit>().updateRuleScore(
          item.id!,
          isCorrect ? 1 : -2,
        );
      }
      setState(() {
        _quizItems.remove(_selectedQuizItem);
        if (!isCorrect) {
          _quizItems.add(_selectedQuizItem);
        }
        _selectedQuizItem = null;
      });
    }
  }
}
