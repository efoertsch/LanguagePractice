import 'package:bloc/bloc.dart';
import 'package:language_practice/phrase/phrase_bloc/phrase_state.dart';
import 'package:language_practice/repository/language_classes/phrase.dart';
import 'package:mongo_dart/mongo_dart.dart';

import '../../repository/language_repository.dart';


class PhraseCubit extends Cubit<PhraseState> {
  final LanguageRepository repository;

  PhraseCubit({required this.repository}) : super(InitialPhraseState());

  /// Fetches an existing phrase or prepares a new one for entry
  Future<void> getPhrase({required String spelledPhrase}) async {
    emit(LoadingPhraseState(spelledPhrase));
    Phrase? phrase;

    try {
      // Fetch the phrase from the repository
      phrase = await repository.getPhrase(spelledPhrase);

      if (phrase == null) {
        // New phrase logic: create the object and fetch initial translation
        phrase = Phrase(phrase: spelledPhrase);
        String translation = await repository.getEnglishTranslation(spelledPhrase);
        phrase.english = translation;
      }

      emit(LoadedPhraseInfoState(phrase));
    } catch (e) {
      emit(ErrorPhraseState("Failed to load phrase: ${e.toString()}"));
    }
  }

  /// Adds a new phrase to the database
  Future<void> savePhrase(Phrase phrase) async {
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
  Future<void> updatePhrase(Phrase phrase) async {
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
  Future<void> deletePhrase(Phrase phrase) async {
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

  void updatePhraseScore(ObjectId objectId, int increment) async {
    try {
      WriteResult result = await repository.updatePhraseQuizScore(objectId, increment);

      if (result.nModified == 1 || result.nMatched == 1) {
        // 2. Optional: If you need the UI to reflect the change immediately without a full refresh,
        // you could fetch the updated word or simply emit a success state.
        // For now, we'll emit a generic success or re-emit the list if in Quiz mode.
      } else {
        emit(ErrorPhraseState("Could not update phrase score."));
      }
    } catch (e) {
      emit(ErrorPhraseState("Failed to update proficiency: ${e.toString()}"));
    }
  }
}