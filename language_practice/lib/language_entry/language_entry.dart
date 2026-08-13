import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'
    show BlocProvider, MultiBlocProvider;
import 'package:get_it/get_it.dart';
import 'package:language_practice/phrase/phrase_bloc/phrase_cubit.dart';
import 'package:language_practice/phrase/phrase_widgets/type_phrase_widget.dart';
import 'package:language_practice/quiz_widgets/master_quiz.dart';
import 'package:language_practice/rule/rule_bloc/rule_cubit.dart';
import 'package:language_practice/rule/rule_widgets/type_rule_widget.dart';
import 'package:language_practice/word_screen/type_word_widget.dart';
import 'package:language_practice/word_screen/word_bloc/word_cubit.dart';
import 'package:language_practice/word_screen/word_widgets/word_type_mixin.dart';

import '../app/AppStateWidget.dart';
import '../quiz_widgets/quiz_bloc/quiz_cubit.dart';

class LanguageEntry extends StatefulWidget {
  const LanguageEntry({super.key});

  @override
  State<LanguageEntry> createState() => _LanguageEntryState();

}

class _LanguageEntryState extends AppStateWidget<LanguageEntry>
    with WidgetsBindingObserver, WordTypeMixin {
  String? _defaultWordType = null;
  final getIt = GetIt.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }



  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   if (state == AppLifecycleState.resumed) {
  //     // Force a UI refresh when the app and OS wake up
  //     setState(() {});
  //   }
 // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Language Entry"),
        backgroundColor: Colors.blue,
        centerTitle: true,
        actions: _getMenu(context),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header for Word Section
            _buildSectionHeader(context, "Word", Colors.blue),
            TypeWordWidget(defaultWordType: _defaultWordType),
            const Divider(height: 20, thickness: 2),
            // Header for Phrase Section
            _buildSectionHeader(context, "Phrase", Colors.green),
            TypePhraseWidget(),
            const Divider(height: 20, thickness: 2),
            _buildSectionHeader(context, "Grammar Rules", Colors.deepPurple),
            const TypeRuleWidget(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: color.withValues(alpha: 0.1),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  List<Widget> _getMenu(BuildContext context) {
    return <Widget>[
      TextButton(
        child: Text("Quiz", style: TextStyle(color: Colors.white)),
        onPressed: () {
          _navigateToMasterQuiz(context);
        },
      ),
    ];
  }


  void _navigateToMasterQuiz(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => getIt<WordCubit>()),
            BlocProvider(create: (_) => getIt<PhraseCubit>()),
            BlocProvider(create: (_) => getIt<RuleCubit>()),
            BlocProvider(create: (_) => getIt<QuizCubit>()),
          ],
          child: const MasterQuizViewer(),
        ),
      ),
    );
  }
}
