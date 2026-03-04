import 'package:flutter_test/flutter_test.dart';
import 'package:gpa_calculator_flutter/main.dart';

void main() {
  testWidgets('renders GPA dashboard shell', (tester) async {
    await tester.pumpWidget(const GpaUiApp());

    expect(find.text('GPA Calculator'), findsOneWidget);
    expect(find.text('Course Input'), findsOneWidget);
  });
}
