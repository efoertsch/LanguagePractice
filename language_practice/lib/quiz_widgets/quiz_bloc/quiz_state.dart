import 'package:flutter/foundation.dart';
import 'package:language_practice/repository/language_classes/word_info.dart';


@immutable
abstract class QuizState {}

class InitialQuizState extends QuizState {
  final state = "InitialQuizState";

  @override
  String toString() => state;
}


class LoadingQuizState extends QuizState{
  LoadingQuizState();
}

class ListOfQuizStuffState extends QuizState{
  final List<dynamic> listOfQuizStuff;
  ListOfQuizStuffState(this.listOfQuizStuff);
}

class ErrorQuizState extends QuizState {
  final String message;
  ErrorQuizState(this.message);
}