<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Artisan;

Route::get('/', function () {
    return view('landing');
});

Route::get('/migrate-now', function () {
    Artisan::call('migrate --force');
    Artisan::call('storage:link');
    return "Migration Done!";
});

Route::get('/migrate-now', function () {
    Artisan::call('migrate --force');
    Artisan::call('storage:link');
    return "Migration Done!";
});