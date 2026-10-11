<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\DB;

Route::get('/', function () {
    return view('landing');
});

Route::get('/migrate-now', function () {
    try {
        Artisan::call('migrate --force');
        Artisan::call('storage:link');
        return "Migration Done!";
    } catch (\Throwable $e) {
        return response('ERR: '.$e->getMessage(), 500);
    }
});

Route::get('/debug-now', function () {
    try {
        $report = [
            'php' => PHP_VERSION,
            'writable_storage' => is_writable(storage_path()),
            'writable_bootstrap' => is_writable(base_path('bootstrap/cache')),
            'db' => null,
        ];
        try {
            DB::select('select 1');
            $report['db'] = 'ok';
        } catch (\Throwable $e) {
            $report['db'] = 'ERR: '.$e->getMessage();
        }
        return response()->json($report);
    } catch (\Throwable $e) {
        return response('ERR: '.$e->getMessage(), 500);
    }
});

Route::get('/migrate-now', function () {
    Artisan::call('migrate --force');
    Artisan::call('storage:link');
    return "Migration Done!";
});