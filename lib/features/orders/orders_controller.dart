import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_inventory_manager/features/orders/data/orders_cache.dart';
import 'package:order_inventory_manager/features/orders/data/orders_providers.dart';
import 'package:order_inventory_manager/features/orders/domain/order.dart';
import 'package:order_inventory_manager/features/orders/domain/order_status.dart';
import 'package:order_inventory_manager/features/orders/domain/orders_repository.dart';

final ordersControllerProvider =
    AsyncNotifierProvider<OrdersController, List<Order>>(OrdersController.new);

class OrdersController extends AsyncNotifier<List<Order>> {
  OrdersRepository get _repo => ref.read(ordersRepositoryProvider);

  @override
  Future<List<Order>> build() async {
    final cached = await loadOrdersCache();
    if (cached != null && cached.isNotEmpty) {
      state = AsyncData(cached);
    }
    try {
      final fresh = await _repo.fetchOrders();
      await saveOrdersCache(fresh);
      return fresh;
    } catch (e) {
      if (cached != null && cached.isNotEmpty) return cached;
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final fresh = await _repo.fetchOrders();
      await saveOrdersCache(fresh);
      return fresh;
    });
  }

  Future<void> updateOrder(Order order) async {
    state = await AsyncValue.guard(() async {
      final updated = await _repo.updateOrder(order);
      final current = state.value ?? const <Order>[];
      return current.map((o) => o.id == updated.id ? updated : o).toList();
    });
  }

  Future<void> deleteOrder(String id) async {
    state = await AsyncValue.guard(() async {
      await _repo.deleteOrder(id);
      final current = state.value ?? const <Order>[];
      return current.where((o) => o.id != id).toList();
    });
  }

  Future<void> addOrder({
    required String title,
    required double total,
    String? notes,
  }) async {
    final repo = ref.read(ordersRepositoryProvider);

    final newOrder = Order(
      id: 'tmp',
      title: title,
      total: total,
      createdAt: DateTime.now(),
      status: OrderStatus.newOrder,
      notes: notes,
    );


    state = await AsyncValue.guard(() async {
      final created = await repo.createOrder(newOrder);
      final current = state.value ?? const <Order>[];
      return [created, ...current];
    });
  }
}
