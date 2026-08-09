import 'package:flutter/material.dart';

import '../models/vocabulary_word.dart';
import '../services/quiz_service.dart';
import '../theme/app_text_styles.dart';
import '../utils/lesson_context.dart';

/// Shows every word in a lesson the way a Quran mushaf's word-by-word page
/// does: Arabic on top, meaning underneath, flowing right-to-left with a
/// small circle marking the end of each verse/line.
class WordListScreen extends StatefulWidget {
  final String lessonFile;
  final String title;

  const WordListScreen({
    super.key,
    required this.lessonFile,
    required this.title,
  });

  @override
  State<WordListScreen> createState() => _WordListScreenState();
}

class _WordListScreenState extends State<WordListScreen> {
  final QuizService _quizService = QuizService();

  List<WordGroup> _groups = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _quizService.loadLesson(widget.lessonFile);

    setState(() {
      _groups = groupIntoPhrases(_quizService.words);
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text("Word List: ${widget.title}"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Wrap(
              textDirection: TextDirection.rtl,
              alignment: WrapAlignment.start,
              runSpacing: 16,
              children: [
                for (final group in _groups) ...[
                  for (final word in group.words) _wordCell(word),
                  _verseBadge(colorScheme, group.number),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _wordCell(VocabularyWord word) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 92),
      margin: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(word.arabic, style: AppTextStyles.arabicWord(fontSize: 22)),
          const SizedBox(height: 4),
          Text(
            word.displayMeaning,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _verseBadge(ColorScheme colorScheme, int number) {
    return Container(
      width: 26,
      height: 26,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: colorScheme.primary, width: 1.5),
      ),
      child: Text(
        "$number",
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: colorScheme.primary,
        ),
      ),
    );
  }
}
