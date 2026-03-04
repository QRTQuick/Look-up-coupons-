import 'package:flutter/material.dart';

class DistanceFilter extends StatelessWidget {
  const DistanceFilter({
    super.key,
    required this.selectedKm,
    required this.onSelected,
  });

  final double? selectedKm;
  final ValueChanged<double?> onSelected;

  @override
  Widget build(BuildContext context) {
    const options = <double?>[null, 1, 3, 5, 10];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: options.map((km) {
          final label = km == null ? 'Any distance' : '${km.toInt()} km';
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(label),
              selected: km == selectedKm,
              onSelected: (_) => onSelected(km),
            ),
          );
        }).toList(),
      ),
    );
  }
}
