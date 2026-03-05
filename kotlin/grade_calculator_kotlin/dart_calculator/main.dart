
import 'dart:io';

void main() {
  print('Enter student\'s name:');
  String? name = stdin.readLineSync();

  List<double> scores = [];
  String? input;

  while (true) {
    print('Enter a score (or \'done\' to finish):');
    input = stdin.readLineSync();

    if (input?.toLowerCase() == 'done') {
      break;
    }

    try {
      double? score = double.tryParse(input ?? '');
      if (score != null) {
        if (score >= 0) {
          scores.add(score);
        } else {
          print('Please enter a non-negative score.');
        }
      } else {
        print('Invalid input. Please enter a number or \'done\'.');
      }
    } catch (e) {
      print('An error occurred. Please try again.');
    }
  }

  if (scores.isNotEmpty) {
    double average = scores.reduce((a, b) => a + b) / scores.length;
    String grade = calculateGrade(average);
    String status = (grade == 'F') ? 'Fail' : 'Pass';

    print('\n--- Grade Report ---');
    print('Student: $name');
    print('Average Score: ${average.toStringAsFixed(2)}');
    print('Grade: $grade');
    print('Status: $status');
    print('--------------------');
  } else {
    print('No scores entered. Cannot calculate grade.');
  }
}

String calculateGrade(double average) {
  if (average >= 90.0) return 'A';
  if (average >= 80.0) return 'B';
  if (average >= 70.0) return 'C';
  if (average >= 60.0) return 'D';
  return 'F';
}
