import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:language_practice/quiz_widgets/quiz_bloc/quiz_state.dart';
import 'package:language_practice/repository/language_classes/word_info.dart'
    show WordInfo;
import 'package:language_practice/repository/language_repository.dart';

class QuizCubit extends Cubit<QuizState> {
  final LanguageRepository repository;

  QuizCubit({required this.repository}) : super(InitialQuizState());

  Future<void> getQuizItemsUsingFilter({
    required String category,
    List<String>? filterTypes,
  }) async {
    List<dynamic> quizItems = [];
    List<dynamic> list = [];
    if (category == "Word") {
      if (filterTypes == null || filterTypes.isEmpty) {
        list = await repository.getQuizWordsForTypes(type: "", score: 0);
        if (list.isEmpty) {
          list = await repository.getQuizWordsForTypes(type: "");
        }
        quizItems.addAll(list);
      } else {
        for (String type in filterTypes) {
          list.addAll(
            await repository.getQuizWordsForTypes(type: type, score: 0),
          );
        }
        if (list.isEmpty) {
          for (String type in filterTypes) {
            list.addAll(
              list = await repository.getQuizWordsForTypes(type: type),
            );
          }
        }
        quizItems.addAll(list);
      }
    } else if (category == "Phrase") {
      list = await repository.getQuizPhrases(score: 0);
      if (list.isEmpty) {
        list = await repository.getQuizPhrases(limit: 10);
      }
      quizItems.addAll(list);
    } else if (category == "Rule") {
      list = await repository.getQuizRulesForTypes(
        type: "",
        score: 0,
      );
      if (list.isEmpty) {
        list = await repository.getQuizRulesForTypes();
      }
      quizItems.addAll(list);
    }
    quizItems.shuffle();
    emit(ListOfQuizItemsState(quizItems));
  }

  Future<void> getQuizWordsForTypes(List<String> types) async {
    List<WordInfo> wordList = [];
    for (String type in types) {
      wordList.addAll(await repository.getQuizWordsForTypes(type: ""));
    }
    wordList.shuffle();
    emit(ListOfQuizItemsState(wordList));
  }
}
