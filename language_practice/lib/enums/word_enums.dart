

import 'package:collection/collection.dart';

enum WordType {
  noun,
  verb,
  adjective,
  adverb,
  pronoun,
  preposition,
  conjunction,
  interjection,
  article;

  /// Returns a formatted version for the UI (e.g., "Preposition")
 // String get displayName => name[0].toUpperCase() + name.substring(1);
  String get displayName => name;

  /// Helper to safely parse a string into the Enum
  static WordType? fromString(String value) {
    return WordType.values.firstWhere(
          (type) => type.name == value.toLowerCase().trim(),
      orElse: () => WordType.noun, // Default fallback
    );
  }
}

enum VerbConjugationClass {
  undefined,
  weak,
  strong,
  mixed;

  /// Returns a formatted version for the UI (e.g., "Preposition")
  String get displayName => name[0].toUpperCase() + name.substring(1);

  /// Helper to safely parse a string into the Enum
  static VerbConjugationClass? fromString(String value) {
    return VerbConjugationClass.values.firstWhere(
          (type) => type.name == value.toLowerCase().trim(),
      orElse: () => VerbConjugationClass.undefined, // Default fallback
    );
  }
}

enum VerbFunctionalType {
  undefined,
  auxiliary,
  separable,
  inseparable;

  /// Returns a formatted version for the UI (e.g., "Preposition")
  String get displayName => name[0].toUpperCase() + name.substring(1);

  /// Helper to safely parse a string into the Enum
  static VerbFunctionalType? fromString(String value) {
    return VerbFunctionalType.values.firstWhere(
          (type) => type.name == value.toLowerCase().trim(),
      orElse: () => VerbFunctionalType.undefined, // Default fallback
    );
  }
}

enum VerbTense {
  present('Präsens'),
  present_perfect('Perfekt'),
  simple_past('Präteritum');

  const VerbTense(this.germanTense);

  final String germanTense;
  /// Returns a formatted version for the UI (e.g., "Preposition")
  String get displayName => name[0].toUpperCase() + name.substring(1);

  // Converts a German string (e.g., "Präsens") back to the Enum
  static VerbTense? fromGermanTense(String value) {
    return VerbTense.values.firstWhereOrNull(
          (type) => type.germanTense.toLowerCase() == value.toLowerCase().trim(),
    );
  }
  /// Helper to safely parse a string into the Enum
  static VerbTense? fromString(String value) {
    return VerbTense.values.firstWhere(
          (type) => type.name == value.toLowerCase().trim(),

    );
  }
}

enum GermanGender {
  der,
  die,
  das;

  /// Returns a formatted version for the UI (e.g., "Preposition")
  String get displayName => name[0].toUpperCase() + name.substring(1);

  GermanGender? stringToGermanGender(String gender){
    try {
      return GermanGender.values.byName(gender.toLowerCase());
    } on ArgumentError{
      return null;
    }
  }

  GermanGender? germanGenderFromString(String gender) {
    try {
      // byName will throw an ArgumentError if the name doesn't match
      return GermanGender.values.byName(gender.toLowerCase());
    } on ArgumentError {
      // If an error is caught, return null or handle as needed
      return null;
    }
  }
}

