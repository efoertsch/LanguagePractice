import 'package:flutter/material.dart';

class CommaDelimitedInputText extends StatefulWidget {
  final String label;
  final String initialValue;
  final ValueChanged<String> onChanged;

  const CommaDelimitedInputText({
    super.key,
    required this.label,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<CommaDelimitedInputText> createState() => _CommaDelimitedInputTextState();
}

class _CommaDelimitedInputTextState extends State<CommaDelimitedInputText> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          // The Label
          SizedBox(
            width: 100, // Fixed width for labels helps align multiple fields
            child: Text(
              widget.label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          // The Input Field
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true, // Makes the field more compact
              ),
              onChanged: widget.onChanged,
            ),
          ),
        ],
      ),
    );
  }
}