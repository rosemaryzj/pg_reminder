import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'storage_service.dart';

enum AppThemeMode { system, light, dark }

class ThemeState {
  final AppThemeMode themeMode;
  final bool isDarkMode;

  ThemeState({this.themeMode = AppThemeMode.system, this.isDarkMode = false});

  ThemeState copyWith({AppThemeMode? themeMode, bool? isDarkMode}) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}

class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier() : super(ThemeState(isDarkMode: true, themeMode: AppThemeMode.dark)) {
    _loadThemeFromStorage();
  }

  void _loadThemeFromStorage() {
    final savedThemeMode = StorageService.getThemeMode();
    final savedIsDarkMode = StorageService.getIsDarkMode();
    
    state = ThemeState(
      themeMode: savedThemeMode,
      isDarkMode: savedIsDarkMode,
    );
  }

  void setThemeMode(AppThemeMode mode) {
    state = state.copyWith(themeMode: mode);
    _updateDarkMode();
    _saveThemeToStorage();
  }

  void _updateDarkMode() {
    switch (state.themeMode) {
      case AppThemeMode.system:
        // 在实际应用中，这里应该监听系统主题变化
        // 这里简化为默认深色主题
        state = state.copyWith(isDarkMode: true);
        break;
      case AppThemeMode.light:
        state = state.copyWith(isDarkMode: false);
        break;
      case AppThemeMode.dark:
        state = state.copyWith(isDarkMode: true);
        break;
    }
  }

  void _saveThemeToStorage() {
    StorageService.setThemeMode(state.themeMode);
    StorageService.setIsDarkMode(state.isDarkMode);
  }

  void toggleTheme() {
    if (state.themeMode == AppThemeMode.light) {
      setThemeMode(AppThemeMode.dark);
    } else {
      setThemeMode(AppThemeMode.light);
    }
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>(
  (ref) => ThemeNotifier(),
);
