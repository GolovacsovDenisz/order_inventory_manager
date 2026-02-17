import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_inventory_manager/core/dio_client.dart';

import '../domain/clients_repository.dart';
import 'clients_api.dart';
import 'clients_repository_api.dart';

final clientsApiProvider = Provider<ClientsApi>((ref) {
  final dio = ref.watch(dioProvider);
  return ClientsApi(dio);
});

final clientsRepositoryProvider = Provider<ClientsRepository>((ref) {
  final api = ref.watch(clientsApiProvider);
  return ClientsRepositoryApi(api);
});
