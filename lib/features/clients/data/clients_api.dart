import 'package:dio/dio.dart';
import 'client_dto.dart';

class ClientsApi {
  final Dio _dio;
  ClientsApi(this._dio);

  Future<List<ClientDto>> fetchClients() async {
    final res = await _dio.get('/clients');
    final data = res.data;
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => ClientDto.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    throw Exception('Unexpected response shape');
  }

  Future<ClientDto> createClient(Map<String, dynamic> body) async {
    final res = await _dio.post('/clients', data: body);
    return ClientDto.fromJson(Map<String, dynamic>.from(res.data));
  }

  Future<ClientDto> updateClient(String id, Map<String, dynamic> body) async {
    final res = await _dio.put('/clients/$id', data: body);
    return ClientDto.fromJson(Map<String, dynamic>.from(res.data));
  }

  Future<void> deleteClient(String id) async {
    await _dio.delete('/clients/$id');
  }
}
