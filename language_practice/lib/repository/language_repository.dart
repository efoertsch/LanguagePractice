import 'package:mongo_dart/mongo_dart.dart';

import '../app/constants.dart' show Constants;
import '../language_classes/word.dart';
import 'mongo_db_connector.dart';

class LanguageRepository {
  final String collectionName =  Constants.collection;
  final Db mongoDb;

  LanguageRepository({ required this.mongoDb});


  Future<Word>  getWord(String word) async{
    Stream<Map<String, dynamic>> jsonStream = await mongoDb.collection(collectionName).find({"word": word});
    List<Map<String, dynamic>> jsonMap= await jsonStream.toList();
    if (jsonMap.isEmpty) {
      throw Exception('{$word} not found');
    }
    return Word.fromJson(jsonMap[0]);
  }
  Future<List<Map<String, dynamic>>> getAllWords() async {
    final db = await MongoDBConnector.database;
    final collection = db.collection(collectionName);

    // Find all documents
    return await collection.find().toList();
  }

  Future<void> addWord(String label, String value) async {
    final db = await MongoDBConnector.database;
    final collection = db.collection(collectionName);

    await collection.insertOne({
      "label": label,
      "value": value,
      "createdAt": DateTime.now().toIso8601String(),
    });
  }


}