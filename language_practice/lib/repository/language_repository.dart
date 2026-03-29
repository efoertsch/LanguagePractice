import 'package:language_practice/enums/word_enums.dart';
import 'package:mongo_dart/mongo_dart.dart';

import '../app/constants.dart' show Constants;
import '../language_classes/word.dart';

class LanguageRepository {
  static late final String collectionName = Constants.wordCollection;
  late final Db mongoDb;
  static late final LanguageRepository languageRepository;

  DbCollection? wordCollection;
  DbCollection? phraseCollection;

  //LanguageRepository({required this.mongoDb});

  LanguageRepository._();

  static Future<LanguageRepository> create(Db mongoDb) async {
    languageRepository = LanguageRepository._();
    languageRepository.mongoDb = mongoDb;
    await languageRepository._getWordCollection();
    await languageRepository._getPhraseCollection();
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

  Future<Word> getWord(String word) async {
    Map<String, dynamic>? jsonMap  = await wordCollection!.findOne(where.eq('word', word));
    if (jsonMap == null) {
      return Word(word:"", type:[ WordType.noun.displayName]);
    }
    return Word.fromJson(jsonMap);
  }

  Future<void> replaceWord(Word word) async {
     Map<String, dynamic> jsonMap =  word.toJson();
     await wordCollection!.replaceOne(where.eq('word', word.word), jsonMap);
  }


  Future<void> addWord(Word word) async {
    Map<String, dynamic> jsonMap =  word.toJson();
    await wordCollection?.insertOne(jsonMap);
  }
}
