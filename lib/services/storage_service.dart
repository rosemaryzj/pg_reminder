import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/project.dart';
import 'theme_service.dart';

class StorageService {
  static const String _projectsKey = 'projects';
  static const String _currentUserKey = 'current_user';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _themeModeKey = 'theme_mode';
  static const String _isDarkModeKey = 'is_dark_mode';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // 项目相关存储
  static Future<void> saveProjects(List<Project> projects) async {
    final projectsJson = projects.map((p) => p.toJson()).toList();
    await _prefs?.setString(_projectsKey, jsonEncode(projectsJson));
  }

  static List<Project> loadProjects() {
    final projectsString = _prefs?.getString(_projectsKey);
    if (projectsString == null) return [];

    try {
      final projectsJson = jsonDecode(projectsString) as List;
      return projectsJson.map((json) => Project.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // 用户登录状态
  static Future<void> setLoggedIn(bool isLoggedIn) async {
    await _prefs?.setBool(_isLoggedInKey, isLoggedIn);
  }

  static bool isLoggedIn() {
    return _prefs?.getBool(_isLoggedInKey) ?? false;
  }

  static Future<void> setCurrentUser(String username) async {
    await _prefs?.setString(_currentUserKey, username);
  }

  static String? getCurrentUser() {
    return _prefs?.getString(_currentUserKey);
  }

  static Future<void> logout() async {
    await _prefs?.setBool(_isLoggedInKey, false);
    await _prefs?.remove(_currentUserKey);
  }

  // 自定义分析数据
  static const String _customTestCoverageKey = 'custom_test_coverage';
  static const String _customBugCountKey = 'custom_bug_count';

  static Future<void> saveCustomTestCoverage(int coverage) async {
    await _prefs?.setInt(_customTestCoverageKey, coverage);
  }

  static int getCustomTestCoverage() {
    return _prefs?.getInt(_customTestCoverageKey) ?? 85;
  }

  static Future<void> saveCustomBugCount(int count) async {
    await _prefs?.setInt(_customBugCountKey, count);
  }

  static int getCustomBugCount() {
    return _prefs?.getInt(_customBugCountKey) ?? 0;
  }

  // 主题相关存储
  static Future<void> setThemeMode(AppThemeMode themeMode) async {
    await _prefs?.setString(_themeModeKey, themeMode.toString());
  }

  static AppThemeMode getThemeMode() {
    final themeModeString = _prefs?.getString(_themeModeKey);
    if (themeModeString == null) return AppThemeMode.dark;
    
    switch (themeModeString) {
      case 'AppThemeMode.light':
        return AppThemeMode.light;
      case 'AppThemeMode.dark':
        return AppThemeMode.dark;
      case 'AppThemeMode.system':
        return AppThemeMode.system;
      default:
        return AppThemeMode.dark;
    }
  }

  static Future<void> setIsDarkMode(bool isDarkMode) async {
    await _prefs?.setBool(_isDarkModeKey, isDarkMode);
  }

  static bool getIsDarkMode() {
    return _prefs?.getBool(_isDarkModeKey) ?? true;
  }

  // 清除所有数据
  static Future<void> clearAll() async {
    await _prefs?.clear();
  }

  // 清除特定项目的相关数据
  static Future<void> clearProjectData(String projectId) async {
    // 清除项目特定的自定义数据
    // 注意：由于当前的自定义数据是全局的，这里暂时保留
    // 如果将来需要项目级别的自定义数据，可以使用带项目ID的key

    // 清除项目相关的缓存数据（如果有的话）
    final projectCacheKey = 'project_cache_$projectId';
    await _prefs?.remove(projectCacheKey);

    // 清除项目相关的临时数据
    final projectTempKey = 'project_temp_$projectId';
    await _prefs?.remove(projectTempKey);
  }

  // 获取所有存储的key（用于调试）
  static Set<String> getAllKeys() {
    return _prefs?.getKeys() ?? {};
  }
}
