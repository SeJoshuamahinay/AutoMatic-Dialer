import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Timestamped tracking log. Prints to logcat and appends to
/// `<app documents>/tracking.log` so a field device that "stopped sending"
/// can be inspected after the fact. The file is rotated at [_maxBytes]
/// (previous contents kept in `tracking.log.1`).
class TrackingLog {
  static const _maxBytes = 512 * 1024;
  static File? _file;
  static Future<void> _pending = Future.value();

  static void info(String tag, String message) => _write('INFO', tag, message);

  static void warn(String tag, String message) => _write('WARN', tag, message);

  static void error(String tag, String message, [Object? error, StackTrace? stack]) {
    final detail = error == null ? message : '$message | $error';
    _write('ERROR', tag, stack == null ? detail : '$detail\n$stack');
  }

  /// Path of the current log file, for sharing/inspection.
  static Future<String> path() async => (await _logFile()).path;

  static void _write(String level, String tag, String message) {
    final line = '${DateTime.now().toIso8601String()} $level [$tag] $message';
    debugPrint(line);
    // Serialise appends so lines never interleave; logging must never throw.
    _pending = _pending.then((_) => _append(line)).catchError((_) {});
  }

  static Future<void> _append(String line) async {
    final file = await _logFile();
    if (await file.exists() && await file.length() > _maxBytes) {
      await file.rename('${file.path}.1');
      _file = null;
      return _append(line);
    }
    await file.writeAsString('$line\n', mode: FileMode.append, flush: true);
  }

  static Future<File> _logFile() async {
    if (_file != null) return _file!;
    final dir = await getApplicationDocumentsDirectory();
    return _file = File(p.join(dir.path, 'tracking.log'));
  }
}
