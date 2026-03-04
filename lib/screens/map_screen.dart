import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import 'package:look_up_coupons/models/deal.dart';
import 'package:look_up_coupons/providers/deals_provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key, this.focusDeal});

  final Deal? focusDeal;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer();

  @override
  Widget build(BuildContext context) {
    final dealsProvider = context.watch<DealsProvider>();
    final deals = dealsProvider.filteredDeals;

    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: _initialCamera(dealsProvider, deals),
        myLocationEnabled: dealsProvider.currentPosition != null,
        myLocationButtonEnabled: true,
        markers: _buildMarkers(deals),
        onMapCreated: (controller) async {
          if (!_controller.isCompleted) {
            _controller.complete(controller);
          }
          if (widget.focusDeal != null) {
            await controller.animateCamera(
              CameraUpdate.newLatLngZoom(widget.focusDeal!.latLng, 15),
            );
          }
        },
      ),
      floatingActionButton: dealsProvider.currentPosition == null
          ? null
          : FloatingActionButton.extended(
              icon: const Icon(Icons.my_location),
              label: const Text('Recenter'),
              onPressed: () async {
                final controller = await _controller.future;
                final position = dealsProvider.currentPosition!;
                await controller.animateCamera(
                  CameraUpdate.newLatLngZoom(
                    LatLng(position.latitude, position.longitude),
                    14,
                  ),
                );
              },
            ),
    );
  }

  CameraPosition _initialCamera(DealsProvider provider, List<Deal> deals) {
    if (widget.focusDeal != null) {
      return CameraPosition(target: widget.focusDeal!.latLng, zoom: 14);
    }
    final position = provider.currentPosition;
    if (position != null) {
      return CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 13,
      );
    }
    if (deals.isNotEmpty) {
      return CameraPosition(target: deals.first.latLng, zoom: 12);
    }
    return const CameraPosition(target: LatLng(0, 0), zoom: 2);
  }

  Set<Marker> _buildMarkers(List<Deal> deals) {
    return deals.map((deal) {
      return Marker(
        markerId: MarkerId(deal.id?.toString() ?? deal.title),
        position: deal.latLng,
        infoWindow: InfoWindow(
          title: deal.title,
          snippet: deal.shopName,
        ),
      );
    }).toSet();
  }
}
