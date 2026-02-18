import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_inventory_manager/core/dio_client.dart';

import '../domain/products_repository.dart';
import 'products_api.dart';
import 'products_repository_api.dart';

final productsApiProvider = Provider<ProductsApi>((ref) {
  final dio = ref.watch(dioProvider);
  return ProductsApi(dio);
});

final productsRepositoryProvider = Provider<ProductsRepository>((ref) {
  final api = ref.watch(productsApiProvider);
  return ProductsRepositoryApi(api);
});