import 'package:shared_preferences/shared_preferences.dart';

const String _keyFavoriteProductIds = 'products_favorite_ids';

/// Loads the set of favorite product IDs.
Future<Set<String>> loadFavoriteProductIds() async {
  final prefs = await SharedPreferences.getInstance();
  final list = prefs.getStringList(_keyFavoriteProductIds);
  return list != null ? list.toSet() : {};
}

/// Saves the set of favorite product IDs.
Future<void> saveFavoriteProductIds(Set<String> ids) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setStringList(_keyFavoriteProductIds, ids.toList());
}

/// Toggles one product ID in favorites; returns the new set.
Future<Set<String>> toggleFavoriteProductId(String id) async {
  final current = await loadFavoriteProductIds();
  final next = Set<String>.from(current);
  if (next.contains(id)) {
    next.remove(id);
  } else {
    next.add(id);
  }
  await saveFavoriteProductIds(next);
  return next;
}
