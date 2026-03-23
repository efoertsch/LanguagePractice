// ─── Sample Data ─────────────────────────────────────────────────────────────
import 'package:language_practice/language_classes/word.dart';

final sampleWord = Word(
  word: 'gehen',
  english: ['to go', 'to walk', 'to leave'],
  type:  ['verb', 'intransitive', 'irregular'],
  tenses:  [
    Tense(
      tense: 'Present (Präsens)',
      s1stPersonSingular: 'gehe',
      s2ndPersonSingular: 'gehst',
      s3rdPersonSingular: 'geht',
      s1stPersonPlural: 'gehen',
      s2ndPersonPlural: 'geht',
      s3rdPersonPlural: 'gehen',
      helperVerb: 'sein',
      pastParticiple: 'gegangen',
    ),
    Tense(
      tense: 'Past (Präteritum)',
      s1stPersonSingular: 'ging',
      s2ndPersonSingular: 'gingst',
      s3rdPersonSingular: 'ging',
      s1stPersonPlural: 'gingen',
      s2ndPersonPlural: 'gingt',
      s3rdPersonPlural: 'gingen',
      helperVerb: 'sein',
      pastParticiple: 'gegangen',
    ),
  ],
);
