extension StringExtensions on String {
  String get capitalized =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}

extension RuntimeFormat on int {
  String get asRuntime {
    if (this <= 0) return '';
    final hours = this ~/ 60;
    final minutes = this % 60;
    if (hours == 0) return '${minutes}m';
    return minutes == 0 ? '${hours}h' : '${hours}h ${minutes}m';
  }
}
