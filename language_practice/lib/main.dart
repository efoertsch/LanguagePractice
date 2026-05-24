
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:language_practice/language_app/language_app.dart';
import 'package:language_practice/phrase/phrase_bloc/phrase_cubit.dart' show PhraseCubit;
import 'package:language_practice/quiz_widgets/quiz_bloc/quiz_cubit.dart';
import 'package:language_practice/repository/language_repository.dart';
import 'package:language_practice/repository/mongo_db_connector.dart';
import 'package:language_practice/rule/rule_bloc/rule_cubit.dart';
import 'package:language_practice/word_screen/word_bloc/word_cubit.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:package_info_plus/package_info_plus.dart';

// Create a global instance (or use GetIt.instance)
final getIt = GetIt.instance;


void main() async {
  late final Db mongoDb;
  // 1. Required for performing async operations before runApp
  WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp();
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  print("Bundle ID: ${packageInfo.packageName}"); // Returns com.example.app

  // 2. Initialize the MongoDB connection
  try {
    await MongoDBConnector.connect();
      mongoDb = await MongoDBConnector.database;
      LanguageRepository languageRepository  = await LanguageRepository.create(mongoDb);
    getIt.registerSingleton<LanguageRepository>(languageRepository);
    getIt.registerFactory(() => WordCubit(repository: getIt<LanguageRepository>()));
    getIt.registerFactory(() => PhraseCubit(repository: getIt<LanguageRepository>()));
    getIt.registerFactory(() => RuleCubit(repository: getIt<LanguageRepository>()));
    getIt.registerFactory(() => QuizCubit(repository: getIt<LanguageRepository>()));
    runApp(const LanguageApp());
  } catch (e) {
    // Log the error or handle it (e.g., show a "Database Offline" screen later)
    debugPrint('Failed to connect to MongoDB: $e');
  }



}