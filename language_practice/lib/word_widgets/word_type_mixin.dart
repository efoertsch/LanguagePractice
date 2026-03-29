import 'package:flutter/material.dart';
import '../word_widgets/wordtype_selection_dialog.dart';

mixin WordTypeMixin  {
  Widget buildTypeChips(BuildContext context, List<String>? types, bool multipleSelectionAllowed,Function onTypesChanged) {

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(right: 8),
          child: Text(
            'Type',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 10),
        Flexible(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (types ?? <String>[])
                .map(
                  (t) =>
                  TypeChip(
                    label: t,
                    onPressed: () async {
                      await displayWordTypes(context, types, multipleSelectionAllowed,onTypesChanged);
                    },
                  ),
            )
                .toList(),
          ),
        ),
        if (multipleSelectionAllowed ||( !multipleSelectionAllowed && (types ?? <String>[]).isEmpty  )) IconButton(
          onPressed: () async {
            await displayWordTypes(
              context,
              types,
              multipleSelectionAllowed,
              onTypesChanged,
            );
          },
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
    );
  }

  Future<void> displayWordTypes(BuildContext context,
      List<String>? types,   bool multipleSelectionAllowed ,Function onTypesChanged,) async {
    final results = await displayWordTypeDialog(context, types, multipleSelectionAllowed);
    onTypesChanged(results);
  }


  Future<List<String>> displayWordTypeDialog(BuildContext context,
      List<String>? currentTypes,bool multipleSelectionAllowed) async {
    final List<String>? results = await showWordTypeSelector(
      context,
      currentTypes,multipleSelectionAllowed
    );
    if (results == null) {
      return currentTypes ?? [];
    } else {
      return results;
    }
  }

}

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