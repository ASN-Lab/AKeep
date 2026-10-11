<?php

namespace App\Filament\Widgets;

use App\Models\Asset;
use Carbon\Carbon;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;
use Filament\Widgets\TableWidget;

class WarrantyAlert extends TableWidget
{
    protected static ?string $heading = 'Warranty Alerts';

    public function table(Table $table): Table
    {
        return $table
            ->query(
                fn () => Asset::where('warranty_expiry', '!=', null)
                    ->where('warranty_expiry', '<=', Carbon::now()->addDays(30))
                    ->orderBy('warranty_expiry', 'asc')
            )
            ->columns([
                TextColumn::make('name')
                    ->label('Asset'),
                TextColumn::make('warranty_expiry')
                    ->label('Expiry Date')
                    ->date(),
                TextColumn::make('warranty_days_left')
                    ->label('Days Left')
                    ->state(fn (Asset $record): int => Carbon::now()->diffInDays(Carbon::parse($record->warranty_expiry)))
                    ->color(fn (int $state): string => $state <= 7 ? 'danger' : ($state <= 30 ? 'warning' : 'success')),
            ]);
    }
}
