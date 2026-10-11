<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;

class MaintenanceLog extends Model
{
    use HasUuids;
    protected $fillable = ['id', 'asset_id', 'service_date', 'cost', 'service_center', 'description', 'next_service_date', 'receipt_image'];
    public function asset() { return $this->belongsTo(Asset::class); }
}
