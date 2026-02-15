import 'order_status.dart';

class Order {
  final String id;
  final String title;
  final double total;
  final DateTime createdAt;
  final OrderStatus status;
  final String? clientId;
  final String? notes;

  const Order({
    required this.id,
    required this.title,
    required this.total,
    required this.createdAt,
    required this.status,
    this.clientId,
    this.notes,
  });

  Order copyWith({
    String? id,
    String? title,
    double? total,
    DateTime? createdAt,
    OrderStatus? status,
    String? clientId,
    String? notes,
  }) {
    return Order(
      id: id ?? this.id,
      title: title ?? this.title,
      total: total ?? this.total,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      clientId: clientId ?? this.clientId,
      notes: notes ?? this.notes,
    );
  }
}