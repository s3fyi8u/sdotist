import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _storageKey = 'app_language';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  Locale _locale = const Locale('ar'); // Default: Arabic

  Locale get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    try {
      final saved = await _storage.read(key: _storageKey);
      if (saved != null) {
        _locale = Locale(saved);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading locale: $e');
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
    await _storage.write(key: _storageKey, value: locale.languageCode);
  }

  String get currentLanguageName {
    switch (_locale.languageCode) {
      case 'ar':
        return 'العربية';
      case 'en':
        return 'English';
      case 'tr':
        return 'Türkçe';
      default:
        return 'العربية';
    }
  }

  static const List<Locale> supportedLocales = [
    Locale('ar'),
    Locale('en'),
    Locale('tr'),
  ];

  static const Map<String, String> languageNames = {
    'ar': 'العربية',
    'en': 'English',
    'tr': 'Türkçe',
  };
}
