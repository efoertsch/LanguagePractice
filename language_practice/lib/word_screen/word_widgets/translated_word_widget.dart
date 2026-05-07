import 'package:flutter/material.dart';
import 'package:language_practice/utility_widgets/row_with_label_and_child.dart' show RowWithLabelAndChildMixin;

class TranslatedWordWidget extends StatefulWidget {
  final List<String> translatedLanguage;
  final Function(List<String>) onTranslatedLanguageChanged;

  const TranslatedWordWidget({
    super.key,
    required this.translatedLanguage,
    required this.onTranslatedLanguageChanged,
  });

  @override
  State<TranslatedWordWidget> createState() =>
      _TranslatedWordWidgetState();
}

class _TranslatedWordWidgetState extends State<TranslatedWordWidget> with RowWithLabelAndChildMixin {
  late TextEditingController _englishController;

  @override
  void initState() {
    super.initState();
    // Convert the List<String> to a comma-separated string for the input field
    String englishText = widget.translatedLanguage.join(', ') ;
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
    widget.onTranslatedLanguageChanged(newList);
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
