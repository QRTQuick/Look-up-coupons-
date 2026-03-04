import 'package:flutter/material.dart';

import 'package:look_up_coupons/screens/business_panel_screen.dart';
import 'package:look_up_coupons/screens/favorites_screen.dart';
import 'package:look_up_coupons/screens/home_screen.dart';
import 'package:look_up_coupons/screens/map_screen.dart';
import 'package:look_up_coupons/screens/settings_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    FavoritesScreen(),
    MapScreen(),
    BusinessPanelScreen(),
  ];

  final List<String> _titles = const [
    'Deals',
    'Favorites',
    'Map',
    'Business',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) {
          setState(() {
            _index = value;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.local_offer_outlined),
            label: 'Deals',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            label: 'Favorites',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            label: 'Map',
          ),
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            label: 'Business',
          ),
        ],
      ),
    );
  }
}
