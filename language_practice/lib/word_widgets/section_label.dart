
import 'package:flutter/material.dart';

class SectionLabel extends StatelessWidget {
  final String label;

  const SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        //color: Color(0xFF4A4AFF),
        letterSpacing: 2.5,
        fontFamily: 'monospace',
      ),
    );
  }
}