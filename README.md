# AKeep - Inventory & Asset Management System

AKeep adalah sistem manajemen aset dan inventaris modern berbasis *local-first* dengan sinkronisasi ke server cloud. Didesain untuk melacak aset pribadi/organisasi, garansi, serta histori perawatan (*maintenance logs*).

---

## 🚀 Fitur Utama
- **Aplikasi Mobile (Flutter)**:
  - Penyimpanan data lokal (*offline-first*) menggunakan Hive.
  - Antrean sinkronisasi otomatis (*sync queue*) saat koneksi internet tersedia.
  - Pengompresan gambar nota/struk secara otomatis.
  - Notifikasi pengingat masa berlaku garansi aset.
  - Pemformatan mata uang sesuai standar Indonesia (`Rp X.XXX.XXX`).
- **Backend API (Laravel 11)**:
  - Otentikasi API berbasis token (*Laravel Sanctum*).
  - RESTful API untuk CRUD aset, kategori, dan log perawatan.
  - Endpoint khusus bulk-sync (`/api/v1/sync`).
- **Dashboard Admin (Filament PHP v3)**:
  - Dashboard statistik total nilai aset, biaya perawatan, dan alert garansi.
  - Pengelolaan aset, kategori, dan user secara visual.
  - Integrasi upload media Cloudinary.

---

## 🛠️ Tech Stack

### Mobile App
- **Framework**: Flutter (Dart)
- **State Management**: Provider
- **Database Lokal**: Hive
- **HTTP Client**: Dio
- **Utilities**: `connectivity_plus`, `flutter_image_compress`, `image_picker`, `flutter_local_notifications`

### Backend & Admin
- **Framework**: Laravel 11 (PHP 8.2+)
- **Admin Panel**: Filament PHP v3
- **Authentication**: Laravel Sanctum
- **Database**: SQLite (Dev) / MySQL (Production/Wasmer)
- **Media Storage**: Cloudinary SDK

---

## 💻 Panduan Setup Development (Lokal)

### Prasyarat
- PHP >= 8.2
- Composer
- Flutter SDK (stable)
- Node.js & npm

### 1. Setup Backend (Laravel)
```bash
cd backend
composer install
cp .env.example .env
php artisan key:generate
php artisan migrate --seed
php artisan serve
```
> Server akan berjalan di `http://127.0.0.1:8000`. Dashboard admin di `http://127.0.0.1:8000/admin`.

### 2. Setup Mobile (Flutter)
```bash
cd mobile
flutter pub get
flutter run
```
> **Catatan Endpoint**: Atur IP backend di `mobile/lib/services/api_service.dart` (gunakan IP lokal `http://10.0.2.2:8000` untuk emulator Android).

---

## ☁️ Panduan Production & Deployment

### Deployment Server (Wasmer)
1. **Database Setup**: Gunakan database MySQL yang disediakan oleh Wasmer.
2. **Environment Variables**:
   Atur variabel berikut pada dashboard Wasmer:
   ```env
   APP_ENV=production
   APP_DEBUG=false
   APP_URL=https://backend-asn-lab.wasmer.app
   DB_CONNECTION=mysql
   DB_HOST=<wasmer-db-host>
   DB_PORT=3306
   DB_DATABASE=<wasmer-db-name>
   DB_USERNAME=<wasmer-db-user>
   DB_PASSWORD=<wasmer-db-password>
   CLOUDINARY_URL=cloudinary://<api_key>:<api_secret>@<cloud_name>
   ```
3. **Build & Deploy Container**: Perintah deploy di Wasmer menggunakan `Dockerfile` yang sudah tersedia di folder `backend/`.

### Publish Aplikasi Mobile (APK)
Aplikasi mobile dibuild secara otomatis menggunakan **GitHub Actions**:
1. Buat git tag baru, misalnya `v1.0.0`:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```
2. Workflow GitHub Actions (`.github/workflows/apk-release.yml`) akan otomatis membuat release di GitHub dan mengunggah file `app-release.apk`.
3. Tombol **Download APK** di landing page web akan secara otomatis mengunduh APK versi terbaru melalui link GitHub Release:
   `https://github.com/ASN-Lab/AKeep/releases/latest/download/app-release.apk`
