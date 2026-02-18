import 'package:order_inventory_manager/features/products/data/product_dto.dart';

import '../domain/product.dart';
import '../domain/products_repository.dart';
import 'products_api.dart';

class ProductsRepositoryApi implements ProductsRepository {
  final ProductsApi _api;

  ProductsRepositoryApi(this._api);

  @override
  Future<List<Product>> fetchProducts() async {
    final dtos = await _api.fetchProducts();
    return dtos.map((e) => e.toDomain()).toList();
  }

  @override
  Future<Product> createProduct(Product product) async {
    final dto = ProductDto(
      id: product.id,
      name: product.name,
      price: product.price,
      stock: product.stock,
      notes: product.notes,
    );

    final createdDto = await _api.createProduct(dto.toJson());
    return createdDto.toDomain();
  }

  @override
  Future<Product> updateProduct(Product product) {
    final dto = ProductDto(
      id: product.id,
      name: product.name,
      price: product.price,
      stock: product.stock,
      notes: product.notes,
    );
    return _api.updateProduct(product.id, dto.toJson()).then((value) => value.toDomain());
  }

  @override
  Future<void> deleteProduct(String id) {
    return _api.deleteProduct(id);
  }
}
