import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gpa_calculator_flutter/models/course_entry.dart';
import 'package:gpa_calculator_flutter/models/gpa_report.dart';
import 'package:gpa_calculator_flutter/services/gpa_calculator.dart';
import 'package:gpa_calculator_flutter/services/grade_parser.dart';

void main() {
  runApp(const GpaUiApp());
}

class GpaUiApp extends StatelessWidget {
  const GpaUiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Modern GPA Calculator',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F9D88),
          brightness: Brightness.light,
        ),
      ),
      home: const GpaHomePage(),
    );
  }
}

class GpaHomePage extends StatefulWidget {
  const GpaHomePage({super.key});

  @override
  State<GpaHomePage> createState() => _GpaHomePageState();
}

class _GpaHomePageState extends State<GpaHomePage> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _gradeController = TextEditingController();
  final GradeParser _gradeParser = const GradeParser();
  late final GpaCalculator _calculator = GpaCalculator(
    gradeParser: _gradeParser,
  );
  final List<CourseEntry> _courses = <CourseEntry>[];

  double _passingThreshold = 2.0;
  String? _message;
  bool _isErrorMessage = false;

  GpaReport get _report => _calculator.buildReport(
    courses: _courses,
    passingThreshold: _passingThreshold,
  );

  @override
  void dispose() {
    _subjectController.dispose();
    _gradeController.dispose();
    super.dispose();
  }

  void _setMessage(String message, {bool isError = false}) {
    setState(() {
      _message = message;
      _isErrorMessage = isError;
    });
  }

  void _addCourse() {
    final subject = _subjectController.text.trim();
    final gradeInput = _gradeController.text.trim();

    if (subject.isEmpty || gradeInput.isEmpty) {
      _setMessage('Please enter both subject and grade.', isError: true);
      return;
    }

    final point = _gradeParser.parseToPoint(gradeInput);
    if (point == null) {
      _setMessage(
        'Invalid grade. Use A/B+/C- or numeric values (0-4 or 0-100).',
        isError: true,
      );
      return;
    }

    setState(() {
      _courses.add(
        CourseEntry(
          subject: subject,
          gradeInput: _gradeParser.normalizeLabel(gradeInput),
          gradePoint: point,
        ),
      );
      _subjectController.clear();
      _gradeController.clear();
      _message = 'Course added.';
      _isErrorMessage = false;
    });
  }

  Future<void> _importFromCsv() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['csv'],
      withData: true,
    );

    if (result == null) {
      return;
    }

    final picked = result.files.single;
    final bytes = picked.bytes;
    if (bytes == null) {
      _setMessage('Could not read file data.', isError: true);
      return;
    }

    try {
      final csvText = utf8.decode(bytes, allowMalformed: true);
      final imported = _calculator.parseCsv(csvText);

      setState(() {
        _courses
          ..clear()
          ..addAll(imported);
        _message = 'Imported ${imported.length} courses from ${picked.name}.';
        _isErrorMessage = false;
      });
    } on FormatException catch (error) {
      _setMessage(error.message, isError: true);
    } catch (_) {
      _setMessage('Failed to import CSV.', isError: true);
    }
  }

  Future<void> _copyCsvToClipboard() async {
    if (_courses.isEmpty) {
      _setMessage('No data to export.', isError: true);
      return;
    }

    final csv = _calculator.toCsv(_report);
    await Clipboard.setData(ClipboardData(text: csv));
    _setMessage('CSV copied to clipboard.');
  }

  void _removeCourseAt(int index) {
    setState(() {
      _courses.removeAt(index);
      _message = 'Course removed.';
      _isErrorMessage = false;
    });
  }

  void _clearAll() {
    setState(() {
      _courses.clear();
      _message = 'All courses cleared.';
      _isErrorMessage = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final report = _report;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE8F7F4), Color(0xFFF8F5E8), Color(0xFFF0F8FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 1050;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 5, child: _buildPrimaryColumn(report)),
                          const SizedBox(width: 20),
                          Expanded(
                            flex: 3,
                            child: _buildSecondaryColumn(report),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildHeader(report),
                          const SizedBox(height: 16),
                          _buildSummaryCard(report),
                          const SizedBox(height: 16),
                          _buildEntryCard(),
                          const SizedBox(height: 16),
                          _buildTableCard(report),
                          const SizedBox(height: 16),
                          _buildPerformanceCard(report),
                        ],
                      ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryColumn(GpaReport report) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(report),
        const SizedBox(height: 16),
        _buildEntryCard(),
        const SizedBox(height: 16),
        _buildTableCard(report),
      ],
    );
  }

  Widget _buildSecondaryColumn(GpaReport report) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSummaryCard(report),
        const SizedBox(height: 16),
        _buildPerformanceCard(report),
      ],
    );
  }

  Widget _buildHeader(GpaReport report) {
    return _panel(
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.school_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'GPA Calculator',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                ),
                Text(
                  'OOP + lambdas + higher-order functions (Dart only)',
                  style: TextStyle(color: Colors.blueGrey.shade700),
                ),
              ],
            ),
          ),
          Chip(
            backgroundColor: report.finalStatus == 'PASS'
                ? const Color(0xFFDDF6E8)
                : const Color(0xFFFCE2E2),
            side: BorderSide.none,
            label: Text(
              report.finalStatus,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: report.finalStatus == 'PASS'
                    ? const Color(0xFF17663A)
                    : const Color(0xFF9F2222),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryCard() {
    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Course Input',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 290,
                child: TextField(
                  controller: _subjectController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Subject',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.menu_book_rounded),
                  ),
                ),
              ),
              SizedBox(
                width: 170,
                child: TextField(
                  controller: _gradeController,
                  onSubmitted: (_) => _addCourse(),
                  decoration: const InputDecoration(
                    labelText: 'Grade',
                    hintText: 'A-, 3.5, 84',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.percent_rounded),
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: _addCourse,
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
              OutlinedButton.icon(
                onPressed: _importFromCsv,
                icon: const Icon(Icons.upload_file_rounded),
                label: const Text('Upload CSV'),
              ),
              OutlinedButton.icon(
                onPressed: _copyCsvToClipboard,
                icon: const Icon(Icons.copy_rounded),
                label: const Text('Copy CSV'),
              ),
              TextButton.icon(
                onPressed: _courses.isEmpty ? null : _clearAll,
                icon: const Icon(Icons.delete_sweep_rounded),
                label: const Text('Clear'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                'Passing Threshold: ${_passingThreshold.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Slider(
                  value: _passingThreshold,
                  min: 0,
                  max: 4,
                  divisions: 40,
                  label: _passingThreshold.toStringAsFixed(2),
                  onChanged: (value) {
                    setState(() {
                      _passingThreshold = value;
                    });
                  },
                ),
              ),
            ],
          ),
          if (_message != null) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: _isErrorMessage
                    ? const Color(0xFFFDE9E9)
                    : const Color(0xFFE8F6EC),
              ),
              child: Text(
                _message!,
                style: TextStyle(
                  color: _isErrorMessage
                      ? const Color(0xFF8A2020)
                      : const Color(0xFF1D6C3D),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTableCard(GpaReport report) {
    if (report.courses.isEmpty) {
      return _panel(
        child: SizedBox(
          height: 220,
          child: Center(
            child: Text(
              'No courses yet. Add manually or upload a CSV.',
              style: TextStyle(
                color: Colors.blueGrey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Courses',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStatePropertyAll(Colors.blueGrey.shade50),
              columns: const [
                DataColumn(label: Text('#')),
                DataColumn(label: Text('Subject')),
                DataColumn(label: Text('Grade')),
                DataColumn(label: Text('Point')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Action')),
              ],
              rows: report.courses
                  .asMap()
                  .entries
                  .map(
                    (entry) => DataRow(
                      cells: [
                        DataCell(Text((entry.key + 1).toString())),
                        DataCell(Text(entry.value.subject)),
                        DataCell(Text(entry.value.gradeInput)),
                        DataCell(
                          Text(entry.value.gradePoint.toStringAsFixed(2)),
                        ),
                        DataCell(
                          _statusChip(
                            entry.value.isPassing(report.passingThreshold)
                                ? 'PASS'
                                : 'FAIL',
                          ),
                        ),
                        DataCell(
                          IconButton(
                            tooltip: 'Remove course',
                            onPressed: () => _removeCourseAt(entry.key),
                            icon: const Icon(Icons.delete_outline_rounded),
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(GpaReport report) {
    final passCount = report.statusBreakdown['PASS'] ?? 0;
    final failCount = report.statusBreakdown['FAIL'] ?? 0;

    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Summary',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 14),
          Text(
            report.gpa.toStringAsFixed(2),
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Final GPA / 4.00',
            style: TextStyle(color: Colors.blueGrey.shade700),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _summaryTile(
                  title: 'Passing',
                  value: passCount.toString(),
                  background: const Color(0xFFDDF6E8),
                  textColor: const Color(0xFF17663A),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _summaryTile(
                  title: 'Failing',
                  value: failCount.toString(),
                  background: const Color(0xFFFCE2E2),
                  textColor: const Color(0xFF9F2222),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Threshold: ${report.passingThreshold.toStringAsFixed(2)}',
            style: TextStyle(
              color: Colors.blueGrey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceCard(GpaReport report) {
    final topCourses = report.rankedCourses.take(3).toList(growable: false);

    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Performance',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          if (topCourses.isEmpty)
            Text(
              'Add courses to see ranking insights.',
              style: TextStyle(color: Colors.blueGrey.shade700),
            )
          else
            ...topCourses.map(
              (course) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        course.subject,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(
                      course.gradePoint.toStringAsFixed(2),
                      style: TextStyle(
                        color: Colors.blueGrey.shade800,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          Text(
            'Use Upload CSV to calculate quickly from file input.',
            style: TextStyle(color: Colors.blueGrey.shade700),
          ),
        ],
      ),
    );
  }

  Widget _summaryTile({
    required String title,
    required String value,
    required Color background,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    final isPass = status == 'PASS';
    return Chip(
      label: Text(
        status,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isPass ? const Color(0xFF17663A) : const Color(0xFF9F2222),
        ),
      ),
      side: BorderSide.none,
      backgroundColor: isPass
          ? const Color(0xFFDDF6E8)
          : const Color(0xFFFCE2E2),
    );
  }

  Widget _panel({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}
