import 'package:flutter/material.dart';

import '../theme/app_text_styles.dart';
import '../utils/lesson_context.dart';

/// Shows the full phrase a word belongs to, with the tested word rendered
/// large and centered, and the surrounding words small on either side, so
/// the learner sees where it fits without losing emphasis.
class ContextPhrase extends StatelessWidget {
  final WordContext context;
  final bool showMeaning;

  const ContextPhrase({
    super.key,
    required this.context,
    this.showMeaning = false,
  });

  static const double _targetFontSize = 48;
  static const double _smallFontSize = 20;

  @override
  Widget build(BuildContext buildContext) {
    final colorScheme = Theme.of(buildContext).colorScheme;

    final before = context.words.sublist(0, context.index);
    final target = context.words[context.index];
    final after = context.words.sublist(context.index + 1);

    final smallStyle = AppTextStyles.arabicWord(
      fontSize: _smallFontSize,
    ).copyWith(color: Colors.black45);

    final targetStyle = AppTextStyles.arabicWord(
      fontSize: _targetFontSize,
    ).copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold);

    return Column(
      children: [
        Row(
          textDirection: TextDirection.rtl,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                before.map((w) => w.arabic).join(' '),
                textAlign: TextAlign.left,
                textDirection: TextDirection.rtl,
                style: smallStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(target.arabic, style: targetStyle),
            ),
            Expanded(
              child: Text(
                after.map((w) => w.arabic).join(' '),
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: smallStyle,
              ),
            ),
          ],
        ),
        if (showMeaning) ...[
          const SizedBox(height: 8),
          Text(
            context.meaningPhrase,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
