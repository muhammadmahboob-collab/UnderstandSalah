import 'package:flutter/material.dart';

import '../models/vocabulary_word.dart';
import '../services/quiz_service.dart';
import '../theme/app_text_styles.dart';

/// Shows every word in a lesson, in order, alongside its meaning — a plain
/// reference list/table rather than a quiz.
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

  List<VocabularyWord> _words = [];
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
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(
              colorScheme.primaryContainer,
            ),
            columnSpacing: 24,
            columns: const [
              DataColumn(
                label: Text(
                  "Arabic",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  "Meaning",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
            rows: [
              for (final word in _words)
                DataRow(
                  cells: [
                    DataCell(
                      Text(word.arabic, style: AppTextStyles.arabicWord(fontSize: 22)),
                    ),
                    DataCell(
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 180),
                        child: Text(
                          word.displayMeaning,
                          softWrap: true,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
