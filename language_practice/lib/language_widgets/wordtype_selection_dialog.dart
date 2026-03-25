import 'package:flutter/material.dart';
import 'package:language_practice/app/dialog_widgets.dart';
import '../enums/word_enums.dart';

Future<List<String>?> showWordTypeSelector(
    BuildContext context,
    List<String> initialSelection,
    bool multipleSelectionAllowed,
    ) async {
  // Create a local copy of the selection to modify within the dialog
  List<String> selectedTypes = List.from(initialSelection);
  bool selectionmade = selectedTypes.isNotEmpty;

  return showDialog<List<String>>(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(multipleSelectionAllowed ? 'Select Word Types' : 'Select Word Type'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: WordType.values.length,
                itemBuilder: (context, index) {
                  final type = WordType.values[index].displayName;
                  final isSelected = selectedTypes.contains(type);

                  return CheckboxListTile(
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(type),
                    value: isSelected,
                    onChanged: (bool? checked) {
                      setState(() {
                        if (checked == true) {
                          // IF SINGLE SELECTION: Clear previous before adding new
                          if (!multipleSelectionAllowed) {
                            selectedTypes.clear();
                          }
                          selectedTypes.add(type);
                          selectionmade = true;
                        } else {
                          // If multiple selection is allowed, we can remove items
                          if (multipleSelectionAllowed) {
                            selectedTypes.remove(type);
                            if (selectedTypes.isEmpty) {
                              selectionmade = false;
                              CommonWidgets.showErrorDialog(
                                context,
                                "Word type needed",
                                "The word needs at least one word type selected",
                              );
                            }
                          } else {
                            // If single selection, don't allow unchecking the active item
                            // This ensures at least one item remains selected.
                            if (selectedTypes.length <= 1 && isSelected) {
                              return;
                            }
                            selectedTypes.remove(type);
                          }
                        }
                      });
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, null),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (selectionmade && selectedTypes.isNotEmpty) {
                    Navigator.pop(context, selectedTypes);
                  }
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    },
  );
}
