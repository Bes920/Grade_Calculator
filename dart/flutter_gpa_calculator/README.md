# Flutter GPA Calculator (Modern UI Refactor)

This Flutter app is a refactor of the console GPA calculator into a modern
visual interface using Dart OOP, higher-order functions, and lambdas.

## Features

- Modern responsive UI (cards, summary panels, table, status chips)
- Manual course entry (`subject + grade`)
- CSV upload/import (`Subject,Grade`)
- GPA and pass/fail status calculation
- CSV export content copy to clipboard
- Course ranking and pass/fail breakdown

## OOP + Functional Design

- `CourseEntry` model: `lib/models/course_entry.dart`
- `GpaReport` model: `lib/models/gpa_report.dart`
- `GradeParser` service: `lib/services/grade_parser.dart`
- `GpaCalculator` service: `lib/services/gpa_calculator.dart`

Higher-order functions and lambdas are used throughout calculation/parsing:
- `map`, `where`, `fold`, `skip`, `whereType`, `sort`

## Run

```powershell
cd "dart/flutter_gpa_calculator"
flutter pub get
flutter run
```

## Test / Analyze

```powershell
flutter analyze
flutter test
```
