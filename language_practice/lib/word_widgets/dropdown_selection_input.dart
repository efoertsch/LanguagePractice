import 'package:flutter/material.dart';

class DropdownSelectionField extends StatefulWidget {
  final String label;
  final List<String> options;
  final String initialValue;
  final ValueChanged<String> onChanged;

  const DropdownSelectionField({
    super.key,
    required this.label,
    required this.options,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<DropdownSelectionField> createState() => _DropdownSelectionFieldState();
}

class _DropdownSelectionFieldState extends State<DropdownSelectionField> {
  late String _currentValue;

  @override
  void initState() {
    super.initState();
    // Ensure initialValue exists in options to avoid errors
    _currentValue = widget.options.contains(widget.initialValue)
        ? widget.initialValue
        : widget.options.first;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          // The Label
          SizedBox(
            width: 100, // Fixed width to match your CommaDelimitedInputText
            child: Text(
              widget.label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          // The Dropdown
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: _currentValue,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
              items: widget.options.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _currentValue = newValue;
                  });
                  widget.onChanged(newValue);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}