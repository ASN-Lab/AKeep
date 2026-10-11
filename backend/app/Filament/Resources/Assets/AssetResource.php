<?php

namespace App\Filament\Resources\Assets;

use App\Filament\Resources\Assets\Pages\ManageAssets;
use App\Models\Asset;
use BackedEnum;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteAction;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Forms\Components\DatePicker;
use Filament\Forms\Components\FileUpload;
use Filament\Forms\Components\Hidden;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Tables\Columns\ImageColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;
use Illuminate\Support\Facades\Auth;

class AssetResource extends Resource
{
    protected static ?string $model = Asset::class;

    protected static string|BackedEnum|null $navigationIcon = 'heroicon-o-rectangle-stack';

    protected static ?string $recordTitleAttribute = 'name';

    public static function form(Schema $schema): Schema
    {
        return $schema
            ->components([
                Hidden::make('user_id')
                    ->default(fn () => Auth::id()),
                Select::make('user_id')
                    ->relationship('user', 'name')
                    ->label('Owner (User)')
                    ->required(),
                TextInput::make('name')
                    ->required()
                    ->maxLength(255),
                TextInput::make('brand')
                    ->maxLength(255),
                TextInput::make('model')
                    ->maxLength(255),
                TextInput::make('serial_number')
                    ->maxLength(255),
                DatePicker::make('purchase_date')
                    ->required(),
                TextInput::make('purchase_price')
                    ->numeric()
                    ->prefix('Rp'),
                TextInput::make('warranty_months')
                    ->numeric()
                    ->default(0),
                DatePicker::make('warranty_expiry'),
                FileUpload::make('receipt_image')
                    ->image()
                    ->imageEditor()
                    ->directory('receipts')
                    ->label('Receipt Image'),
                Select::make('status')
                    ->options([
                        'active' => 'Active',
                        'repaired' => 'Repaired',
                        'disposed' => 'Disposed',
                        'sold' => 'Sold',
                    ])
                    ->default('active'),
                Select::make('category_id')
                    ->relationship('category', 'name')
                    ->required(),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->recordTitleAttribute('name')
            ->columns([
                ImageColumn::make('receipt_image')
                    ->label('Receipt')
                    ->width(50)
                    ->height(50),
                TextColumn::make('name')
                    ->searchable(),
                TextColumn::make('category.name'),
                TextColumn::make('brand'),
                TextColumn::make('purchase_date')
                    ->date(),
                TextColumn::make('purchase_price')
                    ->money('idr'),
                TextColumn::make('status')
                    ->badge(),
            ])
            ->filters([
                //
            ])
            ->recordActions([
                EditAction::make(),
                DeleteAction::make(),
            ])
            ->toolbarActions([
                BulkActionGroup::make([
                    DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => ManageAssets::route('/'),
        ];
    }
}
