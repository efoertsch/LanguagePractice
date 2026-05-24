import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:language_practice/language_entry/language_entry.dart';
import 'package:language_practice/phrase/phrase_bloc/phrase_cubit.dart';
import 'package:language_practice/rule/rule_bloc/rule_cubit.dart';
import 'package:language_practice/word_screen/word_bloc/word_cubit.dart';

import '../quiz_widgets/quiz_bloc/quiz_cubit.dart';

// ─── App Entry ───────────────────────────────────────────────────────────────
class LanguageApp extends StatelessWidget {
  const LanguageApp({super.key});

  @override
  Widget build(BuildContext context) {
    final GetIt getIt = GetIt.instance;
    return MaterialApp(
      title: 'Language Practice',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: false),
      home: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => getIt<WordCubit>()),
          BlocProvider(create: (_) => getIt<PhraseCubit>()),
          BlocProvider(create: (_) => getIt<RuleCubit>()),
          BlocProvider(create: (_) => getIt<QuizCubit>()),
        ],
        child: LanguageEntry(),
      ),
    );
  }
}
