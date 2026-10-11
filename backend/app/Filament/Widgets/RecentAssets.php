<?php

namespace App\Filament\Widgets;

use App\Models\Asset;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;
use Filament\Widgets\TableWidget;

class RecentAssets extends TableWidget
{
    protected static ?string $heading = 'Recent Assets';

    protected int | string | array $columnSpan = 'full';

    public function table(Table $table): Table
    {
        return $table
            ->query(fn () => Asset::orderBy('created_at', 'desc')->limit(5))
            ->columns([
                TextColumn::make('name')
                    ->label('Asset'),
                TextColumn::make('brand')
                    ->label('Brand'),
                TextColumn::make('purchase_price')
                    ->label('Price')
                    ->money('idr'),
                TextColumn::make('created_at')
                    ->label('Added At')
                    ->dateTime(),
            ]);
    }
}
