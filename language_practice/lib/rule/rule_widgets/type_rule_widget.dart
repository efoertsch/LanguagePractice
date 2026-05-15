import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:language_practice/app/dialog_widgets.dart';
import 'package:language_practice/repository/language_classes/rule.dart';
import 'package:language_practice/rule/rule_bloc/rule_cubit.dart';
import 'package:language_practice/rule/rule_bloc/rule_state.dart';
import 'package:language_practice/rule/rule_widgets/rule_widget.dart';
import 'package:language_practice/utility_widgets/row_with_label_and_child.dart';

class TypeRuleWidget extends StatefulWidget {
  const TypeRuleWidget({super.key});

  @override
  State<TypeRuleWidget> createState() => _TypeRuleWidgetState();
}

class _TypeRuleWidgetState extends State<TypeRuleWidget>
    with RowWithLabelAndChildMixin {
  late TextEditingController _ruleNameController;
  final FocusNode _ruleInputFieldFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _ruleNameController = TextEditingController();
  }

  @override
  void dispose() {
    _ruleNameController.dispose();
    _ruleInputFieldFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Note: Scaffold is omitted here because this widget is intended
    // to be placed inside the Column of WordAndPhraseEntryScreen
    return _createRuleEntry();
  }

  Widget _createRuleEntry() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize:MainAxisSize.min,
        children: [
          buildHorizontalRow(
            label: "Rule Name:",
            child: TextField(
              focusNode: _ruleInputFieldFocusNode,
              autofocus: false,
              decoration: const InputDecoration(
                hintText: 'Enter grammar rule (e.g. Dative)',
                border: OutlineInputBorder(),
              ),
              controller: _ruleNameController,
              onSubmitted: _handleRuleChange,
            ),
          ),
          _processRuleListener(),
        ],
      ),
    );
  }

  void _handleRuleChange(String value) {
    if (value.trim().isEmpty) return;

    context.read<RuleCubit>().getRule(
      ruleName: value.trim(),
    );
  }

  Widget _processRuleListener() {
    return BlocListener<RuleCubit, RuleState>(
      listener: (context, state) {
        if (state is LoadedRuleInfoState) {
          _navigateToRuleWidget(context, state.rule);
        }

        if (state is ErrorRuleState) {
          CommonWidgets.showInfoDialog(
            context: context,
            title: 'Rule Error',
            msg: state.message,
            button1Text: 'OK',
            button1Function: (() => Navigator.pop(context)),
          );
        }
      },
      child: const SizedBox.shrink(),
    );
  }

  void _navigateToRuleWidget(BuildContext context, Rule rule) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (routeContext) => BlocProvider.value(
          value: BlocProvider.of<RuleCubit>(context),
          child: RuleWidget(rule: rule),
        ),
      ),
    );

    // Clear the input and return focus after returning from the detail screen
    _ruleNameController.clear();
    _ruleInputFieldFocusNode.requestFocus();
  }
}