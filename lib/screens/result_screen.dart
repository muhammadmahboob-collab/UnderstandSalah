import 'package:flutter/material.dart';

import '../models/lesson_progress.dart';
import '../theme/app_text_styles.dart';

enum ResultAction { retry, reviewMissed, back }

class ResultScreen extends StatelessWidget {
  final String title;
  final int score;
  final int totalQuestions;
  final LessonProgress progress;

  const ResultScreen({
    super.key,
    required this.title,
    required this.score,
    required this.totalQuestions,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final wordsToReview = progress.strugglingWords
      ..sort((a, b) => b.wrongCount.compareTo(a.wrongCount));

    final masteredFraction = totalQuestions == 0
        ? 0.0
        : progress.masteredWordCount / totalQuestions;

    return Scaffold(
      appBar: AppBar(title: Text(title), centerTitle: true),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              "$score / $totalQuestions",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              "This quiz's score",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    _statRow(
                      "Best score for this lesson",
                      "${progress.bestScore} / $totalQuestions",
                    ),
                    const SizedBox(height: 10),
                    _statRow(
                      "Times you've completed this lesson",
                      "${progress.timesCompleted}",
                    ),
                    const SizedBox(height: 10),
                    _statRow(
                      "Words mastered",
                      "${progress.masteredWordCount} / $totalQuestions",
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: masteredFraction,
                        minHeight: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            if (wordsToReview.isNotEmpty) ...[
              const Text(
                "Words to review",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...wordsToReview.map(
                (w) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: Text(w.arabic, style: AppTextStyles.arabicWord(fontSize: 24)),
                    title: Text(w.meaning ?? ""),
                    subtitle: w.isRepeatedMistake
                        ? Row(
                            children: [
                              if (w.isCurrentlyStruggling) ...[
                                const Icon(
                                  Icons.warning_amber_rounded,
                                  size: 14,
                                  color: Colors.orange,
                                ),
                                const SizedBox(width: 4),
                              ],
                              Text(
                                "Missed ${w.wrongCount} times",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: w.isCurrentlyStruggling
                                      ? Colors.orange[800]
                                      : Colors.grey[600],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],

            const SizedBox(height: 10),

            if (wordsToReview.isNotEmpty) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context, ResultAction.reviewMissed),
                  icon: const Icon(Icons.refresh),
                  label: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      "Review ${wordsToReview.length} Missed Words",
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context, ResultAction.retry),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text("Try Again", style: TextStyle(fontSize: 18)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context, ResultAction.back),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text("Back to Lessons", style: TextStyle(fontSize: 18)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(label, style: const TextStyle(fontSize: 15))),
        Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
