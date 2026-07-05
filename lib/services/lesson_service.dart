import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/lesson.dart';

class LessonService {
  Future<List<Lesson>> loadLessons() async {
    final jsonString = await rootBundle.loadString('assets/data/lessons.json');

    final List<dynamic> jsonData = json.decode(jsonString);

    return jsonData.map((lesson) => Lesson.fromJson(lesson)).toList();
  }
}
