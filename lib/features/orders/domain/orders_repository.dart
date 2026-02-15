import 'order.dart';

abstract class OrdersRepository {
  Future<List<Order>> fetchOrders();

  Future<Order> createOrder(Order order);
  Future<Order> updateOrder(Order order);
  Future<void> deleteOrder(String id);
}