import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_inventory_manager/core/dio_client.dart';

import '../domain/orders_repository.dart';
import 'orders_api.dart';
import 'orders_repository_api.dart';

final ordersApiProvider = Provider<OrdersApi>((ref) {
  final dio = ref.watch(dioProvider);
  return OrdersApi(dio);
});

final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  final api = ref.watch(ordersApiProvider);
  return OrdersRepositoryApi(api);
});