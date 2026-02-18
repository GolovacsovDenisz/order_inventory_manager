import 'package:dio/dio.dart';
import 'order_dto.dart';

class OrdersApi {
  final Dio _dio;
  OrdersApi(this._dio);

  Future<OrderDto> createOrder(Map<String, dynamic> body) async {
    final res = await _dio.post('/orders', data: body);
    final data = _singleRowFromResponse(res.data);
    return OrderDto.fromJson(Map<String, dynamic>.from(data));
  }

  Future<OrderDto> updateOrder(String id, Map<String, dynamic> body) async {
    final res = await _dio.patch('/orders?id=eq.$id', data: body);
    final data = _singleRowFromResponse(res.data);
    return OrderDto.fromJson(Map<String, dynamic>.from(data));
  }

  Future<void> deleteOrder(String id) async {
    await _dio.delete('/orders?id=eq.$id');
  }

  static Map<String, dynamic> _singleRowFromResponse(dynamic resData) {
    if (resData is List && resData.isNotEmpty) {
      return Map<String, dynamic>.from(resData.first as Map);
    }
    return Map<String, dynamic>.from(resData as Map);
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
