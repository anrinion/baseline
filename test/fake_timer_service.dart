import 'package:baseline/services/timer_service.dart';

/// Fake implementation of [TimerService] for testing that allows manual time control.
class FakeTimerService implements TimerService {
  final List<_FakeTimer> _timers = [];
  Duration _elapsed = Duration.zero;

  @override
  TimerHandle createPeriodic(Duration duration, void Function() callback) {
    final timer = _FakeTimer(
      duration: duration,
      callback: callback,
      isPeriodic: true,
      service: this,
    );
    _timers.add(timer);
    return timer;
  }

  @override
  TimerHandle createOneShot(Duration duration, void Function() callback) {
    final timer = _FakeTimer(
      duration: duration,
      callback: callback,
      isPeriodic: false,
      service: this,
    );
    _timers.add(timer);
    return timer;
  }

  /// Advances fake time by [duration] and triggers any pending callbacks.
  void elapse(Duration duration) {
    _elapsed += duration;
    _processTimers();
  }

  /// Returns the total elapsed fake time.
  Duration get elapsed => _elapsed;

  void _removeTimer(_FakeTimer timer) {
    _timers.remove(timer);
  }

  void _processTimers() {
    // Process timers - create a copy to avoid modification during iteration
    final timersToProcess = List<_FakeTimer>.from(_timers);
    for (final timer in timersToProcess) {
      timer._checkAndFire(_elapsed);
    }
  }
}

/// Fake timer handle implementation.
class _FakeTimer implements TimerHandle {
  final Duration duration;
  final void Function() callback;
  final bool isPeriodic;
  final FakeTimerService service;
  bool _cancelled = false;
  Duration? _lastFired;

  _FakeTimer({
    required this.duration,
    required this.callback,
    required this.isPeriodic,
    required this.service,
  });

  void _checkAndFire(Duration elapsed) {
    if (_cancelled) return;

    if (isPeriodic) {
      // For periodic timers, fire every time the elapsed duration crosses a multiple
      final shouldFireCount = elapsed.inMicroseconds ~/ duration.inMicroseconds;
      final lastFiredCount = (_lastFired?.inMicroseconds ?? -1) ~/ duration.inMicroseconds;
      
      for (var i = lastFiredCount + 1; i <= shouldFireCount; i++) {
        if (!_cancelled) {
          callback();
          _lastFired = Duration(microseconds: i * duration.inMicroseconds);
        }
      }
    } else {
      // For one-shot timers, fire once when elapsed >= duration
      if (_lastFired == null && elapsed >= duration) {
        callback();
        _lastFired = elapsed;
        _cancelled = true;
        service._removeTimer(this);
      }
    }
  }

  @override
  void cancel() {
    if (!_cancelled) {
      _cancelled = true;
      service._removeTimer(this);
    }
  }
}
