import 'package:dio/dio.dart';
import 'order_dto.dart';

class OrdersApi {
  final Dio _dio;
  OrdersApi(this._dio);

  Future<OrderDto> createOrder(Map<String, dynamic> body) async {
    final res = await _dio.post('/orders', data: body);
    return OrderDto.fromJson(Map<String, dynamic>.from(res.data));
  }

  Future<OrderDto> updateOrder(String id, Map<String, dynamic> body) async {
    final res = await _dio.put('/orders/$id', data: body);
    return OrderDto.fromJson(Map<String, dynamic>.from(res.data));
  }

  Future<void> deleteOrder(String id) async {
    await _dio.delete('/orders/$id');
  }

  Future<List<OrderDto>> fetchOrders() async {
    final res = await _dio.get('/orders');

    final data = res.data;

    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => OrderDto.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    throw Exception('Unexpected response shape');
  }
}
