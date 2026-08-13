import 'package:flutter/material.dart';
import 'package:language_practice/app/AppStateWidget.dart';
import 'package:language_practice/app/dialog_widgets.dart';
import 'package:language_practice/enums/word_enums.dart'
    show VerbTense, WordType;
import 'package:language_practice/repository/language_classes/word_info.dart';
import 'package:language_practice/word_screen/word_widgets/plural_widget.dart'
    show PluralWidget;
import 'package:language_practice/word_screen/word_widgets/translated_word_widget.dart';
import 'package:language_practice/word_screen/word_widgets/verb_tenses_widget.dart';
import 'package:language_practice/word_screen/word_widgets/word_rules.dart'
    show WordRulesSection;
import 'package:language_practice/word_screen/word_widgets/word_section.dart';
import 'package:language_practice/word_screen/word_widgets/word_type_mixin.dart';

class WordInfoWidgetLayout extends StatefulWidget {
  final WordInfo wordInfo;
  final List<String> genders;
  final bool editable;

  const WordInfoWidgetLayout({
    super.key,
    required this.wordInfo,
    required this.genders,
    this.editable = true,
  });

  @override
  State<WordInfoWidgetLayout> createState() => _WordInfoWidgetLayoutState();
}

class _WordInfoWidgetLayoutState extends AppStateWidget<WordInfoWidgetLayout>
    with WordTypeMixin, TickerProviderStateMixin {
  ValueNotifier<String>? presentTenseEnglish;

  @override
  void initState() {
    if (widget.editable) {
      if (widget.wordInfo.type != null &&
          widget.wordInfo.type!.contains(WordType.verb.displayName) &&
          widget.wordInfo.tenses == null) {
        widget.wordInfo.tenses = [
          Tense(
            tense: VerbTense.present.germanTense,
            english: widget.wordInfo.word,
            s1stPersonPlural: widget.wordInfo.word,
            s3rdPersonPlural: widget.wordInfo.word,
          ),
        ];
      }
      if (widget.editable) {
        presentTenseEnglish = ValueNotifier<String>(
          widget.wordInfo.english?.join(', ') ?? "",
        );
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        // Displays the Word and Gender Selection
        _getWordWidget(
          wordInfo: widget.wordInfo,
          genders: widget.genders,
          editable: widget.editable,
        ),
        const SizedBox(height: 8),
        // Displays the chips (noun, verb, etc.)
        buildTypeChips(
          context: context,
          types: widget.wordInfo.type,
          multipleSelectionAllowed: true,
          onTypesChanged: (widget.editable) ? onTypesChanged : null,
        ),

        const SizedBox(height: 8),
        _getTranslatedLanguageWidget(
          wordInfo: widget.wordInfo,
          englishValueNotifier: presentTenseEnglish,
        ),

        const SizedBox(height: 8),
        // Only show plurals if the word is marked as a noun
        if (widget.wordInfo.type != null &&
            widget.wordInfo.type!.contains("noun"))
          ..._getPluralWidget(word: widget.wordInfo, editable: widget.editable),

        // Only show conjugation table if the word is marked as a verb
        if (widget.wordInfo.type != null &&
            widget.wordInfo.type!.contains("verb"))
          _getWordTensesSection(
            wordInfo: widget.wordInfo,
            editable: widget.editable,
          ),

        const SizedBox(height: 8),
        // Displays linked grammar rules
        _getRulesWidget(wordInfo: widget.wordInfo, editable: widget.editable),
        const SizedBox(height: 100), // Bottom padding for FAB clearance
      ],
    );
  }

  Widget _getWordWidget({
    required WordInfo? wordInfo,
    required List<String> genders,
    bool editable = true,
  }) {
    String displayWord = wordInfo?.word ?? "";
    bool isNoun = wordInfo?.type?.contains("noun") == true;

    if (editable) _checkWord(wordInfo);
    return WordSection(
      word: displayWord,
      onWordChanged: (editable)
          ? (newValue) {
              setState(() {
                wordInfo?.word = newValue;
              });
            }
          : null,
      onWordFocusLost: (editable)
          ? () {
              if (wordInfo!.type != null) {
                if (wordInfo.type!.contains("noun")) {
                  if (wordInfo.gender == null) {
                    CommonWidgets.showErrorDialog(
                      context,
                      "Gender Missing",
                      "Please add the noun gender to the word. The gender for a noun must be one of the following: "
                          "${genders.map((gender) => gender).join(', ')}",
                    );
                  } else if (!genders.contains(wordInfo.gender)) {
                    CommonWidgets.showErrorDialog(
                      context,
                      "Gender Error",
                      " The gender for a noun must be one of the following: "
                          "${genders..map((gender) => gender).join(', ')}",
                    );
                  }
                }
              }
            }
          : null,
      selectedGender: (editable)
          ? (isNoun ? (wordInfo?.gender ?? genders.first) : null)
          : wordInfo?.gender ?? "",
      genders: (isNoun ? genders.map((gender) => gender).toList() : null),
      onGenderChanged: (editable)
          ? (isNoun
                ? (newValue) {
                    setState(() {
                      wordInfo?.gender = newValue;
                    });
                  }
                : null)
          : null,
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

  Widget _getTranslatedLanguageWidget({
    required WordInfo wordInfo,
    ValueNotifier<String>? englishValueNotifier,
  }) {
    return TranslatedWordWidget(
      translatedLanguage: wordInfo.english ?? <String>[],
      onChange: (englishValueNotifier != null)
          ? (newList) {
              wordInfo.english = newList;
            }
          : null,
      englishValueNotifier: englishValueNotifier,
    );
  }

  void onTypesChanged(List<String> types) {
    if (mounted) {
      setState(() {
        widget.wordInfo.type = types;
        if (types.isNotEmpty &&
            types.contains(WordType.noun.displayName) &&
            widget.wordInfo.gender == null) {
          widget.wordInfo.gender = widget.genders.first;
          showSnackBar(
            content:
                "Default gender of ${widget.wordInfo.gender} assigned. Change as needed",
          );
        } else if (types.isNotEmpty &&
            !types.contains(WordType.noun.displayName)) {
          widget.wordInfo.gender = null;
        }
      });
    }
  }

  Widget _getWordTensesSection({
    required WordInfo wordInfo,
    bool editable = true,
  }) {
    if (editable) {
      if (wordInfo.tenses == null || wordInfo.tenses!.isEmpty) {
        wordInfo.tenses = [
          _createPresentTense(wordInfo.english?.join(", ") ?? ""),
        ];
      }
    }
    if (!editable && (wordInfo.tenses == null || wordInfo.tenses!.isEmpty)) {
      return const SizedBox.shrink();
    }
    ;

    return WordTensesWidget(
      tenses: wordInfo.tenses ?? <Tense>[],
      onTenseChanged: editable
          ? (index, updatedTense) {
              wordInfo.tenses![index] = updatedTense;
            }
          : null,
    );
  }

  Tense _createPresentTense(String english) {
    return (Tense(tense: VerbTense.present.germanTense, english: english));
  }

  List<Widget> _getPluralWidget({
    required WordInfo word,
    bool editable = true,
  }) {
    List<Widget> widgets = [];
    widgets.add(const SizedBox(height: 8));
    widgets.add(
      PluralWidget(
        pluralNoun: word.plural ?? "",
        onPluralChanged: editable
            ? (newValue) {
                word.plural = newValue;
              }
            : null,
        onFocusLost: editable
            ? () {
                if (word.plural == null || word.plural!.isEmpty) {
                  CommonWidgets.showErrorDialog(
                    context,
                    "Missing plural form",
                    "Please enter a plural form for ${word.plural}",
                  );
                }
              }
            : null,
      ),
    );
    return widgets;
  }

  Widget _getRulesWidget({required WordInfo wordInfo, editable = true}) {
    return WordRulesSection(
      rules: wordInfo.rules ?? [],
      defaultWordType: wordInfo.type?.firstOrNull ?? "",
      onRulesChanged: editable
          ? (newList) {
              setState(() {
                wordInfo.rules = newList;
              });
            }
          : null,
    );
  }
}
