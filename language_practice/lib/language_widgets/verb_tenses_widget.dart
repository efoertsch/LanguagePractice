import 'package:flutter/material.dart';
import 'package:language_practice/language_classes/word.dart';

import '../app/constants.dart' show Constants;
import '../enums/word_enums.dart' show VerbTense;

class WordTensesWidget extends StatefulWidget {
  final List<Tense> tenses;
  final Function(int, Tense) onTenseChanged;

  const WordTensesWidget({
    super.key,
    required this.tenses,
    required this.onTenseChanged,
  });

  @override
  State<WordTensesWidget> createState() => _WordTensesWidgetState();
}

class _WordTensesWidgetState extends State<WordTensesWidget> {
  int _activeTenseIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.tenses.isEmpty) return const SizedBox.shrink();

    final currentTense = widget.tenses[_activeTenseIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Tenses",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        // Tense Selector (Tabs)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: widget.tenses.asMap().entries.map((entry) {
              int idx = entry.key;
              bool isSelected = _activeTenseIndex == idx;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  selectedColor: Colors.green.shade50,
                  backgroundColor: Colors.white,
                  label: Text(entry.value.tense ?? "Unnamed"),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _activeTenseIndex = idx);
                  },
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 16),

        // Horizontal Input Fields for the Selected Tense
        // _buildTenseInput("Tense Name", currentTense.tense ?? "", (val) {
        //   currentTense.tense = val;
        //   widget.onTenseChanged(_activeTenseIndex, currentTense);
        // }),
        if (currentTense.tense != null &&
            currentTense.tense == VerbTense.present_perfect.germanTense)
          ..._getPresentPerfectFields(currentTense),
        if (currentTense.tense != null &&
            currentTense.tense != VerbTense.present_perfect.germanTense)
        ..._getFullVerbConjugationFields(currentTense)

      ],
    );
  }

  Widget _buildTenseInput(String label, String value, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 50, // Matches your existing horizontal label pattern
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              initialValue: value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              key: Key("${_activeTenseIndex}_$label"), // Forces rebuild when switching tenses
              onChanged: onChanged,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _getPresentPerfectFields(Tense currentTense) {
    return [
    _buildTenseInput("Helper Verb", currentTense.helperVerb ?? "", (val) {
      currentTense.helperVerb = val;
      widget.onTenseChanged(_activeTenseIndex, currentTense);
    }),
    _buildTenseInput("Past Part.", currentTense.pastParticiple ?? "", (val) {
    currentTense.pastParticiple = val;
    widget.onTenseChanged(_activeTenseIndex, currentTense);
    })];
  }

  List<Widget> _getFullVerbConjugationFields(Tense currentTense) {
    return [

      Row(
        children: [
          Expanded(
            child: _buildTenseInput(Constants.deNominativePronouns[0], currentTense.s1stPersonSingular ?? "", (val) {
              currentTense.s1stPersonSingular = val;
              widget.onTenseChanged(_activeTenseIndex, currentTense);
            }),
          ),
          SizedBox(width: 10),
          Expanded(
            child: _buildTenseInput(Constants.deNominativePronouns[3], currentTense.s1stPersonPlural ?? "", (val) {
              currentTense.s1stPersonPlural = val;
              widget.onTenseChanged(_activeTenseIndex, currentTense);
            }),
          ),
        ],
      ),

      Row(
        children: [
          Expanded(
            child: _buildTenseInput(Constants.deNominativePronouns[1], currentTense.s2ndPersonSingular ?? "", (val) {
              currentTense.s2ndPersonSingular = val;
              widget.onTenseChanged(_activeTenseIndex, currentTense);
            }),
          ),
          SizedBox(width: 10),
          Expanded(
            child: _buildTenseInput(Constants.deNominativePronouns[4], currentTense.s2ndPersonPlural ?? "", (val) {
              currentTense.s2ndPersonPlural = val;
              widget.onTenseChanged(_activeTenseIndex, currentTense);
            }),
          ),
        ],
      ),
      Row(
        children: [
          Expanded(
            child: _buildTenseInput(Constants.deNominativePronouns[2], currentTense.s3rdPersonSingular ?? "", (val) {
              currentTense.s3rdPersonSingular = val;
              widget.onTenseChanged(_activeTenseIndex, currentTense);
            }),
          ),
          SizedBox(width: 10),
          Expanded(
            child: _buildTenseInput(Constants.deNominativePronouns[5], currentTense.s3rdPersonPlural ?? "", (val) {
              currentTense.s3rdPersonPlural = val;
              widget.onTenseChanged(_activeTenseIndex, currentTense);
            }),
          ),
        ],
      ),
    ];
  }
}