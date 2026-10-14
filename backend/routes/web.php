<?php

use Illuminate\Support\Facades\Route;

Route::get('/migrate-db-internal-only', function () {
    \Illuminate\Support\Facades\Artisan::call('migrate --force');
    \Illuminate\Support\Facades\Artisan::call('storage:link');
    return "Migration Done!";
});