import 'package:bloc/bloc.dart';
import 'package:language_practice/repository/language_classes/rule.dart';
import 'package:language_practice/rule/rule_bloc/rule_state.dart';
import 'package:mongo_dart/mongo_dart.dart';

import '../../../repository/language_repository.dart';

class RuleCubit extends Cubit<RuleState> {
  final LanguageRepository repository;

  RuleCubit({required this.repository}) : super(InitialRuleState());

  /// Fetches an existing rule or prepares a new one for entry
  Future<void> getRule({required String ruleName}) async {
    emit(LoadingRuleState(ruleName));
    Rule? rule;

    try {
      // Fetch the rule from the repository
      rule = await repository.getRule(ruleName);

      rule ??= Rule(rule: ruleName);

      emit(LoadedRuleInfoState(rule));
    } catch (e) {
      emit(ErrorRuleState("Failed to load rule: ${e.toString()}"));
    }
  }

  /// Adds a new rule to the database
  Future<void> saveRule(Rule rule) async {
    try {
      WriteResult writeResult = await repository.saveRule(rule);
      if (writeResult.nInserted == 1) {
        emit(RuleSavedState(rule));
      } else {
        emit(
          ErrorRuleState(
            "An error occurred while saving the rule: "
                "${writeResult.errmsg ?? "Unknown error"}",
          ),
        );
      }
    } catch (e) {
      emit(ErrorRuleState("Failed to save rule: $e"));
    }
  }

  /// Updates an existing rule in the database
  Future<void> updateRule(Rule rule) async {
    try {
      WriteResult writeResult = await repository.updateRule(rule);
      // nMatched handles cases where values are the same and nothing actually changed in DB
      if (writeResult.nModified == 1 || writeResult.nMatched == 1) {
        emit(RuleSavedState(rule));
      } else {
        emit(
          ErrorRuleState(
            "An error occurred while updating the rule: "
                "${writeResult.errmsg ?? "Unknown error"}",
          ),
        );
      }
    } catch (e) {
      emit(ErrorRuleState("Failed to update rule: $e"));
    }
  }

  /// Deletes a rule from the database
  Future<void> deleteRule(Rule rule) async {
    try {
      WriteResult writeResult = await repository.deleteRule(rule);
      if (writeResult.nRemoved == 1) {
        emit(RuleDeletedState(rule));
      } else {
        emit(
          ErrorRuleState(
            "An error occurred while deleting the rule: "
                "${writeResult.errmsg ?? "Unknown error"}",
          ),
        );
      }
    } catch (e) {
      emit(ErrorRuleState("Failed to delete rule: $e"));
    }
  }


  void updateRuleScore(ObjectId objectId, bool isCorrect) async {
    try {
      WriteResult result = await repository.updateRuleQuizScore(
          objectId, isCorrect ? 1 : -2);

      if (result.nModified == 1 || result.nMatched == 1) {
        // 2. Optional: If you need the UI to reflect the change immediately without a full refresh,
        // you could fetch the updated word or simply emit a success state.
        // For now, we'll emit a generic success or re-emit the list if in Quiz mode.
      } else {
        emit(ErrorRuleState("Could not update rule score."));
      }
    } catch (e) {
      emit(ErrorRuleState("Failed to update proficiency: ${e.toString()}"));
    }
  }


  void listRules(String startOfRule) async {
    try {
      List<Rule> result = await repository.getListOfRules(startOfRule);
      emit(ListOfRulesState(result));
    } catch (e) {
      emit(ErrorRuleState(
          "Error in getting rules that match input: ${e.toString()}"));
    }
  }
}
