import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  final Box<bool> _settingsBox;
  static const String _darkModeKey = 'darkMode';

  ThemeCubit(this._settingsBox) : super(const ThemeState()) {
    _loadTheme();
  }

  void _loadTheme() {
    final isDark = _settingsBox.get(_darkModeKey);
    if (isDark != null) {
      emit(state.copyWith(
        themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      ));
    }
  }

  void toggleTheme() {
    final isCurrentlyDark = state.themeMode == ThemeMode.dark;
    final newMode = isCurrentlyDark ? ThemeMode.light : ThemeMode.dark;
    _settingsBox.put(_darkModeKey, newMode == ThemeMode.dark);
    emit(state.copyWith(themeMode: newMode));
  }

  void setTheme(ThemeMode mode) {
    _settingsBox.put(_darkModeKey, mode == ThemeMode.dark);
    emit(state.copyWith(themeMode: mode));
  }
}
