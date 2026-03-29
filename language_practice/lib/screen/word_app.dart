import 'package:flutter/material.dart';
import 'input_word.dart';


// ─── App Entry ───────────────────────────────────────────────────────────────
class WordApp extends StatelessWidget {
  const WordApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Word Detail',

      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
      ),
      //  theme: ThemeData(
      // //   colorScheme: ColorScheme.fromSeed(
      // //     seedColor: const Color(0xFF1A1A2E),
      // //     brightness: Brightness.dark,
      // //   ),
      //    // Set global scaffold background to white
      //    scaffoldBackgroundColor: Colors.white,
      //    // Optional: Ensure other theme elements are light if needed
      //    brightness: Brightness.light,
      //   useMaterial3: true,
      //   fontFamily: 'Georgia',
      // ),
      home: //DisplayWordScreen(word: sampleWord),
       InputWordScreen(stringWord: "fahren"),

    );
  }


}
