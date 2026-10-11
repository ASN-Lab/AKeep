# 🚀 AKeep - Dokumen Rencana Pengembangan Lanjutan (Phase 2 Roadmap)

Dokumen ini berisi cetak biru (*blueprint*) teknis dan antarmuka untuk tahap pengembangan lanjutan proyek **AKeep** (Asset & Warranty Management System). Fokus fase ini adalah mengubah antarmuka menjadi berstandar industri (*Tactile Utility Design*), menyempurnakan Filament Admin Panel, dan merombak total aplikasi mobile Flutter dari *template counter app* menjadi aplikasi *offline-first* fungsional.

---

## 🎨 1. Panduan Desain & Bahasa Visual (Anti-AI / Anti-Generic Look)

Untuk menghindari tampilan generik khas template pasaran (serba gradient ungu-biru, ilustrasi kartun, atau rounded cards standar), AKeep menerapkan tema **Swiss Minimalist / Dark Tech Utility**.

### Palet Warna (Color Palette)
* **Background Utama (Dark):** `#0F1115` (Deep Charcoal)
* **Background Surface (Card/Panel):** `#181B20` (Tactile Surface)
* **Text / Primary Neutral:** `#F8F9FA` (Off-White)
* **Aksen Aksesibilitas & Status:**
  * **Electric Amber:** `#FF9F0A` (Peringatan / Garansi $< 30$ hari)
  * **Warning Lime / Cyber Green:** `#D4FF00` (Aksi Utama / Garansi Aktif)
  * **Critical Red:** `#FF453A` (Garansi Kadaluarsa / Offline Alert)
  * **Muted Gray:** `#6C757D` (Sub-teks & Border)

### Tipografi (Typography)
* **Display / Header:** `Space Grotesk` atau `Plus Jakarta Sans` (Tegas, Geometris)
* **Data / Metric / Serial Number:** `JetBrains Mono` (Monospaced untuk angka, tanggal, harga, & nomor seri agar berkesan presisi)

---

## 🌐 2. Frontend Web & Gateway Landing Page (`/`)

Mengubah halaman utama Laravel (`welcome.blade.php`) menjadi *Gateway & Product Showroom* yang fungsional.

### Structure & Component Breakdown

```text
web/resources/views/landing.blade.php
├── Header & Navigation (Logo, Live API Status Badge, Quick Links)
├── Hero Section (Value Proposition, Dual CTA: Download APK & Admin Panel)
├── Bento Grid Features Section
│   ├── Card 1: Live Asset Value Counter (Rp)
│   ├── Card 2: Warranty Countdown Demo Widget
│   └── Card 3: Offline Queue Visualizer
└── APK Release Download Banner (Direct Github Release / Internal Storage)
```

### Detail Fitur
1. **Live Server Status Indicator:** Badge dinamis menunjukkan kesehatan server (`API Status: Operational`).
2. **Bento Grid Layout:**
   * **Visualisasi Garansi:** Card interaktif yang memperlihatkan contoh perhitungan sisa masa garansi secara real-time.
   * **Statistik Cepat:** Menampilkan total kapasitas efisiensi penyimpanan nota ($< 200\text{ KB}$ per gambar).
3. **Gateway Akses Admin:** Tombol pemicu cepat langsung menuju `/admin/login`.

---

## 💻 3. Pengembangan Backend & Filament Admin Panel

Pengembangan pada backend Laravel difokuskan pada manajemen pengguna dan visualisasi laporan dashboard.

### 3.1 Penambahan `UserResource` (Filament Admin)
* **Tujuan:** Mengelola akun pengguna yang terdaftar via aplikasi Flutter (Laravel Sanctum).
* **Fitur:**
  * Tabel daftar user (Nama, Email, Tanggal Registrasi, Jumlah Aset).
  * Filter berdasarkan *Role* (Admin vs Regular User).
  * Fitur reset password & aktivasi/deaktivasi akun.

### 3.2 Custom Widget pada Dashboard Utama (`/admin`)
* **`AssetValueOverviewWidget`:** Stat card total akumulasi nilai finansial aset yang tercatat.
* **`WarrantyAlertWidget`:** Daftar aset yang masuk dalam periode kritis (garansi habis dalam $t \le 30$ hari).
* **`MaintenanceCostWidget`:** Total pengeluaran perbaikan/servis aset dalam kurun waktu berjalan.
* **`RecentAssetsTableWidget`:** Stream 5 data aset terbaru yang masuk dari API mobile.

### 3.3 Fitur Ekspor Data
* Mengaktifkan Filament Table Action `ExportAction` (Excel & CSV) untuk:
  * Laporan Rekap Aset Pribadi.
  * Laporan Riwayat & Biaya Servis (Maintenance Log).

---

## 📱 4. Refactoring Aplikasi Mobile (Flutter)

Mengganti total kode bawaan *Counter App* dengan arsitektur UI/UX berbasis **Tactile Utility**.

### 4.1 Struktur Direktori Project
```text
mobile/lib/
├── core/
│   ├── constants/       # Color, Theme, API Endpoints
│   └── utils/           # Formatters (Rupiah, Date)
├── models/              # Asset, Category, Maintenance, User models
├── services/            # ApiService, HiveService, ImageService, NotificationService
├── views/
│   ├── auth/            # LoginScreen, RegisterScreen
│   ├── home/            # HomeDashboardScreen (Summary + Filtered List)
│   ├── asset/           # AddAssetScreen, AssetDetailScreen
│   └── maintenance/     # AddMaintenanceLogScreen
└── main.dart            # Routing & Provider/State Initialization
```

### 4.2 Layar Utama & Fitur Mobile

#### A. Dashboard Utama (`HomeDashboardScreen`)
* **Header Status Sync:** Display status koneksi + jumlah antrean data lokal yang belum tersinkronisasi (*Offline Queue Badge*).
* **Financial Summary Card:** Kartu monokrom memuat Total Nilai Aset (`Rp XX.XXX.XXX`) dan Jumlah Barang Aktif.
* **Instant Filter Chips:** Filter cepat kategori (`Semua`, `Garansi Aktif`, `Perlu Servis`, `Expired`).
* **Asset List Items:**
  * Thumbnail nota/foto barang (kompresi optimal).
  * Indicator Bar sisa garansi ($G \rightarrow Y \rightarrow R$).
  * Badge visual status sinkronisasi (Ikon *Cloud Synced* vs *Pending Local*).

#### B. Form Tambah Aset (`AddAssetScreen`)
* **Live Camera/Gallery Compressor:**
  * Pratinjau gambar dengan kalkulator ukuran file *real-time* (Misal: `142 KB / Limit 200 KB`).
* **Smart Warranty Calculator:**
  * Pengguna memasukkan `Tanggal Pembelian` dan `Durasi Garansi (Bulan)`.
  * Sistem menghitung otomatis `Tanggal Kadaluarsa Garansi`.
* **Hive Offline Ingestion:** Jika perangkat tidak terhubung internet, data langsung disimpan ke antrean lokal Hive.

#### C. Detail Aset & Timeline Servis (`AssetDetailScreen`)
* **Visual Progress Bar Garansi:** Bar perjalanan masa garansi dari $T_{\text{pembelian}} \rightarrow T_{\text{sekarang}} \rightarrow T_{\text{kadaluarsa}}$.
* **Interactive Image Viewer:** Tampilan foto nota/faktur pembelian yang bisa di-*zoom*.
* **Maintenance Log Timeline:** Daftar riwayat perbaikan yang mencantumkan tanggal, tempat servis, biaya, dan deskripsi kerusakan.

---

## 🗓️ 5. Jadwal & Tahapan Eksekusi (Implementation Roadmap)

| Sprint / Tahap | Fokus Utama | Output Deliverable |
| --- | --- | --- |
| **Sprint 1** | Web Landing Page & Filament Admin | Halaman `/` siap pakai, `UserResource` aktif, & Dashboard Widgets terpasang. |
| **Sprint 2** | Flutter Auth & Home Dashboard UI | Sistem Login/Register API Sanctum, UI Dashboard utama dengan gaya *Tactile Utility*. |
| **Sprint 3** | Flutter Asset Management & Hive Engine | Form tambah aset, kompresi gambar $<200\text{ KB}$, & mesin sinkronisasi *offline-first*. |
| **Sprint 4** | Maintenance Logs, Notifications & Polish | Detail aset, timeline servis, notifikasi lokal (H-30, H-7, H-1), dan pengujian *end-to-end*. |

---

## 📌 6. Standard Operasional Pengujian (QA Checklist)

- [ ] Route web `/` tidak lagi menampilkan default Laravel welcome page.
- [ ] Admin panel `/admin` memuat widget statistik aset dan manajemen user.
- [ ] Aplikasi mobile dapat login dan menyimpan token Sanctum secara aman.
- [ ] Penambahan aset saat *Airplane Mode* aktif tersimpan di Hive dan otomatis ter-upload ketika internet kembali menyala.
- [ ] Kompresi foto tidak pernah melebihi ukuran $200\text{ KB}$.