import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:language_practice/quiz_widgets/quiz_bloc/quiz_state.dart';
import 'package:language_practice/repository/language_classes/word_info.dart'
    show WordInfo;
import 'package:language_practice/repository/language_repository.dart';

class QuizCubit extends Cubit<QuizState> {
  final LanguageRepository repository;

  QuizCubit({required this.repository}) : super(InitialQuizState());

  Future<void> getQuizItemsUsingFilter(String filterType) async {
    List<dynamic> quizItems = [];
    if (filterType == "Word") {
      List<dynamic> list = await repository.getQuizWordsForTypes(
          type: filterType, score: 0);
      if (list.isEmpty) {
        List<WordInfo> list = await repository.getQuizWordsForTypes(type:filterType);
      }
      quizItems.addAll(list);
    }else if (filterType == "Phrase") {
      List<dynamic> list = await repository.getQuizPhrases(score: 0, limit: 10);
      if (list.isEmpty){
      quizItems.addAll(await repository.getQuizPhrases(limit:10));
    }else if (filterType == "Rule") {
        List<dynamic> list = await repository.getQuizRulesForTypes(type: filterType, score: 0);
      }
      if (list.isEmpty) {
        quizItems.addAll(await repository.getQuizRulesForTypes(type: ""));
      }
    }
    quizItems.shuffle();
    emit(ListOfQuizItemsState(quizItems));
  }

  Future<void> getQuizWordsForTypes(List<String> types) async {
    List<WordInfo> wordList = [];
    for (String type in types) {
      wordList.addAll(await repository.getQuizWordsForTypes(type:""));
    }
    wordList.shuffle();
    emit(ListOfQuizItemsState(wordList));
  }
}
