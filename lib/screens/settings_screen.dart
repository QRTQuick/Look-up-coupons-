import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:look_up_coupons/providers/settings_provider.dart';
import 'package:look_up_coupons/services/permission_service.dart';
import 'package:look_up_coupons/widgets/section_header.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionHeader(
            title: 'Appearance',
            subtitle: 'Choose light or dark mode.',
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            value: settings.themeMode == ThemeMode.dark,
            title: const Text('Dark mode'),
            onChanged: (value) {
              settings.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
            },
          ),
          const SizedBox(height: 24),
          const SectionHeader(
            title: 'Notifications',
            subtitle: 'Daily reminders for new or expiring deals.',
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            value: settings.notificationsEnabled,
            title: const Text('Daily notifications'),
            onChanged: (value) {
              settings.setNotificationsEnabled(value);
            },
          ),
          const SizedBox(height: 24),
          const SectionHeader(
            title: 'Business Panel PIN',
            subtitle: 'Protect editing with a simple local PIN.',
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            value: settings.requirePin,
            title: const Text('Require PIN to edit deals'),
            onChanged: (value) async {
              if (value && !settings.hasPin) {
                final pin = await _promptForPin(context, 'Set PIN');
                if (pin == null || pin.isEmpty) return;
                await settings.setPin(pin);
              }
              await settings.setRequirePin(value);
            },
          ),
          ListTile(
            title: Text(settings.hasPin ? 'Change PIN' : 'Set PIN'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final pin = await _promptForPin(context, 'Enter new PIN');
              if (pin == null || pin.isEmpty) return;
              await settings.setPin(pin);
            },
          ),
          if (settings.hasPin)
            ListTile(
              title: const Text('Clear PIN'),
              trailing: const Icon(Icons.delete_outline),
              onTap: () async {
                await settings.setPin(null);
                await settings.setRequirePin(false);
              },
            ),
          const SizedBox(height: 24),
          const SectionHeader(
            title: 'Permissions',
            subtitle:
                'Location, background location, storage, and notifications.',
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            icon: const Icon(Icons.lock_open),
            label: const Text('Grant Permissions'),
            onPressed: () async {
              await PermissionService().requestAll();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Permissions requested.')),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<String?> _promptForPin(BuildContext context, String title) async {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            obscureText: true,
            decoration: const InputDecoration(hintText: 'PIN'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(null),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(controller.text.trim()),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
