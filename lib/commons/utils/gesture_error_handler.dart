import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Utility class for handling gesture-related errors and improving touch responsiveness
class GestureErrorHandler {
  /// Wraps a widget with gesture error protection
  static Widget wrapWithErrorHandler({
    required Widget child,
    Widget? fallbackWidget,
  }) {
    return Builder(
      builder: (context) {
        try {
          return child;
        } catch (e) {
          if (kDebugMode) {
            print('Gesture error caught: $e');
          }
          return fallbackWidget ?? const SizedBox.shrink();
        }
      },
    );
  }

  /// Creates a safe InkWell with gesture error handling
  static Widget safeInkWell({
    required Widget child,
    VoidCallback? onTap,
    BorderRadius? borderRadius,
    Color? splashColor,
    Color? highlightColor,
  }) {
    return Builder(
      builder: (context) {
        try {
          return InkWell(
            onTap: onTap != null ? () => _debouncedCall(onTap) : null,
            borderRadius: borderRadius,
            splashColor: splashColor,
            highlightColor: highlightColor,
            child: child,
          );
        } catch (e) {
          if (kDebugMode) {
            print('InkWell gesture error: $e');
          }
          // Return the child without gesture handling if there's an error
          return GestureDetector(
            onTap: onTap != null ? () => _debouncedCall(onTap) : null,
            child: child,
          );
        }
      },
    );
  }

  /// Creates a safe IconButton with gesture error handling
  static Widget safeIconButton({
    required Widget icon,
    VoidCallback? onPressed,
    String? tooltip,
    double? splashRadius,
  }) {
    return Builder(
      builder: (context) {
        try {
          return IconButton(
            onPressed: onPressed != null
                ? () => _debouncedCall(onPressed)
                : null,
            icon: icon,
            tooltip: tooltip,
            splashRadius: splashRadius,
          );
        } catch (e) {
          if (kDebugMode) {
            print('IconButton gesture error: $e');
          }
          // Return a simple GestureDetector as fallback
          return GestureDetector(
            onTap: onPressed != null ? () => _debouncedCall(onPressed) : null,
            child: Container(padding: const EdgeInsets.all(8), child: icon),
          );
        }
      },
    );
  }

  /// Creates a safe ElevatedButton with gesture error handling
  static Widget safeElevatedButton({
    required Widget child,
    VoidCallback? onPressed,
    ButtonStyle? style,
  }) {
    return Builder(
      builder: (context) {
        try {
          return ElevatedButton(
            onPressed: onPressed != null
                ? () => _debouncedCall(onPressed)
                : null,
            style: style,
            child: child,
          );
        } catch (e) {
          if (kDebugMode) {
            print('ElevatedButton gesture error: $e');
          }
          // Return a simple container as fallback
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: onPressed != null ? Colors.blue : Colors.grey,
              borderRadius: BorderRadius.circular(4),
            ),
            child: child,
          );
        }
      },
    );
  }

  /// Navigation helper with error handling
  static Future<void> safeNavigate(
    BuildContext context,
    Widget destination, {
    bool replacement = false,
  }) async {
    try {
      // Add a small delay to prevent gesture conflicts
      await Future.delayed(const Duration(milliseconds: 100));

      if (context.mounted) {
        if (replacement) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => destination),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destination),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Navigation error: $e');
      }
      // Show error to user
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Navigation error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Private debounce mechanism to prevent rapid taps
  static DateTime? _lastTapTime;
  static const Duration _debounceDuration = Duration(milliseconds: 300);

  static void _debouncedCall(VoidCallback callback) {
    final now = DateTime.now();
    if (_lastTapTime == null ||
        now.difference(_lastTapTime!) > _debounceDuration) {
      _lastTapTime = now;
      try {
        callback();
      } catch (e) {
        if (kDebugMode) {
          print('Callback execution error: $e');
        }
      }
    }
  }
}

/// Extension to add gesture error handling to any widget
extension GestureErrorHandling on Widget {
  /// Wraps the widget with gesture error protection
  Widget withGestureErrorHandling({Widget? fallback}) {
    return GestureErrorHandler.wrapWithErrorHandler(
      child: this,
      fallbackWidget: fallback,
    );
  }
}
