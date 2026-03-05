import 'package:gpa_calculator_flutter/models/course_entry.dart';

class GpaReport {
  const GpaReport({required this.courses, required this.passingThreshold});

  final List<CourseEntry> courses;
  final double passingThreshold;

  double get totalPoints =>
      courses.fold<double>(0, (sum, course) => sum + course.gradePoint);

  double get gpa => courses.isEmpty ? 0 : totalPoints / courses.length;

  String get finalStatus => gpa >= passingThreshold ? 'PASS' : 'FAIL';

  Map<String, int> get statusBreakdown =>
      courses.fold<Map<String, int>>({'PASS': 0, 'FAIL': 0}, (acc, course) {
        final key = course.isPassing(passingThreshold) ? 'PASS' : 'FAIL';
        acc[key] = (acc[key] ?? 0) + 1;
        return acc;
      });

  List<CourseEntry> get rankedCourses {
    final sorted = [...courses];
    sorted.sort((a, b) => b.gradePoint.compareTo(a.gradePoint));
    return sorted;
  }
}
