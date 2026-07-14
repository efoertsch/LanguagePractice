import 'package:flutter/material.dart';
import 'package:language_practice/phrase/phrase_widgets/phrase_widget.dart';
import 'package:language_practice/utility_widgets/row_with_label_and_child.dart';
import 'package:language_practice/word_screen/word_widgets/word_type_mixin.dart';

import '../../repository/language_classes/phrase.dart' show Phrase;

class PhraseLayoutWidget extends StatefulWidget {
  final Phrase phrase;
  final bool readOnly;

  const PhraseLayoutWidget({
    super.key,
    required this.phrase,
    this.readOnly = false, // 2. Defaulted to false for backward compatibility
  });

  @override
  State<PhraseLayoutWidget> createState() => _phraseLayoutWidgetState();
}

class _phraseLayoutWidgetState extends State<PhraseLayoutWidget>
    with RowWithLabelAndChildMixin, WordTypeMixin {
  late TextEditingController _phraseController;
  late TextEditingController _englishController;
  late TextEditingController _usageController;


  @override
  void initState() {
    super.initState();
    _phraseController = TextEditingController(text: widget.phrase.phrase);
    _phraseController.addListener(() => widget.phrase.phrase = _phraseController.text.trim());

    _englishController = TextEditingController(text: widget.phrase.english);
    _englishController.addListener(() => widget.phrase.english = _englishController.text.trim());

    _usageController = TextEditingController(text: widget.phrase.usage);
    _usageController.addListener(() => widget..phrase.usage = _usageController.text.trim());

  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PhraseWidget(
            label: "Phrase:",
            controller: _phraseController,
            autoFocus: true,
            inputDecoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          PhraseWidget(
            label: "English:",
            maxLines:2,
            controller: _englishController,
            inputDecoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          PhraseWidget(
            label: "Usage:",
            maxLines: 5,
           controller: _usageController,
            inputDecoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}
