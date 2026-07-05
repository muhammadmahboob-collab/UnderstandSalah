import 'package:flutter/material.dart';

import '../models/vocabulary_word.dart';
import '../services/quiz_service.dart';
import '../theme/app_text_styles.dart';
import '../utils/lesson_context.dart';
import '../widgets/context_phrase.dart';

/// A simple flip-card study mode: see the Arabic word, tap to reveal its
/// meaning and the full phrase it belongs to. Words are shown in the
/// order they appear in the lesson.
class FlashcardScreen extends StatefulWidget {
  final String lessonFile;
  final String title;

  const FlashcardScreen({
    super.key,
    required this.lessonFile,
    required this.title,
  });

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  final QuizService _quizService = QuizService();

  List<VocabularyWord> _words = [];
  int _index = 0;
  bool _showMeaning = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _quizService.loadLesson(widget.lessonFile);

    setState(() {
      _words = _quizService.words;
      _loading = false;
    });
  }

  void _flip() {
    setState(() => _showMeaning = !_showMeaning);
  }

  void _goTo(int newIndex) {
    setState(() {
      _index = newIndex;
      _showMeaning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final word = _words[_index];
    final phraseContext = contextFor(_words, word);

    return Scaffold(
      appBar: AppBar(
        title: Text("Flashcards: ${widget.title}"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            LinearProgressIndicator(value: (_index + 1) / _words.length),
            const SizedBox(height: 10),
            Text(
              "Card ${_index + 1} of ${_words.length}",
              style: const TextStyle(fontSize: 16),
            ),
            const Spacer(),
            Expanded(
              flex: 6,
              child: GestureDetector(
                onTap: _flip,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Container(
                    key: ValueKey(_showMeaning),
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: _showMeaning
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                word.displayMeaning,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ContextPhrase(
                                context: phraseContext,
                                showMeaning: true,
                              ),
                            ],
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                word.arabic,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.arabicWord(),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "Tap to reveal meaning",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _index > 0 ? () => _goTo(_index - 1) : null,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text("Previous"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _index < _words.length - 1
                        ? () => _goTo(_index + 1)
                        : null,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text("Next"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
