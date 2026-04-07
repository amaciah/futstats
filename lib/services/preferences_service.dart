// services/preferences_service.dart

import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  PreferencesService._privateConstructor();
  static final PreferencesService instance = PreferencesService._privateConstructor();

  static const String _cardSizePrefix = 'card_size_';

  Future<int> getCardSize(String category) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_cardSizePrefix$category') ?? 0; // 0: small
  }

  Future<void> setCardSize(String category, int size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_cardSizePrefix$category', size);
  }

  Future<Map<String, int>> getAllCardSizes(List<String> categories) async {
    final prefs = await SharedPreferences.getInstance();
    return {
      for (final category in categories)
        category: prefs.getInt('$_cardSizePrefix$category') ?? 0,
    };
  }
}