<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Asset;
use App\Models\MaintenanceLog;
use Illuminate\Http\Request;

class MaintenanceController extends Controller
{
    public function index(Request $request, $asset_id) {
        Asset::where('user_id', $request->user()->id)->findOrFail($asset_id);
        return response()->json(MaintenanceLog::where('asset_id', $asset_id)->orderBy('service_date', 'desc')->get());
    }

    public function store(Request $request) {
        $data = $request->validate([
            'id' => 'nullable|uuid',
            'asset_id' => 'required|uuid',
            'service_date' => 'required|date',
            'cost' => 'nullable|numeric',
            'service_center' => 'nullable|string',
            'description' => 'nullable|string',
            'next_service_date' => 'nullable|date',
            'receipt_image' => 'nullable|string',
        ]);
        Asset::where('user_id', $request->user()->id)->findOrFail($data['asset_id']);
        $log = MaintenanceLog::create($data);
        return response()->json($log, 201);
    }
}
