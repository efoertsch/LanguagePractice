import 'package:flutter/material.dart';
import 'package:language_practice/language_classes/word_info.dart';
import '../word_widgets/word_type_mixin.dart';
import '../word_widgets/wordtype_selection_dialog.dart';

class WordRulesSection extends StatelessWidget with WordTypeMixin {
  final List<Rules> rules;
  final Function(List<Rules>)? onRulesChanged;

  const WordRulesSection({
    super.key,
    required this.rules,
    this.onRulesChanged, // 2. Removed 'required'
  });

  @override
  Widget build(BuildContext context) {
    // 3. Helper to determine if we are in read-only mode
    final bool isReadOnly = onRulesChanged == null;

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Rule Type
                      Expanded(
                        flex: 2,
                        child: buildTypeChips(
                          context: context,
                          types: [ruleItem.type!],
                          multipleSelectionAllowed: false,
                          onTypesChanged: isReadOnly
                              ? (list) {} // Disable interaction in read-only
                              : (List<String> selectedTypes) {
                            ruleItem.type = selectedTypes.isNotEmpty
                                ? selectedTypes.first
                                : "";
                            onRulesChanged!(rules);
                          },
                        ),
                      ),
                      // 4. Conditionally hide delete button
                      if (!isReadOnly) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.redAccent,
                          ),
                          onPressed: () {
                            List<Rules> newList = List.from(rules);
                            newList.removeAt(index);
                            onRulesChanged!(newList);
                          },
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  // 5. Toggle between TextFormField and Text
                  isReadOnly
                      ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    child: Text(
                      ruleItem.rule ?? "",
                      style: const TextStyle(fontSize: 14),
                    ),
                  )
                      : TextFormField(
                    initialValue: ruleItem.rule,
                    maxLines: null,
                    decoration: const InputDecoration(
                      labelText: "Rule Description",
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) {
                      ruleItem.rule = val;
                      onRulesChanged!(rules);
                    },
                  ),
                ],
              ),
            ),
          );
        }).toList(),

        // 6. Conditionally hide Add Rule Button
        if (!isReadOnly)
          TextButton.icon(
            onPressed: () async {
              final List<String>? results = await showWordTypeSelector(
                context,
                [],
                false,
              );
              if (results != null && results.isNotEmpty) {
                onRulesChanged!([...rules, Rules(type: results[0], rule: "")]);
              }
            },
            icon: const Icon(Icons.add),
            label: const Text("Add New Rule"),
          ),
      ],
    );
  }
}