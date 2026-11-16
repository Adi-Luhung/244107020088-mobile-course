# Log Eksperimen & Verifikasi AI (AI-Assisted Development)
**Mata Kuliah:** Pemrograman Mobile  
**Modul:** 09 - AI-Assisted Development / Vibe Coding  
**Nama Mahasiswa:** Adi Luhung  
**NIM:** 244107020088  
**Kelas:** TI-3D  

---

## 1. Formula 5 Slot Prompting (Praktikum 1)

Berikut adalah penerapan formula 5 slot yang dirancang untuk meminta asisten AI mengusulkan fitur pencarian judul dan isi pengumuman tanpa merusak arsitektur:

```text
Peran: Senior Flutter Developer
Konteks: feature-first Clean Architecture (presentation -> domain <- data), Flutter Riverpod 3.x, SQLite + Dio.
Tugas: Tambah fitur search/filter judul & isi pengumuman akademik dengan penanganan empty state jika pencarian tidak cocok.
Batas: Jangan ubah struktur arsitektur yang ada, domain use case harus Pure Dart tanpa dependensi Flutter/Riverpod/Dio, maks 80 baris.
Output: Kode use case domain + Notifier provider + cuplikan UI TextField + 2 unit test (pencarian sukses & empty state).
```

---

## 2. Prompt Mentah dan Output Awal AI (Praktikum 2)

### A. Output Awal Usulan AI
Asisten AI menghasilkan implementasi awal sebagai berikut:

```dart
// Usulan AI: Langsung filter di dalam widget atau gunakan StateProvider
class AnnouncementsPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(announcementsStateProvider).value ?? [];
    final filtered = list.where((x) => x.title.contains(query)).toList(); // HALUSINASI LOGIKA 1
    ...
  }
}

// Usulan AI Provider (Riverpod versi lama):
final searchQueryProvider = StateProvider<String>((ref) => ''); // HALUSINASI API / KADALUARSA 2
```

---

## 3. Identifikasi Bug & Halusinasi AI (Praktikum 2 & 3)

Melalui proses verifikasi 6 langkah, ditemukan 3 halusinasi/kelemahan kritis pada usulan awal AI:

### Halusinasi 1: Logika Pencarian Case-Sensitive & Tidak Menghiraukan Body
* **Temuan:** AI menggunakan method bawaan `.contains(query)` tanpa normalisasi `.toLowerCase()` dan tanpa `.trim()`. Selain itu, pencarian hanya memeriksa field `title`.
* **Dampak:** Pencarian kata kunci `"krs"` tidak akan menemukan item berjudul `"Pengumuman KRS"`, sehingga membingungkan pengguna.
* **Bukti Uji / Test Merah:**
  ```dart
  test('Pencarian harus case-insensitive (mengabaikan huruf besar/kecil)', () {
    final resultLower = searchUseCase(announcements: dummyList, query: 'uts');
    expect(resultLower.length, 1); // GAGAL jika case-sensitive
  });
  ```

### Halusinasi 2: API Kadaluarsa (Riverpod 2 vs Riverpod 3)
* **Temuan:** AI menyarankan penggunaan `StateProvider<String>` untuk menyimpan search query.
* **Dampak:** Saat diuji dengan compiler `flutter test`, terjadi error kompilasi:
  ```text
  Error: Method not found: 'StateProvider'.
  final searchQueryProvider = StateProvider<String>((ref) => '');
  ```
  Hal ini terjadi karena proyek menggunakan `flutter_riverpod: ^3.4.3` di mana Riverpod 3 telah mempensiunkan `StateProvider` demi mendukung class `Notifier` / `NotifierProvider`.

### Halusinasi 3: Pelanggaran Separation of Concerns (Filter di Layer UI)
* **Temuan:** AI menaruh logika pemfilteran data list langsung di dalam method `build` widget UI.
* **Dampak:** Widget UI menjadi kotor (*fat widget*), sulit diuji secara terisolasi tanpa merender widget tree, dan melanggar prinsip *Clean Architecture*.

---

## 4. Siklus Debug & Refactoring (Praktikum 3)

### Alur Debugging dengan Test Merah:
1. **Reproduksi:** Memasukkan query huruf kecil `'krs'` pada data berjudul `'Pengumuman KRS'`. Hasilnya list kosong (0 item ditemukan).
2. **Isolasi Masalah:** Memisahkan algoritma filtering dari UI ke use case murni `SearchAnnouncements` di `domain/usecases/search_announcements.dart`.
3. **Test Merah:** Menulis skenario test di `test/search_announcements_test.dart` dan `test/announcements_search_page_test.dart`.
4. **Perbaikan Kecil (Refactor):**
   - Menggunakan normalisasi `.trim().toLowerCase()`.
   - Mengganti `StateProvider` menjadi `Notifier<String>` dan `NotifierProvider<SearchQueryNotifier, String>`.
   - Memastikan layer domain bebas dari import Flutter/Riverpod (Pure Dart).

### Pemisahan Layer Setelah Refactoring:
```text
[UI Widget (announcements_page.dart)]
        ↓ watch
[filteredAnnouncementsProvider & searchQueryProvider (presentation/providers)]
        ↓ memanggil
[SearchAnnouncements Use Case (domain/usecases/search_announcements.dart)]
        ↓ memfilter
[Announcement Entity List (Pure Domain Model)]
```

---

## 5. Matriks Rekomendasi AI vs Keputusan Developer

| No | Rekomendasi AI | Status | Alasan Teknis Developer |
|:--:|:---|:---:|:---|
| 1 | Menambahkan `TextField` dengan `clear_search_button` dan *empty state* informatif | **DITERIMA** | Meningkatkan kenyamanan pengguna (UX) saat hasil filter tidak ditemukan. |
| 2 | Menggunakan `StateProvider<String>` untuk search state | **DITOLAK** | Tidak kompatibel dengan Flutter Riverpod 3. Diganti dengan `Notifier<String>` yang modern dan *future-proof*. |
| 3 | Menaruh pemfilteran di dalam widget `build()` | **DITOLAK** | Melanggar Clean Architecture. Logika filter dipindahkan ke `SearchAnnouncements` (Domain Layer). |
| 4 | Case-insensitive matching + query trimming | **DITERIMA + DIREFACTOR** | Diperluas tidak hanya mencocokkan judul (`title`), namun juga mencocokkan deskripsi (`body`). |

---

## 6. Bukti Eksekusi Mesin Hijau

Semua proses pengujian verifikasi mandiri telah dijalankan dan menghasilkan status bersih:
1. **`flutter test`**:
   - `test/get_announcements_test.dart` (3 unit test arsitektur lolos)
   - `test/search_announcements_test.dart` (4 unit test use case domain lolos)
   - `test/announcements_search_page_test.dart` (3 widget test search bar & empty state lolos)
   - Total: **10/10 All tests passed!**
2. **`flutter analyze`**: **No issues found!** (0 error, 0 warning)
3. **`dart format --set-exit-if-changed .`**: **0 files changed** (Format rapi standar Dart).
