<?php

namespace App\Filament\Widgets;

use App\Models\Asset;
use Filament\Widgets\StatsOverviewWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class AssetValueOverview extends StatsOverviewWidget
{
    protected function getStats(): array
    {
        $totalValue = Asset::sum('purchase_price');
        $activeCount = Asset::where('status', 'active')->count();

        return [
            Stat::make('Total Asset Value', 'Rp ' . number_format($totalValue, 0, ',', '.'))
                ->description('Akumulasi seluruh aset tercatat')
                ->color('success'),
            Stat::make('Active Assets', $activeCount)
                ->description('Jumlah barang berstatus aktif')
                ->color('warning'),
        ];
    }
}
