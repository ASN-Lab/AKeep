class Asset {
  final String id;
  final int categoryId;
  final String name;
  final String? brand;
  final String? model;
  final String? serialNumber;
  final String purchaseDate;
  final double purchasePrice;
  final int warrantyMonths;
  final String? warrantyExpiry;
  final String? receiptImage;
  final String status;
  final bool isSynced;

  Asset({
    required this.id,
    this.categoryId = 1,
    required this.name,
    this.brand,
    this.model,
    this.serialNumber,
    required this.purchaseDate,
    this.purchasePrice = 0.0,
    this.warrantyMonths = 0,
    this.warrantyExpiry,
    this.receiptImage,
    this.status = 'active',
    this.isSynced = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'category_id': categoryId,
    'name': name,
    'brand': brand,
    'model': model,
    'serial_number': serialNumber,
    'purchase_date': purchaseDate,
    'purchase_price': purchasePrice,
    'warranty_months': warrantyMonths,
    'warranty_expiry': warrantyExpiry,
    'receipt_image': receiptImage,
    'status': status,
    'is_synced': isSynced,
  };

  factory Asset.fromJson(Map<dynamic, dynamic> json) {
    return Asset(
      id: json['id'].toString(),
      categoryId: (json['category_id'] is String)
          ? int.parse(json['category_id'])
          : (json['category_id'] as int? ?? 1),
      name: json['name'] as String? ?? 'Unnamed',
      brand: json['brand'] as String?,
      model: json['model'] as String?,
      serialNumber: json['serial_number'] as String?,
      purchaseDate: json['purchase_date'] as String? ?? '',
      purchasePrice: (json['purchase_price'] is String)
          ? double.parse(json['purchase_price'])
          : (json['purchase_price'] as num?)?.toDouble() ?? 0.0,
      warrantyMonths: (json['warranty_months'] is String)
          ? int.parse(json['warranty_months'])
          : (json['warranty_months'] as int?) ?? 0,
      warrantyExpiry: json['warranty_expiry'] as String?,
      receiptImage: json['receipt_image'] as String?,
      status: (json['status'] as String?) ?? 'active',
      isSynced: (json['is_synced'] as bool?) ?? true,
    );
  }
}
