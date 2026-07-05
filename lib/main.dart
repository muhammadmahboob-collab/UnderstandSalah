import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/settings_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final SettingsService _settingsService = SettingsService();

  double _textScale = 1.0;

  @override
  void initState() {
    super.initState();
    _loadTextScale();
  }

  Future<void> _loadTextScale() async {
    final scale = await _settingsService.loadTextScale();
    setState(() => _textScale = scale);
  }

  void _updateTextScale(double scale) {
    setState(() => _textScale = scale);
    _settingsService.saveTextScale(scale);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Quran Vocabulary Quiz",
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(_textScale)),
          child: child!,
        );
      },
      home: HomeScreen(
        textScale: _textScale,
        onTextScaleChanged: _updateTextScale,
      ),
    );
  }
}
