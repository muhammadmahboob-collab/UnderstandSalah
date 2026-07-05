class Lesson {
  final int id;
  final String title;
  final String arabicTitle;
  final String subtitle;
  final String category;
  final String fileName;
  final int totalWords;
  final String icon;
  final bool sequential;

  const Lesson({
    required this.id,
    required this.title,
    required this.arabicTitle,
    required this.subtitle,
    required this.category,
    required this.fileName,
    required this.totalWords,
    required this.icon,
    this.sequential = false,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'],
      title: json['title'],
      arabicTitle: json['arabicTitle'],
      subtitle: json['subtitle'],
      category: json['category'],
      fileName: json['fileName'],
      totalWords: json['totalWords'],
      icon: json['icon'],
      sequential: json['sequential'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'arabicTitle': arabicTitle,
      'subtitle': subtitle,
      'category': category,
      'fileName': fileName,
      'totalWords': totalWords,
      'icon': icon,
      'sequential': sequential,
    };
  }
}
