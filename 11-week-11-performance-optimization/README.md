# Laporan Praktikum Pemrograman Mobile
## #11 | Optimasi Performa (Performance Optimization)

* **Nama Mahasiswa:** Adi Luhung
* **NIM:** 244107020088
* **Kelas:** TI-3D

---

## 1. Fitur Utama & Optimasi Performa (Performance Optimization)

Pada praktikum Minggu ke-11 ini, aplikasi **Campus Notify** ditingkatkan dengan serangkaian strategi optimasi performa terstruktur berbasis arsitektur *feature-first Clean Architecture*:

* **Lapisan Caching In-Memory (CacheManager):**
  Implementasi `CacheManager<K, V>` generik yang mendukung penyimpanan data dengan *Time-To-Live* (TTL) default 5 menit. Setiap pemanggilan `fetchAnnouncements()` pertama kali menyimpan hasilnya ke cache; pemanggilan berikutnya dilayani langsung dari cache tanpa menyentuh lapisan jaringan/database — menghasilkan latensi mendekati **0ms** dibanding ~600ms dari sumber asli.

* **Statistik Cache (Hit Rate & Miss Rate):**
  `CacheManager` mencatat jumlah *cache hit*, *cache miss*, dan total permintaan secara otomatis, serta menghitung `hitRate` sebagai persentase. Data ini tersedia untuk keperluan monitoring dan debugging performa.

* **Force-Refresh Melalui Pull-to-Refresh:**
  Mekanisme tarik-to-refresh (*pull-to-refresh*) pada daftar pengumuman kini memanggil `fetchAnnouncements(forceRefresh: true)` yang secara eksplisit mengosongkan entri cache dan mengambil data segar. Ini memastikan pengguna selalu dapat memaksa pembaruan data kapan pun dibutuhkan.

* **Optimasi Rendering UI dengan RepaintBoundary:**
  Widget kartu pengumuman diekstrak ke kelas `AnnouncementCardItem` yang mandiri dengan konstruktor `const` dan dibungkus `RepaintBoundary`. Ini mengisolasi *render canvas* setiap item sehingga perubahan pada satu item tidak memicu *repaint* seluruh daftar, mengurangi *frame drops* (jank) secara signifikan.

* **Penonaktifan addRepaintBoundaries Otomatis pada ListView:**
  `ListView.builder` dikonfigurasi dengan `addRepaintBoundaries: false` karena setiap `AnnouncementCardItem` sudah membawa `RepaintBoundary`-nya sendiri — menghindari *double-wrapping* yang memboroskan memori.

* **Pencarian Asinkron Berbasis Isolate:**
  Use case `SearchAnnouncements` dilengkapi metode `executeInIsolate()` yang menjalankan logika filter berat di dalam *Dart isolate* terpisah via `Isolate.run`, sehingga thread UI utama tetap responsif selama pencarian berlangsung pada dataset besar.

---

## 2. Struktur Modul & Alur Kerja Optimasi Performa

```text
lib/
├── core/
│   ├── cache/
│   │   └── cache_manager.dart           # CacheManager generik dengan TTL & hit/miss stats
│   ├── utils/
│   │   └── performance_tracker.dart     # Helper PerformanceTracker (pencatatan durasi)
│   └── failures.dart
└── features/
    └── announcements/
        ├── data/
        │   └── repositories/
        │       └── announcement_repository_impl.dart   # Repo + integrasi CacheManager
        ├── domain/
        │   ├── repositories/
        │   │   └── announcement_repository.dart        # Kontrak forceRefresh
        │   └── usecases/
        │       ├── get_announcements.dart               # Mendukung forceRefresh
        │       └── search_announcements.dart            # + executeInIsolate()
        └── presentation/
            ├── widgets/
            │   └── announcement_card_item.dart          # Widget terisolasi + RepaintBoundary
            └── announcements_page.dart                  # Pull-to-refresh → forceRefresh

test/
└── features/
    └── performance/
        └── cache_optimization_test.dart  # Unit & integration test caching
```

---

## 3. Bukti Pengujian Mesin Hijau (Definisi Selesai)

### A. Hasil Analisis Linter Statis Lokal
Eksekusi pemeriksaan kualitas kode dengan `dart format` dan `flutter analyze`:

```text
Analyzing 11-week-11-performance-optimization...
No issues found! (ran in 6.8s)
```

* **Penjelasan:** Seluruh berkas baru pada direktori `lib/core/cache/`, `lib/core/utils/`, dan `test/features/performance/` berstatus hijau bersih tanpa galat sintaksis, peringatan linter (*unused import*, *deprecated api*), maupun pelanggaran *code style*.

### B. Hasil Uji Kelayakan Unit & Integration Testing Mandiri
Pengujian *suite* otomatis dijalankan melalui perintah `flutter test`:

```text
00:04 +26: All tests passed!
```

* **Penjelasan:** Seluruh skenario pengujian komprehensif berhasil lolos 100%, meliputi:
  1. `cache_optimization_test.dart` *(CacheManager Unit Tests)*:
     - **Cache Hit:** menyimpan dan membaca nilai yang masih valid → `hitCount = 1`, `missCount = 0`, `hitRate = 100%`.
     - **Cache Expiration:** nilai kedaluwarsa setelah TTL 200ms → mengembalikan `null`, `missCount = 1`.
     - **Manual Invalidation:** pemanggilan `invalidate(key)` menghapus entri dari cache seketika.
     - **Hit Rate Calculation:** rasio hit/miss dihitung secara presisi (2 hit, 1 miss → 66.67%).
  2. `cache_optimization_test.dart` *(Integration Tests — Repository)*:
     - **Cache Miss → Slow Path:** pemanggilan pertama memakan ≥500ms (simulasi delay jaringan).
     - **Cache Hit → Fast Path:** pemanggilan kedua selesai dalam <100ms tanpa menyentuh data source.
     - **forceRefresh: true:** menginvalidasi cache dan mengambil data segar dari sumber.
  3. Pengujian fitur pencarian, use case Clean Architecture, dan AI Assistant dari minggu sebelumnya tetap terverifikasi hijau (bebas dari regresi kode).

---

## 4. Hasil Validasi Sterilitas Arsitektur (Grep Rule Verification)

Sesuai kaidah arsitektur bersih, dilakukan verifikasi mandiri:

* **Pemeriksaan Sterilitas Layer Domain:**
  ```bash
  Get-ChildItem -Recurse lib\features\announcements\domain | Select-String -Pattern "package:flutter/", "CacheManager", "package:dio"
  ```
  *Hasil:* **NOL TEMUAN (100% STERIL)**. Layer Domain murni (*Pure Dart*) tanpa dependensi cache, framework UI, atau pustaka jaringan luar.

* **Pemeriksaan Sterilitas CacheManager dari Business Logic:**
  ```bash
  Get-ChildItem -Recurse lib\core\cache | Select-String -Pattern "package:flutter/", "Announcement", "BuildContext"
  ```
  *Hasil:* **NOL TEMUAN (100% STERIL)**. `CacheManager` bersifat generik — bebas dari dependensi domain maupun UI.

---

## 5. Berkas Jawaban Refleksi Praktikum Minggu 11

* **Mengapa teknik caching sangat krusial untuk performa aplikasi mobile, khususnya pada fitur yang menampilkan data dari jaringan?**
  *Jawaban:* Aplikasi mobile beroperasi dalam lingkungan dengan latensi jaringan yang bervariasi dan kuota data yang terbatas. Setiap pemanggilan jaringan yang tidak perlu membuang waktu pengguna (500ms–2000ms), menguras baterai akibat aktivasi radio chip, dan menghabiskan kuota data. Dengan menyimpan respons di cache in-memory dengan TTL yang tepat, pemanggilan berulang dalam satu sesi dapat dilayani dalam waktu mendekati 0ms. Ini langsung berdampak pada metrik performa nyata: *First Contentful Paint* lebih cepat saat navigasi kembali ke halaman, serta pengalaman *scroll* yang mulus karena data sudah tersedia.

* **Bagaimana `RepaintBoundary` bekerja dan mengapa penting dalam optimasi daftar panjang Flutter?**
  *Jawaban:* Flutter merender UI melalui dua fase: *build* (menyusun widget tree) dan *paint* (menggambar ke *layer tree* GPU). Secara default, setiap kali satu widget di dalam sebuah kontainer berubah, Flutter berpotensi me-*repaint* keseluruhan subtree. `RepaintBoundary` membuat sebuah *layer* GPU baru yang terisolasi — sehingga perubahan di dalam widget yang dibungkusnya hanya memicu *repaint* pada *layer*-nya sendiri, bukan pada widget saudara atau induknya. Dalam `ListView` panjang, membungkus setiap item kartu dengan `RepaintBoundary` berarti saat satu item berubah (misalnya state tombol), item-item lain di layar tidak perlu digambar ulang. Hasilnya adalah frame rendering yang lebih efisien dan berkurangnya *jank* secara nyata.

* **Apa keuntungan dan kapan waktu yang tepat menggunakan `Isolate.run()` untuk operasi komputasi di Flutter?**
  *Jawaban:* Dart berjalan dalam satu thread utama yang bertanggung jawab atas rendering UI 60fps (target 16.67ms per frame). Operasi komputasi berat — seperti parsing JSON besar, enkripsi, atau filter/sort pada dataset ribuan elemen — yang dijalankan di thread utama akan memblokir rendering dan menyebabkan *jank*. `Isolate.run()` mendelegasikan komputasi tersebut ke thread terpisah yang memiliki *heap* memori sendiri. Data dikomunikasikan melalui mekanisme *message passing* (bukan *shared memory*) yang aman dari *race condition*. Waktu yang tepat menggunakannya adalah ketika operasi diperkirakan memakan lebih dari ~1ms, bekerja pada data murni yang dapat di-*serialize* (tidak ada `BuildContext`, `ChangeNotifier`, atau objek dengan *finalizer* native), dan frekuensi pemanggilannya tidak terlalu sering (karena overhead spawning isolate itu sendiri sekitar 15–50ms).

---