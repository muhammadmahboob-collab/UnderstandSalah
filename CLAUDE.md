````markdown
# CLAUDE.md

# Quran Vocabulary Quiz App – Project Handoff

## Project Overview

### Purpose

This application is a Flutter mobile application that teaches Quranic Arabic vocabulary through a word-by-word multiple choice quiz.

The primary objective is for a learner to gradually memorize the meanings of Arabic words occurring in:

- Quran Surahs
- Tashahhud
- Durood Ibrahim
- Dua Qunoot
- Later:
  - Entire Salah
  - Entire Quran
  - Daily Duas
  - 99 Names of Allah

Unlike memorization apps, this app focuses on **recognizing Arabic vocabulary**.

Each question displays:

- one Arabic word

The user chooses from:

- four English meanings

After selecting an answer:

- correct answer becomes green
- wrong answer becomes red
- automatically proceeds to next question after a short delay

The application should become data-driven so adding lessons requires only creating JSON files rather than modifying Dart code.

---

# Target Audience

- Muslims learning Quranic Arabic
- Students memorizing Salah
- Quran schools
- Self-paced learners

---

# Technology Stack

Framework

- Flutter (latest stable)

Language

- Dart

State Management

Currently:

- StatefulWidget
- setState()

No Provider/Riverpod/BLoC yet.

Assets

JSON files inside:

```
assets/data/
```

Future

- SharedPreferences
- Audio playback
- Progress persistence
- Dark mode

---

# Project Structure

```
lib/

main.dart

models/
    vocabulary_word.dart
    quiz_item.dart
    lesson.dart

services/
    quiz_service.dart
    lesson_service.dart

screens/
    home_screen.dart
    quiz_screen.dart

theme/
    app_text_styles.dart   (planned)

assets/

data/
    lessons.json
    surah109.json
    tashahhud.json
    durood_ibrahim.json
    dua_qunoot.json

fonts/
    NotoNaskhArabic-Regular.ttf (planned)
```

---

# Current Architecture

There are four major layers.

## Models

Contain only data.

### vocabulary_word.dart

Represents a single Arabic vocabulary item.

Current fields:

```dart
class VocabularyWord {

  final String arabic;
  final String meaning;

  final int? surah;
  final int? ayah;

  final int? word;

  final String? lesson;
  final String? section;

  final int? line;

}
```

Supports:

- Quran
- Salah
- Duas

without modification.

---

### quiz_item.dart

Represents one quiz question.

```dart
class QuizItem {

    final VocabularyWord question;

    final List<String> options;

    final int correctAnswer;

}
```

Also contains helper getters:

```
arabicWord

correctMeaning

isCorrect()
```

---

### lesson.dart

Represents one lesson.

Current structure:

```dart
class Lesson {

    final int id;

    final String title;

    final String arabicTitle;

    final String subtitle;

    final String category;

    final String fileName;

    final int totalWords;

    final String icon;

}
```

Loaded from JSON.

---

# Services

## quiz_service.dart

Responsible for:

Loading lesson JSON

```
Future<void> loadLesson(String fileName)
```

Loading:

```
assets/data/<lesson>.json
```

Generates randomized quiz.

Methods:

```
loadLesson()

hasNextQuestion()

getNextQuestion()

restart()

totalQuestions

remainingQuestions
```

Questions are randomized.

Answer choices are randomized.

Correct answer index stored inside QuizItem.

Duplicate options prevented.

---

## lesson_service.dart

Responsible for:

Loading:

```
assets/data/lessons.json
```

Returns:

```
Future<List<Lesson>>
```

This removes all hardcoded lessons from UI.

---

# Screens

## home_screen.dart

Current implementation:

Uses

```
LessonService
```

Loads

```
lessons.json
```

Displays grouped cards by category.

Categories currently:

```
Quran

Salah
```

Each card displays

- title
- Arabic title
- total words
- arrow icon

Selecting card opens

```
QuizScreen
```

using

```
lesson.fileName
```

---

## quiz_screen.dart

Constructor

```
QuizScreen({

required lessonFile,

required title

})
```

Flow

```
loadLesson()

↓

QuizService

↓

QuizItem

↓

display Arabic

↓

display 4 choices

↓

select answer

↓

color feedback

↓

automatic next question

↓

results dialog
```

Current state:

Working.

---

# Assets

Lessons stored in

```
assets/data/
```

Current files

```
lessons.json

surah109.json

tashahhud.json

durood_ibrahim.json

dua_qunoot.json
```

Each lesson JSON is an array.

Each object contains

```
arabic

meaning

surah (optional)

ayah (optional)

word (optional)

lesson (optional)

section (optional)

line (optional)
```

No transliteration stored.

English meaning only.

---

# Data Flow

```
HomeScreen

↓

LessonService

↓

lessons.json

↓

Lesson

↓

QuizScreen

↓

QuizService

↓

lesson JSON

↓

VocabularyWord

↓

QuizItem

↓

UI
```

---

# Current Features

Working

✔ Dynamic lesson loading

✔ JSON driven

✔ Random question order

✔ Random answer order

✔ No duplicate questions

✔ No duplicate answers

✔ Restart quiz

✔ Home screen

✔ Lesson cards

✔ Result dialog

✔ Multiple lesson support

---

# Current Bugs

None known.

---

# In Progress

Arabic typography.

Need:

Google Font

```
Noto Naskh Arabic
```

Create

```
assets/fonts/
```

Update

```
pubspec.yaml
```

Planned

```
theme/app_text_styles.dart
```

Example

```
AppTextStyles.arabicWord

AppTextStyles.arabicTitle
```

---

# pubspec.yaml

Assets

```
flutter:

  assets:

    - assets/data/
```

Later

```
fonts:

- family: NotoNaskhArabic

  fonts:

  - asset: assets/fonts/NotoNaskhArabic-Regular.ttf
```

---

# Coding Conventions

File names

snake_case

Examples

```
quiz_service.dart

lesson_service.dart

vocabulary_word.dart
```

Classes

PascalCase

```
QuizService

VocabularyWord

Lesson
```

Variables

camelCase

```
currentQuestion

lessonFile

correctAnswer
```

Models

Contain data only.

Services

Contain logic only.

UI

Contains presentation only.

Architecture intentionally separates

Model

Service

Screen

Future Widget layer

---

# Design Decisions

Important

Everything should become JSON driven.

Developer should never have to edit Dart code to add content.

Adding lesson should only require

1.

Create JSON

2.

Add one entry to

```
lessons.json
```

No other code.

---

No English stored in code.

Everything comes from JSON.

---

Future widgets

Reusable.

Avoid giant screens.

Prefer

```
widgets/

lesson_card.dart

answer_button.dart

progress_card.dart
```

---

# Planned UI

Home screen

Professional dashboard.

Header

```
Assalamu Alaikum
```

Sections

```
Quran

Salah

Daily Duas
```

Cards

Rounded

Elevation

Progress

Words count

Future

Continue Learning section.

Search.

Dark mode.

Favorites.

---

# Planned Features

High priority

Progress tracking

SharedPreferences

Words mastered

Wrong answers review

Lesson completion

Progress bars

Achievements

Daily streak

---

Audio

Every Arabic word

Clickable speaker icon

---

Animations

Correct answer

Wrong answer

Smooth transitions

---

Future Lessons

Entire Quran

Entire Salah

Daily Duas

Morning/Evening Adhkar

99 Names

Prophetic Duas

---

# Future Folder Structure

```
lib/

models/

    vocabulary_word.dart

    quiz_item.dart

    lesson.dart

    lesson_progress.dart

services/

    quiz_service.dart

    lesson_service.dart

    progress_service.dart

screens/

    home_screen.dart

    quiz_screen.dart

    result_screen.dart

    settings_screen.dart

widgets/

    lesson_card.dart

    answer_button.dart

    progress_card.dart

    category_header.dart

theme/

    app_text_styles.dart

main.dart
```

---

# Immediate Next Tasks

1.

Install

Noto Naskh Arabic

2.

Create

```
theme/app_text_styles.dart
```

3.

Apply typography across app.

4.

Create reusable

```
lesson_card.dart
```

5.

Create reusable

```
answer_button.dart
```

6.

Implement

SharedPreferences

7.

Progress tracking

8.

Circular progress indicators

9.

Search lessons

10.

Dark mode

---

# Long-Term Goal

The app should become a polished, offline-first Quranic Arabic learning platform where new lessons are added entirely through JSON files, with a clean separation between models, services, screens, and reusable widgets. The architecture should remain modular and scalable as the content grows from a few lessons to the entire Quran, Salah, and additional Islamic learning material.
````
