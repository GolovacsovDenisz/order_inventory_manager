import 'package:order_inventory_manager/features/orders/data/order_dto.dart';
import 'package:order_inventory_manager/features/orders/domain/order_status.dart';

import '../domain/order.dart';
import '../domain/orders_repository.dart';
import 'orders_api.dart';

class OrdersRepositoryApi implements OrdersRepository {
  final OrdersApi _api;

  OrdersRepositoryApi(this._api);

  @override
  Future<List<Order>> fetchOrders() async {
    final dtos = await _api.fetchOrders();
    return dtos.map((e) => e.toDomain()).toList();
  }

  @override
  Future<Order> createOrder(Order order) async {
    final dto = OrderDto(
      id: order.id,
      title: order.title,
      status: order.status.label,
      total: order.total,
      createdAt: order.createdAt.toUtc().toIso8601String(),
      notes: order.notes,
    );

    final createdDto = await _api.createOrder(dto.toJson());
    return createdDto.toDomain();
  }

  @override
  Future<Order> updateOrder(Order order) {
    final dto = OrderDto(
      id: order.id,
      title: order.title,
      status: order.status.label,
      total: order.total,
      createdAt: order.createdAt.toUtc().toIso8601String(),
      notes: order.notes,
    );
    return _api.updateOrder(order.id, dto.toJson()).then((value) => value.toDomain());
  }

  @override
  Future<void> deleteOrder(String id) {
    return _api.deleteOrder(id);
  }
}
