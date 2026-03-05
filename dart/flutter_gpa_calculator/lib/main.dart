import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
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
      title: 'Premium GPA Calculator',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF2F2F7),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF007AFF),
          brightness: Brightness.light,
        ),
        fontFamily: 'Inter',
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
  final TextEditingController _scoreController = TextEditingController();
  final GradeParser _gradeParser = const GradeParser();
  late final GpaCalculator _calculator = GpaCalculator(
    gradeParser: _gradeParser,
  );

  final List<CourseEntry> _courses = <CourseEntry>[
    const CourseEntry(
      subject: 'Advanced Math',
      gradeInput: '96%',
      gradePoint: 4.00,
    ),
    const CourseEntry(
      subject: 'Physics 101',
      gradeInput: '86%',
      gradePoint: 3.70,
    ),
    const CourseEntry(subject: 'History', gradeInput: '32%', gradePoint: 0.00),
  ];

  double _passingThreshold = 2.0;

  GpaReport get _report => _calculator.buildReport(
    courses: _courses,
    passingThreshold: _passingThreshold,
  );

  @override
  void dispose() {
    _subjectController.dispose();
    _scoreController.dispose();
    super.dispose();
  }

  void _addCourse() {
    final subject = _subjectController.text.trim();
    final scoreText = _scoreController.text.trim();

    if (subject.isEmpty || scoreText.isEmpty) {
      _showMessage('Please enter subject and score.', isError: true);
      return;
    }

    final score = double.tryParse(scoreText);
    if (score == null || score < 0 || score > 100) {
      _showMessage('Score must be a number from 0 to 100.', isError: true);
      return;
    }

    final point = _gradeParser.parseToPoint(score.toString());
    if (point == null) {
      _showMessage('Could not parse score.', isError: true);
      return;
    }

    setState(() {
      _courses.add(
        CourseEntry(
          subject: subject,
          gradeInput: '${score.toStringAsFixed(score % 1 == 0 ? 0 : 1)}%',
          gradePoint: point,
        ),
      );
      _subjectController.clear();
      _scoreController.clear();
    });
  }

  Future<void> _importCsv() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['csv'],
      withData: true,
    );

    if (picked == null || picked.files.single.bytes == null) {
      return;
    }

    try {
      final csvText = utf8.decode(
        picked.files.single.bytes!,
        allowMalformed: true,
      );
      final imported = _calculator.parseCsv(csvText);

      setState(() {
        _courses
          ..clear()
          ..addAll(
            imported.map(
              (course) => course.copyWith(
                gradeInput: _displayGradeLabel(course.gradeInput),
              ),
            ),
          );
      });
      _showMessage('Imported ${imported.length} courses.');
    } on FormatException catch (error) {
      _showMessage(error.message, isError: true);
    } catch (_) {
      _showMessage('Failed to import CSV.', isError: true);
    }
  }

  void _clearCourses() {
    setState(_courses.clear);
  }

  String _displayGradeLabel(String raw) {
    final trimmed = raw.trim();
    if (trimmed.endsWith('%')) {
      return trimmed;
    }
    final numeric = double.tryParse(trimmed);
    if (numeric == null) {
      return trimmed;
    }
    if (numeric >= 0 && numeric <= 100) {
      return '${numeric.toStringAsFixed(numeric % 1 == 0 ? 0 : 1)}%';
    }
    return trimmed;
  }

  void _showMessage(String text, {bool isError = false}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: isError ? const Color(0xFFB3261E) : Colors.black87,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final report = _report;
    final passCount = report.statusBreakdown['PASS'] ?? 0;
    final failCount = report.statusBreakdown['FAIL'] ?? 0;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _header(),
                  const SizedBox(height: 20),
                  _gpaCard(report, passCount, failCount),
                  const SizedBox(height: 20),
                  _addCourseCard(),
                  const SizedBox(height: 20),
                  _breakdownSection(report),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GPA Calculator',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.8,
                    color: Color(0xFF1C1C1E),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'OOP + Lambdas (Dart)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF8E8E93),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.settings_outlined, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _gpaCard(GpaReport report, int passCount, int failCount) {
    return _iosCard(
      child: Stack(
        children: [
          Positioned(
            right: -40,
            top: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x14007AFF),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CUMULATIVE GPA',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: Color(0xFF8E8E93),
                ),
              ),
              const SizedBox(height: 6),
              LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 390;
                  final gpaFontSize = compact ? 56.0 : 72.0;
                  final suffixFontSize = compact ? 16.0 : 20.0;
                  final suffixBottom = compact ? 8.0 : 10.0;

                  return SizedBox(
                    width: double.infinity,
                    child: FittedBox(
                      alignment: Alignment.centerLeft,
                      fit: BoxFit.scaleDown,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFF1C1C1E), Color(0xFF6A6A72)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds),
                            child: Text(
                              report.gpa.toStringAsFixed(2),
                              style: TextStyle(
                                fontSize: gpaFontSize,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -2.2,
                                color: Colors.white,
                                height: 1,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Padding(
                            padding: EdgeInsets.only(bottom: suffixBottom),
                            child: Text(
                              '/ 4.00 pts',
                              style: TextStyle(
                                fontSize: suffixFontSize,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF8E8E93),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _statusMiniCard(
                      title: 'Passing',
                      value: '$passCount',
                      label: passCount == 1 ? 'course' : 'courses',
                      icon: Icons.check_circle,
                      iconColor: const Color(0xFF34C759),
                      iconBg: const Color(0x1534C759),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _statusMiniCard(
                      title: 'Failing',
                      value: '$failCount',
                      label: failCount == 1 ? 'course' : 'courses',
                      icon: Icons.cancel,
                      iconColor: const Color(0xFFFF3B30),
                      iconBg: const Color(0x15FF3B30),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _addCourseCard() {
    return _iosCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Add Course',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              _pillButton(
                icon: Icons.upload_file_outlined,
                label: 'CSV',
                textColor: const Color(0xFF007AFF),
                bgColor: const Color(0xFFF2F2F7),
                onTap: _importCsv,
              ),
              const SizedBox(width: 8),
              _pillButton(
                icon: Icons.delete_outline,
                label: 'Clear',
                textColor: const Color(0xFFFF3B30),
                bgColor: const Color(0x14FF3B30),
                onTap: _clearCourses,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _subjectController,
                  textInputAction: TextInputAction.next,
                  decoration: _inputDecoration(
                    hint: 'Subject Name',
                    icon: Icons.bookmark_border,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 110,
                child: TextField(
                  controller: _scoreController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onSubmitted: (_) => _addCourse(),
                  decoration: _inputDecoration(
                    hint: '0',
                    suffix: '%',
                    textAlign: TextAlign.right,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _addCourse,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF007AFF),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.add_circle_outline),
              label: const Text(
                'Add to Calculator',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0x1A3C3C43)),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Passing Threshold',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1C1C1E),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0x1A3C3C43)),
                ),
                child: Text(
                  '${_passingThreshold.toStringAsFixed(2)} pts',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF007AFF),
              inactiveTrackColor: const Color(0xFFE5E5EA),
              trackHeight: 6,
              thumbColor: Colors.white,
              overlayColor: const Color(0x33007AFF),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
            ),
            child: Slider(
              min: 0,
              max: 4,
              divisions: 40,
              value: _passingThreshold,
              onChanged: (value) {
                setState(() {
                  _passingThreshold = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _breakdownSection(GpaReport report) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'COURSE BREAKDOWN',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: Color(0xFF8E8E93),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 30,
                offset: Offset(0, 8),
              ),
            ],
            border: Border.all(color: const Color(0x0D3C3C43)),
          ),
          child: report.courses.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'No courses available.',
                      style: TextStyle(
                        color: Color(0xFF8E8E93),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: report.courses.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1, color: Color(0x1A3C3C43)),
                  itemBuilder: (context, index) {
                    final course = report.courses[index];
                    final isPass = course.isPassing(report.passingThreshold);
                    final scoreLabel = _displayGradeLabel(course.gradeInput);

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isPass
                                  ? const Color(0xFFF2F2F7)
                                  : const Color(0x14FF3B30),
                            ),
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                color: isPass
                                    ? const Color(0xFF8E8E93)
                                    : const Color(0xFFFF3B30),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  course.subject,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1C1C1E),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    if (!isPass) ...[
                                      const Icon(
                                        Icons.warning_amber_rounded,
                                        size: 14,
                                        color: Color(0xFFFF3B30),
                                      ),
                                      const SizedBox(width: 4),
                                    ] else ...[
                                      const Icon(
                                        Icons.trending_up,
                                        size: 14,
                                        color: Color(0xFF34C759),
                                      ),
                                      const SizedBox(width: 4),
                                    ],
                                    Text(
                                      'Score: $scoreLabel',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: isPass
                                            ? const Color(0xFF8E8E93)
                                            : const Color(0xFFFF3B30),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                course.gradePoint.toStringAsFixed(2),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: isPass
                                      ? const Color(0xFF1C1C1E)
                                      : const Color(0xFFFF3B30),
                                ),
                              ),
                              Text(
                                'PTS',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1,
                                  color: isPass
                                      ? const Color(0xFF8E8E93)
                                      : const Color(0xFFFF3B30),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _statusMiniCard({
    required String title,
    required String value,
    required String label,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0x80F2F2F7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x1A3C3C43)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                    color: Color(0xFF8E8E93),
                  ),
                ),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Color(0xFF1C1C1E)),
                    children: [
                      TextSpan(
                        text: value,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(
                        text: ' $label',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF8E8E93),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pillButton({
    required IconData icon,
    required String label,
    required Color textColor,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: textColor),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    IconData? icon,
    String? suffix,
    TextAlign? textAlign,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFF8E8E93),
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: icon != null
          ? Icon(icon, color: const Color(0xFF8E8E93))
          : null,
      suffixText: suffix,
      suffixStyle: const TextStyle(
        color: Color(0xFF8E8E93),
        fontWeight: FontWeight.w600,
      ),
      filled: true,
      fillColor: const Color(0xFFF2F2F7),
      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0x4D007AFF), width: 2),
      ),
      isDense: textAlign == TextAlign.right,
    );
  }

  Widget _iosCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 30,
            offset: Offset(0, 8),
          ),
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );
  }
}
