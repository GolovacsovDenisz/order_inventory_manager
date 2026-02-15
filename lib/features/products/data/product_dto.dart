import '../domain/product.dart';

class ProductDto {
  final String id;
  final String name;
  final double price;
  final int stock;
  final String? notes;

  ProductDto({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    this.notes,
  });

  factory ProductDto.fromJson(Map<String, dynamic> json) {
    return ProductDto(
      id: json['id'].toString(),
      name: (json['name'] ?? '').toString(),
      price: _toDouble(json['price']),
      stock: _toInt(json['stock']),
      notes: json['notes']?.toString(),
    );
  }

  static double _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '') ?? 0.0;
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  Product toDomain() {
    return Product(
      id: id,
      name: name,
      price: price,
      stock: stock,
      notes: notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'stock': stock,
      'notes': notes,
    };
  }
}
