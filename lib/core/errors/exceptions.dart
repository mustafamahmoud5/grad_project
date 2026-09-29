class ServerException implements Exception {
  const ServerException([this.message = 'A server error occurred.']);

  final String message;

  @override
  String toString() => 'ServerException: $message';
}

class NetworkException implements Exception {
  const NetworkException([this.message = 'No internet connection.']);

  final String message;

  @override
  String toString() => 'NetworkException: $message';
}

class TimeoutException implements Exception {
  const TimeoutException([this.message = 'The request timed out.']);

  final String message;

  @override
  String toString() => 'TimeoutException: $message';
}

class ParsingException implements Exception {
  const ParsingException([this.message = 'Received an invalid response.']);

  final String message;

  @override
  String toString() => 'ParsingException: $message';
}

class CacheException implements Exception {
  const CacheException([this.message = 'A cache error occurred.']);

  final String message;

  @override
  String toString() => 'CacheException: $message';
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => 'AuthException: $message';
}
