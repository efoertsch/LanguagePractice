import 'package:flutter/material.dart';

import '../utility_widgets/row_with_label_and_child.dart'
    show RowWithLabelAndChildMixin;
import 'gender_selector.dart';

class WordSection extends StatefulWidget {
  final String word;
  final Function(String) onWordChanged;
  final Function() onWordFocusLost;
  final String? selectedGender;
  final List<String>? genders;
  final Function(String)? onGenderChanged;

  const WordSection({
    super.key,
    required this.word,
    required this.onWordChanged,
    required this.onWordFocusLost,
    required this.onGenderChanged,
    required this.selectedGender,
    required this.genders,
  });

  @override
  State<WordSection> createState() => _WordSectionState();
}

class _WordSectionState extends State<WordSection>
    with RowWithLabelAndChildMixin {
  late TextEditingController _wordController;
  late FocusNode _wordFocusNode;

  @override
  void initState() {
    super.initState();
    _wordController = TextEditingController(text: widget.word);
    _wordFocusNode = FocusNode();
    _wordFocusNode.addListener(() {
      if (!_wordFocusNode.hasFocus) {
        widget.onWordFocusLost();
      }
    });
  }

  @override
  void dispose() {
    _wordController.dispose();
    _wordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildHorizontalRow(
      label: "Word",
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
        children: [
          if (widget.genders != null) ...[
            Expanded(
              flex: 1, // Give gender field less space than the word
              child: GenderSelector(
                selectedGender: widget.selectedGender,
                genders: widget.genders!,
                onGenderChanged: widget.onGenderChanged!,
              ),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            flex: 9,
            child: TextField(
              focusNode: _wordFocusNode,
              controller: _wordController,
              onChanged: widget.onWordChanged,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

