import 'dart:convert';

import 'package:order_inventory_manager/features/clients/domain/client.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _keyClientsCache = 'clients_cache';

/// Saves the list of clients to local storage so it can be shown immediately on next open.
Future<void> saveClientsCache(List<Client> clients) async {
  final prefs = await SharedPreferences.getInstance();
  final list = clients.map(_clientToJson).toList();
  await prefs.setString(_keyClientsCache, jsonEncode(list));
}

/// Loads the last saved list of clients, or null if none or parse error.
Future<List<Client>?> loadClientsCache() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_keyClientsCache);
  if (raw == null || raw.isEmpty) return null;
  try {
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => _clientFromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  } catch (_) {
    return null;
  }
}

Map<String, dynamic> _clientToJson(Client c) => {
      'id': c.id,
      'name': c.name,
      'phone': c.phone,
      'notes': c.notes,
      'email': c.email,
    };

Client _clientFromJson(Map<String, dynamic> json) => Client(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String?,
      notes: json['notes'] as String?,
      email: json['email'] as String?,
    );
