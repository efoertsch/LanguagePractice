import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:language_practice/app/dialog_widgets.dart';
import 'package:language_practice/repository/language_classes/rule.dart';
import 'package:language_practice/rule/rule_bloc/rule_cubit.dart';
import 'package:language_practice/rule/rule_bloc/rule_state.dart';
import 'package:language_practice/rule/rule_widgets/rule_edit_widget.dart';
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
  late ScrollController _listScrollController;
  List<Rule> _listOfRules = []; // Add this

  @override
  void initState() {
    super.initState();
    _ruleNameController = TextEditingController();
    _ruleNameController.addListener(() {
        _getMatchingRules(_ruleNameController.text);
      });
    _listScrollController = ScrollController();
  }

  @override
  void dispose() {
    _ruleNameController.dispose();
    _ruleInputFieldFocusNode.dispose();
    _listScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Column(
            // Note: AnimatedSize can be kept, but Column works best
            mainAxisSize: MainAxisSize.min,
            children: [
              _getRuleWidget(),
              if (_listOfRules.isNotEmpty) _displayListOfRules(),
              _processRuleListener(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getRuleWidget() {
    return buildHorizontalRow(
      label: "Rule:",
        child: TextField(
          focusNode: _ruleInputFieldFocusNode,
          autofocus: true,
      decoration: const InputDecoration(hintText: 'Enter a rule name'),
      controller: _ruleNameController,
      onSubmitted: _handleRuleChange,
        ) );
  }

  Widget _displayListOfRules() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 300),
      child: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Material(
          color: Colors.transparent,
          child: Scrollbar(
            controller: _listScrollController,
            child: ListView.separated(
              controller: _listScrollController,
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: _listOfRules.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final ruleItem = _listOfRules[index];
                return ListTile(
                  title: Text(
                    ruleItem.rule ?? "",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    ruleItem.explanation ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    _navigateToRuleEdit(context, ruleItem);
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _handleRuleChange(String value) {
    if (value.trim().isEmpty) return;
    context.read<RuleCubit>().getRule(ruleName: value.trim());
  }

  Widget _processRuleListener() {
    return BlocListener<RuleCubit, RuleState>(
      listener: (context, state) {
        if (state is LoadedRuleInfoState) {
          _navigateToRuleEdit(context, state.rule);
        }
        if (state is ListOfRulesState) {
          // Handle the list state
          setState(() {
            _listOfRules = state.listOfRules;
          });
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

  void _navigateToRuleEdit(BuildContext context, Rule rule) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (routeContext) => BlocProvider.value(
          value: BlocProvider.of<RuleCubit>(context),
          child: RuleEditWidget(rule: rule),
        ),
      ),
    );
    setState(() {
      _ruleNameController.clear();
      _listOfRules = [];
    });
    _ruleInputFieldFocusNode.requestFocus();
  }

  void _getMatchingRules(String value) {
    if (value.isEmpty) {
      setState(() => _listOfRules = []);
      return;
    }
    context.read<RuleCubit>().listRules(value);
  }

}
