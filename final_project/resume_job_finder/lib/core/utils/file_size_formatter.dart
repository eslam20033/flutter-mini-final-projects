import 'dart:math';

class FileSizeFormatter {
  static String formatBytes(int bytes, [int decimals = 1]) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = (log(bytes) / log(1024)).floor();
    if (i >= suffixes.length) i = suffixes.length - 1;
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }
}
