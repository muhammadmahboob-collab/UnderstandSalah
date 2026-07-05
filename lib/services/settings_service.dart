import 'package:shared_preferences/shared_preferences.dart';

/// Persists app-wide settings, such as text size, on the device.
class SettingsService {
  static const _textScaleKey = 'text_scale';

  Future<double> loadTextScale() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_textScaleKey) ?? 1.0;
  }

  Future<void> saveTextScale(double scale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_textScaleKey, scale);
  }
}
