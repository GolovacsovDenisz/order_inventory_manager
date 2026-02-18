import 'product.dart';

abstract class ProductsRepository {
  Future<List<Product>> fetchProducts();

  Future<Product> createProduct(Product product);
  Future<Product> updateProduct(Product product);
  Future<void> deleteProduct(String id);
}