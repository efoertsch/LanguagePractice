import 'package:flutter/material.dart';
import '../language_classes/word_info.dart';
import '../word_widgets/word_type_mixin.dart';

/// A Stateless widget that combines word display with the type selection logic.
class WordDetailHeader extends StatelessWidget with WordTypeMixin {
  final WordInfo word;
  final bool multipleSelectionAllowed;
  final Function(List<String>) onTypesChanged;
  final Function(String) onWordChanged;

  const WordDetailHeader({
    super.key,
    required this.word,
    required this.onTypesChanged,
    required this.onWordChanged,
    this.multipleSelectionAllowed = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. The Word Input/Display Section
        // Using a TextField here as a placeholder for your 'WordSection' logic
        TextField(
          controller: TextEditingController(text: word.word)
            ..selection = TextSelection.fromPosition(
              TextPosition(offset: word.word?.length ?? 0),
            ),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          decoration: const InputDecoration(
            labelText: "Word",
            hintText: "Enter German word...",
            border: InputBorder.none,
          ),
          onChanged: onWordChanged,
        ),

        const SizedBox(height: 16),

        // 2. The Word Type Chips Section
        // This calls the method from WordTypeMixin
        buildTypeChips(
          context: context,
          types: word.type ?? [],
          multipleSelectionAllowed: multipleSelectionAllowed,
            onTypesChanged:   (List<String> newTypes) {
            onTypesChanged(newTypes);
          },
        ),

        const Divider(height: 32),
      ],
    );
  }
}