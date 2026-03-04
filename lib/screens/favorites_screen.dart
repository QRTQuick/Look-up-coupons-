import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:look_up_coupons/providers/deals_provider.dart';
import 'package:look_up_coupons/providers/favorites_provider.dart';
import 'package:look_up_coupons/screens/deal_details_screen.dart';
import 'package:look_up_coupons/widgets/deal_card.dart';
import 'package:look_up_coupons/widgets/empty_state.dart';
import 'package:look_up_coupons/widgets/section_header.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>();
    final dealsProvider = context.watch<DealsProvider>();

    final favoriteDeals = dealsProvider.allDeals
        .where((deal) => favorites.isDealFavorite(deal.id))
        .toList();

    final favoriteShops = favorites.favoriteShops;

    if (favoriteDeals.isEmpty && favoriteShops.isEmpty) {
      return const Center(
        child: EmptyState(
          title: 'No favorites yet',
          subtitle: 'Save deals and shops to access them quickly.',
          icon: Icons.favorite_border,
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (favoriteDeals.isNotEmpty) ...[
          const SectionHeader(
            title: 'Favorite Deals',
            subtitle: 'Deals you have saved locally.',
          ),
          const SizedBox(height: 12),
          ...favoriteDeals.map((deal) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DealCard(
                deal: deal,
                distanceMeters: dealsProvider.distanceTo(deal),
                isFavorite: true,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => DealDetailsScreen(deal: deal),
                    ),
                  );
                },
                onFavoriteToggle: () {
                  if (deal.id == null) return;
                  favorites.toggleFavoriteDeal(deal.id!);
                },
              ),
            );
          }),
        ],
        if (favoriteShops.isNotEmpty) ...[
          const SizedBox(height: 16),
          const SectionHeader(
            title: 'Favorite Shops',
            subtitle: 'Shops you have starred for quick access.',
          ),
          const SizedBox(height: 12),
          ...favoriteShops.map((shop) {
            return Card(
              child: ListTile(
                leading: const Icon(Icons.storefront),
                title: Text(shop),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => favorites.toggleFavoriteShop(shop),
                ),
              ),
            );
          }),
        ],
      ],
    );
  }
}
