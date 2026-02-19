import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order_inventory_manager/features/clients/data/clients_cache.dart';
import 'package:order_inventory_manager/features/clients/data/clients_providers.dart';
import 'package:order_inventory_manager/features/clients/domain/client.dart';
import 'package:order_inventory_manager/features/clients/domain/clients_repository.dart';

final clientsControllerProvider =
    AsyncNotifierProvider<ClientsController, List<Client>>(
  ClientsController.new,
);

class ClientsController extends AsyncNotifier<List<Client>> {
  ClientsRepository get _repo => ref.read(clientsRepositoryProvider);

  @override
  Future<List<Client>> build() async {
    final cached = await loadClientsCache();
    if (cached != null && cached.isNotEmpty) {
      state = AsyncData(cached);
    }
    try {
      final fresh = await _repo.fetchClients();
      await saveClientsCache(fresh);
      return fresh;
    } catch (e) {
      if (cached != null && cached.isNotEmpty) return cached;
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final fresh = await _repo.fetchClients();
      await saveClientsCache(fresh);
      return fresh;
    });
  }

  Future<void> addClient({
    required String name,
    String? phone,
    String? notes,
    String? email,
  }) async {
    final repo = ref.read(clientsRepositoryProvider);
    final newClient = Client(
      id: 'tmp',
      name: name,
      phone: phone,
      notes: notes,
      email: email,
    );
    state = await AsyncValue.guard(() async {
      final created = await repo.createClient(newClient);
      final current = state.value ?? const <Client>[];
      return [created, ...current];
    });
  }

  Future<void> updateClient(Client client) async {
    state = await AsyncValue.guard(() async {
      final updated = await _repo.updateClient(client);
      final current = state.value ?? const <Client>[];
      return current.map((c) => c.id == updated.id ? updated : c).toList();
    });
  }

  Future<void> deleteClient(String id) async {
    state = await AsyncValue.guard(() async {
      await _repo.deleteClient(id);
      final current = state.value ?? const <Client>[];
      return current.where((c) => c.id != id).toList();
    });
  }
}
