
extension ExtendedIterable<E> on Iterable<E> {
  Iterable<T> indexedMap<T>(T Function(E e, int i) f) {
    int i = 0;
    return map((e) => f(e, i++));
  }

  void forEachIndex(void Function(E e, int i) f) {
    int i = 0;
    forEach((e) => f(e, i++));
  }
}

extension StringExtension on String {
  String capitalize() => "${this[0].toUpperCase()}${substring(1)}";

  String capitalizeFirstofEach() => split(" ").map((str) => str.capitalize()).join(" ");

  String removeTrailingZero() {
    if (!contains('.')) return this;

    // String trimmed = this.replaceAll(RegExp(r'0*$'), '');
    String trimmed = replaceAll(RegExp(r'00+$'), '');
    if (trimmed.endsWith('.')) trimmed = trimmed.substring(0, trimmed.length - 1);

    return trimmed;
  }
}

extension DurationExtension on Duration{
  String formatDuration() {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(inMinutes.abs().remainder(60));
    return "${twoDigits(inHours)}:$twoDigitMinutes";
  }
}

extension DoubleExtension on num{
  String formatAsString() => toStringAsFixed(2).removeTrailingZero();
}

String convertEnumsToCapitalizedString(dynamic _enum) => _enum.toString().toLowerCase().split(".")[1].replaceAll("_", " ").capitalizeFirstofEach();

String convertEnumsToUpperCasedString(dynamic _enum) => _enum.toString().toLowerCase().split(".")[1].replaceAll("_", " ").toUpperCase();