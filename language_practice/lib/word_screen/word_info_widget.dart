import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:language_practice/app/dialog_widgets.dart';
import 'package:language_practice/repository/language_classes/word_info.dart';
import 'package:language_practice/word_screen/word_bloc/word_cubit.dart';
import 'package:language_practice/word_screen/word_bloc/word_state.dart';
import 'package:language_practice/word_screen/word_widgets/word_info_layout_widget.dart';
import 'package:language_practice/word_screen/word_widgets/word_type_mixin.dart'
    show WordTypeMixin;

import '../enums/word_enums.dart' show WordType, VerbTense;

class WordInfoWidget extends StatefulWidget {
  final WordInfo wordInfo;
  final getIt = GetIt.instance;

  WordInfoWidget({super.key, required this.wordInfo});

  @override
  State<WordInfoWidget> createState() => _WordInfoWidgetState();
}

class _WordInfoWidgetState extends State<WordInfoWidget>
    with TickerProviderStateMixin, WordTypeMixin {
  List<String> _genders = [];
  late final ValueNotifier<String> presentTenseEnglish;

  @override
  void initState() {
    _getGenders();
    if (widget.wordInfo.type != null
        && widget.wordInfo.type!.contains(WordType.verb.displayName)
        && widget.wordInfo.tenses == null){
      widget.wordInfo.tenses = [Tense(tense: VerbTense.present.germanTense,
          english: widget.wordInfo.word,
          s1stPersonPlural: widget.wordInfo.word,
          s3rdPersonPlural: widget.wordInfo.word
      )];
    }
    presentTenseEnglish = ValueNotifier<String>(widget.wordInfo.english?.join(', ') ?? "");
    super.initState();
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
              child: WordInfoWidgetLayout(
                wordInfo: widget.wordInfo,
                genders: _genders
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
          autofocus: true,
          heroTag: "save_btn",
          onPressed: () async {
              await context.read<WordCubit>().saveWord(widget.wordInfo);
          },
          label: Text(widget.wordInfo.previouslyEntered ? "Update" : "Save"),
          icon: const Icon(Icons.save),
        ),
      ],
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
