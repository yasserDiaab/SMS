import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:pro/cache/CacheHelper.dart';
import 'package:pro/core/API/ApiKey.dart';

class ApiInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = CacheHelper.getData(key: ApiKey.token);

    if (token != null && token.toString().isNotEmpty) {
      // Add token as Authorization header with Bearer prefix
      options.headers['Authorization'] = 'Bearer $token';

      // Also keep the original token header for backward compatibility
      options.headers[ApiKey.token] = token.toString();

      log("DEBUG: Adding token to request: Bearer $token");
    } else {
      log("WARNING: No token found in cache");
    }

    super.onRequest(options, handler);
  }
}
