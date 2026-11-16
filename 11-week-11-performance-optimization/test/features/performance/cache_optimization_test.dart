import 'package:flutter_test/flutter_test.dart';
import 'package:campus_notify/core/cache/cache_manager.dart';
import 'package:campus_notify/features/announcements/data/repositories/announcement_repository_impl.dart';
import 'package:campus_notify/features/announcements/domain/entities/announcement.dart';

void main() {
  group('CacheManager Unit Tests', () {
    late CacheManager<String, String> cache;

    setUp(() {
      cache = CacheManager<String, String>(
        defaultTtl: const Duration(milliseconds: 200),
      );
    });

    test('Harus menyimpan dan membaca cache yang masih valid (Cache Hit)', () {
      cache.set('key1', 'value1');

      final result = cache.get('key1');
      expect(result, 'value1');
      expect(cache.hitCount, 1);
      expect(cache.missCount, 0);
      expect(cache.hitRate, 100.0);
    });

    test(
      'Harus mengembalikan null jika data kedaluwarsa sesuai TTL (Cache Expiration)',
      () async {
        cache.set('temp_key', 'temp_val');
        expect(cache.get('temp_key'), 'temp_val');

        // Tunggu hingga melebihi TTL 200ms
        await Future.delayed(const Duration(milliseconds: 250));

        final expiredResult = cache.get('temp_key');
        expect(expiredResult, isNull);
        expect(cache.missCount, 1);
      },
    );

    test('Harus menghapus entri cache saat di-invalidate secara manual', () {
      cache.set('item', 'data');
      expect(cache.containsKey('item'), isTrue);

      cache.invalidate('item');
      expect(cache.containsKey('item'), isFalse);
      expect(cache.get('item'), isNull);
    });

    test('Harus menghitung rasio hit & miss secara presisi', () {
      cache.set('a', '1');
      cache.set('b', '2');

      cache.get('a'); // hit
      cache.get('b'); // hit
      cache.get('c'); // miss

      expect(cache.hitCount, 2);
      expect(cache.missCount, 1);
      expect(cache.totalRequests, 3);
      expect(cache.hitRate, closeTo(66.66, 0.1));
    });
  });

  group('AnnouncementRepository Caching Integration Tests', () {
    test(
      'Pemanggilan kedua fetchAnnouncements harus dilayani dari cache tanpa delay',
      () async {
        final customCache = CacheManager<String, List<Announcement>>();
        final repository = AnnouncementRepositoryImpl(cacheManager: customCache);

        final stopwatch = Stopwatch()..start();

        // Panggilan Pertama: Cache Miss (harus menunggu simulasi delay ~600ms)
        final firstResult = await repository.fetchAnnouncements();
        final firstDuration = stopwatch.elapsedMilliseconds;
        expect(firstResult.announcements.isNotEmpty, isTrue);
        expect(firstDuration, greaterThanOrEqualTo(500));
        expect(customCache.hitCount, 0);

        // Panggilan Kedua: Cache Hit (instan, < 50ms)
        stopwatch.reset();
        final secondResult = await repository.fetchAnnouncements();
        final secondDuration = stopwatch.elapsedMilliseconds;

        expect(secondResult.announcements.length, firstResult.announcements.length);
        expect(secondDuration, lessThan(100)); // Latensi mendekati 0ms
        expect(customCache.hitCount, 1);
        expect(customCache.hitRate, 100.0);
      },
    );

    test('forceRefresh: true harus menginvalidasi cache dan mengambil data segar', () async {
      final customCache = CacheManager<String, List<Announcement>>();
      final repository = AnnouncementRepositoryImpl(cacheManager: customCache);

      // Isi cache awal
      await repository.fetchAnnouncements();
      expect(customCache.containsKey('all_announcements'), isTrue);

      // Force refresh
      final refreshResult = await repository.fetchAnnouncements(forceRefresh: true);
      expect(refreshResult.announcements.isNotEmpty, isTrue);
      expect(customCache.containsKey('all_announcements'), isTrue);
    });
  });
}

