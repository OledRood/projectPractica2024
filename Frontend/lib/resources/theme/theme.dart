import 'package:flutter/cupertino.dart';
import 'package:hr_monitor/resources/theme/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppTheme extends ChangeNotifier {
  static const String _themeKey = 'selected_theme';
  ColorPalette _currentPalette = AppColors.pinkTheme;

  ColorPalette get palette => _currentPalette;

  // Загрузка темы из SharedPreferences
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final theme =
        prefs.getString(_themeKey) ?? 'pink'; // По умолчанию светлая тема
    switch (theme) {
      case 'dark':
        _currentPalette = AppColors.darkTheme;
        break;
      case 'green':
        _currentPalette = AppColors.greenTheme;
        break;
      case 'yellow':
        _currentPalette = AppColors.yellowTheme;
        break;
      case 'blue':
        _currentPalette = AppColors.blueTheme;
        break;
      case 'brown':
        _currentPalette = AppColors.brownTheme;
        break;
      case 'pink':
      default:
        _currentPalette = AppColors.pinkTheme;
    }
    notifyListeners();
  }

  // Сохранение темы в SharedPreferences
  Future<void> _saveTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, theme);
  }

  void switchToLightTheme() {
    _currentPalette = AppColors.pinkTheme;
    _saveTheme('pink');
    notifyListeners();
  }

  void switchToDarkTheme() {
    _currentPalette = AppColors.darkTheme;
    _saveTheme('dark');
    notifyListeners();
  }

  void switchToGreenTheme() {
    _currentPalette = AppColors.greenTheme;
    _saveTheme('green');
    notifyListeners();
  }

  void switchToYellowTheme() {
    _currentPalette = AppColors.yellowTheme;
    _saveTheme('yellow');
    notifyListeners();
  }

  void switchToBlueTheme() {
    _currentPalette = AppColors.blueTheme;
    _saveTheme('blue');
    notifyListeners();
  }

  void switchToBrownTheme() {
    _currentPalette = AppColors.brownTheme;
    _saveTheme('brown');
    notifyListeners();
  }
}
