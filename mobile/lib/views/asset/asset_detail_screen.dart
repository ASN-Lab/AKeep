import 'package:flutter/material.dart';

import '../../models/asset.dart';
import '../../core/utils/currency_formatter.dart';
import '../../services/hive_service.dart';
import '../../services/notification_service.dart';
import '../maintenance/add_maintenance_log_screen.dart';

class AssetDetailScreen extends StatefulWidget {
  final String assetId;
  const AssetDetailScreen({super.key, required this.assetId});

  @override
  State<AssetDetailScreen> createState() => _AssetDetailScreenState();
}

class _AssetDetailScreenState extends State<AssetDetailScreen> {
  Asset? _asset;

  @override
  void initState() {
    super.initState();
    _loadAsset();
  }

  void _loadAsset() {
    final data = HiveService.assets.get(widget.assetId);
    if (data != null) {
      setState(() => _asset = Asset.fromJson(data as Map<dynamic, dynamic>));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_asset == null) {
      return const Scaffold(body: Center(child: Text('Asset not found')));
    }

    final asset = _asset!;
    final purchase = DateTime.parse(asset.purchaseDate);
    final expiry = asset.warrantyExpiry != null
        ? DateTime.parse(asset.warrantyExpiry!)
        : null;

    double progress = 0;
    if (expiry != null) {
      final total = expiry.difference(purchase).inDays;
      final elapsed = DateTime.now().difference(purchase).inDays;
      progress = (elapsed / total).clamp(0.0, 1.0);
    }

    return Scaffold(
      appBar: AppBar(title: Text(asset.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Warranty Progress',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(value: progress),
                    const SizedBox(height: 8),
                    Text(
                      'Purchase: ${asset.purchaseDate}\n'
                      'Expiry: ${asset.warrantyExpiry ?? '-'}\n'
                      'Status: ${asset.status}',
                      style: const TextStyle(fontFamily: 'JetBrainsMono'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Details', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _DetailRow('Brand', asset.brand),
            _DetailRow('Model', asset.model),
            _DetailRow('Serial', asset.serialNumber),
            _DetailRow('Price', AppCurrency.format(asset.purchasePrice)),
            _DetailRow('Synced', asset.isSynced ? 'Yes' : 'Pending'),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => NotificationService.scheduleWarrantyReminders(),
              icon: const Icon(Icons.notifications_active),
              label: const Text('Schedule Warranty Reminders'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AddMaintenanceLogScreen(assetId: asset.id),
                  ),
                );
              },
              icon: const Icon(Icons.build),
              label: const Text('Add Maintenance Log'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String? value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Theme.of(context).hintColor)),
          Text(
            value ?? '-',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
