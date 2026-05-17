
import 'package:language_practice/repository/language_classes/phrase.dart';
import 'package:language_practice/repository/language_classes/rule.dart';
import 'package:language_practice/repository/language_classes/word_info.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app/constants.dart' show Constants;
import '../enums/word_enums.dart' show GermanGender;
import '../translation_service/translation_service.dart';

class LanguageRepository {
  late final Db mongoDb;
  static late final LanguageRepository languageRepository;
  static late final SharedPreferences sharedPreferences;

  DbCollection? wordCollection;
  DbCollection? phraseCollection;
  DbCollection? ruleCollection;

  //LanguageRepository({required this.mongoDb});

  LanguageRepository._();

  static Future<LanguageRepository> create(Db mongoDb) async {
    languageRepository = LanguageRepository._();
    languageRepository.mongoDb = mongoDb;
    await languageRepository._getWordCollection();
    await languageRepository._getPhraseCollection();
    await languageRepository._getRuleCollection();
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

  Future<DbCollection> _getRuleCollection() async {
    ruleCollection ??= await _getCollection(Constants.ruleCollection);
    return ruleCollection!;
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

  Future<String> getGermanTranslation(String wordOrPhrase) async {
    try {
      final translation = await TranslationService.translateText(
        text: wordOrPhrase,
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

  Future<List<WordInfo>> getQuizWordsForTypes(String type) async {
    // 1. Query the collection.
    // In mongo_dart, if 'type' is a list in the DB,
    // where.eq will find items containing the value.
    final List<Map<String, dynamic>> jsonList = await wordCollection!
        .find(where.eq('type', type).and( where.lte('quiz_score',0)))
        .toList();

    // 2. Map the list of JSON maps to a list of WordInfo objects
    return jsonList.map((json) => WordInfo.fromJson(json)).toList();
  }

  Future<WriteResult> updateQuizScore(ObjectId id, int increment) async {
    return await wordCollection!.updateOne(
      where.id(id),
      modify.inc('quiz_score', increment), // This adds the integer (e.g., -1 or 1) to the current 'score' field
    );
  }

  Future<Phrase?> getPhrase(String spelledPhrase) async {
    Map<String, dynamic>? jsonMap = await phraseCollection!.findOne(
      where.eq('phrase', spelledPhrase),
    );
    if (jsonMap == null) {
      return null;
    }
    return Phrase.fromJson(jsonMap);
  }


  Future<WriteResult> savePhrase(Phrase phrase) async {
    Map<String, dynamic> jsonMap = phrase.toJson();
    WriteResult writeResult = await phraseCollection!.insertOne(jsonMap);
    return writeResult;
  }

  Future<WriteResult> updatePhrase(Phrase phrase) async {
    Map<String, dynamic> jsonMap = phrase.toJson();
    WriteResult writeResult = await phraseCollection!.replaceOne(
      where.eq('phrase', phrase.phrase),
      jsonMap,
    );
    return writeResult;
  }

  Future<WriteResult> deletePhrase(Phrase phrase) async {
    WriteResult writeResult = await phraseCollection!.deleteOne(
      where.eq('phrase', phrase.phrase),
    );
    return writeResult;
  }

  Future<Rule?> getRule(String ruleName) async {
    Map<String, dynamic>? jsonMap = await ruleCollection!.findOne(
      where.eq('rule', ruleName),
    );
    if (jsonMap == null) {
      return null;
    }
    return Rule.fromJson(jsonMap);
  }

  Future<WriteResult> saveRule(Rule rule) async {
    Map<String, dynamic> jsonMap = rule.toJson();
    WriteResult writeResult = await ruleCollection!.insertOne(jsonMap);
    return writeResult;
  }

  Future<WriteResult> updateRule(Rule rule) async {
    Map<String, dynamic> jsonMap = rule.toJson();
    WriteResult writeResult = await ruleCollection!.replaceOne(
      where.eq('rule', rule.rule),
      jsonMap,
    );
    return writeResult;
  }

  Future<WriteResult> deleteRule(Rule rule) async {
    WriteResult writeResult = await ruleCollection!.deleteOne(
      where.eq('rule', rule.rule),
    );
    return writeResult;
  }


}

