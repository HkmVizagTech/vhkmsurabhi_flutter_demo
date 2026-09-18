import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:surabhi/core/shared_preferences/preferences_service.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final PreferencesService _preferencesService;

  ThemeCubit(this._preferencesService) : super(ThemeMode.light) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final savedTheme = await _preferencesService.getThemeMode();
    if (savedTheme == 'dark') {
      emit(ThemeMode.dark);
    } else {
      // Default is always light — the DCC brand theme (navy/gold) has no
      // dark mode, so we don't follow ThemeMode.system here.
      emit(ThemeMode.light);
    }
  }

  void toggleTheme(bool isDark) async {
    final newTheme = isDark ? ThemeMode.dark : ThemeMode.light;
    await _preferencesService.saveThemeMode(newTheme.name);
    emit(newTheme);
  }
}
