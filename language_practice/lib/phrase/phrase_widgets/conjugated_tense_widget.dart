import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'
    show
        StatefulWidget,
        State,
        BuildContext,
        Padding,
        EdgeInsets,
        TextStyle,
        SizedBox,
        InputDecoration,
        FontWeight,
        Text,
        Key,
        OutlineInputBorder,
        TextFormField,
        Row,
        ValueListenableBuilder,
        Widget;
import 'package:flutter/widgets.dart';

class ConjugatedTenseWidget extends StatefulWidget {
  const ConjugatedTenseWidget({
    super.key,
    required this.activeTenseIndex,
    required this.label,
    required this.value,
    required this.isReadOnly,
    required this.onChanged,
    this.valueNotifier,
  });

  final int activeTenseIndex;
  final String label;
  final String value;
  final bool isReadOnly;
  final Function(String)? onChanged;
  final ValueNotifier<String>? valueNotifier;

  @override
  State<ConjugatedTenseWidget> createState() => _ConjugatedTenseWidgetState();
}

class _ConjugatedTenseWidgetState extends State<ConjugatedTenseWidget> {

  // Add a controller
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    // Initialize with the current value
    _controller = TextEditingController(text: widget.value);

    // If a notifier is provided, listen for changes and update the controller text
    widget.valueNotifier?.addListener(_handleNotifierChange);
  }

  @override
  void didUpdateWidget(ConjugatedTenseWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Handle case where the active index changes (e.g., user switched tenses)
    if (oldWidget.activeTenseIndex != widget.activeTenseIndex) {
      _controller.text = widget.value;
    }

    // Re-attach listener if notifier changed
    if (oldWidget.valueNotifier != widget.valueNotifier) {
      oldWidget.valueNotifier?.removeListener(_handleNotifierChange);
      widget.valueNotifier?.addListener(_handleNotifierChange);
    }
  }

  @override
  void dispose() {
    widget.valueNotifier?.removeListener(_handleNotifierChange);
    _controller.dispose();
    super.dispose();
  }

  void _handleNotifierChange() {
    if (widget.valueNotifier != null) {
      final newValue = widget.valueNotifier!.value;
      // Only update if the text is actually different to avoid moving the cursor
      if (_controller.text != newValue) {
        _controller.text = newValue;
        widget.onChanged?.call(_controller.text);
      }
    }
  }

  @override
  build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          _getConjugatedTenseLabel(),
          const SizedBox(width: 12),
          _getConjugatedTense(),
        ],
      ),
    );
  }

  SizedBox _getConjugatedTenseLabel() {
    return SizedBox(
      width: 60,
      child: Text(
        widget.label,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }

  Widget  _getConjugatedTense() {
    return SizedBox(
      width: 250,
      child: widget.isReadOnly
          ? getReadOnlyConjugatedTense(widget.value)
          : _getEditableConjugatedTense(),
    );
  }


  Widget _getEditableConjugatedTense() {
    print("${widget.activeTenseIndex}_${widget.label}_${_controller.value}");
    return TextFormField(
      // The key must be stable (no $value) to preserve focus
      key: Key("${widget.activeTenseIndex}_${widget.label}"),
      controller: _controller,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      onChanged: (val) {
        // Update the notifier if this is the field being typed inwidget.valueNotifier?.value = val;
        // Call the original onChanged callback
        widget.onChanged?.call(val);
      },
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
    );
  }

  Padding getReadOnlyConjugatedTense(String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
      child: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }
}
