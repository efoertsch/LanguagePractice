import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:language_practice/app/dialog_widgets.dart';
import 'package:language_practice/language_classes/word_info.dart';

import '../enums/word_enums.dart' show WordType;
import '../word_bloc/word_cubit.dart';
import '../word_bloc/word_state.dart';
import '../word_widgets/plural_widget.dart';
import '../word_widgets/translated_word_widget.dart';
import '../word_widgets/verb_tenses_widget.dart';
import '../word_widgets/word_rules.dart';
import '../word_widgets/word_section.dart' show WordSection;
import '../word_widgets/word_type_mixin.dart';

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
  final Map<String, TextEditingController> _controllers = {};
  List<String> _genders = [];

  @override
  void initState() {
    super.initState();
    _initControllers();
    _getGenders();
  }

  void _initControllers() async {
    _controllers['word'] = TextEditingController(text: widget.wordInfo.word);
    _controllers['plural'] = TextEditingController(
      text: widget.wordInfo.plural,
    );
    // 1. Initialize translation controllers
    if (widget.wordInfo.english != null) {
      for (int i = 0; i < (widget.wordInfo.english!.length); i++) {
        _controllers['english_$i'] = TextEditingController(
          text: widget.wordInfo.english![i],
        );
      }
    }

    // 2. Initialize Tense controllers
    if (widget.wordInfo.tenses != null) {
      for (int t = 0; t < widget.wordInfo.tenses!.length; t++) {
        final tense = widget.wordInfo.tenses![t];
        // We use a naming convention: "tense_{index}_{field}"
        _controllers['tense_${t}_name'] = TextEditingController(
          text: tense.tense,
        );
        _controllers['english_${t}'] = TextEditingController(
          text: tense.english,
        );
        _controllers['tense_${t}_s1'] = TextEditingController(
          text: tense.s1stPersonSingular,
        );
        _controllers['tense_${t}_s2'] = TextEditingController(
          text: tense.s2ndPersonSingular,
        );
        _controllers['tense_${t}_s3'] = TextEditingController(
          text: tense.s3rdPersonSingular,
        );
        _controllers['tense_${t}_p1'] = TextEditingController(
          text: tense.s1stPersonPlural,
        );
        _controllers['tense_${t}_p2'] = TextEditingController(
          text: tense.s2ndPersonPlural,
        );
        _controllers['tense_${t}_p3'] = TextEditingController(
          text: tense.s3rdPersonPlural,
        );
        _controllers['tense_${t}_helper'] = TextEditingController(
          text: tense.helperVerb,
        );
        _controllers['tense_${t}_pastP'] = TextEditingController(
          text: tense.pastParticiple,
        );
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
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
                    context:context,
                    types: widget.wordInfo.type,
                   multipleSelectionAllowed:  true,
                    onTypesChanged: onTypesChanged,
                  ),
                  const SizedBox(height: 8),
                  _getTranslatedLanguageWidget(),
                  const SizedBox(height: 8),
                  if (widget.wordInfo.type != null &&
                      widget.wordInfo.type!.contains("noun"))
                    ..._getPluralWidget(widget.wordInfo),
                  if (widget.wordInfo.type != null &&
                      widget.wordInfo.type!.contains("verb"))
                    _getWordTensesSection(),
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

    return WordSection(
      word: displayWord,
      onWordChanged: (newValue) {
        setState(() {
          wordInfo?.word = newValue;
        });
      },
      onWordFocusLost: () {
        if (widget.wordInfo.gender == null) {
          CommonWidgets.showErrorDialog(
            context,
            "Gender Missing",
            "Please add the noun gender to the word. The gender for a noun must be one of the following: "
                "${_genders.map((gender) => gender).join(', ')}",
          );
        } else if (!_genders.contains(wordInfo!.gender)) {
          CommonWidgets.showErrorDialog(
            context,
            "Gender Error",
            " The gender for a noun must be one of the following: "
                "${_genders..map((gender) => gender).join(', ')}",
          );
        }
      },
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

  Widget _getTranslatedLanguageWidget() {
    return TranslatedWordWidget(
      translatedLanguage: widget.wordInfo.english ?? <String>[],
      onTranslatedLanguageChanged: (newList) {
        setState(() {
          widget.wordInfo.english = newList;
        });
      },
    );
  }

  Widget _getWordTensesSection() {
    if (widget.wordInfo.tenses != null) {
      return WordTensesWidget(
        tenses: widget.wordInfo.tenses ?? <Tense>[],
        onTenseChanged: (index, updatedTense) {
          setState(() {
            widget.wordInfo.tenses![index] = updatedTense;
          });
        },
      );
    }
    return SizedBox.shrink();
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
