import 'dart:convert';
import 'dart:io';
import 'dart:math';

class SubjectGrade {
  SubjectGrade({
    required this.subject,
    required this.gradeInput,
    required this.gradePoint,
  });

  final String subject;
  final String gradeInput;
  final double gradePoint;
}

void main(List<String> arguments) {
  _printLaunchScreen();
  stdout.writeln('Enter subjects and grades to calculate final GPA.');
  stdout.writeln('');

  final passingThreshold = _readDoubleInRange(
    'Passing GPA threshold (0.0 - 4.0, default 2.0): ',
    min: 0.0,
    max: 4.0,
    defaultValue: 2.0,
  );

  final records = _readRecords();
  final totalPoints = records.fold<double>(
    0,
    (sum, record) => sum + record.gradePoint,
  );
  final gpa = totalPoints / records.length;
  final finalStatus = _statusFromPoint(gpa, passingThreshold);

  stdout.writeln('');
  stdout.writeln('=== Results ===');
  _printTable(records, passingThreshold);
  stdout.writeln('');
  stdout.writeln('Final GPA: ${gpa.toStringAsFixed(2)} / 4.00');
  stdout.writeln('Final Status: $finalStatus');
  stdout.writeln('Passing Threshold: ${passingThreshold.toStringAsFixed(2)}');
  stdout.writeln('');

  if (_readYesNo('Export to CSV? (y/n): ')) {
    final defaultPath =
        '${Directory.current.path}${Platform.pathSeparator}gpa_results.csv';
    final savePath = _readSavePath(defaultPath);
    _exportCsv(
      records: records,
      gpa: gpa,
      passingThreshold: passingThreshold,
      finalStatus: finalStatus,
      savePath: savePath,
    );
    stdout.writeln('CSV exported to: $savePath');
  }

  stdout.writeln('');
  stdout.write('Press Enter to close...');
  stdin.readLineSync();
}

void _printLaunchScreen() {
  final supportsAnsi = stdout.supportsAnsiEscapes;

  if (supportsAnsi) {
    stdout.write('\x1B[2J\x1B[H');
    stdout.write('\x1B[36m');
  }

  const banner = [
    '   ____ ____   ___      ____      _            _       _             ',
    '  / ___|  _ \\ / _ \\    / ___|__ _| | ___ _   _| | __ _| |_ ___  _ __ ',
    ' | |  _| |_) | | | |  | |   / _` | |/ __| | | | |/ _` | __/ _ \\|  __|',
    ' | |_| |  __/| |_| |  | |__| (_| | | (__| |_| | | (_| | || (_) | |   ',
    '  \\____|_|    \\___/    \\____\\__,_|_|\\___|\\__,_|_|\\__,_|\\__\\___/|_|   ',
  ];

  for (final line in banner) {
    stdout.writeln(line);
  }

  if (supportsAnsi) {
    stdout.write('\x1B[0m');
  }

  stdout.writeln(
    '-----------------------------------------------------------------------',
  );
  stdout.writeln(
    ' Manual mode, CSV import mode, pass/fail status, and CSV export support ',
  );
  stdout.writeln(
    '-----------------------------------------------------------------------',
  );
}

List<SubjectGrade> _readRecords() {
  stdout.writeln('Data Source:');
  stdout.writeln('  1) Manual entry');
  stdout.writeln('  2) Import from CSV file');

  final choice = _readIntInRange('Choose option (1-2): ', min: 1, max: 2);
  if (choice == 1) {
    return _readRecordsManually();
  }
  return _readRecordsFromCsv();
}

List<SubjectGrade> _readRecordsManually() {
  final subjectCount = _readPositiveInt('How many subjects? ');
  final records = <SubjectGrade>[];

  for (var i = 0; i < subjectCount; i++) {
    stdout.writeln('');
    stdout.writeln('Subject ${i + 1}:');

    final subjectName = _readRequiredText('  Subject name: ');
    final parsedGrade = _readGrade('  Grade (A, B+, 3.5, or 87): ');

    records.add(
      SubjectGrade(
        subject: subjectName,
        gradeInput: parsedGrade.$1,
        gradePoint: parsedGrade.$2,
      ),
    );
  }

  return records;
}

List<SubjectGrade> _readRecordsFromCsv() {
  stdout.writeln('');
  stdout.writeln('CSV format expected: Subject,Grade');
  stdout.writeln('Examples:');
  stdout.writeln('  Math,A');
  stdout.writeln('  Physics,78');
  stdout.writeln('');

  while (true) {
    final path = _readRequiredText('CSV file path: ');
    final file = File(path);
    if (!file.existsSync()) {
      stdout.writeln('File not found. Please provide a valid path.');
      continue;
    }

    try {
      final records = _loadRecordsFromCsv(file);
      stdout.writeln('Loaded ${records.length} subject(s) from CSV.');
      return records;
    } on FormatException catch (error) {
      stdout.writeln('CSV format error: ${error.message}');
    } catch (error) {
      stdout.writeln('Could not read CSV: $error');
    }
  }
}

List<SubjectGrade> _loadRecordsFromCsv(File file) {
  final content = file.readAsStringSync();
  final rows = _parseCsvContent(content);
  if (rows.isEmpty) {
    throw const FormatException('CSV file is empty.');
  }

  var startIndex = 0;
  if (_looksLikeHeader(rows.first)) {
    startIndex = 1;
  }

  final records = <SubjectGrade>[];

  for (var i = startIndex; i < rows.length; i++) {
    final row = rows[i];
    if (row.isEmpty || row.every((cell) => cell.trim().isEmpty)) {
      continue;
    }
    if (row.length < 2) {
      continue;
    }

    final subject = row[0].trim();
    if (subject.isEmpty || _isSummaryRow(subject)) {
      continue;
    }

    final gradeCell = row[1].trim();
    final pointCell = row.length > 2 ? row[2].trim() : '';
    final gradeText = gradeCell.isNotEmpty ? gradeCell : pointCell;

    var gradePoint = _parseGradePoint(gradeCell);
    gradePoint ??= _parseGradePoint(pointCell);

    if (gradePoint == null) {
      throw FormatException(
        'Row ${i + 1}: invalid grade "$gradeCell" for subject "$subject".',
      );
    }

    records.add(
      SubjectGrade(
        subject: subject,
        gradeInput: gradeText.toUpperCase(),
        gradePoint: gradePoint,
      ),
    );
  }

  if (records.isEmpty) {
    throw const FormatException('No valid subject rows found in CSV.');
  }

  return records;
}

List<List<String>> _parseCsvContent(String content) {
  final rows = <List<String>>[];
  for (final line in const LineSplitter().convert(content)) {
    if (line.trim().isEmpty) {
      continue;
    }
    rows.add(_parseCsvLine(line));
  }
  return rows;
}

List<String> _parseCsvLine(String line) {
  final fields = <String>[];
  final field = StringBuffer();
  var inQuotes = false;

  for (var i = 0; i < line.length; i++) {
    final char = line[i];
    if (char == '"') {
      if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
        field.write('"');
        i++;
      } else {
        inQuotes = !inQuotes;
      }
      continue;
    }

    if (char == ',' && !inQuotes) {
      fields.add(field.toString().trim());
      field.clear();
      continue;
    }

    field.write(char);
  }

  fields.add(field.toString().trim());
  return fields;
}

bool _looksLikeHeader(List<String> row) {
  if (row.length < 2) {
    return false;
  }

  final first = row[0].trim().toLowerCase();
  final second = row[1].trim().toLowerCase();
  return first.contains('subject') &&
      (second.contains('grade') || second.contains('point'));
}

bool _isSummaryRow(String subject) {
  final value = subject.trim().toLowerCase();
  return value == 'final gpa' ||
      value == 'overall status' ||
      value == 'passing threshold';
}

int _readPositiveInt(String prompt) {
  while (true) {
    final input = _readInputOrExit(prompt);
    final value = int.tryParse(input);
    if (value != null && value > 0) {
      return value;
    }
    stdout.writeln('Please enter a valid number greater than 0.');
  }
}

int _readIntInRange(String prompt, {required int min, required int max}) {
  while (true) {
    final input = _readInputOrExit(prompt);
    final value = int.tryParse(input);
    if (value != null && value >= min && value <= max) {
      return value;
    }
    stdout.writeln('Please enter a number between $min and $max.');
  }
}

String _readRequiredText(String prompt) {
  while (true) {
    final input = _readInputOrExit(prompt);
    if (input.isNotEmpty) {
      return input;
    }
    stdout.writeln('This field cannot be empty.');
  }
}

(double min, double max) _normalizeRange(double a, double b) {
  return (a <= b) ? (a, b) : (b, a);
}

double _readDoubleInRange(
  String prompt, {
  required double min,
  required double max,
  double? defaultValue,
}) {
  final normalized = _normalizeRange(min, max);
  final low = normalized.$1;
  final high = normalized.$2;

  while (true) {
    final input = _readInputOrExit(prompt);

    if (input.isEmpty && defaultValue != null) {
      return defaultValue;
    }

    final value = double.tryParse(input);
    if (value != null && value >= low && value <= high) {
      return value;
    }

    stdout.writeln(
      'Please enter a valid number between ${low.toStringAsFixed(1)} and ${high.toStringAsFixed(1)}.',
    );
  }
}

bool _readYesNo(String prompt) {
  while (true) {
    final input = _readInputOrExit(prompt).toLowerCase();
    if (input == 'y' || input == 'yes') {
      return true;
    }
    if (input == 'n' || input == 'no') {
      return false;
    }
    stdout.writeln('Please type y or n.');
  }
}

String _readSavePath(String defaultPath) {
  while (true) {
    final input = _readInputOrExit(
      'Save CSV path (file or folder, Enter for default: $defaultPath): ',
    );
    final resolvedPath = _resolveSavePath(input.isEmpty ? defaultPath : input);

    try {
      final file = File(resolvedPath);
      file.parent.createSync(recursive: true);
      return file.path;
    } catch (error) {
      stdout.writeln('Invalid save path: $error');
    }
  }
}

String _resolveSavePath(String path) {
  final normalized = path.trim().replaceAll('/', Platform.pathSeparator);
  final isDirectoryPath =
      normalized.endsWith('\\') ||
      normalized.endsWith('/') ||
      FileSystemEntity.typeSync(normalized) == FileSystemEntityType.directory;

  if (isDirectoryPath) {
    final separator = normalized.endsWith(Platform.pathSeparator)
        ? ''
        : Platform.pathSeparator;
    return '$normalized${separator}gpa_results.csv';
  }

  if (normalized.toLowerCase().endsWith('.csv')) {
    return normalized;
  }

  if (!_hasExtension(normalized)) {
    return '$normalized.csv';
  }

  return normalized;
}

bool _hasExtension(String path) {
  final slashIndex = max(path.lastIndexOf('/'), path.lastIndexOf('\\'));
  final fileName = slashIndex >= 0 ? path.substring(slashIndex + 1) : path;
  return fileName.contains('.');
}

(String, double) _readGrade(String prompt) {
  while (true) {
    final input = _readInputOrExit(prompt);

    if (input.isEmpty) {
      stdout.writeln('Grade cannot be empty.');
      continue;
    }

    final gradePoint = _parseGradePoint(input);
    if (gradePoint != null) {
      return (input.toUpperCase(), gradePoint);
    }

    stdout.writeln(
      'Invalid grade. Use letters (A, B+, C-) or numbers (0-4 or 0-100).',
    );
  }
}

String _readInputOrExit(String prompt) {
  stdout.write(prompt);
  final input = stdin.readLineSync();
  if (input == null) {
    stdout.writeln('\nInput closed. Exiting...');
    exit(0);
  }
  return input.trim();
}

double? _parseGradePoint(String input) {
  final normalized = input.trim().toUpperCase();
  if (normalized.isEmpty) {
    return null;
  }

  const letterMap = <String, double>{
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

  if (letterMap.containsKey(normalized)) {
    return letterMap[normalized];
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

String _statusFromPoint(double gradePoint, double passingThreshold) {
  return gradePoint >= passingThreshold ? 'PASS' : 'FAIL';
}

void _printTable(List<SubjectGrade> records, double passingThreshold) {
  const headers = ['#', 'Subject', 'Grade', 'Point', 'Status'];

  final indexWidth = max(headers[0].length, records.length.toString().length);

  var subjectWidth = headers[1].length;
  var gradeWidth = headers[2].length;
  var pointWidth = headers[3].length;
  var statusWidth = headers[4].length;

  for (final record in records) {
    subjectWidth = max(subjectWidth, record.subject.length);
    gradeWidth = max(gradeWidth, record.gradeInput.length);
    pointWidth = max(pointWidth, record.gradePoint.toStringAsFixed(2).length);
    statusWidth = max(
      statusWidth,
      _statusFromPoint(record.gradePoint, passingThreshold).length,
    );
  }

  final divider =
      '+-${'-' * indexWidth}-+-${'-' * subjectWidth}-+-${'-' * gradeWidth}-+-${'-' * pointWidth}-+-${'-' * statusWidth}-+';

  stdout.writeln(divider);
  stdout.writeln(
    '| ${headers[0].padRight(indexWidth)} | ${headers[1].padRight(subjectWidth)} | ${headers[2].padRight(gradeWidth)} | ${headers[3].padRight(pointWidth)} | ${headers[4].padRight(statusWidth)} |',
  );
  stdout.writeln(divider);

  for (var i = 0; i < records.length; i++) {
    final row = records[i];
    final status = _statusFromPoint(row.gradePoint, passingThreshold);
    stdout.writeln(
      '| ${(i + 1).toString().padRight(indexWidth)} | ${row.subject.padRight(subjectWidth)} | ${row.gradeInput.padRight(gradeWidth)} | ${row.gradePoint.toStringAsFixed(2).padRight(pointWidth)} | ${status.padRight(statusWidth)} |',
    );
  }

  stdout.writeln(divider);
}

void _exportCsv({
  required List<SubjectGrade> records,
  required double gpa,
  required double passingThreshold,
  required String finalStatus,
  required String savePath,
}) {
  final rows = <List<String>>[
    ['Subject', 'Grade', 'Point', 'Status'],
    ...records.map((record) {
      final status = _statusFromPoint(record.gradePoint, passingThreshold);
      return [
        record.subject,
        record.gradeInput,
        record.gradePoint.toStringAsFixed(2),
        status,
      ];
    }),
    [
      'Final GPA',
      gpa.toStringAsFixed(2),
      'Passing Threshold',
      passingThreshold.toStringAsFixed(2),
    ],
    ['Overall Status', finalStatus, '', ''],
  ];

  final csvContent = rows.map(_csvRow).join('\n');
  final file = File(savePath);
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(csvContent);
}

String _csvRow(List<String> fields) {
  return fields.map(_escapeCsvField).join(',');
}

String _escapeCsvField(String value) {
  if (value.contains(',') || value.contains('"') || value.contains('\n')) {
    final escaped = value.replaceAll('"', '""');
    return '"$escaped"';
  }
  return value;
}
