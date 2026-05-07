class FishBatch {
  final int? id;
  final int? fishermanId;
  final int? boatId;
  final String? category;
  final String? fishName;
  final String? catchMethod;
  final double? quantityKg;
  final double? remainingQuantityKg;
  final double? pricePerKg;
  final List<String>? photos;
  final double? latitude;
  final double? longitude;
  final String? additionalNotes;
  final DateTime? dateCaught;
  final String? status;
  final DateTime? createdAt;

  FishBatch({
    this.id,
    this.fishermanId,
    this.boatId,
    this.category,
    this.fishName,
    this.catchMethod,
    this.quantityKg,
    this.remainingQuantityKg,
    this.pricePerKg,
    this.photos,
    this.latitude,
    this.longitude,
    this.additionalNotes,
    this.dateCaught,
    this.status,
    this.createdAt,
  });

  factory FishBatch.fromJson(Map<String, dynamic> json) {
    return FishBatch(
      id: json['id'] as int?,
      fishermanId: json['fisherman_id'] as int?,
      boatId: json['boat_id'] as int?,
      category: json['category'] as String?,
      fishName: json['fish_name'] as String?,
      catchMethod: json['catch_method'] as String?,
      quantityKg: (json['quantity_kg'] as num?)?.toDouble(),
      remainingQuantityKg: (json['remaining_quantity_kg'] as num?)?.toDouble(),
      pricePerKg: (json['price_per_kg'] as num?)?.toDouble(),
      photos: json['photo'] != null
          ? List<String>.from(json['photo'])
          : [], // ✅ تحويل إلى List
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      additionalNotes: json['additional_notes'] as String?,
      dateCaught: json['date_caught'] != null
          ? DateTime.tryParse(json['date_caught'])
          : null,
      status: json['status'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  static List<FishBatch> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => FishBatch.fromJson(json)).toList();
  }
}
