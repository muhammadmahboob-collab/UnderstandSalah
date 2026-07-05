import '../models/quiz_item.dart';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

import '../models/vocabulary_word.dart';

class QuizService {
  final Random _random = Random();

  List<VocabularyWord> _words = [];
  List<int> _remainingQuestions = [];
  bool _sequential = false;
  Set<String>? _restrictedToWords;
  Set<String>? _priorityWords;
  int _totalQuestions = 0;

  /// Loads any lesson JSON file from assets/data/
  ///
  /// Example:
  /// await loadLesson("surah109.json");
  /// await loadLesson("tashahhud.json");
  ///
  /// If [sequential] is true, words are asked in the order they appear
  /// in the lesson instead of a random order.
  ///
  /// If [priorityWords] is given (and [sequential] is false), those words
  /// are weighted to appear earlier in the quiz, so words the learner has
  /// struggled with come back sooner instead of at random.
  Future<void> loadLesson(
    String fileName, {
    bool sequential = false,
    Set<String>? priorityWords,
  }) async {
    final jsonString = await rootBundle.loadString('assets/data/$fileName');

    final List<dynamic> jsonData = json.decode(jsonString);

    _words = jsonData.map((e) => VocabularyWord.fromJson(e)).toList();
    _sequential = sequential;
    _restrictedToWords = null;
    _priorityWords = priorityWords;

    _resetQuestionOrder();
  }

  /// Restricts the quiz to only ask about the given Arabic words (e.g. for
  /// a "review missed words" session), while still using the full lesson
  /// vocabulary to generate multiple-choice distractors.
  void restrictToWords(Iterable<String> arabicWords) {
    _restrictedToWords = arabicWords.toSet();
    _resetQuestionOrder();
  }

  void _resetQuestionOrder() {
    Iterable<int> indices = List.generate(_words.length, (index) => index);

    if (_restrictedToWords != null) {
      indices = indices.where(
        (i) => _restrictedToWords!.contains(_words[i].arabic),
      );
    }

    final indexList = indices.toList();

    if (_sequential) {
      // getNextQuestion() pops from the end, so reverse to ask in order.
      _remainingQuestions = indexList.reversed.toList();
    } else if (_restrictedToWords == null &&
        _priorityWords != null &&
        _priorityWords!.isNotEmpty) {
      final priority = indexList
          .where((i) => _priorityWords!.contains(_words[i].arabic))
          .toList()
        ..shuffle();
      final normal = indexList
          .where((i) => !_priorityWords!.contains(_words[i].arabic))
          .toList()
        ..shuffle();
      // getNextQuestion() pops from the end, so priority words go last
      // in this list to come out first.
      _remainingQuestions = [...normal, ...priority];
    } else {
      _remainingQuestions = indexList..shuffle();
    }

    _totalQuestions = _remainingQuestions.length;
  }

  /// Total number of questions in the current quiz session
  int get totalQuestions => _totalQuestions;

  /// The full lesson vocabulary, in file order (used to reconstruct the
  /// phrase a word belongs to, and for flashcard mode).
  List<VocabularyWord> get words => List.unmodifiable(_words);

  /// Remaining words
  int get remainingQuestions => _remainingQuestions.length;

  /// Are there more questions?
  bool hasNextQuestion() {
    return _remainingQuestions.isNotEmpty;
  }

  /// Returns next quiz question
  QuizItem getNextQuestion() {
    if (_remainingQuestions.isEmpty) {
      throw Exception("No questions remaining.");
    }

    final currentIndex = _remainingQuestions.removeLast();

    final VocabularyWord currentWord = _words[currentIndex];

    final Set<String> answerSet = {};

    answerSet.add(currentWord.displayMeaning);

    while (answerSet.length < 4 && answerSet.length < _words.length) {
      final randomWord = _words[_random.nextInt(_words.length)];
      answerSet.add(randomWord.displayMeaning);
    }

    final options = answerSet.toList();
    options.shuffle();

    return QuizItem(
      question: currentWord,
      options: options,
      correctAnswer: options.indexOf(currentWord.displayMeaning),
    );
  }

  /// Restart current lesson
  void restart() {
    _resetQuestionOrder();
  }
}
