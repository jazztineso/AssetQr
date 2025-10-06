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

  // Create from JSON (supports Laravel API structure)
  factory Asset.fromJson(Map<String, dynamic> json) {
    print('Parsing Asset from JSON: $json');

    // Helper function to get string value with multiple fallbacks
    String getStringValue(List<String> keys) {
      for (var key in keys) {
        if (json[key] != null) {
          return json[key].toString();
        }
      }
      return '';
    }

    // Helper function to extract nested object name
    String getNestedName(String key, {String defaultValue = ''}) {
      if (json[key] != null && json[key] is Map) {
        return json[key]['name']?.toString() ?? defaultValue;
      }
      return json[key]?.toString() ?? defaultValue;
    }

    // Helper function to parse dates
    DateTime? parseDate(List<String> keys) {
      for (var key in keys) {
        final value = json[key];
        if (value != null && value.toString().isNotEmpty) {
          try {
            return DateTime.parse(value.toString());
          } catch (e) {
            print('Error parsing date for $key: $e');
          }
        }
      }
      return null;
    }

    return Asset(
      id: getStringValue(['id']),
      name: getStringValue(['assetName', 'name', 'asset_name']),
      assetId: getStringValue(['propertyCode', 'assetId', 'asset_id', 'property_code']),
      category: getNestedName('category', defaultValue: 'Unknown'),
      location: getNestedName('department', defaultValue: 'Unknown'),
      status: getNestedName('status', defaultValue: getNestedName('condition', defaultValue: 'Unknown')),
      purchaseDate: parseDate(['purchaseDate', 'purchase_date', 'dateAccountable', 'date_accountable', 'created_at']) ?? DateTime.now(),
      lastMaintenance: parseDate(['lastMaintenance', 'last_maintenance']),
      nextMaintenance: parseDate(['nextMaintenance', 'next_maintenance']),
      notes: (json['description'] ?? json['notes'])?.toString(),
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
