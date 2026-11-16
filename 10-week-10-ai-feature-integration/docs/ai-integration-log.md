# Log Integrasi Fitur AI (AI Feature Integration Log)
**Mata Kuliah:** Pemrograman Mobile  
**Modul:** 10 - Integrasi Fitur AI (AI Feature Integration)  
**Nama Mahasiswa:** Adi Luhung  
**NIM:** 244107020088  
**Kelas:** TI-3D  

---

## 1. Analisis Kebutuhan & Desain Fitur AI pada Campus Notify

Aplikasi **Campus Notify** dirancang untuk mahasiswa JTI Polinema dalam menerima dan menelusuri pengumuman akademik. Pada minggu ke-10 ini, aplikasi ditingkatkan dengan integrasi kapabilitas kecerdasan buatan (*Artificial Intelligence*) yang mencakup:

1. **AI Smart Summarization & Key Takeaways Extraction (Prompt & Summarizer):**
   * Mahasiswa sering membaca pengumuman akademik yang panjang dan padat.
   * Fitur ini menyaring inti sari dokumen, mengekstrak batas waktu/langkah konkret (*action items*), dan mendeteksi tingkat urgensi pengumuman (*Tinggi*, *Sedang*, *Informasi*).
   * Ditempatkan langsung pada setiap kartu pengumuman melalui aksi satu-klik modal bottom sheet.

2. **AI Campus Q&A Assistant (Interactive Academic Chatbot):**
   * Memfasilitasi interaksi percakapan dua arah antara mahasiswa dengan asisten akademik virtual.
   * Asisten mampu menjawab pertanyaan seputar jadwal UTS/UAS luring di Gedung TI, prosedur pendaftaran beasiswa, revisi KRS di SIAKAD, dan workshop Flutter.
   * Dilengkapi tombol *Quick Prompts* untuk akses cepat topik yang sering ditanyakan mahasiswa.

3. **Voice Query & Speech-to-Text Input (Pengenalan Suara):**
   * Memberikan aksesibilitas input pertanyaan melalui suara (*voice-to-text dictation*).
   * Menampilkan indikator visual saat sistem menangkap audio dan melakukan transkripsi teks ke input prompt percakapan secara otomatis.

---

## 2. Desain Prompt Engineering & Structured Output

### A. System Prompt untuk AI Smart Summarizer
```text
Peran: Asisten Eksekutif Akademik Jurusan Teknologi Informasi Polinema.
Tugas: Analisis judul dan isi pengumuman akademik, kemudian hasilkan ringkasan terstruktur.
Batasan:
1. Ringkasan maksimal 3 kalimat padat dan jelas.
2. Ekstrak minimal 2 poin tindakan konkret (action items) yang wajib dilakukan mahasiswa.
3. Tentukan tingkat urgensi: 'Tinggi' (jika ada tenggat waktu/ujian/kewajiban), 'Sedang' (info pendaftaran/kegiatan), atau 'Informasi' (edukasi umum).
Format Output: Valid JSON { "summary": String, "action_items": List<String>, "urgency_level": String }
```

### B. System Prompt untuk Campus Q&A Assistant
```text
Peran: Smart Campus Academic Assistant JTI Polinema.
Konteks: Mahasiswa D4 Teknik Informatika JTI Polinema.
Pedoman Jawaban:
1. Berikan jawaban yang ramah, solutif, dan berbasis data pengumuman akademik resmi.
2. Bila menyangkut lokasi ujian, rujuk ke Gedung TI JTI Polinema.
3. Bila menyangkut beasiswa, sebutkan batas waktu tanggal 30 dan syarat IPK minimal 3.25.
4. Bila menyangkut KRS, arahkan konsultasi ke Dosen Pembina Akademik (DPA) melalui portal SIAKAD.
```

---

## 3. Arsitektur Bersih (Clean Architecture) pada Modul AI

Integrasi fitur AI dirancang mematuhi *Dependency Inversion Principle* (DIP) dan *Separation of Concerns* (SoC):

```text
[UI: AiChatPage & AiSummaryModal] (Presentation)
       ↓ membaca state & memicu event
[aiChatProvider & summarizeAnnouncementUseCaseProvider] (Presentation/Providers)
       ↓ memanggil
[SummarizeAnnouncement & AskAiAssistant] (Domain Use Cases - Pure Dart)
       ↓ menggunakan kontrak
[AiRepository Interface] (Domain Repository Contract)
       ↑ diimplementasikan oleh
[AiRepositoryImpl] (Data Repository)
       ↓ mengeksekusi
[AiRemoteDataSourceImpl] (Data Remote Source - REST/Gemini/Simulation Engine)
```

### Keunggulan Desain:
* **Sterilitas Domain:** `ai_summary.dart`, `chat_message.dart`, dan use cases tidak mengimpor pustaka `flutter`, `dio`, atau `flutter_riverpod`.
* **Reliabilitas & Offline Resilience:** `AiRemoteDataSourceImpl` memiliki fallback heuristik cerdas sehingga pengujian unit, widget testing, dan demonstrasi offline tetap berjalan 100% mulus tanpa risiko gagal akibat token habis atau kuota API limit.
* **Testability:** Menggunakan *Fake Object* pada unit testing untuk menguji *happy path* dan *failure path* tanpa ketergantungan jaringan nyata.

---

## 4. Matriks Kasus Uji & Verifikasi Otomatis

| No | Berkas Uji | Skenario Pengujian | Hasil |
|:--:|:---|:---|:---:|
| 1 | `summarize_announcement_test.dart` | Verifikasi keberhasilan pembuatan ringkasan AI dengan parameter valid | **Passed** |
| 2 | `summarize_announcement_test.dart` | Penanganan kegagalan koneksi layanan AI dan pemetaan ke `AiServiceFailure` | **Passed** |
| 3 | `summarize_announcement_test.dart` | Guard clause penolakan ID pengumuman kosong | **Passed** |
| 4 | `summarize_announcement_test.dart` | Guard clause penolakan konten pengumuman kosong | **Passed** |
| 5 | `ask_ai_assistant_test.dart` | Verifikasi pembentukan respons chat AI beserta penanda voice input | **Passed** |
| 6 | `ask_ai_assistant_test.dart` | Validasi guard clause prompt kosong/spasi | **Passed** |
| 7 | `ai_chat_page_test.dart` | Render elemen visual AppBar, Quick Prompts chip, dan Input Bar | **Passed** |
| 8 | `ai_chat_page_test.dart` | Interaksi ketik & kirim pesan teks dengan bubble user & respons AI | **Passed** |
| 9 | `ai_chat_page_test.dart` | Interaksi klik quick prompt chip memicu pengiriman pesan otomatis | **Passed** |
| 10 | `ai_chat_page_test.dart` | Interaksi tombol mic memicu indikator perekaman suara (Speech-to-Text) | **Passed** |

