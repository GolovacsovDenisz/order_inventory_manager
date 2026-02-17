import 'client.dart';

abstract class ClientsRepository {
  Future<List<Client>> fetchClients();
  Future<Client> createClient(Client client);
  Future<Client> updateClient(Client client);
  Future<void> deleteClient(String id);
}
