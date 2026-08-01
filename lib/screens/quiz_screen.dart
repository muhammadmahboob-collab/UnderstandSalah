import 'dart:async';

import 'package:flutter/material.dart';
import '../services/quiz_service.dart';
import '../services/progress_service.dart';
import '../models/quiz_item.dart';
import '../utils/lesson_context.dart';
import '../widgets/context_phrase.dart';
import 'result_screen.dart' show ResultScreen, ResultAction;

class QuizScreen extends StatefulWidget {
  final String lessonFile;
  final String title;
  final bool sequential;

  /// If set, restricts the quiz to only these Arabic words (used for
  /// reviewing previously missed words) instead of the full lesson.
  final List<String>? reviewWords;

  /// If set, restricts the quiz to just this range of verses (ayahs) —
  /// used for long surahs quizzed a few verses at a time.
  final int? ayahRangeStart;
  final int? ayahRangeEnd;

  const QuizScreen({
    super.key,
    required this.lessonFile,
    required this.title,
    this.sequential = false,
    this.reviewWords,
    this.ayahRangeStart,
    this.ayahRangeEnd,
  });

  bool get isReview => reviewWords != null;
  bool get isRangedQuiz => ayahRangeStart != null;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final QuizService _quizService = QuizService();
  final ProgressService _progressService = ProgressService();

  late QuizItem _currentQuestion;

  bool _loading = true;
  bool _answered = false;

  // Guards against advancing twice for the same question — e.g. if the
  // learner taps "Next Question" manually right before the automatic
  // 1-second advance also fires.
  bool _transitioning = false;
  Timer? _autoAdvanceTimer;

  int _selectedIndex = -1;
  int _score = 0;
  int _questionNumber = 0;

  @override
  void initState() {
    super.initState();
    _loadLesson();
  }

  Future<void> _loadLesson() async {
    // Struggling words (missed and not yet mastered) are weighted to come
    // up earlier in the quiz, so they get reinforced sooner.
    final priorityWords = (widget.isReview || widget.isRangedQuiz)
        ? null
        : (await _progressService.loadProgress(
            widget.lessonFile,
          )).strugglingWordsArabic.toSet();

    await _quizService.loadLesson(
      widget.lessonFile,
      sequential: widget.sequential,
      priorityWords: priorityWords,
    );

    if (widget.isReview) {
      _quizService.restrictToWords(widget.reviewWords!);
    } else if (widget.isRangedQuiz) {
      _quizService.restrictToAyahRange(
        widget.ayahRangeStart!,
        widget.ayahRangeEnd!,
      );
    }

    _nextQuestion();

    setState(() {
      _loading = false;
    });
  }

  void _nextQuestion() {
    // Cancel any pending auto-advance so it can't fire again for a
    // question we've already left (e.g. after a manual "Next Question" tap).
    _autoAdvanceTimer?.cancel();

    if (_transitioning) return;
    _transitioning = true;

    if (_quizService.hasNextQuestion()) {
      _currentQuestion = _quizService.getNextQuestion();

      _questionNumber++;

      _answered = false;
      _selectedIndex = -1;

      setState(() {});
      _transitioning = false;
    } else {
      _showResult();
    }
  }

  void _selectAnswer(int index) {
    if (_answered) return;

    final bool correct = index == _currentQuestion.correctAnswer;

    setState(() {
      _answered = true;
      _selectedIndex = index;

      if (correct) {
        _score++;
      }
    });

    _progressService.recordAnswer(
      lessonFile: widget.lessonFile,
      arabicWord: _currentQuestion.arabicWord,
      meaning: _currentQuestion.correctMeaning,
      correct: correct,
    );

    // Wait 1 second before showing next question, unless the learner
    // already moved on manually in the meantime.
    _autoAdvanceTimer?.cancel();
    _autoAdvanceTimer = Timer(const Duration(seconds: 1), () {
      if (mounted) {
        _nextQuestion();
      }
    });
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    super.dispose();
  }

  Color _buttonColor(int index) {
    if (!_answered) return Colors.blue;

    if (index == _currentQuestion.correctAnswer) {
      return Colors.green;
    }

    if (index == _selectedIndex) {
      return Colors.red;
    }

    return Colors.grey;
  }

  Future<void> _showResult() async {
    // A review or ranged (partial-verses) session doesn't count toward the
    // lesson's completion stats, since it only covers a subset of the
    // lesson's words.
    final progress = (widget.isReview || widget.isRangedQuiz)
        ? await _progressService.loadProgress(widget.lessonFile)
        : await _progressService.recordQuizCompletion(
            lessonFile: widget.lessonFile,
            score: _score,
          );

    if (!mounted) return;

    final action = await Navigator.push<ResultAction>(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          title: widget.isReview ? "Review: ${widget.title}" : widget.title,
          score: _score,
          totalQuestions: _quizService.totalQuestions,
          progress: progress,
        ),
      ),
    );

    if (!mounted) return;

    switch (action) {
      case ResultAction.retry:
        _quizService.restart();

        setState(() {
          _score = 0;
          _questionNumber = 0;
        });

        _transitioning = false;
        _nextQuestion();
        break;

      case ResultAction.reviewMissed:
        final missedWords = progress.strugglingWordsArabic;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => QuizScreen(
              lessonFile: widget.lessonFile,
              title: widget.title,
              reviewWords: missedWords,
            ),
          ),
        );
        break;

      case ResultAction.back:
      case null:
        Navigator.pop(context);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    double progress = _questionNumber / _quizService.totalQuestions;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isReview ? "Review: ${widget.title}" : widget.title),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            LinearProgressIndicator(value: progress),

            const SizedBox(height: 10),

            Text(
              "Question $_questionNumber of ${_quizService.totalQuestions}",
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 10),

            Text(
              "Score: $_score",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            ContextPhrase(
              context: contextFor(_quizService.words, _currentQuestion.question),
            ),

            const SizedBox(height: 28),

            ...List.generate(
              _currentQuestion.options.length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _buttonColor(index),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 12,
                      ),
                    ),
                    onPressed: () => _selectAnswer(index),
                    child: Text(
                      _currentQuestion.options[index],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _answered ? _nextQuestion : null,
                child: const Text(
                  "Next Question",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
