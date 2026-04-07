import 'package:mongo_dart/mongo_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app/constants.dart' show Constants;
import '../enums/word_enums.dart' show GermanGender;
import '../language_classes/word_info.dart';
import '../translation_service/translation_service.dart';

class LanguageRepository {
  static final String collectionName = Constants.wordCollection;
  late final Db mongoDb;
  static late final LanguageRepository languageRepository;
  static late final SharedPreferences sharedPreferences;

  DbCollection? wordCollection;
  DbCollection? phraseCollection;

  //LanguageRepository({required this.mongoDb});

  LanguageRepository._();

  static Future<LanguageRepository> create(Db mongoDb) async {
    languageRepository = LanguageRepository._();
    languageRepository.mongoDb = mongoDb;
    await languageRepository._getWordCollection();
    await languageRepository._getPhraseCollection();
    sharedPreferences = await SharedPreferences.getInstance();
    return languageRepository;
  }

  Future<DbCollection> _getCollection(String collectionName) async {
    return await mongoDb.collection(collectionName);
  }

  Future<DbCollection> _getWordCollection() async {
    wordCollection ??= await _getCollection(Constants.wordCollection);
    return wordCollection!;
  }

  Future<DbCollection> _getPhraseCollection() async {
    phraseCollection ??= await _getCollection(Constants.phraseCollection);
    return phraseCollection!;
  }

  Future<WordInfo?> getWord(String word) async {
    Map<String, dynamic>? jsonMap = await wordCollection!.findOne(
      where.eq('word', word),
    );
    if (jsonMap == null) {
      return null;
    }
    return WordInfo.fromJson(jsonMap);
  }

  Future<WriteResult> updateWord(WordInfo word) async {
    Map<String, dynamic> jsonMap = word.toJson();
    WriteResult writeResult = await wordCollection!.replaceOne(
      where.eq('word', word.word),
      jsonMap,
    );
    return writeResult;
  }

  Future<WriteResult> saveWord(WordInfo word) async {
    Map<String, dynamic> jsonMap = word.toJson();
    WriteResult writeResult = await wordCollection!.insertOne(jsonMap);
    return writeResult;
  }

  List<String> getGenders() {
    return GermanGender.values.map((gender) => gender.displayName).toList();
  }

  Future<WriteResult> deleteWord(WordInfo word) async {
    WriteResult writeResult = await wordCollection!.deleteOne(
      where.eq('word', word.word),
    );
    return writeResult;
  }

  Future<String> getEnglishTranslation(String word) async {
    try {
      final translation = await TranslationService.translateText(
        text: word,
        targetLanguage: 'en', // Or your app's target language
        sourceLanguage: 'de',
      );
      // return the translation
      return translation;
    } catch (e) {
      // 1. Log the error locally if needed
      print("Repository Error: $e");
      // 2. Rethrow so the Cubit can catch it and emit the ErrorState
      //throw Exception("Translation failed: $e");
      return "";
    }
  }

  Future<String> getGermanTranslation(String word) async {
    try {
      final translation = await TranslationService.translateText(
        text: word,
        targetLanguage: 'de', // Or your app's target language
        sourceLanguage: 'en',
      );
      // return the translation
      return translation;
    } catch (e) {
      // 1. Log the error locally if needed
      print("Repository Error: $e");
      // 2. Rethrow so the Cubit can catch it and emit the ErrorState
     // throw Exception("Translation failed: $e");
      return "";
    }
  }

  Future<List<WordInfo>> getListOfWordsFromType(String type) async {
    // 1. Query the collection.
    // In mongo_dart, if 'type' is a list in the DB, where.eq will find items containing the value.
    final List<Map<String, dynamic>> jsonList = await wordCollection!
        .find(where.eq('type', type))
        .toList();

    // 2. Map the list of JSON maps to a list of WordInfo objects
    return jsonList.map((json) => WordInfo.fromJson(json)).toList();
  }

}
