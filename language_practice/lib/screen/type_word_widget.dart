import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:language_practice/screen/wordInfo_widget.dart';
import 'package:language_practice/utility_widgets/row_with_label_and_child.dart';

import '../app/dialog_widgets.dart' show CommonWidgets;
import '../word_bloc/word_cubit.dart';
import '../word_bloc/word_state.dart';

class TypeWordWidget extends StatefulWidget {
  const TypeWordWidget({super.key});

  @override
  State<TypeWordWidget> createState() => _TypeWordWidgetState();
}

class _TypeWordWidgetState extends State<TypeWordWidget>
    with RowWithLabelAndChildMixin {
  final GetIt getIt = GetIt.instance;
  late TextEditingController _wordController;
  String _spelledWord = "";
  List<String> _genders = [];
  String? _wordType;
  String? _gender;

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
      _wordType = null;
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
                builder: (routeContext) =>
                    BlocProvider.value(
                      value: BlocProvider.of<WordCubit>(context),
                      child: WordInfoWidget(wordInfo: state.word),
                    ),
              ));
              _wordController.text = "";
              _gender = null;
              _wordType = null;
          }
        if (state is ErrorWordState) {
          CommonWidgets.showInfoDialog(
            context: context,
            title: 'Oops',
            msg:
            "An error occurred: ${state.message}",
            button1Text: 'OK',
            button1Function: (() => Navigator.pop(context)),
          );
        }
          },
      child: SizedBox.shrink(),
    );
  }
}
