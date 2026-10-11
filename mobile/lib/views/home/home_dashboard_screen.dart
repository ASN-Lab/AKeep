import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/asset.dart';
import '../../viewmodels/asset_provider.dart';
import '../asset/add_asset_screen.dart';
import '../asset/asset_detail_screen.dart';
import '../account/account_screen.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  String _filter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AssetProvider>(context, listen: false).loadAssets();
    });
  }

  List<Asset> _filtered(List<Asset> assets) {
    switch (_filter) {
      case 'Active':
        return assets.where((a) => a.status == 'active').toList();
      case 'Expired':
        return assets.where((a) {
          if (a.warrantyExpiry == null) return false;
          return DateTime.parse(a.warrantyExpiry!).isBefore(DateTime.now());
        }).toList();
      default:
        return assets;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AKeep'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () => Provider.of<AssetProvider>(context, listen: false).manualSync(),
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AccountScreen()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final navigator = Navigator.of(context);
          final assetProvider = Provider.of<AssetProvider>(context, listen: false);
          final saved = await navigator.push<bool>(
            MaterialPageRoute(builder: (context) => const AddAssetScreen()),
          );
          if (saved == true) {
            assetProvider.loadAssets();
          }
        },
        child: const Icon(Icons.add),
      ),
      body: Consumer<AssetProvider>(
        builder: (context, provider, child) {
          final assets = _filtered(provider.assets);
          final totalValue = provider.assets.fold<double>(
            0,
            (sum, a) => sum + a.purchasePrice,
          );

          return RefreshIndicator(
            onRefresh: () => provider.loadAssets(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Financial Summary Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Asset Value',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          AppCurrency.format(totalValue),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.inventory_2_outlined,
                                size: 16, color: Theme.of(context).hintColor),
                            const SizedBox(width: 4),
                            Text(
                              '${provider.assets.where((a) => a.status == 'active').length} active items',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const Spacer(),
                            Icon(
                              provider.queueCount > 0
                                  ? Icons.cloud_off
                                  : Icons.cloud_done,
                              size: 16,
                              color: provider.queueCount > 0
                                  ? Theme.of(context).colorScheme.error
                                  : Colors.green,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              provider.queueCount > 0
                                  ? '${provider.queueCount} pending'
                                  : 'Synced',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Filter Chips
                Wrap(
                  spacing: 8,
                  children: ['All', 'Active', 'Expired'].map((f) {
                    return ChoiceChip(
                      label: Text(f),
                      selected: _filter == f,
                      onSelected: (selected) {
                        if (selected) setState(() => _filter = f);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                // Asset List
                if (assets.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 48),
                    child: Center(
                      child: Text('No assets yet. Tap + to add one.'),
                    ),
                  )
                else
                  ...assets.map((asset) => _AssetTile(asset: asset)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AssetTile extends StatelessWidget {
  final Asset asset;
  const _AssetTile({required this.asset});

  @override
  Widget build(BuildContext context) {
    bool isSynced = asset.isSynced;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(asset.name),
        subtitle: Text(
          '${asset.brand ?? '-'} · ${asset.purchaseDate}',
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
        ),
        trailing: Icon(
          isSynced ? Icons.cloud_done : Icons.cloud_off,
          color: isSynced ? Colors.green : Theme.of(context).colorScheme.error,
          size: 20,
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AssetDetailScreen(assetId: asset.id),
          ),
        ),
      ),
    );
  }
}
