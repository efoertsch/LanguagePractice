class Word {
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

  Word({
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
    if (word != null) {
      this._word = word;
    }
    if (english != null) {
      this._english = english;
    }
    if (quizErrors != null) {
      this._quizErrors = quizErrors;
    } else {
      this._quizErrors = 0;
    }
    if (plural != null) {
      this._plural = plural;
    }
    if (gender != null) {
      this._gender = gender;
    }
    if (type != null) {
      this._type = type;
    }
    if (verbConjugationClass != null) {
      this._verbConjugationClass = verbConjugationClass;
    }
    if (verbFunctionalType != null) {
      this._verbFunctionalType = verbFunctionalType;
    }
    if (tenses != null) {
      this._tenses = tenses;
    }
    if (rules != null) {
      this._rules = rules;
    }
  }

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

  Word.fromJson(Map<String, dynamic> json) {
    _word = json['word'];
    _english = <String>[];
     json['english'].forEach((v){_english!.add(v);});
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
        _rules!.add(new Rules.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['word'] = this._word;
    data['english'] = this._english;
    data['quizErrors'] = this._quizErrors;
    data['plural'] = this._plural;
    data['gender'] = this._gender;
    data['type'] = this._type;
    data['verb_conjugation_class'] = this._verbConjugationClass;
    data['verb_functional_type'] = this._verbFunctionalType;
    if (this._tenses != null) {
      data['tenses'] = this._tenses!.map((v) => v.toJson()).toList();
    }
    if (this._rules != null) {
      data['rules'] = this._rules!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Tense {
  String? _tense;
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
      this._tense = tense;
    }
    if (s1stPersonSingular != null) {
      this._s1stPersonSingular = s1stPersonSingular;
    }
    if (s2ndPersonSingular != null) {
      this._s2ndPersonSingular = s2ndPersonSingular;
    }
    if (s3rdPersonSingular != null) {
      this._s3rdPersonSingular = s3rdPersonSingular;
    }
    if (s1stPersonPlural != null) {
      this._s1stPersonPlural = s1stPersonPlural;
    }
    if (s2ndPersonPlural != null) {
      this._s2ndPersonPlural = s2ndPersonPlural;
    }
    if (s3rdPersonPlural != null) {
      this._s3rdPersonPlural = s3rdPersonPlural;
    }
    if (helperVerb != null) {
      this._helperVerb = helperVerb;
    }
    if (pastParticiple != null) {
      this._pastParticiple = pastParticiple;
    }
  }

  String? get tense => _tense;

  set tense(String? tense) => _tense = tense;

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
    data['tense'] = this._tense;
    data['1st_person_singular'] = this._s1stPersonSingular;
    data['2nd_person_singular'] = this._s2ndPersonSingular;
    data['3rd_person_singular'] = this._s3rdPersonSingular;
    data['1st_person_plural'] = this._s1stPersonPlural;
    data['2nd_person_plural'] = this._s2ndPersonPlural;
    data['3rd_person_plural'] = this._s3rdPersonPlural;
    data['helper_verb'] = this._helperVerb;
    data['past_participle'] = this._pastParticiple;
    return data;
  }
}

class Rules {
  String? _type;
  String? _rule;

  Rules({String? type, String? rule}) {
    if (type != null) {
      this._type = type;
    }
    if (rule != null) {
      this._rule = rule;
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
    data['type'] = this._type;
    data['rule'] = this._rule;
    return data;
  }
}
