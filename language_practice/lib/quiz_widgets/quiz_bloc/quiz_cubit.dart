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
      quizItems.addAll(await repository.getQuizWordsForTypes(type:""));
    }
    quizItems.shuffle();
    emit(ListOfQuizStuffState(quizItems));
  }

  Future<void> getQuizWordsForTypes(List<String> types) async {
    List<WordInfo> wordList = [];
    for (String type in types) {
      wordList.addAll(await repository.getQuizWordsForTypes(type:""));
    }
    wordList.shuffle();
    emit(ListOfQuizStuffState(wordList));
  }
}
