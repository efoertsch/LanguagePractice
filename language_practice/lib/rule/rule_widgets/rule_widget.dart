import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:language_practice/app/dialog_widgets.dart' show CommonWidgets;
import 'package:language_practice/repository/language_classes/rule.dart';
import 'package:language_practice/rule/rule_bloc/rule_cubit.dart';
import 'package:language_practice/rule/rule_bloc/rule_state.dart';
import 'package:language_practice/utility_widgets/row_with_label_and_child.dart';
import 'package:language_practice/word_screen/word_widgets/word_type_mixin.dart';

class RuleWidget extends StatefulWidget {
  final Rule rule;

  const RuleWidget({super.key, required this.rule});

  @override
  State<RuleWidget> createState() => _RuleWidgetState();
}

class _RuleWidgetState extends State<RuleWidget>
    with RowWithLabelAndChildMixin, WordTypeMixin {
  late TextEditingController _ruleController;
  late TextEditingController _explanationController;
  late TextEditingController _exampleController;
  late Rule _rule;

  @override
  void initState() {
    super.initState();
    _rule = widget.rule;
    _ruleController = TextEditingController(text: _rule.rule);
    _explanationController = TextEditingController(text: _rule.explanation);
    _exampleController = TextEditingController(text: _rule.example);
  }

  @override
  void dispose() {
    _ruleController.dispose();
    _explanationController.dispose();
    _exampleController.dispose();
    super.dispose();
  }

  void _onSave() {
    _rule.rule = _ruleController.text.trim();
    _rule.explanation = _explanationController.text.trim();
    _rule.example = _exampleController.text.trim();

    if (_rule.id != null) {
      context.read<RuleCubit>().updateRule(_rule);
    } else {
      context.read<RuleCubit>().saveRule(_rule);
    }
  }

  void _onDelete() {
    context.read<RuleCubit>().deleteRule(_rule);
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        appBar: AppBar(
          title: Text(_rule.id != null ? "Edit Rule" : "New Rule"),
          backgroundColor: Colors.deepPurple, // Differentiated color for rules
          centerTitle: true,
          actions: [
            if (_rule.id != null)
              IconButton(onPressed: _onDelete, icon: const Icon(Icons.delete)),
            IconButton(onPressed: _onSave, icon: const Icon(Icons.save)),
          ],
        ),
        floatingActionButton: _getFloatingActionButtonRow(context),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: BlocListener<RuleCubit, RuleState>(
          listener: (context, state) {
            if (state is RuleSavedState || state is RuleDeletedState) {
              String message = state is RuleSavedState ? "Saved" : "Deleted";
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: state is RuleSavedState
                      ? Colors.green
                      : Colors.redAccent,
                  content: Text("${widget.rule.rule} $message."),
                ),
              );
              Navigator.of(context).pop(); // return to prior screen
            }
            if (state is ErrorRuleState) {
              CommonWidgets.showErrorDialog(context, "Error", state.message);
            }

          },
          child:SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildHorizontalRow(
                label: "Rule Name:",
                child: TextField(
                  controller: _ruleController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "e.g., Passive Voice",
                  ),
                ),
              ),
              const SizedBox(height: 8),
              buildTypeChips(
                context: context,
                types: widget.rule.type,
                multipleSelectionAllowed: false,
                onTypesChanged: onTypesChanged,
              ),
              const SizedBox(height: 16),
              buildHorizontalRow(
                label: "Explanation:",
                child: TextField(
                  controller: _explanationController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Explain the grammar rule here...",
                  ),
                ),
              ),
              const SizedBox(height: 16),
              buildHorizontalRow(
                label: "Example:",
                child: TextField(
                  controller: _exampleController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Provide a usage example",
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onTypesChanged(List<String> types) {
    if (mounted) {
      setState(() {
        widget.rule.type = types;
      });
    }
  }

  Widget _getFloatingActionButtonRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // DELETE/CANCEL BUTTON
        FloatingActionButton.extended(
          heroTag: "delete_rule_btn",
          onPressed: () => _confirmDeleteRule(context),
          label: Text(widget.rule.id != null ? "Delete" : "Cancel"),
          icon: const Icon(Icons.delete_forever),
          backgroundColor: Colors.redAccent,
        ),
        // SAVE/UPDATE BUTTON
        FloatingActionButton.extended(
          autofocus: true,
          heroTag: "save_rule_btn",
          onPressed: () async {
            _onSave();
          },
          label: Text(widget.rule.id !=null ? "Update" : "Save"),
          icon: const Icon(Icons.save),
          backgroundColor: Colors.deepPurpleAccent,
        ),
      ],
    );
  }

  void _confirmDeleteRule(BuildContext context) {
    final cubit = context.read<RuleCubit>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(widget.rule.id !=null ? "Delete Rule?" : "Cancel"),
        content: Text(
          "Are you sure you want to ${widget.rule.id !=null ? ("delete '${widget.rule.rule}' permanently?") : "not add the rule?"}",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              if (widget.rule.id !=null) {
                cubit.deleteRule(widget.rule);
              } else {
                Navigator.pop(context);
              }
            },
            child: Text(
              widget.rule.id !=null ? "Delete" : "Don't Save",
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
