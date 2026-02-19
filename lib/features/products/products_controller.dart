import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_inventory_manager/features/products/data/products_cache.dart';
import 'package:order_inventory_manager/features/products/data/products_providers.dart';
import 'package:order_inventory_manager/features/products/domain/product.dart';
import 'package:order_inventory_manager/features/products/domain/products_repository.dart';

final productsControllerProvider =
    AsyncNotifierProvider<ProductsController, List<Product>>(
      ProductsController.new,
    );

class ProductsController extends AsyncNotifier<List<Product>> {
  ProductsRepository get _repo => ref.read(productsRepositoryProvider);

  @override
  Future<List<Product>> build() async {
    final cached = await loadProductsCache();
    if (cached != null && cached.isNotEmpty) {
      state = AsyncData(cached);
    }
    try {
      final fresh = await _repo.fetchProducts();
      await saveProductsCache(fresh);
      return fresh;
    } catch (e) {
      if (cached != null && cached.isNotEmpty) return cached;
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final fresh = await _repo.fetchProducts();
      await saveProductsCache(fresh);
      return fresh;
    });
  }

  Future<void> updateProduct(Product product) async {
    state = await AsyncValue.guard(() async {
      final updated = await _repo.updateProduct(product);
      final current = state.value ?? const <Product>[];
      return current.map((o) => o.id == updated.id ? updated : o).toList();
    });
  }

  Future<void> deleteProduct(String id) async {
    state = await AsyncValue.guard(() async {
      await _repo.deleteProduct(id);
      final current = state.value ?? const <Product>[];
      return current.where((p) => p.id != id).toList();
    });
  }

  Future<void> addProduct({
    required String name,
    required double price,
    required int stock,
    String? notes,
  }) async {
    final repo = ref.read(productsRepositoryProvider);

    final newProduct = Product(
      id: 'tmp',
      name: name,
      price: price,
      stock: stock,
      notes: notes,
    );

    state = await AsyncValue.guard(() async {
      final created = await repo.createProduct(newProduct);
      final current = state.value ?? const <Product>[];
      return [created, ...current];
    });
  }
}
