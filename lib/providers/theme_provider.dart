import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.system;
  bool _isDarkMode = false;

  // Getters
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadThemePreference();
  }

  // Load theme preference from local storage
  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeString = prefs.getString(_themeKey);

      if (themeString != null) {
        switch (themeString) {
          case 'light':
            _themeMode = ThemeMode.light;
            _isDarkMode = false;
            break;
          case 'dark':
            _themeMode = ThemeMode.dark;
            _isDarkMode = true;
            break;
          case 'system':
          default:
            _themeMode = ThemeMode.system;
            _isDarkMode = _getSystemThemeMode();
            break;
        }
      } else {
        // Default to system theme
        _themeMode = ThemeMode.system;
        _isDarkMode = _getSystemThemeMode();
      }

      notifyListeners();
    } catch (e) {
      // Fallback to system theme on error
      _themeMode = ThemeMode.system;
      _isDarkMode = _getSystemThemeMode();
      notifyListeners();
    }
  }

  // Get system theme mode
  bool _getSystemThemeMode() {
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    return brightness == Brightness.dark;
  }

  // Set theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;

    switch (mode) {
      case ThemeMode.light:
        _isDarkMode = false;
        break;
      case ThemeMode.dark:
        _isDarkMode = true;
        break;
      case ThemeMode.system:
        _isDarkMode = _getSystemThemeMode();
        break;
    }

    // Save preference to local storage
    await _saveThemePreference();

    notifyListeners();
  }

  // Toggle between light and dark mode
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.system) {
      // If system theme, switch to light
      await setThemeMode(ThemeMode.light);
    } else if (_themeMode == ThemeMode.light) {
      // If light theme, switch to dark
      await setThemeMode(ThemeMode.dark);
    } else {
      // If dark theme, switch to system
      await setThemeMode(ThemeMode.system);
    }
  }

  // Save theme preference to local storage
  Future<void> _saveThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String themeString;

      switch (_themeMode) {
        case ThemeMode.light:
          themeString = 'light';
          break;
        case ThemeMode.dark:
          themeString = 'dark';
          break;
        case ThemeMode.system:
          themeString = 'system';
          break;
      }

      await prefs.setString(_themeKey, themeString);
    } catch (e) {
      // Handle error silently
      debugPrint('Failed to save theme preference: $e');
    }
  }

  // Get theme data based on current mode
  ThemeData getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color.fromARGB(255, 8, 179, 136), // Modern indigo
        brightness: Brightness.light,
        primary: const Color.fromARGB(255, 8, 179, 136),
        secondary: const Color.fromARGB(255, 8, 179, 136),
        tertiary: const Color(0xFF06B6D4),
        surface: const Color(0xFFFAFAFA),
        background: const Color(0xFFFFFFFF),
      ),
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFF1E293B),
        titleTextStyle: TextStyle(
          color: Color(0xFF1E293B),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Colors.white,
        shadowColor: Colors.black.withOpacity(0.05),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: const Color(0xFF6366F1),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        backgroundColor: const Color(0xFFF1F5F9),
        labelStyle: const TextStyle(
          color: Color(0xFF475569),
          fontWeight: FontWeight.w500,
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: Color(0xFF1E293B),
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: Color(0xFF1E293B),
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: TextStyle(
          color: Color(0xFF1E293B),
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: Color(0xFF1E293B),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: Color(0xFF1E293B),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(color: Color(0xFF475569), fontSize: 16),
        bodyMedium: TextStyle(color: Color(0xFF64748B), fontSize: 14),
      ),
    );
  }

  ThemeData getDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6366F1),
        brightness: Brightness.dark,
        primary: const Color(0xFF818CF8),
        secondary: const Color(0xFFA78BFA),
        tertiary: const Color(0xFF22D3EE),
        surface: const Color(0xFF1E293B),
        background: const Color(0xFF0F172A),
      ),
      scaffoldBackgroundColor: const Color(0xFF0F172A),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: const Color(0xFF1E293B),
        shadowColor: Colors.black.withOpacity(0.3),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: const Color(0xFF818CF8),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: const Color(0xFF334155),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 16),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        backgroundColor: const Color(0xFF334155),
        labelStyle: const TextStyle(
          color: Color(0xFFE2E8F0),
          fontWeight: FontWeight.w500,
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(color: Color(0xFFE2E8F0), fontSize: 16),
        bodyMedium: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
      ),
    );
  }

  // Get current theme data
  ThemeData get currentTheme {
    if (_themeMode == ThemeMode.dark ||
        (_themeMode == ThemeMode.system && _isDarkMode)) {
      return getDarkTheme();
    }
    return getLightTheme();
  }

  // Check if current theme is dark
  bool get isCurrentThemeDark {
    if (_themeMode == ThemeMode.dark) return true;
    if (_themeMode == ThemeMode.light) return false;
    return _isDarkMode; // System theme
  }

  // Get theme mode string for display
  String get themeModeString {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  // Get theme mode description
  String get themeModeDescription {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Always use light theme';
      case ThemeMode.dark:
        return 'Always use dark theme';
      case ThemeMode.system:
        return 'Follow system theme';
    }
  }

  // Get theme icon
  IconData get themeIcon {
    switch (_themeMode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }
}
