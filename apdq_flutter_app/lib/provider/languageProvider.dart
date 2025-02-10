import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  // Key for storing language preference
  static const String _languageKey = 'selected_language';

  // Initialize with French as default
  Locale _currentLocale = const Locale('fr');

  LanguageProvider() {
    // Load saved language preference when provider is created
    _loadSavedLanguage();
  }

  Locale get currentLocale => _currentLocale;

  // Load the saved language preference
  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString(_languageKey);
    if (savedLanguage != null) {
      _currentLocale = Locale(savedLanguage);
      notifyListeners();
    }
  }

  // Toggle between French and English
  Future<void> toggleLanguage() async {
    _currentLocale = _currentLocale.languageCode == 'fr'
        ? const Locale('en')
        : const Locale('fr');

    // Save the language preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, _currentLocale.languageCode);

    notifyListeners();
  }
}
