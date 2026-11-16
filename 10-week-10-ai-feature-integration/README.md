# Laporan Praktikum Pemrograman Mobile
## #10 | Integrasi Fitur AI (AI Feature Integration)

* **Nama Mahasiswa:** Adi Luhung
* **NIM:** 244107020088
* **Kelas:** TI-3D

---

## 1. Fitur Utama & Integrasi Kecerdasan Buatan (AI Integration)

Pada praktikum Minggu ke-10 ini, aplikasi **Campus Notify** ditingkatkan dengan integrasi fungsionalitas kecerdasan buatan (*Artificial Intelligence*) secara terstruktur berbasis arsitektur *feature-first Clean Architecture*:

* **AI Smart Summarizer (Prompt & Ringkasan Dokumen):**
  Setiap pengumuman akademik kini dilengkapi tombol aksi *"Ringkas dengan AI"*. Fitur ini menganalisis isi pengumuman dan menghasilkan intisari ringkas, daftar *action items* konkret bagi mahasiswa, serta penilaian tingkat urgensi (*Tinggi*, *Sedang*, *Informasi*) dalam bentuk modal bottom sheet.
* **Smart Campus Q&A Assistant (Interactive AI Chat):**
  Layanan asisten akademik virtual dua arah yang dapat diakses melalui AppBar dan *Floating Action Button*. Asisten AI mampu menjawab berbagai pertanyaan spesifik mahasiswa terkait jadwal UTS di Gedung TI, beasiswa, maupun kalender perkuliahan, dilengkapi *Quick Prompts* untuk akses cepat.
* **Speech-to-Text Voice Query (Input Suara):**
  Integrasi kemampuan penangkapan masukan suara pada bilah percakapan. Mahasiswa dapat menekan tombol mikrofon untuk melakukan pendiktean pertanyaan suara yang ditranskripsikan secara instan ke dalam prompt percakapan AI.
* **Isolasi Arsitektur Andal (Clean Architecture DIP):**
  Seluruh integrasi fitur AI dibungkus dalam modul mandiri `lib/features/ai_assistant/` dengan pemisahan tegas antara layer *Domain* (Pure Dart entities, use cases, repository contracts), layer *Data* (models, remote sources, implementasi repository), dan layer *Presentation* (Riverpod Notifiers & UI widgets).

---

## 2. Struktur Modul & Alur Kerja Integrasi AI

```text
lib/
├── core/
│   └── failures.dart                     # Ekstensi kegagalan: AiServiceFailure
└── features/
    ├── ai_assistant/                     # Modul Baru: Integrasi Fitur AI
    │   ├── data/
    │   │   ├── datasources/
    │   │   │   └── ai_remote_data_source.dart
    │   │   ├── models/
    │   │   │   ├── ai_summary_model.dart
    │   │   │   └── chat_message_model.dart
    │   │   └── repositories/
    │   │       └── ai_repository_impl.dart
    │   ├── domain/
    │   │   ├── entities/
    │   │   │   ├── ai_summary.dart
    │   │   │   └── chat_message.dart
    │   │   ├── repositories/
    │   │   │   └── ai_repository.dart
    │   │   └── usecases/
    │   │       ├── ask_ai_assistant.dart
    │   │       └── summarize_announcement.dart
    │   └── presentation/
    │       ├── pages/
    │       │   └── ai_chat_page.dart
    │       ├── providers/
    │       │   └── ai_assistant_providers.dart
    │       └── widgets/
    │           └── ai_summary_modal.dart
    ├── announcements/                    # Integrasi tombol AI & FAB
    └── auth/                             # Manajemen sesi pengguna
```

---

## 3. Bukti Pengujian Mesin Hijau (Definisi Selesai)

### A. Hasil Analisis Linter Statis Lokal
Eksekusi pemeriksaan kualitas kode dengan `dart format` dan `flutter analyze`:

```text
Analyzing 10-week-10-ai-feature-integration...
No issues found! (ran in 7.3s)
```

* **Penjelasan:** Seluruh berkas baru pada direktori `lib/features/ai_assistant/` dan `test/features/ai_assistant/` berstatus hijau bersih tanpa ada galat sintaksis, peringatan linter (*unused import*, *deprecated api*), maupun pelanggaran *code style*.

### B. Hasil Uji Kelayakan Unit & Widget Testing Mandiri
Pengujian suite pengujian otomatis dijalankan melalui perintah `flutter test`:

```text
00:04 +21: All tests passed!
```

* **Penjelasan:** Sebanyak 21 skenario pengujian komprehensif berhasil lolos 100%, meliputi:
  1. `summarize_announcement_test.dart`: Pengujian use case pembuatan ringkasan AI, mitigasi kegagalan layanan, dan validasi guard clause parameter kosong.
  2. `ask_ai_assistant_test.dart`: Pengujian use case balasan percakapan, validasi prompt kosong, dan penanganan flag voice input.
  3. `ai_chat_page_test.dart`: Pengujian widget render UI, pengetikan dan pengiriman pesan, pemanfaatan quick prompt chips, dan simulasi speech-to-text.
  4. Pengujian fitur pencarian dan usecase Clean Architecture dari minggu sebelumnya tetap terverifikasi hijau (bebas dari regresi kode).

---

## 4. Hasil Validasi Sterilitas Arsitektur (Grep Rule Verification)

Sesuai kaidah arsitektur bersih, dilakukan verifikasi mandiri menggunakan pencarian string:

* **Pemeriksaan Sterilitas Layer Domain:**
  ```bash
  Get-ChildItem -Recurse lib\features\ai_assistant\domain | Select-String -Pattern "package:flutter/", "package:dio", "package:sqflite"
  ```
  *Hasil:* **NOL TEMUAN (100% STERIL)**. Layer Domain murni (*Pure Dart*) tanpa dependensi framework UI atau pustaka jaringan luar.

* **Pemeriksaan Sterilitas Layer Presentation dari Akses Database/Network Langsung:**
  ```bash
  Get-ChildItem -Recurse lib\features\ai_assistant\presentation | Select-String -Pattern "Dio\(", "openDatabase", "FlutterSecureStorage"
  ```
  *Hasil:* **NOL TEMUAN (100% STERIL)**. Komponen UI dan Notifier hanya berinteraksi melalui Use Case dan Provider.

---

## 5. Berkas Jawaban Refleksi Praktikum Minggu 10

* **Mengapa integrasi model AI perlu diisolasi di balik layer Repository dan Data Source, bukan dipanggil langsung dari widget UI?**
  *Jawaban:* Pemanggilan API AI langsung di widget UI (*fat widget*) melanggar prinsip *Single Responsibility* dan membuat aplikasi sangat rapuh terhadap perubahan eksternal. Jika penyedia layanan AI berganti (misalnya dari OpenAI ke Google Gemini atau ke model lokal on-device), seluruh kode tampilan UI harus dirombak ulang. Dengan menempatkan pemanggilan di balik interface `AiRepository` pada layer Domain dan implementasi konkret di layer Data, kita menerapkan *Dependency Inversion Principle* (DIP). UI hanya mengetahui kontrak data yang diharapkan, sementara mekanisme jaringan, parsing token, penanganan timeout, maupun pergantian model AI dapat diubah secara independen tanpa menyentuh layer antarmuka pengguna.

* **Bagaimana strategi Anda dalam menangani potensi latensi, kegagalan jaringan, dan keterbatasan kuota (rate limiting) pada fitur AI?**
  *Jawaban:* Strategi yang diterapkan mencakup tiga tingkat pertahanan:
  1. *Optimistic UI & Asynchronous Feedback:* Menampilkan state loading visual (indikator shimmer dan animasi status analisis) saat inferensi AI berjalan agar pengguna mengetahui bahwa sistem sedang bekerja.
  2. *Graceful Degradation & Failure Isolation:* Mengisolasi error ke dalam kelas `AiServiceFailure` bertipe sealed class `Failure`. Bila terjadi kegagalan jaringan atau limit kuota, aplikasi tidak mengalami *crash*, melainkan menampilkan pesan informatif ramah pengguna beserta tombol aksi *Coba Lagi*.
  3. *Intelligent Fallback Architecture:* Data source dirancang memiliki mesin pemroses heuristik lokal berbasis konteks pengumuman akademik, sehingga fungsi penting seperti ekstraksi *action items* dan jawaban seputar jadwal kampus tetap dapat beroperasi secara andal bahkan dalam kondisi offline atau saat API eksternal mengalami kendala kuota.

* **Apa perbedaan mendasar antara implementasi AI berbasis Prompt/API dengan On-Device AI (seperti OCR/Speech-to-Text lokal) dalam konteks efisiensi gawai mobile?**
  *Jawaban:* Implementasi AI berbasis API/Cloud (seperti prompting LLM cloud) menghemat ukuran berkas instalasi (*APK size*) dan tidak membebani komputasi CPU/GPU gawai, namun sangat bergantung pada koneksi internet dan memiliki risiko biaya pemakaian token serta latensi jaringan. Sebaliknya, On-Device AI (seperti Speech-to-Text dan pemrosesan offline) bekerja secara instan tanpa internet, menjamin privasi data pengguna tidak keluar dari perangkat, serta bebas dari biaya langganan cloud API. Namun, On-Device AI membutuhkan alokasi memori RAM dan ruang penyimpanan lokal yang lebih besar untuk menampung *weight* model inferensi pada gawai mobile.
