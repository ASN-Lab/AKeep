<?php

namespace App\Filament\Widgets;

use App\Models\MaintenanceLog;
use Filament\Widgets\StatsOverviewWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class MaintenanceCost extends StatsOverviewWidget
{
    protected function getStats(): array
    {
        $totalCost = MaintenanceLog::whereYear('service_date', now()->year)->sum('cost');
        $serviceCount = MaintenanceLog::whereYear('service_date', now()->year)->count();

        return [
            Stat::make('Maintenance Cost', 'Rp ' . number_format($totalCost, 0, ',', '.'))
                ->description("Total pengeluaran servis tahun {$this->currentYearLabel()}")
                ->color('danger'),
            Stat::make('Total Services', $serviceCount)
                ->description('Jumlah servis tahun berjalan')
                ->color('info'),
        ];
    }

    private function currentYearLabel(): string
    {
        return (string) now()->year;
    }
}
