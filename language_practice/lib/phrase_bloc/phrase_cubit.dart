import 'package:bloc/bloc.dart';
import 'package:language_practice/phrase_bloc/phrase_state.dart';
import 'package:mongo_dart/mongo_dart.dart';

import '../../repository/language_repository.dart';
import '../language_classes/phrase.dart';

class PhraseCubit extends Cubit<PhraseState> {
  final LanguageRepository repository;

  PhraseCubit({required this.repository}) : super(InitialPhraseState());

  /// Fetches an existing phrase or prepares a new one for entry
  Future<void> getPhrase({required String spelledPhrase}) async {
    emit(LoadingPhraseState(spelledPhrase));
    PhraseInfo? phraseInfo;

    try {
      // Fetch the phrase from the repository
      phraseInfo = await repository.getPhrase(spelledPhrase);

      if (phraseInfo != null) {
        phraseInfo.previouslyEntered = true;
      } else {
        // New phrase logic: create the object and fetch initial translation
        phraseInfo = PhraseInfo(phrase: spelledPhrase);
        String translation = await repository.getEnglishTranslation(spelledPhrase);
        phraseInfo.english = translation.split(',');
      }

      emit(LoadedPhraseInfoState(phraseInfo));
    } catch (e) {
      emit(ErrorPhraseState("Failed to load phrase: ${e.toString()}"));
    }
  }

  /// Adds a new phrase to the database
  Future<void> savePhrase(PhraseInfo phrase) async {
    try {
      WriteResult writeResult = await repository.savePhrase(phrase);
      if (writeResult.nInserted == 1) {
        emit(PhraseSavedState(phrase));
      } else {
        emit(
          ErrorPhraseState(
            "An error occurred while saving the phrase: "
                "${writeResult.errmsg ?? "Unknown error"}",
          ),
        );
      }
    } catch (e) {
      emit(ErrorPhraseState("Failed to save phrase: $e"));
    }
  }

  /// Updates an existing phrase in the database
  Future<void> updatePhrase(PhraseInfo phrase) async {
    try {
      WriteResult writeResult = await repository.updatePhrase(phrase);
      // nMatched handles cases where values are the same and nothing actually changed in DB
      if (writeResult.nModified == 1 || writeResult.nMatched == 1) {
        emit(PhraseSavedState(phrase));
      } else {
        emit(
          ErrorPhraseState(
            "An error occurred while updating the phrase: "
                "${writeResult.errmsg ?? "Unknown error"}",
          ),
        );
      }
    } catch (e) {
      emit(ErrorPhraseState("Failed to update phrase: $e"));
    }
  }

  /// Deletes a phrase from the database
  Future<void> deletePhrase(PhraseInfo phrase) async {
    try {
      WriteResult writeResult = await repository.deletePhrase(phrase);
      if (writeResult.nRemoved == 1) {
        emit(PhraseDeletedState(phrase));
      } else {
        emit(
          ErrorPhraseState(
            "An error occurred while deleting the phrase: "
                "${writeResult.errmsg ?? "Unknown error"}",
          ),
        );
      }
    } catch (e) {
      emit(ErrorPhraseState("Failed to delete phrase: $e"));
    }
  }
}