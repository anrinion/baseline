/// Abstract interface for timer operations to enable testing.
abstract class TimerService {
  /// Creates a periodic timer that invokes the callback at the specified interval.
  TimerHandle createPeriodic(Duration duration, void Function() callback);

  /// Creates a one-shot timer that invokes the callback after the specified duration.
  TimerHandle createOneShot(Duration duration, void Function() callback);
}

/// Handle to a timer that can be cancelled.
abstract class TimerHandle {
  /// Cancels the timer.
  void cancel();
}
