import 'package:flutter/material.dart';
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
  late Phrase _phrase;

  @override
  void initState() {
    super.initState();
    _phrase = widget.phrase;

    _phraseController = TextEditingController(text: _phrase.phrase);
    _phraseController.addListener(() => widget.phrase.phrase = _phraseController.text);

    // Check if english is a List or String and handle accordingly
    if (_phrase.english is List) {
      _englishController = TextEditingController(text: (_phrase.english as List).join(", "));
    } else {
      _englishController = TextEditingController(text: _phrase.english?.toString() ?? "");
    }
    _englishController.addListener(() => widget.phrase.english = _englishController.text);

    _usageController = TextEditingController(text: _phrase.usage);
    _usageController.addListener(()=> widget.phrase.usage = _usageController.text);
  }

  @override
  void dispose() {
    _phraseController.dispose();
    _englishController.dispose();
    _usageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildHorizontalRow(
            label: "Phrase:",
            child: TextField(
              controller: _phraseController,
              readOnly: widget.readOnly,
              minLines: 1,
              maxLines: 5,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
          ),
          const SizedBox(height: 16),
          buildHorizontalRow(
            label: "English:",
            child: TextField(
              controller: _englishController,
              minLines: 1,
              maxLines: 5,
              readOnly: widget.readOnly,
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
              readOnly: widget.readOnly, // 5. Applied readOnly
              minLines: 1,
              maxLines: 10,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Context or usage notes",
              ),
            ),
          ),
        ],
      ),
    );
  }

}
