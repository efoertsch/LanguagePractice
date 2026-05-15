import 'package:flutter/foundation.dart';
import 'package:language_practice/repository/language_classes/rule.dart';

@immutable
abstract class RuleState {}

class InitialRuleState extends RuleState {}

class LoadingRuleState extends RuleState {
  final String ruleName;
  LoadingRuleState(this.ruleName);
}

class LoadedRuleInfoState extends RuleState {
  final Rule rule;
  LoadedRuleInfoState(this.rule);
}

class RuleSavedState extends RuleState {
  final Rule rule;
  RuleSavedState(this.rule);
}

class RuleDeletedState extends RuleState {
  final Rule rule;
  RuleDeletedState(this.rule);
}

class ErrorRuleState extends RuleState {
  final String message;
  ErrorRuleState(this.message);
}