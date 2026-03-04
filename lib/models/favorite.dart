class Favorite {
  final int? id;
  final int? dealId;
  final String? shopName;
  final DateTime createdAt;

  const Favorite({
    this.id,
    this.dealId,
    this.shopName,
    required this.createdAt,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'dealId': dealId,
      'shopName': shopName,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Favorite.fromMap(Map<String, Object?> map) {
    return Favorite(
      id: map['id'] as int?,
      dealId: map['dealId'] as int?,
      shopName: map['shopName'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
    );
  }
}
