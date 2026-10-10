import 'package:flutter_test/flutter_test.dart';

String routeFromMessage(Map<String, String> data) {
  final route = data['route'] ?? '/';
  return route.startsWith('/') ? route : '/$route';
}

class FakeTokenStore {
  String? access;
  String? refresh;
  void clear() { access = null; refresh = null; }
}

void main() {
  group('Pengujian Unit Test Modul 6', () {
    test('routeFromMessage harus menangani rute kosong', () {
      expect(routeFromMessage({}), '/');
      expect(routeFromMessage({'route': 'pengumuman/3'}), '/pengumuman/3');
    });

    test('Logika deteksi token kosong wajib memaksa login', () {
      final store = FakeTokenStore()..refresh = '';
      final needsLogin = (store.refresh ?? '').isEmpty;
      expect(needsLogin, isTrue);
    });
  });
}
