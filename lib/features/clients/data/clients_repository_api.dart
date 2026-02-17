import '../domain/client.dart';
import '../domain/clients_repository.dart';
import 'client_dto.dart';
import 'clients_api.dart';

class ClientsRepositoryApi implements ClientsRepository {
  final ClientsApi _api;

  ClientsRepositoryApi(this._api);

  @override
  Future<List<Client>> fetchClients() async {
    final dtos = await _api.fetchClients();
    return dtos.map((e) => e.toDomain()).toList();
  }

  @override
  Future<Client> createClient(Client client) async {
    final dto = ClientDto(
      id: client.id,
      name: client.name,
      phone: client.phone,
      notes: client.notes,
      email: client.email,
    );
    final createdDto = await _api.createClient(dto.toJson());
    return createdDto.toDomain();
  }

  @override
  Future<Client> updateClient(Client client) {
    final dto = ClientDto(
      id: client.id,
      name: client.name,
      phone: client.phone,
      notes: client.notes,
      email: client.email,
    );
    return _api
        .updateClient(client.id, dto.toJson())
        .then((value) => value.toDomain());
  }

  @override
  Future<void> deleteClient(String id) {
    return _api.deleteClient(id);
  }
}
