import 'dart:async';

import 'timer_service.dart';

/// Real implementation of [TimerService] using dart:async Timer.
class RealTimerService implements TimerService {
  @override
  TimerHandle createPeriodic(Duration duration, void Function() callback) {
    final timer = Timer.periodic(duration, (_) => callback());
    return _RealTimerHandle(timer);
  }

  @override
  TimerHandle createOneShot(Duration duration, void Function() callback) {
    final timer = Timer(duration, callback);
    return _RealTimerHandle(timer);
  }
}

/// Private implementation of [TimerHandle] wrapping a dart:async Timer.
class _RealTimerHandle implements TimerHandle {
  final Timer _timer;

  _RealTimerHandle(this._timer);

  @override
  void cancel() {
    _timer.cancel();
  }
}
