import 'dart:convert';

import 'package:gpa_calculator_flutter/models/course_entry.dart';
import 'package:gpa_calculator_flutter/models/gpa_report.dart';
import 'package:gpa_calculator_flutter/services/grade_parser.dart';

class GpaCalculator {
  const GpaCalculator({this.gradeParser = const GradeParser()});

  final GradeParser gradeParser;

  GpaReport buildReport({
    required Iterable<CourseEntry> courses,
    required double passingThreshold,
  }) {
    final normalizedCourses = courses
        .map(
          (course) => course.copyWith(
            subject: course.subject.trim(),
            gradeInput: gradeParser.normalizeLabel(course.gradeInput),
          ),
        )
        .where((course) => course.subject.isNotEmpty)
        .toList(growable: false);

    return GpaReport(
      courses: normalizedCourses,
      passingThreshold: passingThreshold,
    );
  }

  List<CourseEntry> parseCsv(String csvText) {
    final lines = const LineSplitter()
        .convert(csvText)
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    if (lines.isEmpty) {
      throw const FormatException('CSV is empty.');
    }

    final startAt = _looksLikeHeader(_splitCsvLine(lines.first)) ? 1 : 0;

    final parsed = lines
        .skip(startAt)
        .map(_splitCsvLine)
        .where((cells) => cells.length >= 2)
        .map((cells) {
          final subject = cells[0].trim();
          final gradeInput = cells[1].trim();
          final point = gradeParser.parseToPoint(gradeInput);
          if (subject.isEmpty || point == null) {
            return null;
          }
          return CourseEntry(
            subject: subject,
            gradeInput: gradeParser.normalizeLabel(gradeInput),
            gradePoint: point,
          );
        })
        .whereType<CourseEntry>()
        .toList(growable: false);

    if (parsed.isEmpty) {
      throw const FormatException(
        'No valid rows found. Expected: Subject,Grade',
      );
    }

    return parsed;
  }

  String toCsv(GpaReport report) {
    final rows = <List<String>>[
      ['Subject', 'Grade', 'Point', 'Status'],
      ...report.courses.map(
        (course) => [
          course.subject,
          course.gradeInput,
          course.gradePoint.toStringAsFixed(2),
          course.isPassing(report.passingThreshold) ? 'PASS' : 'FAIL',
        ],
      ),
      [
        'Final GPA',
        report.gpa.toStringAsFixed(2),
        'Threshold',
        report.passingThreshold.toStringAsFixed(2),
      ],
      ['Overall Status', report.finalStatus, '', ''],
    ];

    return rows.map(_encodeCsvRow).join('\n');
  }

  bool _looksLikeHeader(List<String> row) {
    if (row.length < 2) {
      return false;
    }

    final first = row[0].trim().toLowerCase();
    final second = row[1].trim().toLowerCase();

    return first.contains('subject') && second.contains('grade');
  }

  List<String> _splitCsvLine(String line) {
    final fields = <String>[];
    final buffer = StringBuffer();
    var inQuotes = false;

    for (var i = 0; i < line.length; i++) {
      final char = line[i];

      if (char == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          buffer.write('"');
          i++;
        } else {
          inQuotes = !inQuotes;
        }
        continue;
      }

      if (char == ',' && !inQuotes) {
        fields.add(buffer.toString().trim());
        buffer.clear();
        continue;
      }

      buffer.write(char);
    }

    fields.add(buffer.toString().trim());
    return fields;
  }

  String _encodeCsvRow(List<String> fields) {
    return fields
        .map((field) {
          if (field.contains(',') ||
              field.contains('"') ||
              field.contains('\n')) {
            final escaped = field.replaceAll('"', '""');
            return '"$escaped"';
          }
          return field;
        })
        .join(',');
  }
}
