import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/constants/theme.dart';
import 'services/hive_service.dart';
import 'services/sync_service.dart';
import 'viewmodels/asset_provider.dart';
import 'views/auth/login_screen.dart';
import 'views/home/home_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await HiveService.init();

  final syncService = SyncService();
  syncService.init();

  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? true;
  final token = prefs.getString('auth_token');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AssetProvider()),
      ],
      child: MyApp(isDarkMode: isDarkMode, isLoggedIn: token != null),
    ),
  );
}

class MyApp extends StatefulWidget {
  final bool isDarkMode;
  final bool isLoggedIn;
  const MyApp({super.key, required this.isDarkMode, required this.isLoggedIn});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
  }

  void toggleTheme() async {
    setState(() => _isDarkMode = !_isDarkMode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AKeep',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: widget.isLoggedIn
          ? const HomeDashboardScreen()
          : LoginScreen(toggleTheme: toggleTheme),
    );
  }
}
