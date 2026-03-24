import 'package:flutter/material.dart';

class TypeChip extends StatelessWidget {
  final String label;
  final Function() onPressed;

  const TypeChip({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          // color: const Color(0xFF2A1E3A),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFF5A3A7C)),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}