class BenchmarkResult {
  final String label;
  final Duration elapsed;
  final int microseconds;

  BenchmarkResult({
    required this.label,
    required this.elapsed,
  }) : microseconds = elapsed.inMicroseconds;

  double get inMilliseconds => elapsed.inMicroseconds / 1000.0;

  @override
  String toString() => '$label: ${inMilliseconds.toStringAsFixed(3)} ms';
}

class PerformanceTracker {
  static final Map<String, Stopwatch> _activeWatches = {};
  static final List<BenchmarkResult> _history = [];

  static List<BenchmarkResult> get history => List.unmodifiable(_history);

  static void start(String label) {
    _activeWatches[label] = Stopwatch()..start();
  }

  static BenchmarkResult stop(String label) {
    final watch = _activeWatches.remove(label);
    if (watch == null) {
      throw StateError('Benchmark $label belum dimulai!');
    }
    watch.stop();
    final result = BenchmarkResult(label: label, elapsed: watch.elapsed);
    _history.add(result);
    return result;
  }

  static Future<BenchmarkResult> measureAsync(
    String label,
    Future<void> Function() action,
  ) async {
    final watch = Stopwatch()..start();
    await action();
    watch.stop();
    final result = BenchmarkResult(label: label, elapsed: watch.elapsed);
    _history.add(result);
    return result;
  }

  static BenchmarkResult measureSync(
    String label,
    void Function() action,
  ) {
    final watch = Stopwatch()..start();
    action();
    watch.stop();
    final result = BenchmarkResult(label: label, elapsed: watch.elapsed);
    _history.add(result);
    return result;
  }

  static void reset() {
    _activeWatches.clear();
    _history.clear();
  }
}

