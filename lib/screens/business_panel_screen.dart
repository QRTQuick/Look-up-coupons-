import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:look_up_coupons/models/deal.dart';
import 'package:look_up_coupons/providers/deals_provider.dart';
import 'package:look_up_coupons/providers/settings_provider.dart';
import 'package:look_up_coupons/screens/deal_editor_screen.dart';
import 'package:look_up_coupons/utils/formatters.dart';
import 'package:look_up_coupons/widgets/empty_state.dart';
import 'package:look_up_coupons/widgets/section_header.dart';

class BusinessPanelScreen extends StatelessWidget {
  const BusinessPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dealsProvider = context.watch<DealsProvider>();
    final userDeals = dealsProvider.userAddedDeals;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (!await _authorize(context)) return;
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const DealEditorScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionHeader(
            title: 'Business Panel',
            subtitle: 'Create and manage local deals stored on this device.',
          ),
          const SizedBox(height: 16),
          if (userDeals.isEmpty)
            const EmptyState(
              title: 'No custom deals yet',
              subtitle: 'Tap the + button to add your first deal.',
              icon: Icons.storefront_outlined,
            ),
          ...userDeals.map((deal) => _DealRow(
                deal: deal,
                authorize: () => _authorize(context),
              )),
        ],
      ),
    );
  }

  Future<bool> _authorize(BuildContext context) async {
    final settings = context.read<SettingsProvider>();
    if (!settings.requirePin || !settings.hasPin) return true;

    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Enter PIN'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            obscureText: true,
            decoration: const InputDecoration(hintText: 'PIN'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final isValid = settings.verifyPin(controller.text.trim());
                Navigator.of(dialogContext).pop(isValid);
              },
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) return true;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Incorrect PIN.')),
    );
    return false;
  }
}

class _DealRow extends StatelessWidget {
  const _DealRow({required this.deal, required this.authorize});

  final Deal deal;
  final Future<bool> Function() authorize;

  @override
  Widget build(BuildContext context) {
    final dealsProvider = context.read<DealsProvider>();

    return Card(
      child: ListTile(
        title: Text(deal.title),
        subtitle: Text(
          '${deal.shopName} | ${deal.category} | Expires ${formatDate(deal.expiresAt)}',
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            if (!await authorize()) return;

            if (value == 'edit') {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => DealEditorScreen(deal: deal),
                ),
              );
            } else if (value == 'delete') {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (dialogContext) {
                  return AlertDialog(
                    title: const Text('Delete deal?'),
                    content: const Text('This will remove the deal locally.'),
                    actions: [
                      TextButton(
                        onPressed: () =>
                            Navigator.of(dialogContext).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.of(dialogContext).pop(true),
                        child: const Text('Delete'),
                      ),
                    ],
                  );
                },
              );
              if (confirm == true) {
                await dealsProvider.deleteDeal(deal);
              }
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }
}
