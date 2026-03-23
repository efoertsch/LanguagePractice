import 'package:flutter/material.dart';

import '../enums/word_enums.dart';


Future<List<String>?> showWordTypeSelector(
    BuildContext context,
    List<String> initialSelection
    ) async {
  // Create a local copy of the selection to modify within the dialog
  List<String> selectedTypes = List.from(initialSelection);

  return showDialog<List<String>>(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Select Word Types'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: WordType.values.length,
                itemBuilder: (context, index) {
                  final type = WordType.values[index].toString();
                  final isSelected = selectedTypes.contains(type);

                  return CheckboxListTile(
                    title: Text(type),
                    value: isSelected,
                    onChanged: (bool? checked) {
                      setState(() {
                        if (checked == true) {
                          selectedTypes.add(type);
                        } else {
                          selectedTypes.remove(type);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, null), // Cancel returns null
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, selectedTypes), // OK returns the list
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    },
  );
}