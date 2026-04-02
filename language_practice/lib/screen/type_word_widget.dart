import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  String spelledWord = "";

  late TextEditingController _wordController;

  @override
  void initState() {
    super.initState();
    _wordController = TextEditingController(text: spelledWord);
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
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter a word',
              ),
              controller: _wordController,
              onChanged: _handleWordChange,
              onSubmitted: _checkWord,
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
      spelledWord = parts[0];
    } else {
      if (parts[0].length == 2) {
        spelledWord = parts[1];
      } else {
        CommonWidgets.showErrorDialog(
          context,
          "Entry Error",
          " ust type in the word without any gender or multiple spaces.",
        );
      }
    }
  }

  void _checkWord(String value) {
    context.read<WordCubit>().getWord(spelledWord);
  }

  Widget _processWordListener() {
    return BlocListener<WordCubit, WordState>(
      listener: (context, state) {
        if (state is LoadedWordState) {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => WordInfoWidget(wordInfo: state.word),
            ),
          );
        }
      },
      child: SizedBox.shrink(),
    );
  }
}
