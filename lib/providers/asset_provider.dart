import 'package:flutter/material.dart';
import '../models/asset.dart';

class AssetProvider extends ChangeNotifier {
  final List<Asset> _assets = [];
  List<Asset> _filteredAssets = [];
  String _searchQuery = '';
  String _filterStatus = 'All';

  List<Asset> get assets => _filteredAssets.isEmpty && _searchQuery.isEmpty && _filterStatus == 'All'
      ? _assets
      : _filteredAssets;

  List<Asset> get allAssets => _assets;

  List<Asset> get recentAssets => _assets.take(3).toList();

  // Add sample data
  AssetProvider() {
    _addSampleData();
  }

  void _addSampleData() {
    _assets.addAll([
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
        status: 'Available',
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
    ]);
    _filteredAssets = _assets;
    notifyListeners();
  }

  // Add new asset
  void addAsset(Asset asset) {
    _assets.insert(0, asset);
    _applyFilters();
    notifyListeners();
  }

  // Update asset
  void updateAsset(String id, Asset updatedAsset) {
    final index = _assets.indexWhere((asset) => asset.id == id);
    if (index != -1) {
      _assets[index] = updatedAsset;
      _applyFilters();
      notifyListeners();
    }
  }

  // Delete asset
  void deleteAsset(String id) {
    _assets.removeWhere((asset) => asset.id == id);
    _applyFilters();
    notifyListeners();
  }

  // Get asset by ID
  Asset? getAssetById(String id) {
    try {
      return _assets.firstWhere((asset) => asset.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get asset by asset ID (QR code)
  Asset? getAssetByAssetId(String assetId) {
    try {
      return _assets.firstWhere((asset) => asset.assetId == assetId);
    } catch (e) {
      return null;
    }
  }

  // Search assets
  void searchAssets(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
    notifyListeners();
  }

  // Filter by status
  void filterByStatus(String status) {
    _filterStatus = status;
    _applyFilters();
    notifyListeners();
  }

  // Apply filters and search
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

  // Get statistics
  int get totalAssets => _assets.length;

  int get activeAssets => _assets.where((a) => a.status == 'Active').length;

  int get maintenanceAssets => _assets.where((a) => a.status == 'Maintenance').length;

  // Clear search and filters
  void clearFilters() {
    _searchQuery = '';
    _filterStatus = 'All';
    _filteredAssets = _assets;
    notifyListeners();
  }
}
