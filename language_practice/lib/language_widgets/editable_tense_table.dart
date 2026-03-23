
import 'package:flutter/material.dart';
import 'package:language_practice/language_widgets/editable_conj_row.dart';

class EditableTenseTable extends StatelessWidget {
  final int index;
  final Map<String, TextEditingController> controllers;

  const EditableTenseTable({required this.index, required this.controllers});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            // color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(12),
            //border: Border.all(color: const Color(0xFF3A3A5C)),
          ),
          child: Column(
            children: [
              EditableVerbConjugationRow(
                person: '1st',
                number: 'Singular',
                controller: controllers['tense_${index}_s1']!,
              ),
              EditableVerbConjugationRow(
                person: '2nd',
                number: 'Singular',
                controller: controllers['tense_${index}_s2']!,
              ),
              EditableVerbConjugationRow(
                person: '3rd',
                number: 'Singular',
                controller: controllers['tense_${index}_s3']!,
              ),
              EditableVerbConjugationRow(
                person: '1st',
                number: 'Plural',
                controller: controllers['tense_${index}_p1']!,
              ),
              EditableVerbConjugationRow(
                person: '2nd',
                number: 'Plural',
                controller: controllers['tense_${index}_p2']!,
              ),
              EditableVerbConjugationRow(
                person: '3rd',
                number: 'Plural',
                controller: controllers['tense_${index}_p3']!,
                isLast: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Formal and Auxiliary sections follow the same logic
        Row(
          children: [
            Expanded(
              child: _EditableAuxCard(
                label: 'FORMAL S.',
                controller: controllers['tense_${index}_formalS']!,
                color: const Color(0xFF5C9B5C),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _EditableAuxCard(
                label: 'FORMAL P.',
                controller: controllers['tense_${index}_formalP']!,
                color: const Color(0xFF5C9B5C),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _EditableAuxCard(
                label: 'HELPER',
                controller: controllers['tense_${index}_helper']!,
                color: const Color(0xFF9B5CBB),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _EditableAuxCard(
                label: 'PAST PART.',
                controller: controllers['tense_${index}_pastP']!,
                color: const Color(0xFF9B5CBB),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _EditableAuxCard extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final Color color;

  const _EditableAuxCard({
    required this.label,
    required this.controller,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        //border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 10, color: color, letterSpacing: 1.5),
          ),
          TextField(
            controller: controller,
            style: const TextStyle(fontSize: 15, fontStyle: FontStyle.italic),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }
}