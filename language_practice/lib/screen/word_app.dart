import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:language_practice/screen/type_word_widget.dart';
import '../repository/language_repository.dart';
import '../word_bloc/word_cubit.dart';

// ─── App Entry ───────────────────────────────────────────────────────────────
class WordApp extends StatelessWidget {
  const WordApp({super.key});


  @override
  Widget build(BuildContext context) {
    final GetIt getIt = GetIt.instance;
    return MaterialApp(
      title: 'Word Detail',

      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
      ),
      home: BlocProvider(
        create: (_) => WordCubit(repository: getIt<LanguageRepository>()),
        child: TypeWordWidget(),

      ));
  }


}
