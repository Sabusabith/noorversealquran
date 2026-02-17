import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:noorversealquran/core/app_snackbar.dart';

class ApiProvider {
  late Dio dio;

  ApiProvider() {
    dio = Dio(
      BaseOptions(
        baseUrl: "https://your-base-url.com/api/",
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          debugPrint("📤 ${options.method} => ${options.path}");
          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint(
            "✅ ${response.statusCode} => ${response.requestOptions.path}",
          );
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          final errorMessage = _handleError(e);
          AppSnackbar.show(errorMessage); // 👈 show snackbar here
          return handler.next(e);
        },
      ),
    );
  }

  /// ---------------- ERROR HANDLER ----------------
  String _handleError(DioException error) {
    String message = "Unexpected error occurred.";

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      message = "Connection timeout. Please try again.";
    } else if (error.type == DioExceptionType.unknown) {
      message = "No internet connection.";
    } else if (error.type == DioExceptionType.badResponse) {
      final status = error.response?.statusCode;

      if (error.response?.data is Map<String, dynamic>) {
        final data = error.response?.data;
        if (data['message'] != null) {
          message = data['message'].toString();
        }
      }

      switch (status) {
        case 400:
          message = message == "Unexpected error occurred."
              ? "Bad request."
              : message;
          break;
        case 401:
          message = message == "Unexpected error occurred."
              ? "Unauthorized access."
              : message;
          break;
        case 404:
          message = message == "Unexpected error occurred."
              ? "Resource not found."
              : message;
          break;
        case 500:
          message = message == "Unexpected error occurred."
              ? "Internal server error."
              : message;
          break;
      }
    }

    debugPrint("❌ ERROR: $message");
    return message;
  }

  /// ---------------- HTTP METHODS ----------------
  Future<Response> get(String path, {Map<String, dynamic>? queryParams}) async {
    return await dio.get(path, queryParameters: queryParams);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return await dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) async {
    return await dio.put(path, data: data);
  }

  Future<Response> delete(
    String path, {
    Map<String, dynamic>? queryParams,
  }) async {
    return await dio.delete(path, queryParameters: queryParams);
  }
}
