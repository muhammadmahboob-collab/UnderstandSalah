import 'package:flutter/material.dart';

import '../models/lesson.dart';
import '../models/lesson_progress.dart';
import '../services/lesson_service.dart';
import '../services/progress_service.dart';
import '../theme/app_text_styles.dart';
import 'flashcard_screen.dart';
import 'progress_report_screen.dart';
import 'quiz_screen.dart';
import 'settings_screen.dart';
import 'word_list_screen.dart';

class HomeScreen extends StatefulWidget {
  final double textScale;
  final ValueChanged<double> onTextScaleChanged;

  const HomeScreen({
    super.key,
    required this.textScale,
    required this.onTextScaleChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LessonService _lessonService = LessonService();
  final ProgressService _progressService = ProgressService();

  List<Lesson> _lessons = [];
  Map<String, LessonProgress> _progress = {};

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLessons();
  }

  Future<void> _loadLessons() async {
    final lessons = await _lessonService.loadLessons();
    final progress = await _loadProgressFor(lessons);

    setState(() {
      _lessons = lessons;
      _progress = progress;
      _loading = false;
    });
  }

  Future<Map<String, LessonProgress>> _loadProgressFor(
    List<Lesson> lessons,
  ) async {
    final entries = await Future.wait(
      lessons.map((lesson) async {
        final progress = await _progressService.loadProgress(lesson.fileName);
        return MapEntry(lesson.fileName, progress);
      }),
    );

    return Map.fromEntries(entries);
  }

  List<String> _reviewWordsFor(Lesson lesson) {
    final progress = _progress[lesson.fileName];
    if (progress == null) return [];

    return progress.strugglingWordsArabic;
  }

  Future<void> _openLesson(Lesson lesson, {List<String>? reviewWords}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          lessonFile: lesson.fileName,
          title: lesson.title,
          sequential: lesson.sequential,
          reviewWords: reviewWords,
        ),
      ),
    );

    final progress = await _loadProgressFor(_lessons);
    if (mounted) {
      setState(() => _progress = progress);
    }
  }

  IconData _iconFor(String icon) {
    switch (icon) {
      case 'menu_book':
        return Icons.menu_book;
      case 'mosque':
        return Icons.mosque;
      case 'hands':
        return Icons.volunteer_activism;
      default:
        return Icons.book;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildHeader(colorScheme),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCard(colorScheme),

                  const SizedBox(height: 28),

                  ..._buildCategory(colorScheme, "Quran", Icons.menu_book),
                  ..._buildCategory(colorScheme, "Salah", Icons.mosque),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorScheme.primary, colorScheme.primaryContainer],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white.withValues(alpha: 0.25),
            child: const Icon(
              Icons.auto_stories,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Understand Salah",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Master Quranic Arabic, word by word.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.insights, color: Colors.white),
            tooltip: "Progress Report",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProgressReportScreen(
                    lessons: _lessons,
                    progress: _progress,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SettingsScreen(
                    textScale: widget.textScale,
                    onTextScaleChanged: widget.onTextScaleChanged,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(ColorScheme colorScheme) {
    final totalWords = _lessons.fold<int>(0, (sum, l) => sum + l.totalWords);
    final totalMastered = _lessons.fold<int>(
      0,
      (sum, l) => sum + (_progress[l.fileName]?.masteredWordCount ?? 0),
    );
    final lessonsStarted = _lessons
        .where((l) => (_progress[l.fileName]?.timesCompleted ?? 0) > 0)
        .length;

    final masteredFraction = totalWords == 0 ? 0.0 : totalMastered / totalWords;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events, color: colorScheme.primary),
              const SizedBox(width: 8),
              const Text(
                "Your Progress",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _summaryStat(
                  "$totalMastered / $totalWords",
                  "Words Mastered",
                  colorScheme,
                ),
              ),
              Expanded(
                child: _summaryStat(
                  "$lessonsStarted / ${_lessons.length}",
                  "Lessons Started",
                  colorScheme,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: masteredFraction,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryStat(String value, String label, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  List<Widget> _buildCategory(
    ColorScheme colorScheme,
    String category,
    IconData icon,
  ) {
    final categoryLessons = _lessons
        .where((l) => l.category == category)
        .toList();

    if (categoryLessons.isEmpty) return [];

    return [
      Row(
        children: [
          Icon(icon, size: 20, color: colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            category,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),

      const SizedBox(height: 12),

      ...categoryLessons.map((lesson) => _lessonCard(colorScheme, lesson)),

      const SizedBox(height: 12),
    ];
  }

  Widget _lessonCard(ColorScheme colorScheme, Lesson lesson) {
    final progress = _progress[lesson.fileName];
    final hasStarted = progress != null && progress.timesCompleted > 0;
    final reviewWords = _reviewWordsFor(lesson);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _openLesson(lesson),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: colorScheme.primaryContainer,
                      child: Icon(
                        _iconFor(lesson.icon),
                        color: colorScheme.primary,
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lesson.title,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            lesson.arabicTitle,
                            style: AppTextStyles.arabicTitle(fontSize: 22),
                          ),

                          const SizedBox(height: 6),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "${lesson.totalWords} words",
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),

                if (hasStarted) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Best: ${progress.bestScore}/${lesson.totalWords} • "
                          "Mastered: ${progress.masteredWordCount}/${lesson.totalWords}",
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: lesson.totalWords == 0
                          ? 0
                          : progress.masteredWordCount / lesson.totalWords,
                      minHeight: 6,
                    ),
                  ),
                ],

                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: Wrap(
                    alignment: WrapAlignment.start,
                    spacing: 4,
                    children: [
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FlashcardScreen(
                                lessonFile: lesson.fileName,
                                title: lesson.title,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.style, size: 16),
                        label: const Text("Flashcards"),
                      ),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => WordListScreen(
                                lessonFile: lesson.fileName,
                                title: lesson.title,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.list_alt, size: 16),
                        label: const Text("Word List"),
                      ),
                      if (reviewWords.isNotEmpty)
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () =>
                              _openLesson(lesson, reviewWords: reviewWords),
                          icon: const Icon(Icons.refresh, size: 16),
                          label: Text(
                            "Review ${reviewWords.length} missed words",
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
