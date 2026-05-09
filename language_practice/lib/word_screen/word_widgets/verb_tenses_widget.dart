import 'package:flutter/material.dart';
import 'package:language_practice/app/constants.dart' show Constants;
import 'package:language_practice/enums/word_enums.dart';
import 'package:language_practice/language_classes/word_info.dart';
import 'package:language_practice/word_screen/word_widgets/conjugated_tense_widget.dart';

class WordTensesWidget extends StatefulWidget {
  final List<Tense> tenses;
  final Function(int, Tense)? onTenseChanged; // Made optional (?)

  const WordTensesWidget({
    super.key,
    required this.tenses,
    this.onTenseChanged,
  });

  @override
  State<WordTensesWidget> createState() => _WordTensesWidgetState();
}

class _WordTensesWidgetState extends State<WordTensesWidget> {
  int _activeTenseIndex = 0;
  late final ValueNotifier<String> firstAndThirdPersonSingular;
  late final ValueNotifier<String> firstAndThirdPersonPlural;
  late Tense currentTense;
  late final bool isReadOnly;

  @override
  void initState() {
    currentTense = widget.tenses[_activeTenseIndex];
    firstAndThirdPersonSingular = ValueNotifier<String>(
      currentTense.s1stPersonSingular ?? "",
    );
    firstAndThirdPersonPlural = ValueNotifier<String>(
      currentTense.s1stPersonPlural ?? "",
    );
    presentTenseEnglish = ValueNotifier<String>(currentTense.english ?? "");
    isReadOnly = widget.onTenseChanged == null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    currentTense = widget.tenses[_activeTenseIndex];
    if (widget.tenses.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Tenses",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        // Tense Selector (Tabs)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ...widget.tenses.asMap().entries.map((entry) {
                int idx = entry.key;
                bool isSelected = _activeTenseIndex == idx;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: InputChip(
                    // Visual settings to match your ChoiceChip
                    selected: isSelected,
                    showCheckmark: false,
                    selectedColor: Colors.green.shade50,
                    backgroundColor: Colors.white,
                    label: Text(entry.value.tense ?? "Unnamed"),

                    // Selection logic
                    onSelected: (selected) {
                      if (selected) setState(() => _activeTenseIndex = idx);
                    },

                    // DELETE LOGIC
                    onDeleted: widget.onTenseChanged != null
                        ? () {
                            _confirmDeleteTense(idx);
                          }
                        : null,
                    deleteIcon: const Icon(Icons.delete, size: 18),
                    deleteIconColor: Colors.red.shade300,
                  ),
                );
              }).toList(),
              // ADD BUTTON
              if (_getAvailableTenses().isNotEmpty &&
                  widget.onTenseChanged != null)
                IconButton(
                  onPressed: _showAddTenseDialog,
                  tooltip: "Add Tense",
                  icon: const Icon(Icons.add),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        30.0,
                      ), // Customize roundness
                    ),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: Colors.grey.shade200,
                    disabledForegroundColor: Colors.grey,
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 16),
        // English Translation for the selected Tense
        ConjugatedTenseWidget(
          activeTenseIndex: _activeTenseIndex,
          label: "English",
          value: currentTense.english ?? "",
          isReadOnly: isReadOnly,
          onChanged: ((val) {
            currentTense.english = val;
            widget.onTenseChanged?.call(_activeTenseIndex, currentTense);
          }),
          //valueNotifier:
          //currentTense.tense == VerbTense.present.germanTense
          //    ? presentTenseEnglish
          //    : null,
        ),
        const SizedBox(height: 16),
        // Horizontal Input Fields for the Selected Tense
        if (currentTense.tense != null &&
            currentTense.tense == VerbTense.present_perfect.germanTense)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              children: _getPresentPerfectFields(
                currentTense: currentTense,
                isReadOnly: isReadOnly,
              ),
            ),
          ),
        if (currentTense.tense != null &&
            currentTense.tense != VerbTense.present_perfect.germanTense)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              children: _getFullVerbConjugationFields(
                currentTense: currentTense,
                isReadOnly: isReadOnly,
              ),
            ),
          ),
      ],
    );
  }

  void _showAddTenseDialog() {
    // Filter out tenses already present in the list
    final availableTenses = _getAvailableTenses();
    if (availableTenses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All tenses already added.")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Tense"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: availableTenses.length,
            itemBuilder: (context, index) {
              final tense = availableTenses[index];
              return ListTile(
                title: Text(tense.germanTense),
                onTap: () {
                  final newTense = Tense(tense: tense.germanTense);
                  // Add to list and notify parent
                  setState(() {
                    widget.tenses.add(newTense);
                    _activeTenseIndex = widget.tenses.length - 1;
                  });
                  widget.onTenseChanged?.call(_activeTenseIndex, newTense);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _confirmDeleteTense(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Tense?"),
        content: Text(
          "Are you sure you want to remove the ${widget.tenses[index].tense} conjugation?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                widget.tenses.removeAt(index);
                // Adjust active index if we deleted the current or a preceding item
                if (_activeTenseIndex >= widget.tenses.length) {
                  _activeTenseIndex = widget.tenses.isEmpty
                      ? 0
                      : widget.tenses.length - 1;
                }
              });
              // Notify parent of the change (passing null or updated list depending on your architecture)
              // Since we modified the list in place, we just trigger a save-ready event
              if (widget.tenses.isNotEmpty) {
                widget.onTenseChanged?.call(
                  _activeTenseIndex,
                  widget.tenses[_activeTenseIndex],
                );
              }
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  List<VerbTense> _getAvailableTenses() {
    final existingTenses = widget.tenses.map((t) => t.tense).toSet();
    final availableTenses = VerbTense.values
        .where((vt) => !existingTenses.contains(vt.germanTense))
        .toList();
    return availableTenses;
  }

  List<Widget> _getPresentPerfectFields({
    required Tense currentTense,
    required bool isReadOnly,
  }) {
    return [
      ConjugatedTenseWidget(
        activeTenseIndex: _activeTenseIndex,
        label: "Helper Verb",
        value: currentTense.helperVerb ?? "",
        isReadOnly: isReadOnly,
        onChanged: (val) {
          currentTense.helperVerb = val;
          widget.onTenseChanged?.call(
            _activeTenseIndex,
            currentTense,
          ); // Use ?.call
        },
      ),
      ConjugatedTenseWidget(
        activeTenseIndex: _activeTenseIndex,
        label: "Past Part.",
        value: currentTense.pastParticiple ?? "",
        isReadOnly: isReadOnly,
        onChanged: (val) {
          currentTense.pastParticiple = val;
          widget.onTenseChanged?.call(
            _activeTenseIndex,
            currentTense,
          ); // Use ?.call
        },
      ),
    ];
  }

  List<Widget> _getFullVerbConjugationFields({
    required Tense currentTense,
    required bool isReadOnly,
  }) {
    // Helper to dry up the repeated calls
    void update(VoidCallback action) {
      action();
      widget.onTenseChanged?.call(_activeTenseIndex, currentTense);
    }

    return [
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: ConjugatedTenseWidget(
              activeTenseIndex: _activeTenseIndex,
              label: Constants.deNominativePronouns[0],
              value: currentTense.s1stPersonSingular ?? "",
              isReadOnly: isReadOnly,
              onChanged: (val) => update(() {
                currentTense.s1stPersonSingular = val;
              }),
              valueNotifier:
                  currentTense.tense == VerbTense.simple_past.germanTense
                  ? firstAndThirdPersonSingular
                  : null,
            ),
          ),
          const SizedBox(width: 20),
          Flexible(
            child: ConjugatedTenseWidget(
              activeTenseIndex: _activeTenseIndex,
              label: Constants.deNominativePronouns[3],
              value: currentTense.s1stPersonPlural ?? "",
              isReadOnly: isReadOnly,
              onChanged: (val) {
                update(() {
                  currentTense.s1stPersonPlural = val;
                  firstAndThirdPersonPlural.value = val;
                });
              },
              valueNotifier:
                  (currentTense.tense == VerbTense.present.germanTense ||
                      currentTense.tense == VerbTense.simple_past.germanTense)
                  ? firstAndThirdPersonPlural
                  : null,
            ),
          ),
        ],
      ),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: ConjugatedTenseWidget(
              activeTenseIndex: _activeTenseIndex,
              label: Constants.deNominativePronouns[1],
              value: currentTense.s2ndPersonSingular ?? "",
              isReadOnly: isReadOnly,
              onChanged: (val) =>
                  update(() => currentTense.s2ndPersonSingular = val),
            ),
          ),
          const SizedBox(width: 20),
          Flexible(
            child: ConjugatedTenseWidget(
              activeTenseIndex: _activeTenseIndex,
              label: Constants.deNominativePronouns[4],
              value: currentTense.s2ndPersonPlural ?? "",
              isReadOnly: isReadOnly,
              onChanged: (val) =>
                  update(() => currentTense.s2ndPersonPlural = val),
            ),
          ),
        ],
      ),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: ConjugatedTenseWidget(
              activeTenseIndex: _activeTenseIndex,
              label: Constants.deNominativePronouns[2],
              value: currentTense.s3rdPersonSingular ?? "",
              isReadOnly: isReadOnly,
              onChanged: (val) => update(() {
                currentTense.s3rdPersonSingular = val;
              }),
              valueNotifier:
                  currentTense.tense == VerbTense.simple_past.germanTense
                  ? firstAndThirdPersonSingular
                  : null,
            ),
          ),
          const SizedBox(width: 20),
          Flexible(
            child: ConjugatedTenseWidget(
              activeTenseIndex: _activeTenseIndex,
              label: Constants.deNominativePronouns[5],
              value: currentTense.s3rdPersonPlural ?? "",
              isReadOnly: isReadOnly,
              onChanged: (val) => update(() {
                currentTense.s3rdPersonPlural = val;
              }),
              valueNotifier:
                  (currentTense.tense == VerbTense.present.germanTense ||
                      currentTense.tense == VerbTense.simple_past.germanTense)
                  ? firstAndThirdPersonPlural
                  : null,
            ),
          ),
        ],
      ),
    ];
  }
}
