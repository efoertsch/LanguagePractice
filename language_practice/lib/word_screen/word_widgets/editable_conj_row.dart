import 'package:flutter/material.dart';

class EditableVerbConjugationRow extends StatelessWidget {
  final String person;
  final String number;
  final TextEditingController controller;
  final bool isLast;

  const EditableVerbConjugationRow({
    required this.person,
    required this.number,
    required this.controller,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: Color(0xFF2A2A45))),
      ),
      child: Row(
        children: [
          Text(
            person,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
          ),
          const SizedBox(width: 12),
          Text(number, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 20),
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}