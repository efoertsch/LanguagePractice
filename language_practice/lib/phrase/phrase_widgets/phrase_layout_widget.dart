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
  late Phrase _phrase;

  @override
  void initState() {
    super.initState();
    _phrase = widget.phrase;
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
            text: _phrase.phrase ?? "",
            autoFocus: true,
            inputDecoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            onChange: (value) => _phrase.phrase = value,
          ),
          const SizedBox(height: 16),
          PhraseWidget(
            label: "English:",
            maxLines:2,
            text: _phrase.english ?? "",
            onChange: (value) => _phrase.english = value,
            inputDecoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          PhraseWidget(
            label: "Usage:",
            maxLines: 5,
            text: _phrase.usage ?? "",
            onChange: (value) => _phrase.usage = value,
            inputDecoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}
