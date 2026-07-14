import 'package:flutter/material.dart';
import 'package:language_practice/utility_widgets/row_with_label_and_child.dart';

class PhraseWidget extends StatefulWidget {
  final String label;
  final TextEditingController? controller;
  final bool readOnly;
  final bool autoFocus;
  final InputDecoration? inputDecoration;
  final FocusNode? focusNode;
  final Function(String)? onSubmitted;
  final int maxLines;

  PhraseWidget({
    Key? key,
    required this.label,
    required this.controller,
    this.readOnly = false,
    this.autoFocus = false,
    this.inputDecoration = const InputDecoration(hintText: 'Enter a phrase'),
    this.onSubmitted,
    this.focusNode,
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
  Widget build(BuildContext context) {
    return buildHorizontalRow(
      label: widget.label,
      child: TextField(
        autofocus: widget.autoFocus,
        focusNode: widget.focusNode,
        controller: widget.controller,
        onSubmitted: widget.onSubmitted,
        readOnly: widget.readOnly,
        minLines: 1,
        maxLines: widget.maxLines,
        decoration: widget.inputDecoration ,
      ),
    );
  }
}
