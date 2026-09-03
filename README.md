# YouTube Downloader Pro - Cinnamon Edition v18.0

Aplikasi desktop berbasis Windows untuk mengunduh video dan audio dari YouTube secara massal (Multi-Link) menggunakan antarmuka grafis (GUI) yang modern. Alat ini ditenagai oleh **yt-dlp** sebagai mesin pengunduh utama dan **FFmpeg** sebagai mesin pengolah/penggabung media.

Dikembangkan oleh: `jacksport_game` & `kak gem` 💚

## 🚀 Fitur Utama

- **Multi-Link & Playlist:** Unduh banyak tautan sekaligus atau satu playlist penuh secara otomatis.
- **Dua Mode Utama:** Mode **Video** (hingga resolusi 8K Ultra HD) dan Mode **Ekstrak Audio** (MP3/WAV/FLAC kualitas tinggi hingga 320 Kbps).
- **Dynamic Themes:** Mendukung Tema Gelap (*Dark*), Terang (*Light*), atau Otomatis mengikuti sistem Windows.
- **Bypass Cookie:** Mengatasi video yang terkena pembatasan usia (*age-restricted*) dengan membaca cookie dari browser favorit Anda (Chrome, Edge, Firefox, Brave).
- **Fitur Cerdas (Smart Save):** Menyimpan konfigurasi terakhir Anda secara otomatis agar tidak perlu menyetel ulang saat aplikasi dibuka kembali.
- **Multi-Threading Speed:** Mengunduh fragmen video secara paralel untuk kecepatan maksimal.
- **Fitur Tambahan:** Pembersih cache yt-dlp, riwayat unduhan (*History log*), musik latar UI (No Copyright), dan opsi otomatis mematikan PC (*Auto-Shutdown*) setelah unduhan selesai.

## 📦 Persyaratan Sistem

- **Sistem Operasi:** Windows 10 / 11
- **PowerShell:** Versi 5.1 atau yang lebih baru (Sudah bawaan Windows)
- **Koneksi Internet** (Untuk unduhan otomatis komponen `yt-dlp.exe` dan `ffmpeg.exe` pada peluncuran pertama).

## 🛠️ Cara Penggunaan

1. **Unduh Repositori Ini:** Download proyek ini dalam bentuk `.zip` lalu ekstrak ke komputer Anda, atau lakukan `git clone`.
2. **Jalankan Aplikasi:** Klik dua kali pada file peluncur utama:
   ```bash
   youtube-downloader.bat
   ```
3. **Proses Awal:** Pada peluncuran pertama, sistem akan otomatis mengunduh *core engine* (`yt-dlp.exe` dan `ffmpeg.exe`). Harap tunggu hingga status berubah menjadi `🟢 STANDBY`.
4. **Mulai Mengunduh:** Masukkan tautan YouTube, pilih folder penyimpanan, atur kualitas, lalu klik tombol **🚀 MULAI PROSES SEKARANG**.

> ⚠️ **Penting untuk Bypass Cookie:** Jika Anda mengaktifkan centang *Bypass Cookie*, pastikan browser yang Anda pilih (misal: Chrome) dalam keadaan **TERTUTUP** selama proses pengunduhan berlangsung agar file cookie tidak terkunci oleh sistem.

## 📂 Struktur File Proyek

- `youtube-downloader.bat` - Skrip batch peluncur utama (membuka CMD dan memicu PowerShell).
- `downloader.ps1` - Skrip utama PowerShell yang berisi kode GUI (XAML) dan logika unduhan.
- `cinnamon_config_pro.json` - File konfigurasi otomatis (terbentuk setelah aplikasi dijalankan).
- `cinnamon_history_pro.txt` - Catatan riwayat unduhan sukses.
