# Dokumentasi Verifikasi Rekomendasi AI (AI Review vs Keputusan Teknis)
**Mata Kuliah:** Pemrograman Mobile  
**Modul:** 08 - Mid-Project Review & AI Challenge  
**Nama Mahasiswa:** Adi Luhung  
**NIM:** 244107020088  
**Kelas:** TI-3D  

---

## 1. Prompt AI yang Diberikan (AI Prompt Challenge)

```markdown
Review PR Flutter ini sebagai senior Flutter dev.
Konteks: feature-first Clean Architecture (presentation -> domain <- data), Riverpod, GoRouter, SQLite + Dio.
Fokus: kebenaran, arsitektur, dan test. Abaikan style.
Berikan 5 temuan teratas + level (blocker/saran)
+ alasan + usulan potongan kode perbaikan.
```

---

## 2. Output Review Mentah dari Asisten AI

Berikut adalah 5 temuan teratas yang diajukan oleh AI reviewer:

1. **Temuan 1 (Level: Blocker) - Penanganan Kegagalan Jaringan & Timeout pada Remote Data Source:**
   * *Alasan:* Pada `announcement_repository_impl.dart`, pemanggilan Dio tidak dibungkus dalam blok penanganan eksepsi khusus (`DioException`). Jika koneksi timeout atau server 500, aplikasi dapat crash tanpa memberikan entitas kegagalan (`Failure`).
   * *Usulan:* Bungkus pemanggilan Dio dalam try-catch bertipe `DioException` dan kembalikan `Left(ServerFailure(e.message))`.

2. **Temuan 2 (Level: Blocker) - Validasi Parameter Masukan Entity/Model Domain:**
   * *Alasan:* Model data `AnnouncementModel.fromJson` belum memberikan penanganan *fallback* jika nilai field `id` atau `title` dari server bernilai null atau tipe tidak sesuai, berpotensi memicu `TypeError` di runtime.
   * *Usulan:* Tambahkan pengecekan null safety eksplisit atau default value: `title: json['title'] as String? ?? 'Tanpa Judul'`.

3. **Temuan 3 (Level: Saran) - Dependency Injection Use Case Langsung Mengimpor Dio:**
   * *Alasan:* AI menduga ada ketergantungan langsung pustaka Dio di layer domain atau use case, mengusulkan pemindahan client Dio ke dalam use case constructor.
   * *Usulan:* Mengimpor `package:dio/dio.dart` ke dalam berkas `get_announcements.dart` agar use case bisa mengelola HTTP request secara langsung.

4. **Temuan 4 (Level: Saran) - Penggunaan `const` Constructor pada Seluruh Widget Tree:**
   * *Alasan:* Menemukan beberapa widget `SizedBox` dan `Text` di presentation layer yang belum memiliki kata kunci `const`, sehingga widget dibuat ulang setiap build.
   * *Usulan:* Tambahkan kata kunci `const` di semua widget statis presentation.

5. **Temuan 5 (Level: Saran) - Kelengkapan Unit Test untuk Skenario Edge Case (Empty List & Failure State):**
   * *Alasan:* Berkas uji `get_announcements_test.dart` sebaiknya mencakup verifikasi saat data pengumuman yang dikembalikan server bernilai kosong (`[]`), bukan hanya data sukses berisi item dan server error.
   * *Usulan:* Tambahkan unit test baru yang menguji kondisi `Right([])` dan pastikan state UI menampilkan placeholder data kosong.

---

## 3. Matriks Keputusan: Verifikasi Rekomendasi AI vs Keputusan Teknis

Sesuai aturan evaluasi di Modul Halaman 6:
* **Minimal 2 temuan AI terbukti benar** dengan bukti konkret.
* **Minimal 1 temuan AI ditolak** dengan alasan teknis yang kuat.

| No | Temuan AI | Level | Bukti Verifikasi (Grep / Test / Analisis) | Status Keputusan | Alasan Teknis & Tindak Lanjut |
|:--:|:---|:---:|:---|:---:|:---|
| 1 | **Penanganan `DioException` pada Repository Impl** | Blocker | Ditemukan pada `announcement_repository_impl.dart` bahwa try-catch masih bersifat umum `catch (e)`. Bila terjadi error jaringan, pesan error teknis mentah bocor ke layer atas. | **DITERIMA** | *Tindak lanjut:* Spesifikasikan penangkapan `DioException` dan map ke `ServerFailure` domain agar konsisten dengan prinsip error handling Clean Architecture. |
| 2 | **Cakupan Test untuk Data Pengumuman Kosong (`Right([])`)** | Saran | Pada `test/get_announcements_test.dart`, hanya terdapat 2 test: data sukses dan data gagal. Skenario respons list kosong belum teruji. | **DITERIMA** | *Tindak lanjut:* Menambahkan kasus uji unit test untuk memastikan use case mampu menangani list kosong tanpa error. |
| 3 | **Usulan Mengimpor Dio ke Layer Domain / Use Case** | Saran | Dilakukan pengujian dengan grep: `rg "import 'package:dio" lib/features/announcements/domain/`. Hasil saat ini steril (0 temuan). | **DITOLAK (Melanggar Arsitektur)** | *Alasan Penolakan:* Usulan AI ini **fatal dan merusak Dependency Rule**. Layer Domain adalah inti bisnis murni (*Pure Dart*) dan mutlak tidak boleh bergantung pada pustaka eksternal pihak ketiga seperti Dio atau HTTP client. Logika jaringan wajib diisolasi di layer Data. |
| 4 | **Perbaikan Penambahan Keyword `const` (Nitpick Style)** | Saran | Menjalankan `flutter analyze` dan `dart format`. Linter sudah otomatis mendeteksi saran const jika aturan `prefer_const_constructors` aktif. | **DITOLAK (Tugas Mesin / Linter)** | *Alasan Penolakan:* Fokus review AI ini diminta untuk kebenaran dan arsitektur (*abaikan style*). Isu const widget adalah ranah static analysis (`flutter analyze`) dan linter otomatis, bukan topik arsitektur tingkat tinggi. |
| 5 | **Fallback Null Safety pada `AnnouncementModel`** | Blocker | Diperiksa pada `announcement_model.dart`: parsing JSON mengasumsikan kontrak API backend selalu ideal. | **DITERIMA** | *Tindak lanjut:* Ditambahkan *guard clause* dan konversi aman saat memetakan payload server ke atribut entity. |

---

## 4. Kesimpulan Evaluasi AI Reviewer

1. **Akurasi AI:** AI sangat cepat dan efektif dalam mendeteksi *edge cases* seperti penanganan error jaringan (`DioException`) dan celah *test coverage* (skenario list kosong).
2. **Kelemahan AI (Blind Spot):** AI rentan menyarankan pola yang **melanggar arsitektur Clean Architecture** (seperti menyarankan import framework/Dio ke domain usecase) jika tidak dikawal oleh pemahaman mendalam insinyur perangkat lunak.
3. **Prinsip Utama:** Keputusan akhir selalu berada di tangan software engineer. Review dari AI harus selalu diverifikasi menggunakan *static analysis*, *grep test*, dan prinsip desain sebelum diadopsi.
