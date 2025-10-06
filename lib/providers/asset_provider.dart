import 'package:flutter/material.dart';
import '../models/asset.dart';
import '../database/database_helper.dart';

class AssetProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<Asset> _assets = [];
  List<Asset> _filteredAssets = [];
  String _searchQuery = '';
  String _filterStatus = 'All';
  bool _isLoading = false;

  List<Asset> get assets {
    // If no search or filter is active, return all assets
    if (_searchQuery.isEmpty && _filterStatus == 'All') {
      return _assets;
    }
    // Otherwise return filtered results
    return _filteredAssets;
  }

  List<Asset> get allAssets => _assets;

  List<Asset> get recentAssets => _assets.take(3).toList();

  bool get isLoading => _isLoading;

  /// Initialize provider - Load data from SQLite
  /// Call this when app starts
  AssetProvider() {
    loadAssets();
  }

  /// Load all assets from SQLite database
  Future<void> loadAssets() async {
    _isLoading = true;
    notifyListeners();

    try {
      _assets = await _db.getAllAssets();

      // If no assets exist, add sample data
      if (_assets.isEmpty) {
        await _addSampleData();
      }

      _filteredAssets = _assets;
    } catch (e) {
      print('Error loading assets: $e');
      _assets = [];
      _filteredAssets = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Add sample data to database (only on first run)
  Future<void> _addSampleData() async {
    final sampleAssets = [
      Asset(
        id: '1',
        name: 'Laptop - Dell XPS 15',
        assetId: 'AST-001',
        category: 'Electronics',
        location: 'Office 101',
        status: 'Active',
        purchaseDate: DateTime(2023, 1, 15),
        lastMaintenance: DateTime(2024, 12, 1),
        nextMaintenance: DateTime(2025, 6, 1),
        notes: 'Primary development laptop',
      ),
      Asset(
        id: '2',
        name: 'Projector - Epson EB-X41',
        assetId: 'AST-002',
        category: 'Electronics',
        location: 'Conference Room A',
        status: 'In Use',
        purchaseDate: DateTime(2023, 3, 20),
        lastMaintenance: DateTime(2024, 11, 15),
        nextMaintenance: DateTime(2025, 5, 15),
        notes: 'Used for presentations',
      ),
      Asset(
        id: '3',
        name: 'Desk Chair - ErgoMax',
        assetId: 'AST-003',
        category: 'Furniture',
        location: 'Warehouse B',
        status: 'Active',
        purchaseDate: DateTime(2023, 5, 10),
        notes: 'Ergonomic office chair',
      ),
      Asset(
        id: '4',
        name: 'Monitor - LG 27" 4K',
        assetId: 'AST-004',
        category: 'Electronics',
        location: 'Office 203',
        status: 'Active',
        purchaseDate: DateTime(2023, 6, 5),
        lastMaintenance: DateTime(2024, 10, 20),
        nextMaintenance: DateTime(2025, 4, 20),
      ),
      Asset(
        id: '5',
        name: 'Printer - HP LaserJet',
        assetId: 'AST-005',
        category: 'Electronics',
        location: 'Print Room',
        status: 'Maintenance',
        purchaseDate: DateTime(2022, 12, 1),
        lastMaintenance: DateTime(2024, 9, 30),
        nextMaintenance: DateTime(2025, 3, 30),
        notes: 'Scheduled for maintenance',
      ),
    ];

    for (var asset in sampleAssets) {
      await _db.insertAsset(asset);
      _assets.add(asset);
    }

    notifyListeners();
  }

  /// Add new asset (saves to SQLite)
  Future<void> addAsset(Asset asset) async {
    try {
      // Save to database
      await _db.insertAsset(asset);

      // Update in-memory list
      _assets.insert(0, asset);
      _applyFilters();
      notifyListeners();
    } catch (e) {
      print('Error adding asset: $e');
      rethrow;
    }
  }

  /// Update existing asset (saves to SQLite)
  Future<void> updateAsset(String id, Asset updatedAsset) async {
    try {
      // Update in database
      await _db.updateAsset(updatedAsset);

      // Update in-memory list
      final index = _assets.indexWhere((asset) => asset.id == id);
      if (index != -1) {
        _assets[index] = updatedAsset;
        _applyFilters();
        notifyListeners();
      }
    } catch (e) {
      print('Error updating asset: $e');
      rethrow;
    }
  }

  /// Delete asset (removes from SQLite)
  Future<void> deleteAsset(String id) async {
    try {
      // Delete from database
      await _db.deleteAsset(id);

      // Remove from in-memory list
      _assets.removeWhere((asset) => asset.id == id);
      _applyFilters();
      notifyListeners();
    } catch (e) {
      print('Error deleting asset: $e');
      rethrow;
    }
  }

  /// Get asset by ID (from memory, faster)
  Asset? getAssetById(String id) {
    try {
      return _assets.firstWhere((asset) => asset.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get asset by asset ID / QR code (from memory, faster)
  Asset? getAssetByAssetId(String assetId) {
    try {
      return _assets.firstWhere((asset) => asset.assetId == assetId);
    } catch (e) {
      return null;
    }
  }

  /// Search assets (uses SQLite for better performance)
  Future<void> searchAssets(String query) async {
    _searchQuery = query.toLowerCase();

    if (_searchQuery.isEmpty) {
      _applyFilters();
    } else {
      try {
        // Use database search for better performance with large datasets
        final results = await _db.searchAssets(_searchQuery);

        // Apply status filter on search results
        if (_filterStatus != 'All') {
          _filteredAssets = results.where((asset) => asset.status == _filterStatus).toList();
        } else {
          _filteredAssets = results;
        }
      } catch (e) {
        print('Error searching assets: $e');
        _applyFilters(); // Fallback to in-memory search
      }
    }

    notifyListeners();
  }

  /// Filter by status
  Future<void> filterByStatus(String status) async {
    _filterStatus = status;

    if (status == 'All') {
      _applyFilters();
    } else {
      try {
        // Use database filter for better performance
        final results = await _db.getAssetsByStatus(status);

        // Apply search filter on status results
        if (_searchQuery.isNotEmpty) {
          _filteredAssets = results.where((asset) {
            return asset.name.toLowerCase().contains(_searchQuery) ||
                   asset.assetId.toLowerCase().contains(_searchQuery) ||
                   asset.location.toLowerCase().contains(_searchQuery);
          }).toList();
        } else {
          _filteredAssets = results;
        }
      } catch (e) {
        print('Error filtering assets: $e');
        _applyFilters(); // Fallback to in-memory filter
      }
    }

    notifyListeners();
  }

  /// Apply filters (in-memory, for backward compatibility)
  void _applyFilters() {
    _filteredAssets = _assets.where((asset) {
      final matchesSearch = _searchQuery.isEmpty ||
          asset.name.toLowerCase().contains(_searchQuery) ||
          asset.assetId.toLowerCase().contains(_searchQuery) ||
          asset.location.toLowerCase().contains(_searchQuery);

      final matchesStatus = _filterStatus == 'All' || asset.status == _filterStatus;

      return matchesSearch && matchesStatus;
    }).toList();
  }

  /// Get statistics
  int get totalAssets => _assets.length;

  int get activeAssets => _assets.where((a) => a.status == 'Active').length;

  int get maintenanceAssets => _assets.where((a) => a.status == 'Maintenance').length;

  /// Get asset count from database (for verification)
  Future<int> getDatabaseAssetCount() async {
    return await _db.getAssetCount();
  }

  /// Get asset count by status from database
  Future<Map<String, int>> getAssetCountByStatus() async {
    return await _db.getAssetCountByStatus();
  }

  /// Clear search and filters
  void clearFilters() {
    _searchQuery = '';
    _filterStatus = 'All';
    _filteredAssets = _assets;
    notifyListeners();
  }

  /// Refresh data from database (useful after external changes)
  Future<void> refresh() async {
    await loadAssets();
  }

  /// Clear all data (for testing only)
  Future<void> clearAllAssets() async {
    try {
      await _db.deleteAllAssets();
      _assets.clear();
      _filteredAssets.clear();
      notifyListeners();
    } catch (e) {
      print('Error clearing assets: $e');
      rethrow;
    }
  }
}
