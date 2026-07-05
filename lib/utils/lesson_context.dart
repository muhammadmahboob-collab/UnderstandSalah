import '../models/vocabulary_word.dart';

/// The full phrase (ayah or recitation line) a word belongs to, in order,
/// along with which position the target word is at.
class WordContext {
  final List<VocabularyWord> words;
  final int index;

  const WordContext({required this.words, required this.index});

  String get arabicPhrase => words.map((w) => w.arabic).join(' ');
  String get meaningPhrase => words.map((w) => w.meaning).join(' ');
}

/// Reconstructs the full phrase [target] belongs to from [allWords], using
/// the ayah (Quran) or line (Salah/dua) grouping already present in the
/// lesson data, ordered by each word's position within that phrase.
WordContext contextFor(List<VocabularyWord> allWords, VocabularyWord target) {
  String keyFor(VocabularyWord w) =>
      w.ayah != null ? 'ayah:${w.surah}:${w.ayah}' : 'line:${w.line}';

  final key = keyFor(target);

  final group = allWords.where((w) => keyFor(w) == key).toList()
    ..sort((a, b) => (a.word ?? 0).compareTo(b.word ?? 0));

  final index = group.indexWhere((w) => identical(w, target));

  return WordContext(words: group, index: index < 0 ? 0 : index);
}
