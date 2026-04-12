import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:language_practice/screen/word_info_widget.dart';
import 'package:language_practice/screen/word_quiz_screen.dart';
import 'package:language_practice/utility_widgets/row_with_label_and_child.dart';
import 'package:language_practice/word_widgets/word_type_mixin.dart';

import '../app/dialog_widgets.dart' show CommonWidgets;
import '../enums/word_enums.dart';
import '../word_bloc/word_cubit.dart';
import '../word_bloc/word_state.dart';

class TypeWordWidget extends StatefulWidget {
  const TypeWordWidget({super.key});

  @override
  State<TypeWordWidget> createState() => _TypeWordWidgetState();
}

class _TypeWordWidgetState extends State<TypeWordWidget>
    with RowWithLabelAndChildMixin, WordTypeMixin {
  final GetIt getIt = GetIt.instance;
  late TextEditingController _wordController;
  String _spelledWord = "";
  List<String> _genders = [];
  String? _wordType;
  String? _gender;
  String? _defaultWordType;

  @override
  void initState() {
    super.initState();
    _wordController = TextEditingController(text: _spelledWord);
    _genders = context.read<WordCubit>().getGenders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Language Practice"),
        backgroundColor: Colors.blue,
        centerTitle: true,
        actions: [_getMenu(context)],
      ),
      body: _createWordEntry(),
    );
  }

  Widget _createWordEntry() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          buildHorizontalRow(
            label: "Word:",
            child: TextField(
              decoration: const InputDecoration(hintText: 'Enter a word'),
              controller: _wordController,
              onSubmitted: _handleWordChange,
            ),
          ),
          _processWordListener(),
        ],
      ),
    );
  }

  void _handleWordChange(String value) {
    final parts = value.split(' ');
    if (parts.length == 1) {
      _spelledWord = value;
      _wordType = _defaultWordType;
      _gender = null;
    } else {
      if (parts.length == 2) {
        if (_genders.contains(parts[0].toLowerCase())) {
          _wordType = "noun";
          _gender = parts[0].toLowerCase();
          _spelledWord = parts[1];
        } else {
          _wordType = null;
          _gender = null;
          CommonWidgets.showInfoDialog(
            context: context,
            title: 'Word Entry',
            msg:
                "Multiple words entered but no gender determined. The word will be used as is",
            button1Text: 'OK',
            button1Function: (() => _spelledWord = value),
          );
        }
      }
    }

    context.read<WordCubit>().getWord(
      spelledWord: _spelledWord,
      gender: _gender,
      type: _wordType,
    );
  }

  Widget _processWordListener() {
    return BlocListener<WordCubit, WordState>(
      listener: (context, state) {
        if (state is LoadedWordInfoState) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (routeContext) => BlocProvider.value(
                value: BlocProvider.of<WordCubit>(context),
                child: WordInfoWidget(wordInfo: state.word),
              ),
            ),
          );
          _wordController.text = "";
          _gender = null;
          _wordType = null;
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

  Widget _getMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.menu),
      onSelected: (value) {
        if (value != "set_word_type"){
        // Pass the value (either 'german' or 'english') to the navigation method
        _navigateToQuiz(context, value);
      }},
      itemBuilder: (BuildContext context) => [
        const PopupMenuItem<String>(
          value: 'german',
          child: Row(
            children: [
              Icon(Icons.quiz, color: Colors.black54),
              SizedBox(width: 8),
              Text("Quiz German"),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'english',
          child: Row(
            children: [
              Icon(Icons.translate, color: Colors.black54),
              SizedBox(width: 8),
              Text("Quiz English"),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'set_word_type',
          child: Text('Set default Word Type'),
          onTap: _getWordTypesDisplay,
        ),
      ],
    );
  }

  Future<void> _getWordTypesDisplay() {
    return displayWordTypes(
      context,
      [_defaultWordType ?? "adjective"] ,
      false,
      (List<String> newTypes) {
        _defaultWordType = newTypes[0] ?? " adjective";
      },
    );
  }

  void _navigateToQuiz(BuildContext context, String languageMode) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (routeContext) => BlocProvider.value(
          value: BlocProvider.of<WordCubit>(context),
          child: WordQuiz(
            quizLanguage: languageMode, // Passing 'german' or 'english'
          ),
        ),
      ),
    );
  }
}
