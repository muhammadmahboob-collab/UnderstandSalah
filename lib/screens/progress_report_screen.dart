import 'package:flutter/material.dart';

import '../models/lesson.dart';
import '../models/lesson_progress.dart';
import '../theme/app_text_styles.dart';

/// A combined report: words missed repeatedly across every lesson, and a
/// simple trend of recent scores per lesson.
class ProgressReportScreen extends StatelessWidget {
  final List<Lesson> lessons;
  final Map<String, LessonProgress> progress;

  const ProgressReportScreen({
    super.key,
    required this.lessons,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final troubleEntries = <MapEntry<WordProgress, String>>[];

    for (final lesson in lessons) {
      final lessonProgress = progress[lesson.fileName];
      if (lessonProgress == null) continue;

      for (final word in lessonProgress.repeatedMistakes) {
        troubleEntries.add(MapEntry(word, lesson.title));
      }
    }

    troubleEntries.sort(
      (a, b) => b.key.wrongCount.compareTo(a.key.wrongCount),
    );

    final lessonsWithHistory = lessons
        .where((l) => (progress[l.fileName]?.scoreHistory.isNotEmpty ?? false))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Progress Report"), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            "Trouble Words",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            "Words you've missed more than once, across every lesson.",
            style: TextStyle(color: Colors.grey[700]),
          ),
          const SizedBox(height: 14),

          if (troubleEntries.isEmpty)
            _emptyCard("No repeated mistakes yet — nice work!")
          else
            ...troubleEntries.map(
              (entry) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: Text(
                    entry.key.arabic,
                    style: AppTextStyles.arabicWord(fontSize: 22),
                  ),
                  title: Text(entry.key.meaning ?? ""),
                  subtitle: Text(entry.value),
                  trailing: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "${entry.key.wrongCount}x missed",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red[700],
                        ),
                      ),
                      if (entry.key.isCurrentlyStruggling)
                        const Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Icon(
                            Icons.warning_amber_rounded,
                            size: 16,
                            color: Colors.orange,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

          const SizedBox(height: 28),

          const Text(
            "Score Trend",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            "Your last few scores per lesson.",
            style: TextStyle(color: Colors.grey[700]),
          ),
          const SizedBox(height: 14),

          if (lessonsWithHistory.isEmpty)
            _emptyCard("Complete a lesson to start seeing your score trend.")
          else
            ...lessonsWithHistory.map((lesson) {
              final lessonProgress = progress[lesson.fileName]!;

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lesson.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _ScoreSparkline(
                        scores: lessonProgress.scoreHistory,
                        total: lesson.totalWords,
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _emptyCard(String message) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}

class _ScoreSparkline extends StatelessWidget {
  final List<int> scores;
  final int total;

  const _ScoreSparkline({required this.scores, required this.total});

  static const double _maxBarHeight = 44;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: _maxBarHeight + 20,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final score in scores)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 14,
                    height:
                        _maxBarHeight *
                        (total == 0 ? 0.0 : (score / total)).clamp(0.08, 1.0),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$score',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
