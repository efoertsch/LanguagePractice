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
    WriteResult writeResult = await wordCollection!.replaceOne(
      where.id(word.id!),
      word.toJson(),
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


  Future<List<WordInfo>> getQuizWordsForTypes({
    String? type,
    int? score,
    int? limit = 10,
  }) async {
    // 1. Initialize empty selector
    SelectorBuilder query = where;
    SelectorBuilder typeQuery = where;
    if (score != null) {
      query.lte('quiz_score', score);
    }
    if (type != null && type.isNotEmpty) {
      if (query.map.isEmpty) {
        query.eq('type', type);
      } else {
        typeQuery = where.eq('type', type);
        query.and(typeQuery);
      }
    };
    if (limit != null){
      query.limit(limit);
    }

    List<Map<String, dynamic>> jsonList = await wordCollection!
        .find(query)
        .toList();

    return jsonList.map((json) => WordInfo.fromJson(json)).toList();
  }

  Future<WriteResult> updateWordQuizScore(ObjectId id, int increment) async {
    return await wordCollection!.updateOne(
      where.id(id),
      modify.inc(
        'quiz_score',
        increment,
      ), // This adds the integer (e.g., -1 or 1) to the current 'score' field
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
    WriteResult writeResult = await phraseCollection!.replaceOne(
      where.id(phrase.id!),
      phrase.toJson(),
    );
    return writeResult;
  }

  Future<WriteResult> deletePhrase(Phrase phrase) async {
    WriteResult writeResult = await phraseCollection!.deleteOne(
      where.eq('phrase', phrase.phrase),
    );
    return writeResult;
  }

  Future<WriteResult> updatePhraseQuizScore(ObjectId id, int increment) async {
    return await phraseCollection!.updateOne(
      where.id(id),
      modify.inc(
        'quiz_score',
        increment,
      ), // This adds the integer (e.g., -1 or 1) to the current 'score' field
    );
  }

  Future<List<Phrase>> getQuizPhrases({
    int? score = 0,
    int? limit = 10,
    List<String>? filterTypes
  }) async {
    SelectorBuilder query = where;
    query.lte('quiz_score', score);
    query.limit(limit!);
  if (filterTypes == null || filterTypes.isEmpty) {
    final List<Map<String, dynamic>> jsonList = await phraseCollection!
        .find(query)
        .toList();
  } else {
    for (String type in filterTypes) {
      SelectorBuilder typeQuery = where.eq('type', type);
      query.and(typeQuery);
    }
  }
    final List<Map<String, dynamic>> jsonList = await phraseCollection!
        .find(query)
        .toList();

    return jsonList.map((json) => Phrase.fromJson(json)).toList();
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
    WriteResult writeResult = await ruleCollection!.replaceOne(
      where.id(rule.id!),
      rule.toJson(),
    );
    return writeResult;
  }

  Future<WriteResult> deleteRule(Rule rule) async {
    WriteResult writeResult = await ruleCollection!.deleteOne(
      where.eq('rule', rule.rule),
    );
    return writeResult;
  }

  Future<WriteResult> updateRuleQuizScore(ObjectId id, int increment) async {
    return await ruleCollection!.updateOne(
      where.id(id),
      modify.inc(
        'quiz_score',
        increment,
      ), // This adds the integer (e.g., -1 or 1) to the current 'score' field
    );
  }

  Future<List<Rule>> getQuizRulesForTypes({
    String? type,
    int? score,
    int? limit = 10,
  }) async {
    SelectorBuilder query = where;
    SelectorBuilder typeQuery = where;
    if (score != null) {
      query.lte('quiz_score', score);
    }
    if (type != null && type.isNotEmpty) {
      typeQuery = where.eq('type', type);
      query.and(typeQuery);
    }
    if (limit != null){
      query.limit(limit);
    }
    final List<Map<String, dynamic>> jsonList = await ruleCollection!
        .find(query)
        .toList();

    // 2. Map the list of JSON maps to a list of WordInfo objects
    return jsonList.map((json) => Rule.fromJson(json)).toList();
  }
}
