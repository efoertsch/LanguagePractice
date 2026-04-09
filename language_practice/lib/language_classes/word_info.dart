import 'package:mongo_dart/mongo_dart.dart';

class WordInfo {
  ObjectId? _id;
  String? _word;
  List<String>? _english;
  int? _quizErrors;

  String? _plural;
  String? _gender;
  List<String>? _type;
  String? _verbConjugationClass;
  String? _verbFunctionalType;
  List<Tense>? _tenses;
  List<Rules>? _rules;
  bool _previouslyEntered = false; // temp field

  WordInfo({
    ObjectId? id,
    String? word,
    List<String>? english,
    int? quizErrors,
    String? plural,
    String? gender,
    List<String>? type,
    String? verbConjugationClass,
    String? verbFunctionalType,
    List<Tense>? tenses,
    List<Rules>? rules,
  }) {
    if (id != null){
      _id = id;
    }
    if (word != null) {
      _word = word;
    }
    if (english != null) {
      _english = english;
    }
    if (quizErrors != null) {
      _quizErrors = quizErrors;
    } else {
      _quizErrors = 0;
    }
    if (plural != null) {
      _plural = plural;
    }
    if (gender != null) {
      _gender = gender;
    }
    if (type != null) {
      _type = type;
    }
    if (verbConjugationClass != null) {
      _verbConjugationClass = verbConjugationClass;
    }
    if (verbFunctionalType != null) {
      _verbFunctionalType = verbFunctionalType;
    }
    if (tenses != null) {
      _tenses = tenses;
    }
    if (rules != null) {
      _rules = rules;
    }
  }

  ObjectId? get id => _id;

  set id(ObjectId? id) => _id = id;

  String? get word => _word;

  set word(String? word) => _word = word;

  List<String>? get english => _english;

  set english(List<String>? english) => _english = english;

  set quizErrors(int? quizerrors) => _quizErrors = quizerrors;

  String? get plural => _plural;

  set plural(String? plural) => _plural = plural;

  String? get gender => _gender;

  set gender(String? gender) => _gender = gender;

  List<String>? get type => _type;

  set type(List<String>? type) => _type = type;

  String? get verbConjugationClass => _verbConjugationClass;

  set verbConjugationClass(String? verbConjugationClass) =>
      _verbConjugationClass = verbConjugationClass;

  String? get verbFunctionalType => _verbFunctionalType;

  set verbFunctionalType(String? verbFunctionalType) =>
      _verbFunctionalType = verbFunctionalType;

  List<Tense>? get tenses => _tenses;

  set tenses(List<Tense>? tenses) => _tenses = tenses;

  List<Rules>? get rules => _rules;

  set rules(List<Rules>? rules) => _rules = rules;

  bool get previouslyEntered => _previouslyEntered;

  set previouslyEntered(bool value) => _previouslyEntered = value;


  WordInfo.fromJson(Map<String, dynamic> json) {
    _id = json['_id'];
    _word = json['word'];
    _english = <String>[];
    if (json['english'] != null) {
      json['english'].forEach((v) {
        _english!.add(v);
      });
    }
    _quizErrors=json['quiz_errors'];
    _plural = json['plural'];
    _gender = json['gender'];

    _type = <String>[];
    if (json['type'] != null) {
      json['type'].forEach((v){_type!.add(v);});
    }

    _verbConjugationClass = json['verb_conjugation_class'];
    _verbFunctionalType = json['verb_functional_type'];
    if (json['tenses'] != null) {
      _tenses = <Tense>[];
      json['tenses'].forEach((v) {
        _tenses!.add(new Tense.fromJson(v));
      });
    }
    if (json['rules'] != null) {
      _rules = <Rules>[];
      json['rules'].forEach((v) {
        _rules!.add(Rules.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['_id'] = _id;
    data['word'] = _word;
    data['english'] = _english;
    data['quizErrors'] = _quizErrors;
    data['plural'] = _plural;
    data['gender'] = _gender;
    data['type'] = _type;
    data['verb_conjugation_class'] = _verbConjugationClass;
    data['verb_functional_type'] = _verbFunctionalType;
    if (_tenses != null) {
      data['tenses'] = _tenses!.map((v) => v.toJson()).toList();
    }
    if (_rules != null) {
      data['rules'] = _rules!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Tense {
  String? _tense;
  String? _english;
  String? _s1stPersonSingular;
  String? _s2ndPersonSingular;
  String? _s3rdPersonSingular;
  String? _s1stPersonPlural;
  String? _s2ndPersonPlural;
  String? _s3rdPersonPlural;
  String? _helperVerb;
  String? _pastParticiple;

  Tense({
    String? tense,
    String? english,
    String? s1stPersonSingular,
    String? s2ndPersonSingular,
    String? s3rdPersonSingular,
    String? s1stPersonPlural,
    String? s2ndPersonPlural,
    String? s3rdPersonPlural,
    String? helperVerb,
    String? pastParticiple,
  }) {
    if (tense != null) {
      _tense = tense;
    }
    if (english != null) {
      _english = english;
    }
    if (s1stPersonSingular != null) {
      _s1stPersonSingular = s1stPersonSingular;
    }
    if (s2ndPersonSingular != null) {
      _s2ndPersonSingular = s2ndPersonSingular;
    }
    if (s3rdPersonSingular != null) {
      _s3rdPersonSingular = s3rdPersonSingular;
    }
    if (s1stPersonPlural != null) {
      _s1stPersonPlural = s1stPersonPlural;
    }
    if (s2ndPersonPlural != null) {
      _s2ndPersonPlural = s2ndPersonPlural;
    }
    if (s3rdPersonPlural != null) {
      _s3rdPersonPlural = s3rdPersonPlural;
    }
    if (helperVerb != null) {
      _helperVerb = helperVerb;
    }
    if (pastParticiple != null) {
      _pastParticiple = pastParticiple;
    }
  }

  String? get tense => _tense;

  set tense(String? tense) => _tense = tense;

  String? get english => _english;

  set english(String? english) => _english = english;


  String? get s1stPersonSingular => _s1stPersonSingular;

  set s1stPersonSingular(String? s1stPersonSingular) =>
      _s1stPersonSingular = s1stPersonSingular;

  String? get s2ndPersonSingular => _s2ndPersonSingular;

  set s2ndPersonSingular(String? s2ndPersonSingular) =>
      _s2ndPersonSingular = s2ndPersonSingular;

  String? get s3rdPersonSingular => _s3rdPersonSingular;

  set s3rdPersonSingular(String? s3rdPersonSingular) =>
      _s3rdPersonSingular = s3rdPersonSingular;

  String? get s1stPersonPlural => _s1stPersonPlural;

  set s1stPersonPlural(String? s1stPersonPlural) =>
      _s1stPersonPlural = s1stPersonPlural;

  String? get s2ndPersonPlural => _s2ndPersonPlural;

  set s2ndPersonPlural(String? s2ndPersonPlural) =>
      _s2ndPersonPlural = s2ndPersonPlural;

  String? get s3rdPersonPlural => _s3rdPersonPlural;

  set s3rdPersonPlural(String? s3rdPersonPlural) =>
      _s3rdPersonPlural = s3rdPersonPlural;

  String? get helperVerb => _helperVerb;

  set helperVerb(String? helperVerb) => _helperVerb = helperVerb;

  String? get pastParticiple => _pastParticiple;

  set pastParticiple(String? pastParticiple) =>
      _pastParticiple = pastParticiple;

  Tense.fromJson(Map<String, dynamic> json) {
    _tense = json['tense'];
    _english = json['english'];
    _s1stPersonSingular = json['1st_person_singular'];
    _s2ndPersonSingular = json['2nd_person_singular'];
    _s3rdPersonSingular = json['3rd_person_singular'];
    _s1stPersonPlural = json['1st_person_plural'];
    _s2ndPersonPlural = json['2nd_person_plural'];
    _s3rdPersonPlural = json['3rd_person_plural'];
    _helperVerb = json['helper_verb'];
    _pastParticiple = json['past_participle'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['tense'] = _tense;
    data['english'] = _english;
    data['1st_person_singular'] = _s1stPersonSingular;
    data['2nd_person_singular'] = _s2ndPersonSingular;
    data['3rd_person_singular'] = _s3rdPersonSingular;
    data['1st_person_plural'] = _s1stPersonPlural;
    data['2nd_person_plural'] = _s2ndPersonPlural;
    data['3rd_person_plural'] = _s3rdPersonPlural;
    data['helper_verb'] = _helperVerb;
    data['past_participle'] = _pastParticiple;
    return data;
  }
}

class Rules {
  String? _type;
  String? _rule;

  Rules({String? type, String? rule}) {
    if (type != null) {
      _type = type;
    }
    if (rule != null) {
      _rule = rule;
    }
  }

  String? get type => _type;

  set type(String? type) => _type = type;

  String? get rule => _rule;

  set rule(String? rule) => _rule = rule;

  Rules.fromJson(Map<String, dynamic> json) {
    _type = json['type'];
    _rule = json['rule'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = _type;
    data['rule'] = _rule;
    return data;
  }
}
