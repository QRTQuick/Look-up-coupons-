import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:look_up_coupons/providers/deals_provider.dart';
import 'package:look_up_coupons/providers/favorites_provider.dart';
import 'package:look_up_coupons/providers/settings_provider.dart';
import 'package:look_up_coupons/screens/home_shell.dart';
import 'package:look_up_coupons/services/database_service.dart';
import 'package:look_up_coupons/services/local_storage_service.dart';
import 'package:look_up_coupons/services/notification_service.dart';
import 'package:look_up_coupons/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final databaseService = DatabaseService();
  await databaseService.init();

  final localStorageService = LocalStorageService();
  await localStorageService.init();

  final notificationService = NotificationService(
    databaseService: databaseService,
  );
  await notificationService.init();

  final settingsProvider = SettingsProvider(
    localStorageService: localStorageService,
    notificationService: notificationService,
  );
  await settingsProvider.initialize();

  final favoritesProvider = FavoritesProvider(databaseService);
  await favoritesProvider.loadFavorites();

  final dealsProvider = DealsProvider(databaseService);
  await dealsProvider.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settingsProvider),
        ChangeNotifierProvider.value(value: favoritesProvider),
        ChangeNotifierProvider.value(value: dealsProvider),
      ],
      child: const LookUpCouponsApp(),
    ),
  );
}

class LookUpCouponsApp extends StatelessWidget {
  const LookUpCouponsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return MaterialApp(
          title: 'Look Up Coupons',
          debugShowCheckedModeBanner: false,
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          themeMode: settings.themeMode,
          home: const HomeShell(),
        );
      },
    );
  }
}
