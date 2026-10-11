import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/hive_service.dart';
import '../../viewmodels/asset_provider.dart';
import '../auth/login_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account & Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.delete_sweep_outlined),
            title: const Text('Clear Local Cache'),
            subtitle: const Text('Wipe Hive data (use if data is stuck)'),
            onTap: () async {
              await HiveService.assets.clear();
              await HiveService.queue.clear();
              if (context.mounted) {
                Provider.of<AssetProvider>(context, listen: false).loadAssets();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Local cache cleared')),
                );
              }
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('auth_token');
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(
                      toggleTheme: () {},
                    ),
                  ),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
