import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:look_up_coupons/models/deal.dart';
import 'package:look_up_coupons/providers/favorites_provider.dart';
import 'package:look_up_coupons/screens/map_screen.dart';
import 'package:look_up_coupons/utils/formatters.dart';

class DealDetailsScreen extends StatelessWidget {
  const DealDetailsScreen({super.key, required this.deal});

  final Deal deal;

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>();
    final isDealFavorite = favorites.isDealFavorite(deal.id);
    final isShopFavorite = favorites.isShopFavorite(deal.shopName);

    return Scaffold(
      appBar: AppBar(title: Text(deal.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: _buildImage(),
          ),
          const SizedBox(height: 16),
          Text(
            deal.title,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(deal.description),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _InfoChip(icon: Icons.storefront, label: deal.shopName),
              _InfoChip(icon: Icons.local_offer, label: deal.category),
              _InfoChip(
                icon: Icons.timer,
                label: 'Expires ${formatDate(deal.expiresAt)}',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            children: [
              ActionChip(
                label: Text(isDealFavorite ? 'Saved Deal' : 'Save Deal'),
                avatar: Icon(
                  isDealFavorite ? Icons.favorite : Icons.favorite_border,
                ),
                onPressed: deal.id == null
                    ? null
                    : () => favorites.toggleFavoriteDeal(deal.id!),
              ),
              ActionChip(
                label: Text(isShopFavorite ? 'Saved Shop' : 'Save Shop'),
                avatar: Icon(
                  isShopFavorite ? Icons.store : Icons.storefront_outlined,
                ),
                onPressed: () => favorites.toggleFavoriteShop(deal.shopName),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.map_outlined),
            label: const Text('View on Map'),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MapScreen(focusDeal: deal),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    final placeholder = Image.asset(
      'assets/images/placeholder.png',
      height: 200,
      fit: BoxFit.cover,
    );

    if (deal.imageUrl == null || deal.imageUrl!.isEmpty) {
      return placeholder;
    }

    return CachedNetworkImage(
      imageUrl: deal.imageUrl!,
      height: 200,
      fit: BoxFit.cover,
      placeholder: (context, url) => placeholder,
      errorWidget: (context, url, error) => placeholder,
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }
}
