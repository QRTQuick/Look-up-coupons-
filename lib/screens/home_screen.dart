import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:look_up_coupons/providers/deals_provider.dart';
import 'package:look_up_coupons/providers/favorites_provider.dart';
import 'package:look_up_coupons/screens/deal_details_screen.dart';
import 'package:look_up_coupons/widgets/category_filter.dart';
import 'package:look_up_coupons/widgets/deal_card.dart';
import 'package:look_up_coupons/widgets/distance_filter.dart';
import 'package:look_up_coupons/widgets/empty_state.dart';
import 'package:look_up_coupons/widgets/search_field.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DealsProvider>().refreshLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dealsProvider = context.watch<DealsProvider>();
    final favoritesProvider = context.watch<FavoritesProvider>();
    final deals = dealsProvider.filteredDeals;

    return RefreshIndicator(
      onRefresh: () async {
        await dealsProvider.reloadDeals();
        await dealsProvider.refreshLocation();
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SearchField(onChanged: dealsProvider.setSearchQuery),
          const SizedBox(height: 12),
          CategoryFilter(
            categories: dealsProvider.categories,
            selected: dealsProvider.selectedCategory,
            onSelected: dealsProvider.setSelectedCategory,
          ),
          const SizedBox(height: 12),
          DistanceFilter(
            selectedKm: dealsProvider.distanceFilterKm,
            onSelected: dealsProvider.setDistanceFilterKm,
          ),
          const SizedBox(height: 12),
          if (dealsProvider.currentPosition == null)
            _LocationCard(onEnable: dealsProvider.refreshLocation),
          if (dealsProvider.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            ),
          if (!dealsProvider.isLoading && deals.isEmpty)
            const EmptyState(
              title: 'No deals found',
              subtitle: 'Try changing your filters or adding a new deal.',
            ),
          ...deals.map((deal) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DealCard(
                deal: deal,
                distanceMeters: dealsProvider.distanceTo(deal),
                isFavorite: favoritesProvider.isDealFavorite(deal.id),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => DealDetailsScreen(deal: deal),
                    ),
                  );
                },
                onFavoriteToggle: () {
                  if (deal.id == null) return;
                  favoritesProvider.toggleFavoriteDeal(deal.id!);
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({required this.onEnable});

  final VoidCallback onEnable;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.my_location),
        title: const Text('Enable location'),
        subtitle: const Text('We use your GPS to sort deals by distance.'),
        trailing: ElevatedButton(
          onPressed: onEnable,
          child: const Text('Enable'),
        ),
      ),
    );
  }
}
