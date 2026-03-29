import 'package:flutter/material.dart';
import '../utility_widgets/row_with_label_and_child.dart'
    show RowWithLabelAndChildMixin;

class WordSection extends StatefulWidget {
  final String wordWithGender;
  final Function(String) onWordChanged;

  const WordSection({
    super.key,
    required this.wordWithGender,
    required this.onWordChanged,
  });

  @override
  State<WordSection> createState() => _WordSectionState();
}

class _WordSectionState extends State<WordSection>
    with RowWithLabelAndChildMixin {
  late TextEditingController _wordController;

  @override
  void initState() {
    super.initState();
    _wordController = TextEditingController(text: widget.wordWithGender);
  }

  @override
  void dispose() {
    _wordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildHorizontalRow(
      label: "Word",
      child: TextField(
        maxLines: 1,
        controller: _wordController,
        onChanged: widget.onWordChanged,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        // decoration: const InputDecoration(
        //   border: OutlineInputBorder(),
        //   isDense: true,
        // ),
      ),
    );
  }
}
