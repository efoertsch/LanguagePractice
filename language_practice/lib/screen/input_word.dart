import 'package:flutter/material.dart';
import 'package:language_practice/app/dialog_widgets.dart';
import 'package:language_practice/language_classes/word.dart';
import 'package:language_practice/language_widgets/word_type_mixin.dart';
import 'package:language_practice/repository/language_repository.dart';

import '../enums/word_enums.dart' show GermanGender;
import '../language_widgets/english_translation_section.dart'
    show EnglishTranslationSection;
import '../language_widgets/plural_widget.dart';
import '../language_widgets/verb_tenses_widget.dart';
import '../language_widgets/word_rules.dart';
import '../language_widgets/word_section.dart' show WordSection;
import '../main.dart' show getIt;

class InputWordScreen extends StatefulWidget {
  final String stringWord;

  InputWordScreen({super.key, required this.stringWord});

  @override
  State<InputWordScreen> createState() => _InputWordScreenState();
}

class _InputWordScreenState extends State<InputWordScreen>
    with TickerProviderStateMixin, WordTypeMixin {
  Word word = Word();
  bool _isLoading = true;

  // Controllers to handle text input
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _getWord(widget.stringWord);
    // Initialize controllers with existing data
    _initControllers();
  }

  // Inside _WordDetailScreenState

  void _initControllers() async {
    _controllers['word'] = TextEditingController(text: word.word);
    _controllers['plural'] = TextEditingController(text: word.plural);
    // 1. Initialize translation controllers
    if (word.english != null) {
      for (int i = 0; i < word.english!.length; i++) {
        _controllers['english_$i'] = TextEditingController(
          text: word.english![i],
        );
      }
    }

    // 2. Initialize Tense controllers
    if (word.tenses != null) {
      for (int t = 0; t < word.tenses!.length; t++) {
        final tense = word.tenses![t];
        // We use a naming convention: "tense_{index}_{field}"
        _controllers['tense_${t}_name'] = TextEditingController(
          text: tense.tense,
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
    if (_isLoading) {
      return CircularProgressIndicator();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(word.word ?? "Not defined"),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      //backgroundColor: const Color(0xFF0D0D1A),
      // Added a Floating Action Button to "Save"
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => /* Handle Save Logic Here */ {},
        //backgroundColor: const Color(0xFF4A4AFF),
        label: const Text("Save Changes"),
        icon: const Icon(Icons.save),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                _getWordWidget(word),
                const SizedBox(height: 8),
                _getEnglishTranslationWidget(),
                const SizedBox(height: 8),
                if (word.type != null && word.type!.indexOf("noun") >= 0)
                  ..._getPluralWidget(word),
                if (word.type != null) buildTypeChips(context, word.type!, true,onTypesChanged),
                if (word.type != null && word.type!.indexOf("verb") >= 0)
                  _getWordTensesSection(),
                const SizedBox(height: 8),
                _getRulesWidget(),
                const SizedBox(height: 100), // Extra space for FAB
              ],
            ),
          ),
        ],
      ),
    );
  }

  void onTypesChanged(List<String> types) {
    if (mounted) {
      setState(() {
        word.type = types;
      });
    };
  }



  Future<void> _getWord(String stringWord) async {
    final LanguageRepository languageRepository = getIt<LanguageRepository>();
    word = await languageRepository.getWord(stringWord);
    // Ensure the widget is still in the tree before calling setState
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _getWordWidget(Word word) {
    String displayWord = word.word ?? "";
    bool isNoun = false;
    if (word.type?.contains("noun") == true) {
      isNoun = true;
      displayWord = "${word.gender ?? ""} $displayWord";
    }
    ;

    return WordSection(
      wordWithGender: displayWord,
      onWordChanged: (newValue) {
        setState(() {
          // new value ca
          if (isNoun) {
            final parts = newValue.split(' ');
            if (parts.length == 1) {
              CommonWidgets.showErrorDialog(
                context,
                "Gender Missing",
                "Please add the noun gender to the word. The gender for a noun must be one of the following: "
                    "${GermanGender.values.map((gender) => gender.name).join(
                    ', ')}",
              );
            } else {
              if (parts[0].length == 3 &&
                  GermanGender.values.any(
                        (gender) => gender.name == parts[0],
                  )) {
                word.gender = parts[0];
                word.word = parts[1];
              } else {
                CommonWidgets.showErrorDialog(
                  context,
                  "Gender Error",
                  " The gender for a noun must be one of the following: "
                      "${GermanGender.values.map((gender) => gender.name).join(
                      ', ')}",
                );
              }
            }
          } else
            word.word = newValue;
        });
      },
    );
  }

  Widget _getEnglishTranslationWidget() {
    return EnglishTranslationSection(
      word: word,
      onEnglishChanged: (newList) {
        setState(() {
          word.english = newList;
        });
      },
    );
  }

  Widget _getWordTensesSection() {
    if (word.tenses != null) {
      return WordTensesWidget(
        tenses: word.tenses!,
        onTenseChanged: (index, updatedTense) {
          setState(() {
            word.tenses![index] = updatedTense;
          });
        },
      );
    }
    return SizedBox.shrink();
  }

  List<Widget> _getPluralWidget(Word word) {
    List<Widget> widgets = [];
    widgets.add(const SizedBox(height: 8));
    widgets.add(
      PluralWidget(
        pluralNoun: word.plural ?? "",
        onPluralChanged: (newValue) {
          setState(() {
            if (newValue.isEmpty) {
              CommonWidgets.showErrorDialog(
                context,
                "Missing plural form",
                "Please enter a plural form for ${word.plural}",
              );
            }
            word.plural = newValue;
          });
        },
      ),
    );
    return widgets;
  }


  Widget _getRulesWidget() {
    return WordRulesSection(
      rules: word.rules ?? [],
      onRulesChanged: (newList) {
        setState(() {
          word.rules = newList;
        });
      },
    );
  }
}
