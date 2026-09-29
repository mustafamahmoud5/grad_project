/// Defensive JSON readers. The YTS API sometimes omits fields or returns them
/// with unexpected types, so every model goes through these helpers.
abstract final class Helpers {
  static String? nullableString(Object? value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static String string(Object? value, [String fallback = '']) =>
      nullableString(value) ?? fallback;

  static int integer(Object? value, [int fallback = 0]) => switch (value) {
    final int v => v,
    final num v => v.toInt(),
    final String v =>
      int.tryParse(v) ?? double.tryParse(v)?.toInt() ?? fallback,
    _ => fallback,
  };

  static double decimal(Object? value, [double fallback = 0]) =>
      switch (value) {
        final num v => v.toDouble(),
        final String v => double.tryParse(v) ?? fallback,
        _ => fallback,
      };

  static List<String> stringList(Object? value) => value is List
      ? value.map(nullableString).whereType<String>().toList()
      : const [];

  static Map<String, dynamic>? map(Object? value) =>
      value is Map ? Map<String, dynamic>.from(value) : null;

  static List<Map<String, dynamic>> mapList(Object? value) => value is List
      ? value.whereType<Map>().map(Map<String, dynamic>.from).toList()
      : const [];

  /// Returns a usable absolute http(s) URL or `null`.
  static String? url(Object? value) {
    final text = nullableString(value);
    if (text == null) return null;
    final uri = Uri.tryParse(text);
    if (uri == null || !uri.hasScheme || !uri.scheme.startsWith('http')) {
      return null;
    }
    return text;
  }
}
