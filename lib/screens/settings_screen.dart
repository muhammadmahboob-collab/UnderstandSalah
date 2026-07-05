import 'package:flutter/material.dart';

import '../theme/app_text_styles.dart';

class SettingsScreen extends StatefulWidget {
  final double textScale;
  final ValueChanged<double> onTextScaleChanged;

  const SettingsScreen({
    super.key,
    required this.textScale,
    required this.onTextScaleChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late double _scale = widget.textScale;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Text Size",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Adjust how large Arabic and English text appears throughout the app.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      "الْحَمْدُ لِلَّهِ",
                      style: AppTextStyles.arabicWord(fontSize: 36),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "All praise is for Allah",
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                const Icon(Icons.text_decrease),
                Expanded(
                  child: Slider(
                    value: _scale,
                    min: 0.85,
                    max: 1.3,
                    divisions: 9,
                    label: "${(_scale * 100).round()}%",
                    onChanged: (value) {
                      setState(() => _scale = value);
                      widget.onTextScaleChanged(value);
                    },
                  ),
                ),
                const Icon(Icons.text_increase),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
