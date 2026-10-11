# Deployment Configuration for Wasmer

## 1. Wasmer Deploy (wasmer.toml)
Buat file ini di root `backend/` untuk deploy ke Wasmer.
```toml
[package]
name = "akeep-backend"
version = "0.1.0"
description = "AKeep Laravel Backend"

[[module]]
name = "php-laravel"
source = "Dockerfile"
```

## 2. Environment Variables (Secret)
Jangan pernah commit file `.env`! Masukkan ke **Wasmer Dashboard -> Settings -> Environment Variables**:

| Variable | Value |
| :--- | :--- |
| `APP_ENV` | `production` |
| `APP_DEBUG` | `false` |
| `APP_URL` | `https://your-app-url.wasmer.app` |
| `DB_CONNECTION` | `mysql` |
| `DB_HOST` | `<wasmer-mysql-host>` |
| `DB_DATABASE` | `<wasmer-mysql-db>` |
| `DB_USERNAME` | `<wasmer-mysql-user>` |
| `DB_PASSWORD` | `<wasmer-mysql-password>` |
| `CLOUDINARY_URL` | `cloudinary://<key>:<secret>@<name>` |

## 3. Database Migration (Post-Deploy)
Setelah deploy berhasil, jalankan migration melalui console Wasmer:
```bash
php artisan migrate --force
php artisan storage:link
```
