class VocabularyWord {
  final String arabic;
  final String meaning;
  final String? urdu;

  // Quran-specific (optional)
  final int? surah;
  final int? ayah;

  // Common fields
  final int? word;
  final String? lesson;
  final String? section;
  final int? line;

  VocabularyWord({
    required this.arabic,
    required this.meaning,
    this.urdu,
    this.surah,
    this.ayah,
    this.word,
    this.lesson,
    this.section,
    this.line,
  });

  /// The English meaning with the Urdu translation alongside it, when
  /// available (e.g. "Say / کہہ دیجیے").
  String get displayMeaning =>
      (urdu != null && urdu!.trim().isNotEmpty) ? '$meaning / $urdu' : meaning;

  factory VocabularyWord.fromJson(Map<String, dynamic> json) {
    return VocabularyWord(
      arabic: json['arabic'] ?? '',
      meaning: json['meaning'] ?? '',
      urdu: json['urdu'],
      surah: json['surah'],
      ayah: json['ayah'],
      word: json['word'],
      lesson: json['lesson'],
      section: json['section'],
      line: json['line'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'arabic': arabic,
      'meaning': meaning,
      'urdu': urdu,
      'surah': surah,
      'ayah': ayah,
      'word': word,
      'lesson': lesson,
      'section': section,
      'line': line,
    };
  }

  @override
  String toString() {
    return 'VocabularyWord(arabic: $arabic, meaning: $meaning)';
  }
}
