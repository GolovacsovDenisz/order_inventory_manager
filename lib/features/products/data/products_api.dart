import 'package:dio/dio.dart';
import 'product_dto.dart';

class ProductsApi {
  final Dio _dio;
  ProductsApi(this._dio);

  Future<ProductDto> createProduct(Map<String, dynamic> body) async {
    final data = Map<String, dynamic>.from(body)..remove('id');
    final res = await _dio.post('/products', data: data);
    final row = _singleRowFromResponse(res.data);
    return ProductDto.fromJson(Map<String, dynamic>.from(row));
  }

  Future<ProductDto> updateProduct(String id, Map<String, dynamic> body) async {
    final data = Map<String, dynamic>.from(body)..remove('id');
    final res = await _dio.patch('/products?id=eq.$id', data: data);
    final row = _singleRowFromResponse(res.data);
    return ProductDto.fromJson(Map<String, dynamic>.from(row));
  }

  Future<void> deleteProduct(String id) async {
    await _dio.delete('/products?id=eq.$id');
  }

  static Map<String, dynamic> _singleRowFromResponse(dynamic resData) {
    if (resData is List && resData.isNotEmpty) {
      return Map<String, dynamic>.from(resData.first as Map);
    }
    return Map<String, dynamic>.from(resData as Map);
  }

  Future<List<ProductDto>> fetchProducts() async {
    final res = await _dio.get('/products');

    final data = res.data;

    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => ProductDto.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    throw Exception('Unexpected response shape');
  }
}
