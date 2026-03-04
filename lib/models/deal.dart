import 'package:google_maps_flutter/google_maps_flutter.dart';

class Deal {
  final int? id;
  final String title;
  final String description;
  final String shopName;
  final String? imageUrl;
  final DateTime expiresAt;
  final String category;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isUserAdded;

  const Deal({
    this.id,
    required this.title,
    required this.description,
    required this.shopName,
    this.imageUrl,
    required this.expiresAt,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    required this.updatedAt,
    required this.isUserAdded,
  });

  LatLng get latLng => LatLng(latitude, longitude);

  Deal copyWith({
    int? id,
    String? title,
    String? description,
    String? shopName,
    String? imageUrl,
    DateTime? expiresAt,
    String? category,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isUserAdded,
  }) {
    return Deal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      shopName: shopName ?? this.shopName,
      imageUrl: imageUrl ?? this.imageUrl,
      expiresAt: expiresAt ?? this.expiresAt,
      category: category ?? this.category,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isUserAdded: isUserAdded ?? this.isUserAdded,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'shopName': shopName,
      'imageUrl': imageUrl,
      'expiresAt': expiresAt.millisecondsSinceEpoch,
      'category': category,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'isUserAdded': isUserAdded ? 1 : 0,
    };
  }

  factory Deal.fromMap(Map<String, Object?> map) {
    return Deal(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String,
      shopName: map['shopName'] as String,
      imageUrl: map['imageUrl'] as String?,
      expiresAt: DateTime.fromMillisecondsSinceEpoch(map['expiresAt'] as int),
      category: map['category'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
      isUserAdded: (map['isUserAdded'] as int) == 1,
    );
  }
}
