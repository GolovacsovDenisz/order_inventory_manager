import '../domain/order.dart';
import '../domain/order_status.dart';

class OrderDto {
  final String id;
  final String title;
  final String status;
  final dynamic total;
  final String createdAt;
  final String? clientId;
  final String? notes;

  const OrderDto({
    required this.id,
    required this.title,
    required this.status,
    required this.total,
    required this.createdAt,
    this.clientId,
    this.notes,
  });

  /// Reads from Supabase (snake_case) or camelCase for compatibility.
  factory OrderDto.fromJson(Map<String, dynamic> json) {
    return OrderDto(
      id: json['id'].toString(),
      title: (json['title'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      total: json['total'],
      createdAt: (json['created_at'] ?? json['createdAt'] ?? '').toString(),
      clientId: json['client_id']?.toString(),
      notes: json['notes']?.toString(),
    );
  }

  Order toDomain() {
    return Order(
      id: id,
      title: title,
      total: _toDouble(total),
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
      status: _mapStatus(status),
      clientId: clientId,
      notes: notes,
    );
  }

  static double _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }
 
  static OrderStatus _mapStatus(String raw) {
    final s = raw.toLowerCase();
    switch (s) {
      case 'neworder':
        return OrderStatus.newOrder;
      case 'inprogress':
        return OrderStatus.inProgress;
      case 'done':
        return OrderStatus.done;
      case 'cancelled':
        return OrderStatus.cancelled;
    }
    if (s.contains('progress')) return OrderStatus.inProgress;
    if (s.contains('done')) return OrderStatus.done;
    if (s.contains('cancel')) return OrderStatus.cancelled;
    return OrderStatus.newOrder;
  }

  /// Supabase expects snake_case columns.
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'status': status,
      'total': total,
      'created_at': createdAt,
      'client_id': clientId,
      'notes': notes,
    };
  }
}
