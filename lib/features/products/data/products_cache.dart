import 'dart:convert';

import 'package:order_inventory_manager/features/products/domain/product.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _keyProductsCache = 'products_cache';

/// Saves the list of products to local storage so it can be shown immediately on next open.
Future<void> saveProductsCache(List<Product> products) async {
  final prefs = await SharedPreferences.getInstance();
  final list = products.map(_productToJson).toList();
  await prefs.setString(_keyProductsCache, jsonEncode(list));
}

/// Loads the last saved list of products, or null if none or parse error.
Future<List<Product>?> loadProductsCache() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_keyProductsCache);
  if (raw == null || raw.isEmpty) return null;
  try {
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => _productFromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  } catch (_) {
    return null;
  }
}

Map<String, dynamic> _productToJson(Product p) => {
      'id': p.id,
      'name': p.name,
      'price': p.price,
      'stock': p.stock,
      'notes': p.notes,
    };

Product _productFromJson(Map<String, dynamic> json) => Product(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      stock: json['stock'] as int? ?? 0,
      notes: json['notes'] as String?,
    );
