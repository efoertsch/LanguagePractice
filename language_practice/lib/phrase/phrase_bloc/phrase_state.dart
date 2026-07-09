import 'package:flutter/foundation.dart';
import 'package:language_practice/repository/language_classes/phrase.dart';


@immutable
abstract class PhraseState {}

class InitialPhraseState extends PhraseState {
  final state = "InitialPhraseState";
  @override
  String toString() => state;
}

class LoadingPhraseState extends PhraseState{
  final String phrase;
  LoadingPhraseState(this.phrase);
}

class LoadedPhraseInfoState extends PhraseState {
  final Phrase phrase;
  LoadedPhraseInfoState(this.phrase);
}

class PhraseSavedState extends PhraseState {
  final Phrase phrase;
  PhraseSavedState(this.phrase);
}

class PhraseDeletedState extends PhraseState {
  final Phrase phrase;
  PhraseDeletedState(this.phrase);
}

class ErrorPhraseState extends PhraseState {
  final String message;
  ErrorPhraseState(this.message);
}

class ListOfPhrasesState extends PhraseState{
  final List<Phrase> listOfPhrases;
  ListOfPhrasesState(this.listOfPhrases);
}

