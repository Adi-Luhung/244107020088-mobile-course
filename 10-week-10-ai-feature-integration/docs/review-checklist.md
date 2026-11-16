# Dokumen Checklist Review Sejawat & Kesiapan Tengah Semester
**Mata Kuliah:** Pemrograman Mobile  
**Modul:** 08 - Mid-Project Review & Code Review  
**Nama Mahasiswa:** Adi Luhung  
**NIM:** 244107020088  
**Kelas:** TI-3D  

---

## 1. Simulasi Perbaikan Pesan Commit Buruk (Praktikum 1 Bagian 3)

Tabel evaluasi dan penulisan ulang pesan commit lama menjadi format *Conventional Commits* standar industri: `tipe(scope): deskripsi singkat`.

| No | Pesan Commit Lama (Buruk) | Format Konvensional Baru (Baik) | Alasan Perbaikan & Penjelasan |
|:--:|:---|:---|:---|
| 1 | `fix bug` | `fix(notes): cegah simpan judul kosong + test` | Menjelaskan secara presisi komponen mana yang diubah (`notes`), apa masalah yang diperbaiki (validasi judul kosong), serta bukti penambahan pengujian terkait. |
| 2 | `update` | `feat(auth): simpan access token ke secure storage` | Mengubah kata generik `update` menjadi aksi fungsional `feat` dengan modul `auth` serta rincian teknis implementasi penyimpanan token keamanan. |
| 3 | `final fix beneran` | `refactor(announcements): pisahkan data source dio dari repository` | Menghapus penamaan non-profesional/emosional, menggantinya dengan jenis perubahan arsitektural (`refactor`) serta batasan tanggung jawab layer Clean Architecture. |

---

## 2. Review Sejawat 15 Menit (Peer Code Review Checklist)

* **Target Pull Request:** PR #12 (`feature/notes-validation` $\rightarrow$ `develop`)
* **Branch Asal:** `feature/notes-validation`
* **Target Merge:** `develop`
* **Peran Reviewer:** Senior Flutter Reviewer / Peer Reviewer
* **Keputusan Akhir:** **Request Changes** (Sebelum diperbaiki) $\rightarrow$ **Approve** (Setelah perbaikan)

### Rincian Temuan Review Terstruktur (Sesuai Pola: Observasi $\rightarrow$ Dampak $\rightarrow$ Usulan Konkret):

#### A. Temuan Kebenaran (Null Safety, State, Error Path, Edge Case)
1. **Temuan 1 (Edge Case - Validasi Whitespace Judul):**
   * *Observasi:* Validasi hanya memeriksa string kosong `title.isEmpty`, belum menangani masukan spasi kosong `title.trim().isEmpty`.
   * *Dampak:* Pengguna tetap bisa menyimpan catatan yang isinya hanya tombol spasi ("   "), menyebabkan data tidak bermakna di penyimpanan SQLite.
   * *Usulan Konkret:* Gunakan `if (title.trim().isEmpty) throw ArgumentError('Judul catatan tidak boleh kosong');` pada use case / controller sebelum transaksi database.

2. **Temuan 2 (Error Path - Penanganan State Gagal Sinkronisasi):**
   * *Observasi:* Pada fungsi sinkronisasi offline-first, kegagalan request jaringan (`DioException` / timeout) belum mengembalikan status feedback error ke UI dan langsung menelan exception.
   * *Dampak:* Pengguna tidak mengetahui apakah data outbox gagal dikirim atau sedang dalam proses antrean.
   * *Usulan Konkret:* Tangkap error secara eksplisit dan set state `AsyncError` pada `notesProvider` agar komponen SnackBar error dapat muncul di UI.

#### B. Temuan Arsitektur (Separation of Concerns, Sterilitas Layer, Dependency Rule)
1. **Temuan 1 (Sterilitas Presentation):**
   * *Observasi:* Terdapat pembacaan langsung instance repositori lokal di dalam berkas UI widget tanpa melalui Provider / Use Case.
   * *Dampak:* Melanggar aturan Dependency Inversion dan menyulitkan widget testing karena UI terikat langsung ke database SQLite.
   * *Usulan Konkret:* Pindahkan pemanggilan ke Notifier Riverpod (`ref.read(notesProvider.notifier).addNote(...)`) dan biarkan UI hanya merespons state.

#### C. Temuan Test & Keterbacaan Kode
1. **Temuan 1 (Kelengkapan Kasus Uji):**
   * *Observasi:* Pengujian unit hanya menguji *happy path* (penyimpanan catatan berhasil). Belum ada kasus uji untuk *negative path* (validasi masukan judul kosong).
   * *Dampak:* Bila terjadi regresi kode validasi di masa depan, CI pipeline tidak akan mendeteksinya.
   * *Usulan Konkret:* Tambahkan unit test:
     ```dart
     test('harus melempar exception ketika judul kosong', () {
       expect(() => addNoteUseCase('   ', 'body'), throwsA(isA<ArgumentError>()));
     });
     ```
2. **Temuan 2 (Saran Keterbacaan / Clean Code):**
   * *Observasi:* Terdapat method build widget yang melebihi 60 baris dengan logika styling inline.
   * *Dampak:* Menurunkan keterbacaan kode (*code readability*) dan memicu rebuild widget yang tidak perlu.
   * *Usulan Konkret:* Ekstraksi sub-widget ke komponen StatelessWidget terpisah (misalnya `NoteListItemCard`).

---

## 3. Matriks Kesiapan Proyek Tengah Semester (Mid-Project Readiness)

| Komponen Evaluasi | Kondisi Saat Ini | Bukti / Catatan Verifikasi | Status |
|:---|:---|:---|:---:|
| **Struktur Feature-First** | `lib/features/announcements/` dan `lib/features/auth/` terisolasi dengan sublayer `data/`, `domain/`, `presentation/`. | Hasil grep sterilitas layer 0 kebocoran import. | **SIAP (100%)** |
| **Static Analysis** | `flutter analyze` menghasilkan nol issue (0 warnings, 0 errors). | `Analyzing 08-week-8-mid-project-review... No issues found! (ran in 43.1s)` | **SIAP (100%)** |
| **Code Formatting** | `dart format --set-exit-if-changed .` lulus bersih (exit code 0). | 14 files checked and formatted. | **SIAP (100%)** |
| **Unit Testing** | Seluruh test di direktori `test/` lulus tanpa kegagalan. | `All tests passed!` (GetAnnouncements Clean Architecture test). | **SIAP (100%)** |
| **CI Automation** | Berkas workflow GitHub Actions `.github/workflows/ci.yml` aktif. | Memverifikasi format, analyze, dan test otomatis pada setiap Pull Request. | **SIAP (100%)** |
| **Dokumentasi & PR Hygiene** | Git branch strategy `develop` $\rightarrow$ `feature/*` dan template PR diterapkan. | Format PR mencakup masalah, solusi, cara uji, dan screenshot. | **SIAP (100%)** |
