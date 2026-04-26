import 'dart:async';
import 'package:flutter/foundation.dart';

/// Debouncer utility to prevent excessive function calls
/// Delays execution until user stops typing for specified duration
class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  /// Run the action after debounce delay
  /// Cancels previous timer if called again before delay expires
  void run(VoidCallback action) {
    // Cancel previous timer if exists
    _timer?.cancel();
    
    // Create new timer
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  /// Cancel any pending action
  void cancel() {
    _timer?.cancel();
  }

  /// Dispose of the debouncer
  void dispose() {
    _timer?.cancel();
  }
}
