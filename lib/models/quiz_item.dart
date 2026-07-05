import 'vocabulary_word.dart';

class QuizItem {
  final VocabularyWord question;
  final List<String> options;
  final int correctAnswer;

  const QuizItem({
    required this.question,
    required this.options,
    required this.correctAnswer,
  });

  /// Returns true if the selected answer is correct.
  bool isCorrect(int selectedIndex) {
    return selectedIndex == correctAnswer;
  }

  /// Returns the correct meaning, with Urdu alongside English when available.
  String get correctMeaning => question.displayMeaning;

  /// Returns the Arabic word.
  String get arabicWord => question.arabic;

  @override
  String toString() {
    return 'QuizItem(question: ${question.arabic}, correct: ${question.meaning})';
  }
}
