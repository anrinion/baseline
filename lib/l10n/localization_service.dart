import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../state/settings.dart';

/// Service to manage app localization and language persistence
class LocalizationService extends ChangeNotifier {
  static const String _defaultLanguage = 'en';
  static const String _settingsKey = 'settings';

  late final Box<Settings> _settingsBox;
  late Locale _currentLocale;

  bool get isInitialized => _settingsBox.isOpen;

  Locale get currentLocale => _currentLocale;

  String get currentLanguageCode => _currentLocale.languageCode;

  /// Initialize the localization service
  /// Call this once in main() after Hive.initFlutter()
  Future<void> initialize(Box<Settings> settingsBox) async {
    try {
      _settingsBox = settingsBox;

      // Load saved language from Settings object or use default
      Settings? settings = _settingsBox.get(_settingsKey);
      final savedLanguage = settings?.language ?? _defaultLanguage;
      _currentLocale = Locale(savedLanguage);
    } catch (e) {
      // Fallback to default language if there's an error
      _currentLocale = Locale(_defaultLanguage);
    }
  }

  /// Change the current language
  /// Persists to Hive and notifies listeners
  Future<void> setLanguage(String languageCode) async {
    if (languageCode == _currentLocale.languageCode) {
      return; // No change needed
    }

    _currentLocale = Locale(languageCode);
    
    try {
      // Update or create the Settings object
      Settings? settings = _settingsBox.get(_settingsKey);
      if (settings == null) {
        // Create new settings object if it doesn't exist
        settings = Settings();
      }
      settings.language = languageCode;
      await _settingsBox.put(_settingsKey, settings);
    } catch (e) {
      // Continue with language change even if persistence fails
      // The UI will still reflect the change, but it won't persist
    }

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
