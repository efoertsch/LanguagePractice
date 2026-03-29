import 'package:flutter/material.dart';

class EditableMetaCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final TextEditingController controller;

  const EditableMetaCard({
    required this.icon,
    required this.label,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        //color: const Color(0xFF1E1E3A),
        borderRadius: BorderRadius.circular(10),
        //border: Border.all(color: const Color(0xFF3A3A5C)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF4A4AFF), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Text(label, style: const TextStyle(fontSize: 9, color: Color(0xFF6B6B9B), letterSpacing: 1.5)),
                TextField(
                  controller: controller,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.only(top: 2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}