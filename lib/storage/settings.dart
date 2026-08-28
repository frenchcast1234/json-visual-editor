import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends ChangeNotifier {
  Settings._(this._prefs);

  final SharedPreferences _prefs;

  static const _themeKey = "theme";
  static const _recentKey = "recent_files";
  static const maxRecent = 10;

  static Future<Settings> load() async => Settings._(await SharedPreferences.getInstance());

  bool get isDark => _prefs.getInt(_themeKey) == 1;

  Future<void> setDark(bool dark) async {
    if (dark == isDark) return;
    await _prefs.setInt(_themeKey, dark ? 1 : 0);
    notifyListeners();
  }

  Future<void> toggleTheme() => setDark(!isDark);

  List<String> get recentFiles => _prefs.getStringList(_recentKey) ?? const [];

  Future<void> pushRecent(String path) async {
    final next = [path, ...recentFiles.where((e) => e != path)];
    await _prefs.setStringList(_recentKey, next.take(maxRecent).toList());
    notifyListeners();
  }

  Future<void> removeRecent(String path) async {
    final next = recentFiles.where((e) => e != path).toList();
    if (next.length == recentFiles.length) return;
    await _prefs.setStringList(_recentKey, next);
    notifyListeners();
  }

  Future<void> clearRecent() async {
    await _prefs.setStringList(_recentKey, const []);
    notifyListeners();
  }
}
