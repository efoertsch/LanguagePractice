import 'package:flutter/material.dart';
import 'package:language_practice/utility_widgets/row_with_label_and_child.dart';

class PhraseWidget extends StatefulWidget {
  final String label;
  final dynamic text; // List<String> or String
  final bool readOnly;
  final bool autoFocus;
  final InputDecoration? inputDecoration;
  final FocusNode? focusNode;
  final Function(String)? onSubmitted;
  final Function(String)? onChange;
  final int maxLines;

  PhraseWidget({
    Key? key,
    required this.label,
    required this.text,
    this.readOnly = false,
    this.autoFocus = false,
    this.inputDecoration,
    this.onSubmitted,
    this.focusNode,
    this.onChange,
    this.maxLines = 1,
  }) : super(key: key);

  @override
  _PhaseWidgetState createState() => _PhaseWidgetState();
}

class _PhaseWidgetState extends State<PhraseWidget>
    with RowWithLabelAndChildMixin {
  late String text;
  late TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    if (widget.text is List) {
      text = (widget.text as List).join(", ");
    } else {
      text = widget.text?.toString() ?? "";
    }
    text = widget.text;
    _textEditingController = TextEditingController(text: widget.text);
    if (widget.onChange != null) {
      _textEditingController.addListener(
        () => widget.onChange?.call(_textEditingController.text),
      );
    }
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildHorizontalRow(
      label: widget.label,
      child: TextField(
        autofocus: widget.autoFocus,
        focusNode: widget.focusNode,
        controller: _textEditingController,
        onSubmitted: widget.onSubmitted,
        readOnly: widget.readOnly,
        minLines: 1,
        maxLines: widget.maxLines,
        decoration: widget.inputDecoration ??
            const InputDecoration(hintText: 'Enter a phrase'),
      ),
    );
  }
}
