import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:look_up_coupons/models/deal.dart';
import 'package:look_up_coupons/providers/deals_provider.dart';
import 'package:look_up_coupons/services/location_service.dart';
import 'package:look_up_coupons/utils/formatters.dart';

class DealEditorScreen extends StatefulWidget {
  const DealEditorScreen({super.key, this.deal});

  final Deal? deal;

  @override
  State<DealEditorScreen> createState() => _DealEditorScreenState();
}

class _DealEditorScreenState extends State<DealEditorScreen> {
  static const _categories = [
    'Restaurant',
    'Retail',
    'Events',
    'Grocery',
    'Services',
    'Other',
  ];

  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _shopController;
  late TextEditingController _imageController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;

  late DateTime _expiresAt;
  late String _category;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final deal = widget.deal;

    _titleController = TextEditingController(text: deal?.title ?? '');
    _descriptionController =
        TextEditingController(text: deal?.description ?? '');
    _shopController = TextEditingController(text: deal?.shopName ?? '');
    _imageController = TextEditingController(text: deal?.imageUrl ?? '');
    _latitudeController = TextEditingController(
      text: deal != null ? deal.latitude.toStringAsFixed(6) : '',
    );
    _longitudeController = TextEditingController(
      text: deal != null ? deal.longitude.toStringAsFixed(6) : '',
    );

    _expiresAt = deal?.expiresAt ?? DateTime.now().add(const Duration(days: 7));
    _category = deal?.category ?? _categories.first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _shopController.dispose();
    _imageController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.deal != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Deal' : 'Add Deal')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _shopController,
              decoration: const InputDecoration(labelText: 'Shop Name'),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
              validator: (value) =>
                  value == null || value.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: _categories
                  .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _category = value;
                });
              },
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Expiration Date'),
              subtitle: Text(formatDate(_expiresAt)),
              trailing: TextButton(
                onPressed: _pickDate,
                child: const Text('Pick'),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _latitudeController,
              decoration: const InputDecoration(labelText: 'Latitude'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: _validateDouble,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _longitudeController,
              decoration: const InputDecoration(labelText: 'Longitude'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: _validateDouble,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _useCurrentLocation,
                icon: const Icon(Icons.my_location),
                label: const Text('Use current location'),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _imageController,
              decoration: const InputDecoration(
                labelText: 'Image URL (optional)',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving ? 'Saving...' : 'Save Deal'),
            ),
          ],
        ),
      ),
    );
  }

  String? _validateDouble(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    final parsed = double.tryParse(value);
    if (parsed == null) return 'Enter a valid number';
    return null;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiresAt,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) return;

    setState(() {
      _expiresAt = picked;
    });
  }

  Future<void> _useCurrentLocation() async {
    final position = await LocationService().getCurrentPosition();
    if (position == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location unavailable.')),
      );
      return;
    }

    setState(() {
      _latitudeController.text = position.latitude.toStringAsFixed(6);
      _longitudeController.text = position.longitude.toStringAsFixed(6);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
    });

    final now = DateTime.now();
    final deal = Deal(
      id: widget.deal?.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      shopName: _shopController.text.trim(),
      imageUrl: _imageController.text.trim().isEmpty
          ? null
          : _imageController.text.trim(),
      expiresAt: _expiresAt,
      category: _category,
      latitude: double.parse(_latitudeController.text.trim()),
      longitude: double.parse(_longitudeController.text.trim()),
      createdAt: widget.deal?.createdAt ?? now,
      updatedAt: now,
      isUserAdded: true,
    );

    final dealsProvider = context.read<DealsProvider>();
    if (widget.deal == null) {
      await dealsProvider.addDeal(deal);
    } else {
      await dealsProvider.updateDeal(deal);
    }

    if (!mounted) return;
    setState(() {
      _saving = false;
    });
    Navigator.of(context).pop();
  }
}
