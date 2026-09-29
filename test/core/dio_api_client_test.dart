import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grad_project/core/errors/exceptions.dart';
import 'package:grad_project/core/network/api_client.dart';

/// Returns canned responses or throws canned errors instead of using the
/// network.
class _Adapter implements HttpClientAdapter {
  _Adapter(this.respond);

  final ResponseBody Function(RequestOptions options) respond;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => respond(options);

  @override
  void close({bool force = false}) {}
}

DioApiClient _client(ResponseBody Function(RequestOptions) respond) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example.com/api/v2/'))
    ..httpClientAdapter = _Adapter(respond);
  return DioApiClient(dio: dio);
}

ResponseBody _json(Object body, [int status = 200]) => ResponseBody.fromString(
  jsonEncode(body),
  status,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);

void main() {
  test('returns the decoded JSON map and forwards query parameters', () async {
    late RequestOptions sent;
    final client = _client((options) {
      sent = options;
      return _json({'status': 'ok'});
    });

    final json = await client.get(
      'list_movies.json',
      queryParameters: {'page': 2},
    );

    expect(json, {'status': 'ok'});
    expect(
      sent.uri.toString(),
      'https://example.com/api/v2/list_movies.json?page=2',
    );
  });

  test('maps HTTP errors to ServerException', () {
    final client = _client((_) => _json({'error': 'boom'}, 500));

    expect(client.get('x'), throwsA(isA<ServerException>()));
  });

  test('maps a non-object body to ParsingException', () {
    final client = _client((_) => _json(['not', 'a', 'map']));

    expect(client.get('x'), throwsA(isA<ParsingException>()));
  });

  test('maps timeouts to TimeoutException', () {
    final client = _client(
      (options) => throw DioException.connectionTimeout(
        timeout: const Duration(seconds: 1),
        requestOptions: options,
      ),
    );

    expect(client.get('x'), throwsA(isA<TimeoutException>()));
  });

  test('maps connection errors to NetworkException', () {
    final client = _client(
      (options) => throw DioException.connectionError(
        requestOptions: options,
        reason: 'offline',
      ),
    );

    expect(client.get('x'), throwsA(isA<NetworkException>()));
  });
}
