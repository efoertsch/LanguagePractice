import 'package:flutter/material.dart';
import 'package:language_practice/utility_widgets/row_with_label_and_child.dart';

class RuleWidget extends StatefulWidget {
  final String label;
  final TextEditingController? controller;
  final bool readOnly;
  final bool autoFocus;
  final InputDecoration? inputDecoration;
  final FocusNode? focusNode;
  final Function(String)? onSubmitted;
  final int maxLines;

  const RuleWidget({
    Key? key,
    required this.label,
    required this.controller,
    this.readOnly = false,
    this.autoFocus = false,
    this.inputDecoration = const InputDecoration(hintText: 'Enter a rule name'),
    this.onSubmitted,
    this.focusNode,
    this.maxLines = 1,
  }) : super(key: key);

  @override
  _RuleWidgetState createState() => _RuleWidgetState();
}

class _RuleWidgetState extends State<RuleWidget>
    with RowWithLabelAndChildMixin {



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
        decoration: widget.inputDecoration,
      ),
    );
  }
}