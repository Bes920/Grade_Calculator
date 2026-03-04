class CourseEntry {
  const CourseEntry({
    required this.subject,
    required this.gradeInput,
    required this.gradePoint,
  });

  final String subject;
  final String gradeInput;
  final double gradePoint;

  bool isPassing(double passingThreshold) => gradePoint >= passingThreshold;

  CourseEntry copyWith({
    String? subject,
    String? gradeInput,
    double? gradePoint,
  }) {
    return CourseEntry(
      subject: subject ?? this.subject,
      gradeInput: gradeInput ?? this.gradeInput,
      gradePoint: gradePoint ?? this.gradePoint,
    );
  }
}
