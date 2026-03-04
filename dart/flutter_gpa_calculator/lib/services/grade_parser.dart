class GradeParser {
  const GradeParser();

  static const Map<String, double> _letterGradeMap = {
    'A+': 4.0,
    'A': 4.0,
    'A-': 3.7,
    'B+': 3.3,
    'B': 3.0,
    'B-': 2.7,
    'C+': 2.3,
    'C': 2.0,
    'C-': 1.7,
    'D+': 1.3,
    'D': 1.0,
    'F': 0.0,
  };

  double? parseToPoint(String rawValue) {
    final normalized = rawValue.trim().toUpperCase();
    if (normalized.isEmpty) {
      return null;
    }

    final mapped = _letterGradeMap[normalized];
    if (mapped != null) {
      return mapped;
    }

    final numeric = double.tryParse(normalized);
    if (numeric == null) {
      return null;
    }

    if (numeric >= 0 && numeric <= 4) {
      return numeric;
    }

    if (numeric >= 0 && numeric <= 100) {
      if (numeric >= 90) return 4.0;
      if (numeric >= 85) return 3.7;
      if (numeric >= 80) return 3.3;
      if (numeric >= 75) return 3.0;
      if (numeric >= 70) return 2.7;
      if (numeric >= 65) return 2.3;
      if (numeric >= 60) return 2.0;
      if (numeric >= 55) return 1.7;
      if (numeric >= 50) return 1.0;
      return 0.0;
    }

    return null;
  }

  String normalizeLabel(String rawValue) => rawValue.trim().toUpperCase();
}
