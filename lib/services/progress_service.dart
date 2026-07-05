import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/lesson_progress.dart';

/// Persists lesson and word progress on the device using SharedPreferences.
class ProgressService {
  static String _keyFor(String lessonFile) => 'progress_$lessonFile';

  Future<LessonProgress> loadProgress(String lessonFile) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_keyFor(lessonFile));

    if (stored == null) {
      return LessonProgress(lessonFile: lessonFile);
    }

    return LessonProgress.fromJson(json.decode(stored));
  }

  Future<void> saveProgress(LessonProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyFor(progress.lessonFile),
      json.encode(progress.toJson()),
    );
  }

  /// Records whether a single word was answered correctly, and persists it.
  Future<LessonProgress> recordAnswer({
    required String lessonFile,
    required String arabicWord,
    required String meaning,
    required bool correct,
  }) async {
    final progress = await loadProgress(lessonFile);
    final word = progress.wordProgressFor(arabicWord);
    word.meaning = meaning;

    if (correct) {
      word.correctCount++;
      word.consecutiveWrong = 0;
    } else {
      word.wrongCount++;
      word.consecutiveWrong++;
    }

    await saveProgress(progress);
    return progress;
  }

  /// Records the result of a completed quiz, and persists it.
  Future<LessonProgress> recordQuizCompletion({
    required String lessonFile,
    required int score,
  }) async {
    final progress = await loadProgress(lessonFile);

    progress.timesCompleted++;
    if (score > progress.bestScore) {
      progress.bestScore = score;
    }
    progress.addScoreToHistory(score);

    await saveProgress(progress);
    return progress;
  }
}
