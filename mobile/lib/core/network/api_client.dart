import 'package:dio/dio.dart';
import 'package:task_mobile/core/constants/app_constants.dart';
import 'package:task_mobile/services/storage_service.dart';

class ApiClient {
  late final Dio dio;
  final StorageService storageService;

  ApiClient({required this.storageService, String? baseUrl}) {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? AppConstants.defaultApiBaseUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 90),
        sendTimeout: const Duration(seconds: 60),
        headers: {
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = storageService.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          if (options.data is! FormData) {
            options.headers['Content-Type'] = 'application/json';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          final isConnError = error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.connectionError;

          if (isConnError && error.requestOptions.extra['retried_fallback'] != true) {
            for (final fallbackBase in AppConstants.fallbackApiBaseUrls) {
              if (dio.options.baseUrl == fallbackBase) continue;
              try {
                dio.options.baseUrl = fallbackBase;
                final opts = error.requestOptions;
                opts.baseUrl = fallbackBase;
                opts.extra['retried_fallback'] = true;
                // Recreate FormData if needed since FormData streams are single-use
                if (opts.extra['raw_form_map'] is Map<String, dynamic>) {
                  opts.data = FormData.fromMap(opts.extra['raw_form_map'] as Map<String, dynamic>);
                }
                final response = await dio.fetch(opts);
                return handler.resolve(response);
              } catch (_) {
                continue;
              }
            }
          }
          return handler.next(error);
        },
      ),
    );
  }
}
