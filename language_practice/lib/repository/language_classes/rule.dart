import 'package:mongo_dart/mongo_dart.dart' show ObjectId;

class Rule {
  ObjectId? _id;
  String? _rule;
  String? _explanation;
  List<String>? _type;
  String? _example;
  int? _quizScore;

  Rule({
    ObjectId? id,
    String? rule,
    String? explanation,
    List<String>? type,
    String? example,
    int? quizScore
  }) {
    if (id != null) {
      _id = id;
    }
    if (rule != null) {
      this._rule = rule;
    }
    if (explanation != null) {
      this._explanation = explanation;
    }
    if (type != null) {
      _type = type;
    }
    if (example != null) {
      this._example = example;
    }
    if (quizScore != null) {
      _quizScore = quizScore;
    } else {
      _quizScore = 0;
    }

  }

  ObjectId? get id => _id;

  set id(ObjectId? id) => _id = id;

  String? get rule => _rule;

  set rule(String? rule) => _rule = rule;

  String? get explanation => _explanation;

  set explanation(String? explanation) => _explanation = explanation;

  List<String>? get type => _type;

  set type(List<String>? type) => _type = type;

  String? get example => _example;

  set example(String? example) => _example = example;

  set quizScore(int? quizScore) => _quizScore = quizScore;

  int? get quizScore => _quizScore;

  @override
  String toString() {
    return 'Rule{_id: $_id, _rule: $_rule, _explanation: $_explanation, _type: $_type, _example: $_example}';
  }

  Rule.fromJson(Map<String, dynamic> json) {
    _id = json['_id'];
    _rule = json['rule'];
    _explanation = json['explanation'];
    _type = <String>[];
    if (json['type'] != null) {
      json['type'].forEach((v){_type!.add(v);});
    }
    _example = json['example'];
    _quizScore=json['quiz_score'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = _id;
    data['rule'] = this._rule;
    data['explanation'] = this._explanation;
    data['type'] = _type;
    data['example'] = this._example;
    data['quiz_score'] = _quizScore;
    return data;
  }
}
