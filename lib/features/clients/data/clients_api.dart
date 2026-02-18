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
    final data = Map<String, dynamic>.from(body)..remove('id');
    final res = await _dio.post('/clients', data: data);
    final row = _singleRowFromResponse(res.data);
    return ClientDto.fromJson(Map<String, dynamic>.from(row));
  }

  Future<ClientDto> updateClient(String id, Map<String, dynamic> body) async {
    final data = Map<String, dynamic>.from(body)..remove('id');
    final res = await _dio.patch('/clients?id=eq.$id', data: data);
    final row = _singleRowFromResponse(res.data);
    return ClientDto.fromJson(Map<String, dynamic>.from(row));
  }

  Future<void> deleteClient(String id) async {
    await _dio.delete('/clients?id=eq.$id');
  }

  static Map<String, dynamic> _singleRowFromResponse(dynamic resData) {
    if (resData is List && resData.isNotEmpty) {
      return Map<String, dynamic>.from(resData.first as Map);
    }
    return Map<String, dynamic>.from(resData as Map);
  }
}
