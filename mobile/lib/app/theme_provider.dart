import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_mobile/features/auth/providers/auth_provider.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeModeNotifier(prefs);
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final SharedPreferences _prefs;
  static const _key = 't_ask_theme_mode';

  ThemeModeNotifier(this._prefs) : super(_loadInitial(_prefs));

  static ThemeMode _loadInitial(SharedPreferences prefs) {
    final val = prefs.getString(_key);
    if (val == 'dark') return ThemeMode.dark;
    if (val == 'system') return ThemeMode.system;
    // Default to Light Mode on fresh install / first app launch
    return ThemeMode.light;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final str = mode == ThemeMode.light
        ? 'light'
        : (mode == ThemeMode.dark ? 'dark' : 'system');
    await _prefs.setString(_key, str);
  }
}
