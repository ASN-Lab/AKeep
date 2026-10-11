import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/currency_formatter.dart';
import '../../models/asset.dart';
import '../../services/api_service.dart';
import '../../services/hive_service.dart';
import '../../services/image_service.dart';

class AddAssetScreen extends StatefulWidget {
  const AddAssetScreen({super.key});

  @override
  State<AddAssetScreen> createState() => _AddAssetScreenState();
}

class _AddAssetScreenState extends State<AddAssetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _serialController = TextEditingController();
  final _priceController = TextEditingController();
  final _warrantyMonthsController = TextEditingController(text: '12');

  DateTime _purchaseDate = DateTime.now();
  File? _imageFile;
  int _imageSizeKB = 0;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _isLoading = true);
      final compressed = await ImageService.compress(File(picked.path));
      if (compressed != null) {
        final bytes = await compressed.readAsBytes();
        setState(() {
          _imageFile = compressed;
          _imageSizeKB = bytes.length ~/ 1024;
        });
      }
      setState(() => _isLoading = false);
    }
  }

  void _saveAsset() async {
    if (!_formKey.currentState!.validate()) return;

    final purchase = _purchaseDate;
    final months = int.tryParse(_warrantyMonthsController.text) ?? 0;
    final expiry = DateTime(
      purchase.year,
      purchase.month + months,
      purchase.day,
    );

    // Parse formatted price
    final price = double.tryParse(
            _priceController.text.replaceAll('.', '').replaceAll(',', '')) ??
        0.0;

    String? base64Image;
    if (_imageFile != null) {
      base64Image = await ImageService.toBase64(_imageFile!);
    }

    final asset = Asset(
      id: const Uuid().v4(),
      name: _nameController.text,
      brand: _brandController.text.isNotEmpty ? _brandController.text : null,
      model: _modelController.text.isNotEmpty ? _modelController.text : null,
      serialNumber:
          _serialController.text.isNotEmpty ? _serialController.text : null,
      purchaseDate: purchase.toIso8601String().split('T')[0],
      purchasePrice: price,
      warrantyMonths: months,
      warrantyExpiry: expiry.toIso8601String().split('T')[0],
      receiptImage: base64Image,
      status: 'active',
      isSynced: false,
    );

    // Save locally to Hive box
    await HiveService.assets.put(asset.id, asset.toJson());

    // Try to sync if connected
    final connectivity = await Connectivity().checkConnectivity();
    if (!connectivity.contains(ConnectivityResult.none)) {
      try {
        await ApiService().post('/assets', asset.toJson());
        // Update local status if sync successful
        final syncedAsset = Asset(
          id: asset.id,
          name: asset.name,
          brand: asset.brand,
          model: asset.model,
          serialNumber: asset.serialNumber,
          purchaseDate: asset.purchaseDate,
          purchasePrice: asset.purchasePrice,
          warrantyMonths: asset.warrantyMonths,
          warrantyExpiry: asset.warrantyExpiry,
          receiptImage: asset.receiptImage,
          status: asset.status,
          isSynced: true,
        );
        await HiveService.assets.put(syncedAsset.id, syncedAsset.toJson());
      } catch (e) {
        debugPrint('Sync failed (likely offline or auth error): $e');
        await HiveService.queue.add(asset.toJson());
      }
    } else {
      await HiveService.queue.add(asset.toJson());
    }

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Asset')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Asset Name *'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _brandController,
                      decoration: const InputDecoration(labelText: 'Brand'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _modelController,
                      decoration: const InputDecoration(labelText: 'Model'),
                    ),
                  ),
                ],
              ),
              TextFormField(
                controller: _serialController,
                decoration: const InputDecoration(labelText: 'Serial Number'),
              ),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyInputFormatter()],
                decoration: const InputDecoration(
                  labelText: 'Purchase Price (IDR)',
                  hintText: 'e.g. 10.000.000',
                ),
              ),
              TextFormField(
                controller: _warrantyMonthsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Warranty (Months)',
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(
                  'Purchase Date: ${_purchaseDate.toIso8601String().split('T')[0]}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _purchaseDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => _purchaseDate = picked);
                },
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _pickImage,
                icon: const Icon(Icons.camera_alt),
                label: Text(
                  _imageFile == null ? 'Attach Receipt' : 'Receipt Attached',
                ),
              ),
              if (_imageFile != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Compressed Size: $_imageSizeKB KB / 200 KB Limit',
                    style: TextStyle(
                      color: _imageSizeKB > 200 ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveAsset,
                child: const Text('Save Asset (Offline-First)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
