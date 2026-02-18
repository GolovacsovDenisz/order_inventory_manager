class Product {
  final String id;
  final String name;
  final double price;
  final int stock;
  final String? notes;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    this.notes,
  });
  Product copyWith({
    String? id,
    String? name,
    double? price,
    int? stock,
    String? notes,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      notes: notes ?? this.notes,
    );
  }
}
