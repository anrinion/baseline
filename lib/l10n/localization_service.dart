import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Service to manage app localization and language persistence
class LocalizationService extends ChangeNotifier {
  static const String _defaultLanguage = 'en';
  static const String _hiveLanguageKey = 'language';

  late final Box<dynamic> _settingsBox;
  late Locale _currentLocale;

  bool get isInitialized => _settingsBox.isOpen;

  Locale get currentLocale => _currentLocale;

  String get currentLanguageCode => _currentLocale.languageCode;

  /// Initialize the localization service
  /// Call this once in main() after Hive.initFlutter()
  Future<void> initialize(Box<dynamic> settingsBox) async {
    _settingsBox = settingsBox;

    // Load saved language or use default
    final savedLanguage =
        _settingsBox.get(_hiveLanguageKey, defaultValue: _defaultLanguage)
            as String;
    _currentLocale = Locale(savedLanguage);
  }

  /// Change the current language
  /// Persists to Hive and notifies listeners
  Future<void> setLanguage(String languageCode) async {
    if (languageCode == _currentLocale.languageCode) {
      return; // No change needed
    }

    _currentLocale = Locale(languageCode);
    await _settingsBox.put(_hiveLanguageKey, languageCode);

    notifyListeners();
  }

  /// Get the list of supported locales
  static List<Locale> getSupportedLocales() {
    return const [
      Locale('en'), // English
      Locale('ru'), // Russian
    ];
  }

  /// Check if a language code is supported
  static bool isSupported(String languageCode) {
    return getSupportedLocales().any((l) => l.languageCode == languageCode);
  }

  /// Get a user-friendly name for a language code
  static String getLanguageName(String languageCode) {
    const names = {
      'en': 'English',
      'ru': 'Русский',
    };
    return names[languageCode] ?? languageCode;
  }
}
