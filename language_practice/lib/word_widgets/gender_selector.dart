import 'package:flutter/material.dart';

class GenderSelector extends StatefulWidget {
  final String? selectedGender;
  final List<String> genders;
  final Function(String) onGenderChanged;

  const GenderSelector({
    super.key,
    required this.selectedGender,
    required this.genders,
    required this.onGenderChanged,
  });

  @override
  State<GenderSelector> createState() => _GenderSelectorState();
}

class _GenderSelectorState extends State<GenderSelector> {
  late TextEditingController _genderController;
  late FocusNode _genderFocusNode;

  @override
  void initState() {
    super.initState();
    _genderController = TextEditingController(text: widget.selectedGender);
    _genderFocusNode = FocusNode();

    // Trigger dialog when the field gains focus
    _genderFocusNode.addListener(() async {
      if (_genderFocusNode.hasFocus) {
        _genderFocusNode.unfocus();
        final result = await _showGenderSelectionDialog(
          context,
          "Select Gender",
          widget.genders,
          widget.selectedGender ?? "",
        );

        if (result != null) {
          widget.onGenderChanged(result);
          _genderController.text = result;
          // Move focus to the next field (usually the Word field)
          _genderFocusNode.nextFocus();
        } else {
          // If canceled, unfocus to prevent infinite loop of dialogs
          _genderFocusNode.unfocus();
        }
      }
    });
  }

  @override
  void didUpdateWidget(covariant GenderSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedGender != _genderController.text) {
      _genderController.text = widget.selectedGender ?? "";
    }
  }

  @override
  void dispose() {
    _genderController.dispose();
    _genderFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _genderController,
      focusNode: _genderFocusNode,
      readOnly: true, // Prevent keyboard from showing up
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      // decoration: const InputDecoration(
      //   isDense: true,
      //   contentPadding: EdgeInsets.symmetric(vertical: 8),
      // ),
    );
  }

  Future<String?> _showGenderSelectionDialog(
      BuildContext context,
      String title,
      List<String> options,
      String currentSelection,
      ) async {
    String? tempSelection = currentSelection;
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(title),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: options.map((option) {
                  return RadioListTile<String>(
                    title: Text(option),
                    value: option,
                    groupValue: tempSelection,
                    onChanged: (value) => setState(() => tempSelection = value),
                  );
                }).toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, null),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, tempSelection),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}