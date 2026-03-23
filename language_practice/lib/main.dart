import 'package:flutter/material.dart';
import 'package:language_practice/repository/language_repository.dart';
import 'package:language_practice/repository/mongo_db_connector.dart';
import 'package:language_practice/screen/word_app.dart';
import 'package:get_it/get_it.dart';
import 'package:mongo_dart/mongo_dart.dart';

// Create a global instance (or use GetIt.instance)
final getIt = GetIt.instance;

void main() async {
  late final Db mongoDb;
  // 1. Required for performing async operations before runApp
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize the MongoDB connection
  try {
    await MongoDBConnector.connect();
      mongoDb = await MongoDBConnector.database;
    getIt.registerLazySingleton<LanguageRepository>(
            () => LanguageRepository(mongoDb: mongoDb));
    runApp(const WordApp());
  } catch (e) {
    // Log the error or handle it (e.g., show a "Database Offline" screen later)
    debugPrint('Failed to connect to MongoDB: $e');
  }

  // 3. Start the application

  //await MongoDBConnector.close();
}