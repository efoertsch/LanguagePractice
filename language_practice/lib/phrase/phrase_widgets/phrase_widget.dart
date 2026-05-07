import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:language_practice/language_classes/phrase.dart';
import 'package:language_practice/phrase/phrase_bloc/phrase_cubit.dart';
import 'package:language_practice/phrase/phrase_bloc/phrase_state.dart';
import 'package:language_practice/utility_widgets/row_with_label_and_child.dart';
import 'package:language_practice/word_screen/word_widgets/word_type_mixin.dart';

class PhraseWidget extends StatefulWidget {
  final Phrase phrase;

  const PhraseWidget({super.key, required this.phrase});

  @override
  State<PhraseWidget> createState() => _phraseWidgetState();
}

class _phraseWidgetState extends State<PhraseWidget>
    with RowWithLabelAndChildMixin, WordTypeMixin {
  late TextEditingController _phraseController;
  late TextEditingController _englishController;
  late TextEditingController _usageController;
  late Phrase _phrase;

  @override
  void initState() {
    super.initState();
    _phrase = widget.phrase;
    _phraseController = TextEditingController(text: _phrase.phrase);
    _englishController = TextEditingController(text: _phrase.english);
    _usageController = TextEditingController(text: _phrase.usage);
  }

  @override
  void dispose() {
    _phraseController.dispose();
    _englishController.dispose();
    _usageController.dispose();
    super.dispose();
  }

  void _onSave() {
    _phrase.phrase = _phraseController.text.trim();
    _phrase.english = _englishController.text.trim();
    _phrase.usage = _usageController.text.trim();

    if (_phrase.previouslyEntered) {
      context.read<PhraseCubit>().updatePhrase(_phrase);
    } else {
      context.read<PhraseCubit>().savePhrase(_phrase);
    }
  }

  void _onDelete() {
    context.read<PhraseCubit>().deletePhrase(_phrase);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PhraseCubit, PhraseState>(
      listener: (context, state) {
        if (state is PhraseSavedState || state is PhraseDeletedState) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_phrase.previouslyEntered ? "Edit Phrase" : "New Phrase"),
          actions: [
            if (_phrase.previouslyEntered)
              IconButton(onPressed: _onDelete, icon: const Icon(Icons.delete)),
            IconButton(onPressed: _onSave, icon: const Icon(Icons.save)),
          ],
        ),
        floatingActionButton: _getFloatingActionButtonRow(context),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildHorizontalRow(
                label: "Phrase:",
                child: TextField(
                  controller: _phraseController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(height: 16),
              buildHorizontalRow(
                label: "English:",
                child: TextField(
                  controller: _englishController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Translations (comma separated)",
                  ),
                ),
              ),
              const SizedBox(height: 16),
              buildHorizontalRow(
                label: "Usage:",
                child: TextField(
                  controller: _usageController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Context or usage notes",
                  ),
                ),
              ),
            ],
          ),
        ),
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
            if (widget.phrase.previouslyEntered) {
              await context.read<PhraseCubit>().updatePhrase(widget.phrase);
            } else {
              await context.read<PhraseCubit>().savePhrase(widget.phrase);
            }
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
      builder: (dialogContext) =>
          AlertDialog(
            title: Text(
                widget.phrase.previouslyEntered ? "Delete Phrase?" : "Cancel"),
            content: Text(
              "Are you sure you want to ${widget.phrase.previouslyEntered
                  ? ("delete '${widget.phrase.phrase}' permanently?")
                  : "not add the phrase?"}",
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