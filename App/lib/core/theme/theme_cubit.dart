import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

/// Simple ThemeCubit with persistence using Hive.
class ThemeCubit extends Cubit<ThemeMode> {
  static const String _boxName = 'AppSettings';
  static const String _themeKey = 'themeMode';

  ThemeCubit() : super(ThemeMode.system) {
    _loadSavedTheme();
  }

  Future<void> _loadSavedTheme() async {
    try {
      final box = await Hive.openBox(_boxName);
      final String? saved = box.get(_themeKey) as String?;
      if (saved != null) {
        switch (saved) {
          case 'light':
            emit(ThemeMode.light);
            break;
          case 'dark':
            emit(ThemeMode.dark);
            break;
          default:
            emit(ThemeMode.system);
        }
      }
    } catch (_) {
      // ignore errors and keep system theme
    }
  }

  Future<void> _saveTheme(ThemeMode mode) async {
    try {
      final box = await Hive.openBox(_boxName);
      final String value = mode == ThemeMode.light
          ? 'light'
          : mode == ThemeMode.dark
              ? 'dark'
              : 'system';
      await box.put(_themeKey, value);
    } catch (_) {
      // ignore persistence errors
    }
  }

  void toggleTheme() {
    if (state == ThemeMode.light) {
      setTheme(ThemeMode.dark);
    } else if (state == ThemeMode.dark) {
      setTheme(ThemeMode.light);
    } else {
      // If system, switch to light as a sensible default
      setTheme(ThemeMode.light);
    }
  }

  void setTheme(ThemeMode mode) {
    emit(mode);
    _saveTheme(mode);
  }
}
