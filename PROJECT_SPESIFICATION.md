# Project Specification: Personal Asset, Warranty & Maintenance Tracker

## 1. Executive Summary & Objectives
**Project Name:** AKeep (Personal Asset, Warranty & Maintenance Tracker)  
**Primary Goal:** A lightweight, low-resource system for tracking personal assets, warranty periods, and maintenance history, optimized for free-tier cloud hosting and offline-first mobile usage.

### Key Objectives:
* Prevent financial loss from expired warranties or missed maintenance routines.
* Enable quick offline data entry via a Flutter Android application.
* Keep server resource usage minimal (compatible with Render Free Tier and TiDB Cloud / Aiven MySQL Free Tier).

---

## 2. Architecture & Tech Stack

### Backend Stack
* **Framework:** Laravel 11 (PHP 8.2+)
* **Admin Dashboard:** Laravel Filament or Blade + TailwindCSS
* **Authentication:** Laravel Sanctum (Token-based API authentication)
* **Database:** MySQL 8.0 (TiDB Cloud or Aiven Serverless Free Tier)
* **Media Storage:** Cloudinary (Free Tier - API integrated)

### Mobile Stack
* **Framework:** Flutter (Targeting Android SDK 21+)
* **State Management:** Riverpod / Provider / BLoC
* **Local Database:** Hive / SQLite (for offline-first capability)
* **Local Notifications:** `flutter_local_notifications`
* **Image Compression:** `flutter_image_compress`
* **HTTP Client:** `dio` with connectivity interceptors

---

## 3. System Roles & Access Control (RBAC)

1. **Regular User**
   * Access: Mobile App & Web User Portal.
   * Permissions: Full CRUD over their own assets, categories, and maintenance records.

2. **Super Admin**
   * Access: Web Admin Panel (`/admin`).
   * Permissions: Manage global categories, view system health, monitor user registration and storage metrics.

---

## 4. Functional Requirements (FR)

### A. Mobile Application (Flutter)
* **FR-M1 (Auth):** Login, Register, Logout, and Token Refresh.
* **FR-M2 (Offline Data Entry):** Store assets and maintenance logs locally in Hive/SQLite when offline.
* **FR-M3 (Sync Engine):** Auto-sync queued offline items to the Laravel API when connectivity is restored.
* **FR-M4 (Client Compression):** Compress image files to $< 200\text{ KB}$ before sending to API.
* **FR-M5 (Local Scheduled Notifications):** Schedule Android local notifications for warranty expiration ($30, 7, 1$ days prior) and upcoming maintenance without server cron jobs.
* **FR-M6 (Dashboard):** Display total asset count, total asset valuation, active warranties, and upcoming maintenance schedules.

### B. Web Backend & Admin Panel (Laravel)
* **FR-W1 (REST API):** Secure endpoints with Sanctum for Mobile App communication.
* **FR-W2 (Web Dashboard):** Visual analytics on asset distribution, costs over time, and upcoming warranty expiries.
* **FR-W3 (Media Handling):** Receive base64 or multipart image payloads and forward them to Cloudinary.
* **FR-W4 (Export):** Export asset and maintenance reports in PDF/CSV format.

---

## 5. Non-Functional Requirements (NFR)

* **NFR-1 (Cold Start Tolerance):** Mobile app must handle Render free-tier cold-starts ($\sim 50\text{s}$ initial response latency) gracefully with user-friendly retry logic and loading indicators.
* **NFR-2 (Low Payload Size):** API responses must be optimized with API Resources, keeping average payload size $< 50\text{ KB}$.
* **NFR-3 (Data Encryption):** Sensitive tokens and local database boxes must be encrypted on the client device.

---

## 6. Database Schema Design

### `users`
| Column | Type | Constraints |
|---|---|---|
| `id` | BigInteger | Primary Key, Auto Increment |
| `name` | String | Not Null |
| `email` | String | Unique, Not Null |
| `password` | String | Not Null |
| `created_at` | Timestamp | Nullable |
| `updated_at` | Timestamp | Nullable |

### `categories`
| Column | Type | Constraints |
|---|---|---|
| `id` | BigInteger | Primary Key, Auto Increment |
| `user_id` | BigInteger | Foreign Key -> `users.id` (Nullable for global default categories) |
| `name` | String | Not Null |
| `icon` | String | Default: 'box' |
| `created_at` | Timestamp | Nullable |

### `assets`
| Column | Type | Constraints |
|---|---|---|
| `id` | UUID / String | Primary Key (UUID generated client-side for offline sync) |
| `user_id` | BigInteger | Foreign Key -> `users.id` |
| `category_id` | BigInteger | Foreign Key -> `categories.id` |
| `name` | String | Not Null |
| `brand` | String | Nullable |
| `model` | String | Nullable |
| `serial_number` | String | Nullable |
| `purchase_date` | Date | Not Null |
| `purchase_price` | Decimal(12,2) | Default: 0.00 |
| `warranty_months`| Integer | Default: 0 |
| `warranty_expiry`| Date | Nullable |
| `receipt_image`  | String | Nullable (Cloudinary URL) |
| `status` | Enum | `active`, `repaired`, `disposed`, `sold` |
| `created_at` | Timestamp | Nullable |
| `updated_at` | Timestamp | Nullable |

### `maintenance_logs`
| Column | Type | Constraints |
|---|---|---|
| `id` | UUID / String | Primary Key |
| `asset_id` | UUID / String | Foreign Key -> `assets.id` |
| `service_date` | Date | Not Null |
| `cost` | Decimal(12,2) | Default: 0.00 |
| `service_center` | String | Nullable |
| `description` | Text | Nullable |
| `next_service_date`| Date | Nullable |
| `receipt_image` | String | Nullable |
| `created_at` | Timestamp | Nullable |
| `updated_at` | Timestamp | Nullable |

---

## 7. API Endpoints Specification

### Auth Endpoints
* `POST /api/v1/auth/register` - Create account.
* `POST /api/v1/auth/login` - Obtain Sanctum token.
* `POST /api/v1/auth/logout` - Revoke token.
* `GET  /api/v1/auth/me` - Fetch profile data.

### Asset Endpoints
* `GET    /api/v1/assets` - Paginated list of assets (`?category=`, `?search=`, `?page=`).
* `POST   /api/v1/assets` - Create new asset.
* `GET    /api/v1/assets/{id}` - Asset details with maintenance history.
* `PUT    /api/v1/assets/{id}` - Update asset.
* `DELETE /api/v1/assets/{id}` - Delete asset.

### Maintenance Endpoints
* `GET  /api/v1/assets/{asset_id}/maintenance` - List logs for an asset.
* `POST /api/v1/maintenance` - Add maintenance entry.

### Synchronization Endpoint
* `POST /api/v1/sync` - Bulk upsert batch payloads from mobile client offline queue.

---

## 8. Offline-First & Sync Workflow

```
[Mobile Action: Add Asset]
        │
        ▼
Is Internet Connected?
   ├── YES ──> Send directly to POST /api/v1/assets ──> Update Local Cache (Hive)
   └── NO  ──> Save locally in Hive with `is_synced = false`
                   │
                   ▼
       [Connectivity Restored event]
                   │
                   ▼
  Send batch POST /api/v1/sync payload ──> On HTTP 200 ──> Set `is_synced = true`
```

---

## 9. AI Agent Implementation Steps

When generating code or executing tasks for this project, follow this exact sequence:

1. **Step 1:** Set up Laravel 11 backend, configure Database migrations, Sanctum, and Cloudinary SDK.
2. **Step 2:** Implement Asset & Maintenance API resources, controllers, and validation rules.
3. **Step 3:** Implement Bulk Sync API route (`POST /api/v1/sync`).
4. **Step 4:** Build Flutter App scaffolding, Hive local database adapters, and state management.
5. **Step 5:** Implement Flutter image picker, local compression service, and offline queue mechanism.
6. **Step 6:** Implement `flutter_local_notifications` scheduler based on asset warranty dates.
7. **Step 7:** Build Web Admin Dashboard using Filament/Blade.
8. **Step 8:** Configure build scripts for Docker/Render deployment and APK release workflows.