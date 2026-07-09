import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:language_practice/repository/language_classes/word_info.dart';
import 'package:language_practice/utility_widgets/row_with_label_and_child.dart';
import 'package:language_practice/word_screen/word_bloc/word_cubit.dart'
    show WordCubit;
import 'package:language_practice/word_screen/word_bloc/word_state.dart';
import 'package:language_practice/word_screen/word_info_widget.dart';
import 'package:language_practice/word_screen/word_widgets/word_type_mixin.dart';

import '../app/dialog_widgets.dart' show CommonWidgets;


class TypeWordWidget extends StatefulWidget {
  late final String? _defaultWordType;

  TypeWordWidget({super.key, String? defaultWordType}) {
    _defaultWordType = defaultWordType;
  }

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
  final FocusNode _wordInputFieldFocusNode = FocusNode();
  List<WordInfo> _listOfWords = [];
  late ScrollController _listScrollController;


  @override
  void initState() {
    super.initState();
    _wordController = TextEditingController(text: _spelledWord);
    _genders = context.read<WordCubit>().getGenders();
    _listScrollController = ScrollController();
    _wordController.addListener(() {
      _spelledWord = _wordController.text;
      if (_spelledWord.trim().isEmpty) {
        setState(() => _listOfWords = []);
      } else {
        if (_spelledWord.length >= 1) {
          context.read<WordCubit>().listWords(_spelledWord);
        }
      }
    });
  }

  @override
  void dispose() {
    _listScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _createWordEntry();
  }

  Widget _createWordEntry() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _getWordWidget(),
          if (_listOfWords.isNotEmpty)
            _displayListOfWords(),
          _processWordListener(),
        ],
      ),
    );
  }

  Widget _getWordWidget() {
    return buildHorizontalRow(
          label: "Word:",
          child: TextField(
            focusNode: _wordInputFieldFocusNode,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Enter a word'),
            controller: _wordController,
            onSubmitted: _handleWordChange,
          ),
        );
  }

  void _handleWordChange(String value) {
    final parts = value.trim().split(' ');
    if (parts.length == 1) {
      _spelledWord = value;
      _wordType = widget._defaultWordType;
      _gender = null;
    } else {
      if (parts.length == 2) {
        if (_genders.contains(parts[0].toLowerCase())) {
          _wordType = "noun";
          _gender = parts[0].toLowerCase();
          _spelledWord = parts[1];
        } else {
          _spelledWord = value;
          _wordType = null;
          _gender = null;
        }
      }
    }

    context.read<WordCubit>().getWord(
      spelledWord: _spelledWord,
      gender: _gender,
      type: _wordType,
    );
  }

  Widget _displayListOfWords() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 300),
      child: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Material(
          color: Colors.transparent,
          child: Scrollbar(
            controller: _listScrollController,
            thumbVisibility: true,
            child: ListView.separated(
              controller: _listScrollController,
              shrinkWrap: true,
              itemCount: _listOfWords.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final wordItem = _listOfWords[index];

                // Formatting: "der Hund" or just "gehen"
                String displayTitle = wordItem.word ?? "";
                if (wordItem.gender != null && wordItem.gender!.isNotEmpty) {
                  displayTitle = "${wordItem.gender} $displayTitle";
                }

                return ListTile(
                  title: Text(
                    displayTitle,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    wordItem.english?.join(", ") ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () {
                    _handleWordChange( wordItem.word ?? "");
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }


  Widget _processWordListener() {
    return BlocListener<WordCubit, WordState>(
      listener: (context, state) {
        if (state is LoadedWordInfoState) {
          _navigateToWordInfoWidget(context, state.wordInfo);
        }
        if (state is ListOfWordsState) {
          setState(() {
            _listOfWords = state
                .listOfWords; // 'words' is the List<WordInfo> from your Cubit
          });
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

  void _navigateToWordInfoWidget(BuildContext context,
      WordInfo wordInfo) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (routeContext) =>
            BlocProvider.value(
              value: BlocProvider.of<WordCubit>(context),
              child: WordInfoWidget(wordInfo: wordInfo),
            ),
      ),
    );
    _wordController.text = "";
    _gender = null;
    _wordType = null;
    _wordInputFieldFocusNode.requestFocus();
  }
}
