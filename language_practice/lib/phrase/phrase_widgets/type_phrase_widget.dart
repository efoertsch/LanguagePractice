import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:language_practice/app/dialog_widgets.dart';
import 'package:language_practice/phrase/phrase_bloc/phrase_cubit.dart';
import 'package:language_practice/phrase/phrase_bloc/phrase_state.dart';
import 'package:language_practice/phrase/phrase_widgets/phrase_edit_widget.dart';
import 'package:language_practice/phrase/phrase_widgets/phrase_widget.dart' show PhraseWidget;
import 'package:language_practice/repository/language_classes/phrase.dart';
import 'package:language_practice/utility_widgets/row_with_label_and_child.dart';

class TypePhraseWidget extends StatefulWidget {
  const TypePhraseWidget({super.key});

  @override
  State<TypePhraseWidget> createState() => _TypePhraseWidgetState();
}

class _TypePhraseWidgetState extends State<TypePhraseWidget>
    with RowWithLabelAndChildMixin {
  final FocusNode _phraseInputFieldFocusNode = FocusNode();
  String _phrase = "";
  bool _isExpanded = false;


  List<Phrase> _listOfPhrases = [];

  @override
  void initState() {
    super.initState();

  }

  @override
  void dispose() {
    _phraseInputFieldFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  _createPhraseEntry();
  }

  Widget _createPhraseEntry() {
    return SizedBox(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Column(
            // Change to max so the Column takes up the full available height
            mainAxisSize: MainAxisSize.min,
            children: [
              _getPhraseWidget(),
              // This will now fill the rest of the window and scroll
              if (_listOfPhrases.isNotEmpty)
                _displayListOfPhrases(),
              _processPhraseListener(),
            ],
          ),
        ),
      ),
    );
  }

  PhraseWidget _getPhraseWidget() {
    return PhraseWidget(
            label: "Phrase:",
            text: _phrase,
            autoFocus: true,
            focusNode: _phraseInputFieldFocusNode,
            onSubmitted: _handlePhraseChange,
            onChange: _getMatchingPhrases,
          );
  }

  Widget _displayListOfPhrases() {
    return ConstrainedBox(
      // This provides the "boundary" the ListView needs to stop the error
      constraints: const BoxConstraints(maxHeight: 300),
      child: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Scrollbar(
          child: ListView.separated(
            // Keep shrinkWrap true when inside a ConstrainedBox
            shrinkWrap: true,
            itemCount: _listOfPhrases.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final phraseItem = _listOfPhrases[index];
              return ListTile(
                title: Text(
                  phraseItem.phrase!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  phraseItem.english?.toString() ?? "",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  _navigateToPhraseInfoWidget(context, phraseItem);
                },
              );
            },
          ),
        ),
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
        if (state is ListOfPhrasesState) {
          _listPhrases(state.listOfPhrases);
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
          child: PhraseEditWidget(phrase: phrase),
        ),
      ),
    );
    setState(() {
      // Reset the phrase input field
      _phrase = "";
    });
    _phraseInputFieldFocusNode.requestFocus();
  }

  void _getMatchingPhrases(String value) {
    if (value.isEmpty){
      setState(() {
        _listOfPhrases = [];
      });
      return;
    };
    if(value == " ") {
      value = "";
    }
    context.read<PhraseCubit>().listPhrases(value);

  }

  void _listPhrases(List<Phrase> listOfPhrases) {
    setState(() {
       _isExpanded = true;
      _listOfPhrases = listOfPhrases;});
  }
}