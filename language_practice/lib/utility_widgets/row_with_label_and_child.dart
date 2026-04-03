// Helper to maintain the horizontal layout with aligned labels
import 'package:flutter/material.dart';

mixin RowWithLabelAndChildMixin {
  Widget buildHorizontalRow({required String label, required Widget child}) {
    return Flexible(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(width: 12),
          Flexible(child: child),
        ],
      ),
    );
  }
}
