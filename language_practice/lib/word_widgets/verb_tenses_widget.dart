import 'package:flutter/material.dart';
import 'package:language_practice/language_classes/word_info.dart';

import '../app/constants.dart' show Constants;
import '../enums/word_enums.dart' show VerbTense;

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

  @override
  Widget build(BuildContext context) {
    if (widget.tenses.isEmpty) return const SizedBox.shrink();

    Tense currentTense = widget.tenses[_activeTenseIndex];

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
                      onDeleted: widget.onTenseChanged != null ? () {
                        _confirmDeleteTense(idx);
                      } : null,
                      deleteIcon: const Icon(Icons.delete, size: 18),
                      deleteIconColor: Colors.red.shade300,
                    ),
                );
              }).toList(),
              // ADD BUTTON
              if (_getAvailableTenses().isNotEmpty && widget.onTenseChanged != null)
              IconButton(
                onPressed:  _showAddTenseDialog ,
                tooltip: "Add Tense",
                icon: const Icon(Icons.add),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0), // Customize roundness
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
        _buildTenseInput(
          "English",
          currentTense.english ?? "",
            ((val) {
              currentTense.english = val;
              widget.onTenseChanged?.call(_activeTenseIndex, currentTense);
            }
            ),
        ),
        const SizedBox(height: 16),
        // Horizontal Input Fields for the Selected Tense
        if (currentTense.tense != null &&
            currentTense.tense == VerbTense.present_perfect.germanTense)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(children: _getPresentPerfectFields(currentTense)),
          ),
        if (currentTense.tense != null &&
            currentTense.tense != VerbTense.present_perfect.germanTense)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(children: _getFullVerbConjugationFields(currentTense)),
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
        content: Text("Are you sure you want to remove the ${widget.tenses[index].tense} conjugation?"),
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
                  _activeTenseIndex = widget.tenses.isEmpty ? 0 : widget.tenses.length - 1;
                }
              });
              // Notify parent of the change (passing null or updated list depending on your architecture)
              // Since we modified the list in place, we just trigger a save-ready event
              if (widget.tenses.isNotEmpty) {
                widget.onTenseChanged?.call(_activeTenseIndex, widget.tenses[_activeTenseIndex]);
              }
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  List <VerbTense> _getAvailableTenses(){
    final existingTenses = widget.tenses.map((t) => t.tense).toSet();
    final availableTenses = VerbTense.values
        .where((vt) => !existingTenses.contains(vt.germanTense))
        .toList();
    return availableTenses;

  }

  // Updated helper to handle read-only mode
  Widget _buildTenseInput(
      String label,
      String value,
      Function(String) onChanged,
      ) {
    final bool isReadOnly = widget.onTenseChanged == null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 250,
            child: isReadOnly
                ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
              child: Text(
                value.isEmpty ? "-" : value,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            )
                : TextFormField(
              initialValue: value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              key: Key("${_activeTenseIndex}_$label"),
              onChanged: onChanged,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
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
        widget.onTenseChanged?.call(_activeTenseIndex, currentTense); // Use ?.call
      }),
      _buildTenseInput("Past Part.", currentTense.pastParticiple ?? "", (val) {
        currentTense.pastParticiple = val;
        widget.onTenseChanged?.call(_activeTenseIndex, currentTense); // Use ?.call
      }),
    ];
  }

  List<Widget> _getFullVerbConjugationFields(Tense currentTense) {
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
            child: _buildTenseInput(
              Constants.deNominativePronouns[0],
              currentTense.s1stPersonSingular ?? "",
                  (val) => update(() => currentTense.s1stPersonSingular = val),
            ),
          ),
          const SizedBox(width: 20),
          Flexible(
            child: _buildTenseInput(
              Constants.deNominativePronouns[3],
              currentTense.s1stPersonPlural ?? "",
                  (val) => update(() => currentTense.s1stPersonPlural = val),
            ),
          ),
        ],
      ),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: _buildTenseInput(
              Constants.deNominativePronouns[1],
              currentTense.s2ndPersonSingular ?? "",
                  (val) => update(() => currentTense.s2ndPersonSingular = val),
            ),
          ),
          const SizedBox(width: 20),
          Flexible(
            child: _buildTenseInput(
              Constants.deNominativePronouns[4],
              currentTense.s2ndPersonPlural ?? "",
                  (val) => update(() => currentTense.s2ndPersonPlural = val),
            ),
          ),
        ],
      ),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: _buildTenseInput(
              Constants.deNominativePronouns[2],
              currentTense.s3rdPersonSingular ?? "",
                  (val) => update(() => currentTense.s3rdPersonSingular = val),
            ),
          ),
          const SizedBox(width: 20),
          Flexible(
            child: _buildTenseInput(
              Constants.deNominativePronouns[5],
              currentTense.s3rdPersonPlural ?? "",
                  (val) => update(() => currentTense.s3rdPersonPlural = val),
            ),
          ),
        ],
      ),
    ];
  }
}
