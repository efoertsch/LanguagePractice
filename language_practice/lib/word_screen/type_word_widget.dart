import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:language_practice/repository/language_classes/word_info.dart';
import 'package:language_practice/utility_widgets/row_with_label_and_child.dart';
import 'package:language_practice/word_screen/word_bloc/word_cubit.dart' show WordCubit;
import 'package:language_practice/word_screen/word_bloc/word_state.dart';
import 'package:language_practice/word_screen/word_info_widget.dart';
import 'package:language_practice/word_screen/word_widgets/word_type_mixin.dart';

import '../app/dialog_widgets.dart' show CommonWidgets;


class TypeWordWidget extends StatefulWidget {
  late final String? _defaultWordType;
  TypeWordWidget({super.key, String? defaultWordType}){
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

  @override
  void initState() {
    super.initState();
    _wordController = TextEditingController(text: _spelledWord);
    _genders = context.read<WordCubit>().getGenders();
  }

  @override
  Widget build(BuildContext context) {
    return  _createWordEntry();
  }

  Widget _createWordEntry() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize:MainAxisSize.min,
        children: [
          buildHorizontalRow(
            label: "Word:",
            child: TextField(
              focusNode: _wordInputFieldFocusNode,
              autofocus: true,
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

  Widget _processWordListener() {
    return BlocListener<WordCubit, WordState>(
      listener: (context, state) {
        if (state is LoadedWordInfoState) {
          _navigateToWordInfoWidget(context, state.wordInfo);
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

  void _navigateToWordInfoWidget(BuildContext context, WordInfo wordInfo) async {
   await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (routeContext) => BlocProvider.value(
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
