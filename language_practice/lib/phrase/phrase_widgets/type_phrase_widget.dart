import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:language_practice/app/dialog_widgets.dart';
import 'package:language_practice/language_classes/phrase.dart';
import 'package:language_practice/phrase/phrase_bloc/phrase_cubit.dart';
import 'package:language_practice/phrase/phrase_bloc/phrase_state.dart';
import 'package:language_practice/phrase/phrase_widgets/phrase_widget.dart';
import 'package:language_practice/utility_widgets/row_with_label_and_child.dart';

class TypePhraseWidget extends StatefulWidget {
  const TypePhraseWidget({super.key});

  @override
  State<TypePhraseWidget> createState() => _TypePhraseWidgetState();
}

class _TypePhraseWidgetState extends State<TypePhraseWidget>
    with RowWithLabelAndChildMixin {
  final GetIt getIt = GetIt.instance;
  late TextEditingController _phraseController;
  final FocusNode _phraseInputFieldFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _phraseController = TextEditingController();
  }

  @override
  void dispose() {
    _phraseController.dispose();
    _phraseInputFieldFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  _createPhraseEntry();
  }

  Widget _createPhraseEntry() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize:MainAxisSize.min,
        children: [
          buildHorizontalRow(
            label: "Phrase:",
            child: TextField(
              focusNode: _phraseInputFieldFocusNode,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Enter a phrase'),
              controller: _phraseController,
              onSubmitted: _handlePhraseChange,
            ),
          ),
          _processPhraseListener(),
        ],
      ),
    );
  }

  void _handlePhraseChange(String value) {
    if (value.trim().isEmpty) return;

    // Phrases are handled more simply than words (no gender/type parsing usually)
    context.read<PhraseCubit>().getPhrase(
      spelledPhrase: value.trim(),
    );
  }

  Widget _processPhraseListener() {
    return BlocListener<PhraseCubit, PhraseState>(
      listener: (context, state) {
        // Handle phrase-specific success state
        if (state is LoadedPhraseInfoState) {
          _navigateToPhraseInfoWidget(context, state.phrase);
        }
        // Handle shared error state
        if (state is ErrorPhraseState) {
          CommonWidgets.showInfoDialog(
            context: context,
            title: 'Oops',
            msg: "An error occurred: ${state.message}",
            button1Text: 'OK',
            button1Function: (() => Navigator.pop(context)),
          );
        }
      },
      child: const SizedBox.shrink(),
    );
  }
  void _navigateToPhraseInfoWidget(BuildContext context, Phrase phrase) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (routeContext) => BlocProvider.value(
          value: BlocProvider.of<PhraseCubit>(context),
          child: PhraseWidget(phrase: phrase),
        ),
      ),
    );
    _phraseController.clear();
    _phraseInputFieldFocusNode.requestFocus();
  }
}