/// Tracks how well a single Arabic word has been learned within a lesson.
class WordProgress {
  final String arabic;
  String? meaning;
  int correctCount;
  int wrongCount;
  int consecutiveWrong;

  WordProgress({
    required this.arabic,
    this.meaning,
    this.correctCount = 0,
    this.wrongCount = 0,
    this.consecutiveWrong = 0,
  });

  /// A word is considered mastered once it has been answered correctly
  /// clearly more often than it has been missed.
  bool get isMastered => (correctCount - wrongCount) >= 3;

  /// A word has repeatedly tripped the learner up if it's been missed
  /// more than once, ever.
  bool get isRepeatedMistake => wrongCount >= 2;

  /// A word is a live, current problem if the last couple of attempts at
  /// it were both wrong (regardless of past successes).
  bool get isCurrentlyStruggling => consecutiveWrong >= 2;

  factory WordProgress.fromJson(Map<String, dynamic> json) {
    return WordProgress(
      arabic: json['arabic'] as String,
      meaning: json['meaning'] as String?,
      correctCount: json['correctCount'] as int? ?? 0,
      wrongCount: json['wrongCount'] as int? ?? 0,
      consecutiveWrong: json['consecutiveWrong'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'arabic': arabic,
      'meaning': meaning,
      'correctCount': correctCount,
      'wrongCount': wrongCount,
      'consecutiveWrong': consecutiveWrong,
    };
  }
}

/// Tracks progress for a single lesson: best score, completions, score
/// history, and per-word mastery.
class LessonProgress {
  static const maxScoreHistory = 10;

  final String lessonFile;
  int timesCompleted;
  int bestScore;
  List<int> scoreHistory;
  Map<String, WordProgress> words;

  LessonProgress({
    required this.lessonFile,
    this.timesCompleted = 0,
    this.bestScore = 0,
    List<int>? scoreHistory,
    Map<String, WordProgress>? words,
  }) : scoreHistory = scoreHistory ?? [],
       words = words ?? {};

  int get masteredWordCount => words.values.where((w) => w.isMastered).length;

  /// Words that have been attempted at least once but aren't mastered yet
  /// (used both for "review missed words" and to weight quiz ordering).
  List<WordProgress> get strugglingWords => words.values
      .where((w) => !w.isMastered && (w.correctCount > 0 || w.wrongCount > 0))
      .toList();

  List<String> get strugglingWordsArabic =>
      strugglingWords.map((w) => w.arabic).toList();

  /// Words that have been missed more than once, ever — used for the
  /// cross-lesson "Trouble Words" report.
  List<WordProgress> get repeatedMistakes =>
      words.values.where((w) => w.isRepeatedMistake).toList();

  WordProgress wordProgressFor(String arabic) {
    return words.putIfAbsent(arabic, () => WordProgress(arabic: arabic));
  }

  void addScoreToHistory(int score) {
    scoreHistory.add(score);
    if (scoreHistory.length > maxScoreHistory) {
      scoreHistory.removeAt(0);
    }
  }

  factory LessonProgress.fromJson(Map<String, dynamic> json) {
    final wordsJson = json['words'] as Map<String, dynamic>? ?? {};

    return LessonProgress(
      lessonFile: json['lessonFile'] as String,
      timesCompleted: json['timesCompleted'] as int? ?? 0,
      bestScore: json['bestScore'] as int? ?? 0,
      scoreHistory: (json['scoreHistory'] as List<dynamic>? ?? [])
          .map((e) => e as int)
          .toList(),
      words: wordsJson.map(
        (key, value) => MapEntry(
          key,
          WordProgress.fromJson(value as Map<String, dynamic>),
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lessonFile': lessonFile,
      'timesCompleted': timesCompleted,
      'bestScore': bestScore,
      'scoreHistory': scoreHistory,
      'words': words.map((key, value) => MapEntry(key, value.toJson())),
    };
  }
}
