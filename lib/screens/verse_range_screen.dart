import 'package:flutter/material.dart';

import '../services/quiz_service.dart';
import 'flashcard_screen.dart';
import 'quiz_screen.dart';

enum VerseRangeTarget { quiz, flashcards }

/// Lets the learner pick a chunk of verses (e.g. "Verses 6-10") to study,
/// instead of always working through the entire lesson at once — meant for
/// long surahs where doing all of it in one sitting isn't practical.
class VerseRangeScreen extends StatefulWidget {
  final String lessonFile;
  final String title;
  final bool sequential;
  final int versesPerRange;
  final VerseRangeTarget target;

  const VerseRangeScreen({
    super.key,
    required this.lessonFile,
    required this.title,
    required this.sequential,
    required this.versesPerRange,
    this.target = VerseRangeTarget.quiz,
  });

  @override
  State<VerseRangeScreen> createState() => _VerseRangeScreenState();
}

class _VerseRangeScreenState extends State<VerseRangeScreen> {
  final QuizService _quizService = QuizService();

  bool _loading = true;
  int _maxAyah = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _quizService.loadLesson(widget.lessonFile);

    var maxAyah = 0;
    for (final word in _quizService.words) {
      if (word.ayah != null && word.ayah! > maxAyah) maxAyah = word.ayah!;
    }

    setState(() {
      _maxAyah = maxAyah;
      _loading = false;
    });
  }

  void _open({int? startAyah, int? endAyah}) {
    final title = startAyah == null
        ? widget.title
        : "${widget.title} (Verses $startAyah-$endAyah)";

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => widget.target == VerseRangeTarget.flashcards
            ? FlashcardScreen(
                lessonFile: widget.lessonFile,
                title: title,
                ayahRangeStart: startAyah,
                ayahRangeEnd: endAyah,
              )
            : QuizScreen(
                lessonFile: widget.lessonFile,
                title: title,
                sequential: widget.sequential,
                ayahRangeStart: startAyah,
                ayahRangeEnd: endAyah,
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final colorScheme = Theme.of(context).colorScheme;
    final ranges = <(int, int)>[];
    for (var start = 1; start <= _maxAyah; start += widget.versesPerRange) {
      final end = (start + widget.versesPerRange - 1).clamp(0, _maxAyah);
      ranges.add((start, end));
    }

    final activity = widget.target == VerseRangeTarget.flashcards
        ? "study"
        : "quiz on";

    return Scaffold(
      appBar: AppBar(title: Text(widget.title), centerTitle: true),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              "This surah is long — pick a chunk of verses to $activity, or do the whole thing at once.",
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _open(),
                icon: const Icon(Icons.all_inclusive),
                label: const Text("All Verses"),
              ),
            ),
            const SizedBox(height: 16),

            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.9,
              children: [
                for (final (start, end) in ranges)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primaryContainer,
                      foregroundColor: colorScheme.primary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                    onPressed: () => _open(startAyah: start, endAyah: end),
                    child: Text(
                      start == end ? "Verse $start" : "$start-$end",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
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
