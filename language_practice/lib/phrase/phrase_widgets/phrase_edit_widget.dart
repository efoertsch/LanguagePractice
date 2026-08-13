import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:language_practice/phrase/phrase_bloc/phrase_cubit.dart';
import 'package:language_practice/phrase/phrase_bloc/phrase_state.dart';
import 'package:language_practice/phrase/phrase_widgets/phrase_layout_widget.dart';
import 'package:language_practice/repository/language_classes/phrase.dart';
import 'package:language_practice/utility_widgets/row_with_label_and_child.dart';
import 'package:language_practice/word_screen/word_widgets/word_type_mixin.dart';

import '../../app/AppStateWidget.dart';
import '../../app/dialog_widgets.dart' show CommonWidgets;

class PhraseEditWidget extends StatefulWidget {
  final Phrase phrase;

  const PhraseEditWidget({super.key, required this.phrase});

  @override
  State<PhraseEditWidget> createState() => _phraseEditWidgetState();
}

class _phraseEditWidgetState extends AppStateWidget<PhraseEditWidget>
    with RowWithLabelAndChildMixin, WordTypeMixin {
  void _onSave() {
    context.read<PhraseCubit>().savePhrase(widget.phrase);
  }

  void _onDelete() {
    context.read<PhraseCubit>().deletePhrase(widget.phrase);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.phrase.previouslyEntered ? "Edit Phrase" : "New Phrase",
        ),
        actions: [
          if (widget.phrase.previouslyEntered)
            IconButton(onPressed: _onDelete, icon: const Icon(Icons.delete)),
          IconButton(onPressed: _onSave, icon: const Icon(Icons.save)),
        ],
      ),
      floatingActionButton: _getFloatingActionButtonRow(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: BlocListener<PhraseCubit, PhraseState>(
        listener: (context, state) {
          if (state is PhraseSavedState || state is PhraseDeletedState) {
            String message = state is PhraseSavedState ? "Saved" : "Deleted";
            showSnackBar(
              backgroundColor: state is PhraseSavedState
                  ? Colors.green
                  : Colors.redAccent,
              content: "${widget.phrase.phrase} $message.",
            );
            Navigator.of(context).pop(); // return to prior screen
          }
          if (state is ErrorPhraseState) {
            CommonWidgets.showErrorDialog(context, "Error", state.message);
          }
        },
        child: PhraseLayoutWidget(phrase: widget.phrase),
      ),
    );
  }

  Widget _getFloatingActionButtonRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // DELETE/CANCEL BUTTON
        FloatingActionButton.extended(
          heroTag: "delete_phrase_btn",
          onPressed: () => _confirmDeletePhrase(context),
          label: Text(widget.phrase.previouslyEntered ? "Delete" : "Cancel"),
          icon: const Icon(Icons.delete_forever),
          backgroundColor: Colors.redAccent,
        ),
        // SAVE/UPDATE BUTTON
        FloatingActionButton.extended(
          autofocus: true,
          heroTag: "save_phrase_btn",
          onPressed: () async {
            await context.read<PhraseCubit>().savePhrase(widget.phrase);
          },
          label: Text(widget.phrase.previouslyEntered ? "Update" : "Save"),
          icon: const Icon(Icons.save),
        ),
      ],
    );
  }

  void _confirmDeletePhrase(BuildContext context) {
    final cubit = context.read<PhraseCubit>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          widget.phrase.previouslyEntered ? "Delete Phrase?" : "Cancel",
        ),
        content: Text(
          "Are you sure you want to ${widget.phrase.previouslyEntered ? ("delete '${widget.phrase.phrase}' permanently?") : "not add the phrase?"}",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              if (widget.phrase.previouslyEntered) {
                cubit.deletePhrase(widget.phrase);
              } else {
                Navigator.pop(context);
              }
            },
            child: Text(
              widget.phrase.previouslyEntered ? "Delete" : "Don't Save",
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
