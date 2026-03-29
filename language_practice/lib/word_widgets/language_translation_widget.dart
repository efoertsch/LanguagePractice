import 'package:flutter/material.dart';
import 'package:language_practice/utility_widgets/row_with_label_and_child.dart' show RowWithLabelAndChildMixin;
import '../language_classes/word.dart' show Word;

class TranslatedLanguageWidget extends StatefulWidget {
  final Word word;
  final Function(List<String>) onEnglishChanged;

  const TranslatedLanguageWidget({
    super.key,
    required this.word,
    required this.onEnglishChanged,
  });

  @override
  State<TranslatedLanguageWidget> createState() =>
      _TranslatedLanguageWidgetState();
}

class _TranslatedLanguageWidgetState extends State<TranslatedLanguageWidget> with RowWithLabelAndChildMixin {
  late TextEditingController _englishController;

  @override
  void initState() {
    super.initState();

    // Convert the List<String> to a comma-separated string for the input field
    String englishText = widget.word.english?.join(', ') ?? '';
    _englishController = TextEditingController(text: englishText);
  }

  @override
  void dispose() {
    _englishController.dispose();
    super.dispose();
  }

  void _handleEnglishChange(String value) {
    // Split by comma, trim whitespace, and filter out empty entries
    List<String> newList = value
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    widget.onEnglishChanged(newList);
  }

  @override
  Widget build(BuildContext context) {
    return buildHorizontalRow(
      label: "English",
      child: TextField(
        controller: _englishController,
        onChanged: _handleEnglishChange,
        // decoration: const InputDecoration(
        //   border: OutlineInputBorder(),
        //   isDense: true,
        //   hintText: "Enter translations separated by commas",
        // ),
      ),
    );
  }
}
