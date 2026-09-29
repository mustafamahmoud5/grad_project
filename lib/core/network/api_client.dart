import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../errors/exceptions.dart';

abstract interface class ApiClient {
  /// Performs a GET request and returns the decoded JSON object.
  ///
  /// Throws [NetworkException], [TimeoutException], [ServerException] or
  /// [ParsingException].
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  });
}

class DioApiClient implements ApiClient {
  DioApiClient({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: ApiConstants.baseUrl,
              connectTimeout: ApiConstants.connectTimeout,
              receiveTimeout: ApiConstants.receiveTimeout,
              responseType: ResponseType.json,
            ),
          );

  final Dio _dio;

  @override
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get<Object?>(
        path,
        queryParameters: queryParameters,
      );
      final data = response.data;
      if (data is Map) return Map<String, dynamic>.from(data);
      throw const ParsingException();
    } on DioException catch (error) {
      throw _mapDioException(error);
    } on FormatException {
      throw const ParsingException();
    }
  }

  Exception _mapDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const TimeoutException();
      case DioExceptionType.connectionError:
        return const NetworkException();
      case DioExceptionType.badResponse:
        final status = error.response?.statusCode;
        return ServerException('Server responded with status $status.');
      case DioExceptionType.cancel:
        return const ServerException('The request was cancelled.');
      case DioExceptionType.badCertificate:
        return const ServerException('Secure connection failed.');
      case DioExceptionType.unknown:
        if (error.error is FormatException) return const ParsingException();
        return const NetworkException();
    }
  }
}
