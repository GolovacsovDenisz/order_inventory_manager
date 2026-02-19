import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'package:order_inventory_manager/features/auth/data/firebase_auth_provider.dart';
import 'supabase_config.dart';

final dioProvider = Provider<Dio>((ref) {
  final getAuthToken = ref.read(getAuthTokenProvider);
  return createDioClient(getAuthToken);
});

Dio createDioClient(Future<String?> Function() getAuthToken) {
  final dio = Dio(
    BaseOptions(
      baseUrl: '${supabaseUrl}/rest/v1',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'apikey': supabaseAnonKey,
        'Prefer': 'return=representation',
      },
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await getAuthToken();
        options.headers['Authorization'] =
            'Bearer ${token ?? supabaseAnonKey}';
        return handler.next(options);
      },
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onError: (error, handler) async {
        final opts = error.requestOptions;
        final statusCode = error.response?.statusCode;
        final retryCount = opts.extra['_retryCount'] as int? ?? 0;
        const maxRetries = 2;
        final is5xx = statusCode != null && statusCode >= 500 && statusCode < 600;
        final isRetryableType = error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout ||
            error.type == DioExceptionType.sendTimeout ||
            error.type == DioExceptionType.connectionError;
        final shouldRetry =
            retryCount < maxRetries && (is5xx || isRetryableType);
        if (!shouldRetry) return handler.next(error);
        opts.extra['_retryCount'] = retryCount + 1;
        await Future.delayed(const Duration(seconds: 1));
        try {
          final response = await dio.fetch(opts);
          return handler.resolve(response);
        } catch (e) {
          return handler.next(e is DioException ? e : error);
        }
      },
    ),
  );

  dio.interceptors.add(
    PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
    ),
  );

  return dio;
}