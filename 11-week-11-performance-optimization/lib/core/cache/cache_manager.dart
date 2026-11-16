class CacheEntry<T> {
  final T data;
  final DateTime expiresAt;

  CacheEntry({
    required this.data,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

class CacheManager<K, V> {
  final Duration defaultTtl;
  final Map<K, CacheEntry<V>> _cache = {};

  int _hitCount = 0;
  int _missCount = 0;

  CacheManager({this.defaultTtl = const Duration(minutes: 5)});

  int get hitCount => _hitCount;
  int get missCount => _missCount;
  int get totalRequests => _hitCount + _missCount;

  double get hitRate =>
      totalRequests == 0 ? 0.0 : (_hitCount / totalRequests) * 100;

  V? get(K key) {
    final entry = _cache[key];
    if (entry == null) {
      _missCount++;
      return null;
    }

    if (entry.isExpired) {
      _cache.remove(key);
      _missCount++;
      return null;
    }

    _hitCount++;
    return entry.data;
  }

  void set(K key, V value, {Duration? ttl}) {
    final effectiveTtl = ttl ?? defaultTtl;
    _cache[key] = CacheEntry(
      data: value,
      expiresAt: DateTime.now().add(effectiveTtl),
    );
  }

  bool containsKey(K key) {
    final entry = _cache[key];
    if (entry == null) return false;
    if (entry.isExpired) {
      _cache.remove(key);
      return false;
    }
    return true;
  }

  void invalidate(K key) {
    _cache.remove(key);
  }

  void clear() {
    _cache.clear();
    _hitCount = 0;
    _missCount = 0;
  }
}

