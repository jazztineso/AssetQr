class Asset {
  final String id;
  final String name;
  final String assetId;
  final String category;
  final String location;
  final String status;
  final DateTime purchaseDate;
  final DateTime? lastMaintenance;
  final DateTime? nextMaintenance;
  final String? notes;

  Asset({
    required this.id,
    required this.name,
    required this.assetId,
    required this.category,
    required this.location,
    required this.status,
    required this.purchaseDate,
    this.lastMaintenance,
    this.nextMaintenance,
    this.notes,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'assetId': assetId,
      'category': category,
      'location': location,
      'status': status,
      'purchaseDate': purchaseDate.toIso8601String(),
      'lastMaintenance': lastMaintenance?.toIso8601String(),
      'nextMaintenance': nextMaintenance?.toIso8601String(),
      'notes': notes,
    };
  }

  // Create from JSON
  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      id: json['id'],
      name: json['name'],
      assetId: json['assetId'],
      category: json['category'],
      location: json['location'],
      status: json['status'],
      purchaseDate: DateTime.parse(json['purchaseDate']),
      lastMaintenance: json['lastMaintenance'] != null
          ? DateTime.parse(json['lastMaintenance'])
          : null,
      nextMaintenance: json['nextMaintenance'] != null
          ? DateTime.parse(json['nextMaintenance'])
          : null,
      notes: json['notes'],
    );
  }

  // Copy with method for updates
  Asset copyWith({
    String? id,
    String? name,
    String? assetId,
    String? category,
    String? location,
    String? status,
    DateTime? purchaseDate,
    DateTime? lastMaintenance,
    DateTime? nextMaintenance,
    String? notes,
  }) {
    return Asset(
      id: id ?? this.id,
      name: name ?? this.name,
      assetId: assetId ?? this.assetId,
      category: category ?? this.category,
      location: location ?? this.location,
      status: status ?? this.status,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      lastMaintenance: lastMaintenance ?? this.lastMaintenance,
      nextMaintenance: nextMaintenance ?? this.nextMaintenance,
      notes: notes ?? this.notes,
    );
  }
}
