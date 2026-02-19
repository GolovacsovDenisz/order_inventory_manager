import 'package:order_inventory_manager/features/orders/domain/order_status.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _keyFilterStatus = 'orders_filter_status';
const String _keySortField = 'orders_sort_field';
const String _keySortAscending = 'orders_sort_ascending';


class OrdersPrefsState {
  final OrderStatus? filterStatus;
  final String sortField; 
  final bool sortAscending;

  const OrdersPrefsState({
    this.filterStatus,
    this.sortField = 'date',
    this.sortAscending = true,
  });
}

/// Load last saved Orders filter and sort from disk.
Future<OrdersPrefsState> loadOrdersPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  final statusStr = prefs.getString(_keyFilterStatus);
  OrderStatus? filterStatus;
  if (statusStr != null && statusStr.isNotEmpty) {
    for (final s in OrderStatus.values) {
      if (s.name == statusStr) {
        filterStatus = s;
        break;
      }
    }
  }
  final sortField = prefs.getString(_keySortField) ?? 'date';
  final sortAscending = prefs.getBool(_keySortAscending) ?? true;
  return OrdersPrefsState(
    filterStatus: filterStatus,
    sortField: sortField,
    sortAscending: sortAscending,
  );
}


Future<void> saveOrdersPrefs({
  OrderStatus? filterStatus,
  required String sortField,
  required bool sortAscending,
}) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(
    _keyFilterStatus,
    filterStatus?.name ?? '',
  );
  await prefs.setString(_keySortField, sortField);
  await prefs.setBool(_keySortAscending, sortAscending);
}
