import 'package:flutter/material.dart';
import 'package:language_practice/language_classes/word.dart';
import '../word_widgets/word_type_mixin.dart';
import '../word_widgets/wordtype_selection_dialog.dart';

class WordRulesSection extends StatelessWidget with WordTypeMixin {
  final List<Rules> rules;
  final Function(List<Rules>) onRulesChanged;

  const WordRulesSection({
    super.key,
    required this.rules,
    required this.onRulesChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Rules",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        ...rules.asMap().entries.map((entry) {
          int index = entry.key;
          Rules ruleItem = entry.value;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Rule Type (e.g., "Dative", "Sentence structure")
                      Expanded(
                        flex: 2,
                        child: buildTypeChips(context,  [ruleItem.type! ], false, (
                          List<String> selectedTypes,
                        ) {
                          // Since ruleItem.type is a String but buildTypeChips returns a List,
                          // we take the first selected item.
                          ruleItem.type = selectedTypes.isNotEmpty
                              ? selectedTypes.first
                              : "";
                          onRulesChanged(rules);
                        }),
                      ),
                      const SizedBox(width: 8),
                      // Delete button
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent,
                        ),
                        onPressed: () {
                          List<Rules> newList = List.from(rules);
                          newList.removeAt(index);
                          onRulesChanged(newList);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // The Rule Content
                  TextFormField(
                    initialValue: ruleItem.rule,
                    maxLines: null, // Allows multiline rules
                    decoration: const InputDecoration(
                      labelText: "Rule Description",
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) {
                      ruleItem.rule = val;
                      onRulesChanged(rules);
                    },
                  ),
                ],
              ),
            ),
          );
        }).toList(),

        // Add Rule Button
        TextButton.icon(
          onPressed: ()async  {
            final List<String>? results = await showWordTypeSelector(
                context,
                [],false
            );
            if (results != null) {
              onRulesChanged([...rules, Rules(type: results[0], rule: "")]);
            }
          },
          icon: const Icon(Icons.add),
          label: const Text("Add New Rule"),
        ),
      ],
    );
  }
}
