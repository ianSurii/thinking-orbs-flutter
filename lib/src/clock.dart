import 'package:flutter/foundation.dart';

/// Monotonic shared clock for all [ThinkingOrb] instances.
///
/// Ensures all orbs mounted across the app remain in exact phase with one another,
/// matching the web `performance.now()` clock semantics.
class OrbClock {
  OrbClock._();

  static final Stopwatch _stopwatch = Stopwatch()..start();
  static double? _frozenTime;

  /// Current elapsed monotonic time in seconds.
  static double get elapsedSeconds {
    if (_frozenTime != null) {
      return _frozenTime!;
    }
    return _stopwatch.elapsedMicroseconds / 1000000.0;
  }

  /// Freezes time to a specific value for testing or snapshot rendering.
  @visibleForTesting
  static void freeze([double time = 0.6]) {
    _frozenTime = time;
  }

  /// Resumes the monotonic stopwatch clock.
  @visibleForTesting
  static void unfreeze() {
    _frozenTime = null;
  }

  /// Resets the stopwatch clock back to 0.
  @visibleForTesting
  static void reset() {
    _stopwatch.reset();
    _stopwatch.start();
    _frozenTime = null;
  }
}
