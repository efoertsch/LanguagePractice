import 'package:flutter/material.dart';

class PluralWidget extends StatefulWidget {
  final String pluralNoun;
  final Function(String) onPluralChanged;
  final Function() onFocusLost;

  const PluralWidget({
    super.key,
    required this.pluralNoun,
    required this.onPluralChanged,
    required this.onFocusLost,
  });

  @override
  State<PluralWidget> createState() => _PluralWidgetState();
}

class _PluralWidgetState extends State<PluralWidget> {
  late TextEditingController _pluralController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _pluralController = TextEditingController(text: widget.pluralNoun);
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        // Logic for when focus is LOST
        widget.onFocusLost();
      }
    });
  }

  @override
  void dispose() {
    _pluralController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          // Label portion
          Text(
            "Plural",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(width: 12),
          // Input portion
          Flexible(
            child: TextField(
              controller: _pluralController,
              onChanged: widget.onPluralChanged,
              decoration: const InputDecoration(
                hintText: 'Enter plural form',
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
