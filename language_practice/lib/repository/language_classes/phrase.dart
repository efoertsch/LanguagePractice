import 'package:mongo_dart/mongo_dart.dart' show ObjectId;

class Phrase {
  ObjectId? _id;
  String? _phrase;
  String? _english;
  String? _usage;
  int? _quizScore;
  // temp field

  Phrase({
    ObjectId? id,
    String? phrase,
    String? english,
    List<String>? type,
    String? usage,
    int? quizScore
  }) {
    if (id != null) {
      _id = id;
    }
    if (phrase != null) {
      this._phrase = phrase;
    }
    if (english != null) {
      this._english = english;
    }
    if (usage != null) {
      this._usage = usage;
    }
    if (quizScore != null) {
      _quizScore = quizScore;
    } else {
      _quizScore = 0;
    }
  }

  ObjectId? get id => _id;

  set id(ObjectId? id) => _id = id;

  String? get phrase => _phrase;

  set phrase(String? phrase) => _phrase = phrase;

  String? get english => _english;

  set english(String? english) => _english = english;

  String? get usage => _usage;

  set usage(String? usage) => _usage = usage;

  set quizScore(int? quizScore) => _quizScore = quizScore;
  int? get quizScore => _quizScore;


  //temp field
  bool get previouslyEntered => _id != null;

  Phrase.fromJson(Map<String, dynamic> json) {
    _id = json['_id'];
    _phrase = json['phrase'];
    _english = json['english'];
    _usage = json['usage'];
    _quizScore=json['quiz_score'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = _id;
    data['phrase'] = this._phrase;
    data['english'] = this._english;
    data['usage'] = this._usage;
    data['quiz_score'] = _quizScore;
    return data;
  }
}
