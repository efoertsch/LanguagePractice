import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:language_practice/app/dialog_widgets.dart';
import 'package:language_practice/repository/language_classes/word_info.dart';
import 'package:language_practice/word_screen/word_bloc/word_cubit.dart';
import 'package:language_practice/word_screen/word_bloc/word_state.dart';
import 'package:language_practice/word_screen/word_widgets/plural_widget.dart'
    show PluralWidget;
import 'package:language_practice/word_screen/word_widgets/translated_word_widget.dart'
    show TranslatedWordWidget;
import 'package:language_practice/word_screen/word_widgets/verb_tenses_widget.dart'
    show WordTensesWidget;
import 'package:language_practice/word_screen/word_widgets/word_rules.dart'
    show WordRulesSection;
import 'package:language_practice/word_screen/word_widgets/word_section.dart'
    show WordSection;
import 'package:language_practice/word_screen/word_widgets/word_type_mixin.dart'
    show WordTypeMixin;

import '../enums/word_enums.dart' show WordType, VerbTense;

class WordInfoWidget extends StatefulWidget {
  final WordInfo wordInfo;
  final getIt = GetIt.instance;

  WordInfoWidget({super.key, required this.wordInfo});

  @override
  State<WordInfoWidget> createState() => _WordInfoWidgetState();
}

class _WordInfoWidgetState extends State<WordInfoWidget>
    with TickerProviderStateMixin, WordTypeMixin {
  // Controllers to handle text input
  List<String> _genders = [];
  late final ValueNotifier<String> presentTenseEnglish;

  @override
  void initState() {
    _getGenders();
    if (widget.wordInfo.type != null
        && widget.wordInfo.type!.contains(WordType.verb.displayName)
        && widget.wordInfo.tenses == null){
      widget.wordInfo.tenses = [Tense(tense: VerbTense.present.germanTense,
          english: widget.wordInfo.word,
          s1stPersonPlural: widget.wordInfo.word,
          s3rdPersonPlural: widget.wordInfo.word
      )];
    }
    presentTenseEnglish = ValueNotifier<String>(widget.wordInfo.english?.join(', ') ?? "");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.wordInfo.word ?? "Not defined"),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      floatingActionButton: _getFloatingActionButtonRow(context),
      body: BlocListener<WordCubit, WordState>(
        listener: (context, state) {
          if (state is WordSavedState || state is WordDeletedState) {
            String message = state is WordSavedState ? "Saved" : "Deleted";
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: state is WordSavedState
                    ? Colors.green
                    : Colors.redAccent,
                content: Text("${widget.wordInfo.word} $message."),
              ),
            );
            Navigator.of(context).pop(); // return to prior screen
          }
          if (state is ErrorWordState) {
            CommonWidgets.showErrorDialog(context, "Error", state.message);
          }
        },
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  _getWordWidget(widget.wordInfo),
                  const SizedBox(height: 8),
                  buildTypeChips(
                    context: context,
                    types: widget.wordInfo.type,
                    multipleSelectionAllowed: true,
                    onTypesChanged: onTypesChanged,
                  ),
                  const SizedBox(height: 8),
                  _getTranslatedLanguageWidget(englishValueNotifier: presentTenseEnglish),
                  const SizedBox(height: 8),
                  if (widget.wordInfo.type != null &&
                      widget.wordInfo.type!.contains("noun"))
                    ..._getPluralWidget(widget.wordInfo),
                  if (widget.wordInfo.type != null &&
                      widget.wordInfo.type!.contains("verb"))
                    _getWordTensesSection(widget.wordInfo),
                  const SizedBox(height: 8),
                  _getRulesWidget(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Row _getFloatingActionButtonRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // DELETE BUTTON
        FloatingActionButton.extended(
          heroTag: "delete_btn",
          // Unique tag to avoid transition errors
          onPressed: () => _confirmDeleteWord(context),
          label: Text(widget.wordInfo.previouslyEntered ? "Delete" : "Cancel"),
          icon: const Icon(Icons.delete_forever),
          backgroundColor: Colors.redAccent,
        ),
        const SizedBox(height: 12),
        // SAVE BUTTON (Existing)
        FloatingActionButton.extended(
          autofocus: true,
          heroTag: "save_btn",
          onPressed: () async {
            if (widget.wordInfo.previouslyEntered) {
              await context.read<WordCubit>().updateWord(widget.wordInfo);
            } else {
              await context.read<WordCubit>().saveWord(widget.wordInfo);
            }
          },
          label: Text(widget.wordInfo.previouslyEntered ? "Update" : "Save"),
          icon: const Icon(Icons.save),
        ),
      ],
    );
  }

  void _checkWord(WordInfo? wordInfo) {
    final parts = wordInfo?.word?.trim().split(' ') ?? [];
    if (parts.length >= 2 && wordInfo?.gender == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        CommonWidgets.showInfoDialog(
          context: context,
          title: 'Word Entry',
          msg:
              "Multiple words entered but no gender determined. The word will be used as is",
          button1Text: 'OK',
          button1Function: (() => Navigator.of(context).pop()),
        );
      });
    }
  }

  void onTypesChanged(List<String> types) {
    if (mounted) {
      setState(() {
        widget.wordInfo.type = types;
        if (types.isNotEmpty &&
            types.contains(WordType.noun.displayName) &&
            widget.wordInfo.gender == null) {
          widget.wordInfo.gender = _genders.first;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: Text(
                "Default gender of ${widget.wordInfo.gender} assigned. Change as needed",
              ),
            ),
          );
        } else if (types.isNotEmpty &&
            !types.contains(WordType.noun.displayName)) {
          widget.wordInfo.gender = null;
        }
      });
    }
  }

  Widget _getWordWidget(WordInfo? wordInfo) {
    String displayWord = wordInfo?.word ?? "";
    bool isNoun = wordInfo?.type?.contains("noun") == true;

    _checkWord(wordInfo);
    return WordSection(
      word: displayWord,
      onWordChanged: (newValue) {
        setState(() {
          wordInfo?.word = newValue;
        });
      },
      onWordFocusLost: () {
        if (wordInfo!.type!.contains("noun")) {
          if( widget.wordInfo.gender == null) {
          CommonWidgets.showErrorDialog(
            context,
            "Gender Missing",
            "Please add the noun gender to the word. The gender for a noun must be one of the following: "
                "${_genders.map((gender) => gender).join(', ')}",
          );
        } else if (!_genders.contains(wordInfo.gender)) {
          CommonWidgets.showErrorDialog(
            context,
            "Gender Error",
            " The gender for a noun must be one of the following: "
                "${_genders..map((gender) => gender).join(', ')}",
          );
        }
      }},
      selectedGender: (isNoun ? (wordInfo?.gender ?? _genders.first) : null),
      genders: (isNoun ? _genders.map((gender) => gender).toList() : null),
      onGenderChanged: (isNoun
          ? (newValue) {
              setState(() {
                wordInfo?.gender = newValue;
              });
            }
          : null),
    );
  }

  Widget _getTranslatedLanguageWidget({ValueNotifier<String>? englishValueNotifier}) {
    return TranslatedWordWidget(
      translatedLanguage: widget.wordInfo.english ?? <String>[],
      onChange: (newList) {
          widget.wordInfo.english = newList;
      },
      englishValueNotifier: englishValueNotifier,
    );
  }

  Widget _getWordTensesSection(WordInfo wordInfo) {
    if (wordInfo.tenses == null || wordInfo.tenses!.isEmpty) {
      wordInfo.tenses = [
        _createPresentTense(wordInfo.english?.join(", ") ?? ""),
      ];
    }
    return WordTensesWidget(
      tenses: wordInfo.tenses ?? <Tense>[],
      onTenseChanged: (index, updatedTense) {
          wordInfo.tenses![index] = updatedTense;
      },
    );
  }

  Tense _createPresentTense(String english) {
    return (Tense(tense: VerbTense.present.germanTense, english: english));
  }

  List<Widget> _getPluralWidget(WordInfo word) {
    List<Widget> widgets = [];
    widgets.add(const SizedBox(height: 8));
    widgets.add(
      PluralWidget(
        pluralNoun: word.plural ?? "",
        onPluralChanged: (newValue) {
          word.plural = newValue;
        },
        onFocusLost: () {
          if (word.plural == null || word.plural!.isEmpty) {
            CommonWidgets.showErrorDialog(
              context,
              "Missing plural form",
              "Please enter a plural form for ${word.plural}",
            );
          }
        },
      ),
    );
    return widgets;
  }

  Widget _getRulesWidget() {
    return WordRulesSection(
      rules: widget.wordInfo.rules ?? [],
      defaultWordType: widget.wordInfo.type?.first ?? "",
      onRulesChanged: (newList) {
        setState(() {
          widget.wordInfo.rules = newList;
        });
      },
    );
  }

  void _getGenders() {
    _genders = widget.getIt<WordCubit>().getGenders();
  }

  void _confirmDeleteWord(BuildContext context) {
    final cubit = context.read<WordCubit>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          widget.wordInfo.previouslyEntered ? "Delete Word?" : "Cancel",
        ),
        content: Text(
          "Are you sure you want to ${widget.wordInfo.previouslyEntered ? ("delete '${widget.wordInfo.word}' permanently?") : "not add the word?"}",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              if (widget.wordInfo.previouslyEntered) {
                cubit.deleteWord(widget.wordInfo);
              } else {
                // If it's a new word we're canceling, just pop the screen
                Navigator.pop(context);
              }
            },
            child: Text(
              widget.wordInfo.previouslyEntered ? "Delete" : "Don't Save",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
