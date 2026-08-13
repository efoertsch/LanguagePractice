import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:language_practice/app/AppStateWidget.dart';
import 'package:language_practice/app/dialog_widgets.dart' show CommonWidgets;
import 'package:language_practice/repository/language_classes/rule.dart';
import 'package:language_practice/rule/rule_bloc/rule_cubit.dart';
import 'package:language_practice/rule/rule_bloc/rule_state.dart';
import 'package:language_practice/rule/rule_widgets/rule_layout_widget.dart';
import 'package:language_practice/utility_widgets/row_with_label_and_child.dart';
import 'package:language_practice/word_screen/word_widgets/word_type_mixin.dart';

class RuleEditWidget extends StatefulWidget {
  final Rule rule;

  const RuleEditWidget({super.key, required this.rule});

  @override
  _RuleEditWidgetState createState() => _RuleEditWidgetState();
}

class _RuleEditWidgetState extends AppStateWidget<RuleEditWidget>
    with RowWithLabelAndChildMixin, WordTypeMixin {
  void _onSave() {
    context.read<RuleCubit>().saveRule(widget.rule);
  }

  void _onDelete() {
    context.read<RuleCubit>().deleteRule(widget.rule);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.rule.id != null ? "Edit Rule" : "New Rule"),
        backgroundColor: Colors.deepPurple, // Differentiated color for rules
        centerTitle: true,
        actions: [
          if (widget.rule.id != null)
            IconButton(onPressed: _onDelete, icon: const Icon(Icons.delete)),
          IconButton(onPressed: _onSave, icon: const Icon(Icons.save)),
        ],
      ),
      //floatingActionButton: _getFloatingActionButtonRow(context),
      //floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: BlocListener<RuleCubit, RuleState>(
        listener: (context, state) {
          if (state is RuleSavedState || state is RuleDeletedState) {
            String message = state is RuleSavedState ? "Saved" : "Deleted";
            showSnackBar(
              backgroundColor: state is RuleSavedState
                  ? Colors.green
                  : Colors.redAccent,
              content: "${widget.rule.rule} $message.",
            );
            Navigator.of(context).pop(); // return to prior screen
          }
          if (state is ErrorRuleState) {
            CommonWidgets.showErrorDialog(context, "Error", state.message);
          }
        },
        child: CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate([
                RuleLayoutWidget(rule: widget.rule),
              ]),
            ),
            SliverFillRemaining(
              hasScrollBody: false, // Essential for positioning at the bottom
              child: Column(
                children: [
                  Spacer(), // Pushes the following widget to the bottom
                  _getFloatingActionButtonRow(context),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
          label: Text(widget.rule.id != null ? "Update" : "Save"),
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
        title: Text(widget.rule.id != null ? "Delete Rule?" : "Cancel"),
        content: Text(
          "Are you sure you want to ${widget.rule.id != null ? ("delete '${widget.rule.rule}' permanently?") : "not add the rule?"}",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              if (widget.rule.id != null) {
                cubit.deleteRule(widget.rule);
              } else {
                Navigator.pop(context);
              }
            },
            child: Text(
              widget.rule.id != null ? "Delete" : "Don't Save",
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
