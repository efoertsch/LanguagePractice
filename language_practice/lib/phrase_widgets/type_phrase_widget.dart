import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:language_practice/screen/phrase_widget.dart'; // Assuming this exists
import 'package:language_practice/utility_widgets/row_with_label_and_child.dart';

import '../app/dialog_widgets.dart' show CommonWidgets;
import '../language_classes/phrase.dart'; // Updated for phrase
import '../word_bloc/word_cubit.dart';
import '../word_bloc/word_state.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Phrase Practice"),
        backgroundColor: Colors.green, // Differentiated color for phrases
        centerTitle: true,
      ),
      body: _createPhraseEntry(),
    );
  }

  Widget _createPhraseEntry() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
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
    context.read<WordCubit>().getPhrase(
      spelledPhrase: value.trim(),
    );
  }

  Widget _processPhraseListener() {
    return BlocListener<WordCubit, WordState>(
      listener: (context, state) {
        // Handle phrase-specific success state
        if (state is LoadedPhraseInfoState) {
          _navigateToPhraseInfoWidget(context, state.phraseInfo);
        }
        // Handle shared error state
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
      child: const SizedBox.shrink(),
    );
  }

  void _navigateToPhraseInfoWidget(BuildContext context, PhraseInfo phraseInfo) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (routeContext) => BlocProvider.value(
          value: BlocProvider.of<WordCubit>(context),
          child: PhraseInfoWidget(phraseInfo: phraseInfo),
        ),
      ),
    );
    _phraseController.clear();
    _phraseInputFieldFocusNode.requestFocus();
  }
}