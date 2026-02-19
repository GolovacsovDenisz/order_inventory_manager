import 'dart:convert';

import 'package:order_inventory_manager/features/orders/domain/order.dart';
import 'package:order_inventory_manager/features/orders/domain/order_status.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _keyOrdersCache = 'orders_cache';


Future<void> saveOrdersCache(List<Order> orders) async {
  final prefs = await SharedPreferences.getInstance();
  final list = orders.map(_orderToJson).toList();
  await prefs.setString(_keyOrdersCache, jsonEncode(list));
}

Future<List<Order>?> loadOrdersCache() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_keyOrdersCache);
  if (raw == null || raw.isEmpty) return null;
  try {
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => _orderFromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  } catch (_) {
    return null;
  }
}

Map<String, dynamic> _orderToJson(Order o) => {
      'id': o.id,
      'title': o.title,
      'total': o.total,
      'createdAt': o.createdAt.toUtc().toIso8601String(),
      'status': o.status.name,
      'clientId': o.clientId,
      'notes': o.notes,
    };

Order _orderFromJson(Map<String, dynamic> json) {
  final statusStr = json['status'] as String? ?? '';
  OrderStatus status = OrderStatus.newOrder;
  for (final s in OrderStatus.values) {
    if (s.name == statusStr) {
      status = s;
      break;
    }
  }
  return Order(
    id: json['id'] as String? ?? '',
    title: json['title'] as String? ?? '',
    total: (json['total'] as num?)?.toDouble() ?? 0,
    createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    status: status,
    clientId: json['clientId'] as String?,
    notes: json['notes'] as String?,
  );
}
