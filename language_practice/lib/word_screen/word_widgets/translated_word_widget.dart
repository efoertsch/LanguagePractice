import 'package:flutter/material.dart';
import 'package:language_practice/utility_widgets/row_with_label_and_child.dart' show RowWithLabelAndChildMixin;

class TranslatedWordWidget extends StatefulWidget {
  final List<String> translatedLanguage;
  final Function(List<String>)? onChange;
  final ValueNotifier<String>? englishValueNotifier;


  const TranslatedWordWidget({
    super.key,
    required this.translatedLanguage,
     this.onChange,
    this.englishValueNotifier,
  });

  @override
  State<TranslatedWordWidget> createState() =>
      _TranslatedWordWidgetState();
}

class _TranslatedWordWidgetState extends State<TranslatedWordWidget> with RowWithLabelAndChildMixin {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    // Convert the List<String> to a comma-separated string for the input field
    String englishText = widget.translatedLanguage.join(', ');
    _controller = TextEditingController(text: englishText);

    // Listen to external changes via the notifier
    widget.englishValueNotifier?.addListener(_handleNotifierChange);
  }

  @override
  void didUpdateWidget(TranslatedWordWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update text if the underlying value object changed (e.g. index switch)
    if (oldWidget.translatedLanguage.join(', ') !=
        widget.translatedLanguage.join(', ')) {
      _controller.text = widget.translatedLanguage.join(', ');
    }

    // Re-bind listener if the notifier instance changes
    if (oldWidget.englishValueNotifier != widget.englishValueNotifier) {
      oldWidget.englishValueNotifier?.removeListener(_handleNotifierChange);
      widget.englishValueNotifier?.addListener(_handleNotifierChange);
    }
  }

  @override
  void dispose() {
    widget.englishValueNotifier?.removeListener(_handleNotifierChange);
    _controller.dispose();
    super.dispose();
  }

  void _handleNotifierChange() {
    if (widget.englishValueNotifier != null) {
      final String newValue = widget.englishValueNotifier!.value.trim();
      // Update text only if different to prevent cursor jumping
      if (_controller.text != newValue) {
        _controller.text = newValue;
        // Ensure the parent's data model is updated as well
        widget.onChange?.call(newValue.split(','));
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          _getLabel(),
          const SizedBox(width: 12),
          _getTranslatedTextField(),
        ],
      ),
    );
  }

  Widget _getLabel() {
    return SizedBox(
      width: 60,
      child: Text(
        "English",
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }

  Widget _getTranslatedTextField() {
    return Flexible(
      child: TextFormField(
        readOnly: widget.onChange == null,
        // Stable key (no $value) preserves focus during rebuilds
        key: Key("trans_english}"),
        minLines: 1,
        maxLines: 3,
        controller: _controller,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        onChanged: (val) {
          // Update the notifier so other linked fields see the change
          widget.englishValueNotifier?.value = val.trim();
          // Notify the parent callback
          widget.onChange?.call(widget.englishValueNotifier!.value.trim().split(','));
        },
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        ),
      ),
    );
  }
}
