<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('landing');
});

Route::get('/migrate-now', function () {
    Artisan::call('migrate --force');
    Artisan::call('storage:link');
    return "Migration Done!";
});