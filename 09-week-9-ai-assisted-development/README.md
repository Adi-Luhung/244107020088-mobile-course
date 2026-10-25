# Laporan Praktikum Pemrograman Mobile
## #09 | AI-Assisted Development & Verifikasi Validasi Fitur Pencarian

* **Nama Mahasiswa:** Adi Luhung
* **NIM:** 244107020088
* **Kelas:** TI-3D

---

## 1. Dokumentasi Proses Alur Kerja AI (Prompt Slot & Log)
Pengembangan fitur penambahan kolom pencarian judul pengumuman ini dikerjakan secara taktis mengacu pada standarisasi formula 5 slot prompt:
* **Berkas Log Pencatatan Lengkap:** Sesi rekaman instruksi mentah, modifikasi manual, dan alasan penolakan fungsionalitas fiktif telah diarsipkan secara aman pada file internal `docs/ai-log.md`.
* **Prinsip Verifikasi Mandiri:** Seluruh draf fungsi asisten tidak langsung diimplementasikan secara mentah, melainkan melalui audit kompilasi linter lokal terlebih dahulu untuk menjamin sterilitas arsitektur Clean Architecture.

---

## 2. Bukti Pengujian Mesin Hijau Bebas Halusinasi (Definisi Selesai)

### A. Hasil Kelulusan Analisis Linter Statis Lokal
<img src="screenshots/1_linter_passed.png" width="520">
<img src="screenshots/1_linter_passed1.png" width="520">

* **Penjelasan:** Bukti eksekusi dari perintah `flutter analyze` dan `dart format --set-exit-if-changed .` di terminal komputer. Seluruh penulisan berkas fungsionalitas baru berstatus bebas galat dan bersih dari sisa import mati.

### B. Hasil Uji Kelayakan Unit Testing Mandiri
<img src="screenshots/2_unit_test_passed.png" width="520">

* **Penjelasan:** Pengujian logika pencarian pada berkas `test/search_filter_test.dart` berhasil meloloskan 3 skenario kritis (kondisi huruf besar-kecil, data kosong, dan query meleset) dengan status **All tests passed!**.

---

## 3. Berkas Jawaban Refleksi Praktikum Laporan Akhir (Halaman 8)

* **Satu halusinasi AI apa yang Anda temukan dan bagaimana membuktikannya?**
  *Jawaban:* AI sempat berasumsi secara keliru dengan menyarankan pemanggilan fungsi fiktif `.searchFuzzy()` langsung pada objek koleksi List data bawaan Dart. Saya membuktikannya dengan melihat indikasi garis merah *Unresolved Reference* di VS Code linter dan memeriksa dokumentasi resmi api di portal `pub.dev`. Halusinasi ini langsung saya refaktor kembali menjadi fungsi kombinasi `.where()`, `.contains()`, dan `.toLowerCase()`.

* **Prompt mana yang paling membantu dan apa yang Anda ubah dari saran AI tersebut?**
  *Jawaban:* Prompt bagian pembatasan (*constraints slot*) arsitektur berlapis yang paling membantu. Meskipun AI sudah membuat kerangka layer yang terpisah, saya mengubah letak penulisan fungsi eksekusi filternya. AI awalnya menaruh fungsi filter string tersebut di dalam kelas komponen Notifier presentation, namun saya pindahkan masuk ke dalam berkas *Use Case Domain murni* agar aturan logika bisnis aplikasi tetap steril dari intervensi luar.

* **Keputusan terima/tolak mana yang paling sulit bagi Anda?**
  *Jawaban:* Keputusan menolak pembuatan berkas model data pencarian khusus (*SearchQueryModel*). AI bersikeras merekomendasikan pembuatan objek entitas baru untuk sekadar membungkus data string kata kunci pencarian. Demi menjaga efisiensi jumlah berkas dari bahaya *over-engineering* pada tim skala kecil, saya menolak usulan tersebut dan memilih menyederhanakannya menggunakan objek primitif `String` bawaan melalui Riverpod `StateProvider`.
