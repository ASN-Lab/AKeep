<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;

class Asset extends Model
{
    use HasUuids;
    protected $fillable = ['id', 'user_id', 'category_id', 'name', 'brand', 'model', 'serial_number', 'purchase_date', 'purchase_price', 'warranty_months', 'warranty_expiry', 'receipt_image', 'status'];

    protected $casts = [
        'purchase_price' => 'float',
        'warranty_months' => 'integer',
        'category_id' => 'integer',
    ];

    public function category() { return $this->belongsTo(Category::class); }
    public function maintenanceLogs() { return $this->hasMany(MaintenanceLog::class); }
    public function user() { return $this->belongsTo(User::class); }
}
