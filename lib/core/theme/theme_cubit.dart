import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:surabhi/core/shared_preferences/preferences_service.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final PreferencesService _preferencesService;

  ThemeCubit(this._preferencesService) : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final savedTheme = await _preferencesService.getThemeMode();
    if (savedTheme == 'light') {
      emit(ThemeMode.light);
    } else if (savedTheme == 'dark') {
      emit(ThemeMode.dark);
    } else {
      emit(ThemeMode.system);
    }
  }

  void toggleTheme(bool isDark) async {
    final newTheme = isDark ? ThemeMode.dark : ThemeMode.light;
    await _preferencesService.saveThemeMode(newTheme.name);
    emit(newTheme);
  }

  void setSystemTheme() async {
    await _preferencesService.saveThemeMode(ThemeMode.system.name);
    emit(ThemeMode.system);
  }
}
