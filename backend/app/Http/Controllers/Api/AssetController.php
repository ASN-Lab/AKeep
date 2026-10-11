<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Asset;
use Illuminate\Http\Request;

class AssetController extends Controller
{
    public function index(Request $request) {
        $query = Asset::where('user_id', $request->user()->id)->with('category');
        if ($request->has('category')) $query->where('category_id', $request->category);
        if ($request->has('search')) $query->where('name', 'like', '%'.$request->search.'%');
        
        $assets = $query->get(); // Get all instead of paginate for simple sync
        return response()->json($assets);
    }

    public function store(Request $request) {
        \Illuminate\Support\Facades\Log::info('Asset store payload:', $request->all());
        $data = $request->validate([
            'id' => 'nullable|uuid',
            'category_id' => 'nullable|exists:categories,id',
            'name' => 'required|string',
            'brand' => 'nullable|string',
            'model' => 'nullable|string',
            'serial_number' => 'nullable|string',
            'purchase_date' => 'required|date',
            'purchase_price' => 'nullable|numeric',
            'warranty_months' => 'nullable|integer',
            'warranty_expiry' => 'nullable|date',
            'receipt_image' => 'nullable|string',
            'status' => 'nullable|in:active,repaired,disposed,sold',
        ]);
        $data['user_id'] = $request->user()->id;
        $data['category_id'] = $data['category_id'] ?? 1;
        $asset = Asset::create($data);
        return response()->json($asset, 201);
    }

    public function show(Request $request, $id) {
        $asset = Asset::where('user_id', $request->user()->id)->with(['category', 'maintenanceLogs'])->findOrFail($id);
        return response()->json($asset);
    }

    public function update(Request $request, $id) {
        $asset = Asset::where('user_id', $request->user()->id)->findOrFail($id);
        $asset->update($request->all());
        return response()->json($asset);
    }

    public function destroy(Request $request, $id) {
        Asset::where('user_id', $request->user()->id)->findOrFail($id)->delete();
        return response()->json(null, 204);
    }
}
