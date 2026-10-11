<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Asset;
use App\Models\MaintenanceLog;
use Illuminate\Http\Request;

class SyncController extends Controller
{
    public function sync(Request $request) {
        $user = $request->user();
        if ($request->has('assets')) {
            foreach ($request->assets as $asset) {
                if (!isset($asset['category_id'])) {
                    $asset['category_id'] = 1;
                }
                Asset::updateOrCreate(['id' => $asset['id'], 'user_id' => $user->id], $asset);
            }
        }
        if ($request->has('maintenance_logs')) {
            foreach ($request->maintenance_logs as $log) {
                MaintenanceLog::updateOrCreate(['id' => $log['id']], $log);
            }
        }
        return response()->json(['message' => 'Synced']);
    }
}
