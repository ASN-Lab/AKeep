import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../services/api_service.dart';
import '../../services/hive_service.dart';
import '../../services/image_service.dart';

class AddMaintenanceLogScreen extends StatefulWidget {
  final String assetId;
  const AddMaintenanceLogScreen({super.key, required this.assetId});

  @override
  State<AddMaintenanceLogScreen> createState() => _AddMaintenanceLogScreenState();
}

class _AddMaintenanceLogScreenState extends State<AddMaintenanceLogScreen> {
  final _formKey = GlobalKey<FormState>();
  final _costController = TextEditingController();
  final _centerController = TextEditingController();
  final _descController = TextEditingController();

  DateTime _serviceDate = DateTime.now();
  DateTime? _nextServiceDate;
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

  void _saveLog() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    String? base64Image;
    if (_imageFile != null) {
      base64Image = await ImageService.toBase64(_imageFile!);
    }

    final payload = {
      'id': const Uuid().v4(),
      'asset_id': widget.assetId,
      'service_date': _serviceDate.toIso8601String().split('T')[0],
      'cost': double.tryParse(_costController.text) ?? 0.0,
      'service_center': _centerController.text,
      'description': _descController.text,
      'next_service_date': _nextServiceDate?.toIso8601String().split('T')[0],
      'receipt_image': base64Image,
    };

    try {
      await ApiService().post('/maintenance', payload);
    } catch (e) {
      // Save locally to queue if offline
      await HiveService.queue.add({'maintenance_logs': [payload]});
    }

    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Maintenance Log')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _costController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Cost (IDR)'),
              ),
              TextFormField(
                controller: _centerController,
                decoration: const InputDecoration(labelText: 'Service Center'),
              ),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description / Notes'),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text('Service Date: ${_serviceDate.toIso8601String().split('T')[0]}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _serviceDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => _serviceDate = picked);
                },
              ),
              ListTile(
                title: Text(_nextServiceDate == null
                    ? 'Set Next Scheduled Service'
                    : 'Next Service: ${_nextServiceDate!.toIso8601String().split('T')[0]}'),
                trailing: const Icon(Icons.event),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 180)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 3650)),
                  );
                  if (picked != null) setState(() => _nextServiceDate = picked);
                },
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _pickImage,
                icon: const Icon(Icons.receipt_long),
                label: Text(_imageFile == null ? 'Attach Receipt' : 'Receipt Attached'),
              ),
              if (_imageFile != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Size: $_imageSizeKB KB / 200 KB Limit',
                    style: TextStyle(
                      color: _imageSizeKB > 200 ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveLog,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Save Log'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
