import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'component/nav_footer.dart';
import 'asset_details.dart';
import 'providers/asset_provider.dart';
import 'models/asset.dart';

class AssetList extends StatefulWidget {
  const AssetList({super.key});

  @override
  State<AssetList> createState() => _AssetListState();
}

class _AssetListState extends State<AssetList> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final assetProvider = Provider.of<AssetProvider>(context);
    final assets = assetProvider.assets;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text("Asset List"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog(context, assetProvider);
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "All Assets",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "${assets.length} assets found",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                assetProvider.searchAssets(value);
              },
              decoration: InputDecoration(
                hintText: 'Search assets...',
                prefixIcon: Icon(Icons.search, color: Colors.blue),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                ),
              ),
            ),
          ),

          // Asset List
          Expanded(
            child: assets.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          "No assets found",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: assets.length,
                    itemBuilder: (context, index) {
                      return _buildAssetCard(context, assets[index]);
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: NavFooter(initialIndex: 1),
    );
  }

  void _showFilterDialog(BuildContext context, AssetProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Filter by Status"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFilterOption('All', provider),
            _buildFilterOption('Active', provider),
            _buildFilterOption('Inactive', provider),
            _buildFilterOption('In Use', provider),
            _buildFilterOption('Maintenance', provider),
            _buildFilterOption('Retired', provider),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              provider.clearFilters();
              _searchController.clear();
              Navigator.pop(context);
            },
            child: Text("Clear"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close"),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOption(String status, AssetProvider provider) {
    return ListTile(
      title: Text(status),
      leading: Radio<String>(
        value: status,
        groupValue: _selectedFilter,
        onChanged: (value) {
          setState(() {
            _selectedFilter = value!;
          });
          provider.filterByStatus(value!);
        },
      ),
      onTap: () {
        setState(() {
          _selectedFilter = status;
        });
        provider.filterByStatus(status);
      },
    );
  }

  Widget _buildAssetCard(BuildContext context, Asset asset) {
    final Map<String, IconData> categoryIcons = {
      'Electronics': Icons.devices,
      'Furniture': Icons.chair,
      'Equipment': Icons.build,
      'Vehicles': Icons.directions_car,
    };

    final Map<String, Color> categoryColors = {
      'Electronics': Colors.blue,
      'Furniture': Colors.orange,
      'Equipment': Colors.purple,
      'Vehicles': Colors.green,
    };

    final Map<String, Color> statusColors = {
      'Active': Colors.green,
      'Inactive': Colors.grey,
      'In Use': Colors.orange,
      'Maintenance': Colors.red,
      'Retired': Colors.brown,
    };

    final icon = categoryIcons[asset.category] ?? Icons.inventory_2;
    final iconColor = categoryColors[asset.category] ?? Colors.grey;
    final statusColor = statusColors[asset.status] ?? Colors.grey;

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AssetDetails(asset: asset),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Icon
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 28,
                ),
              ),
              SizedBox(width: 16),

              // Asset Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      asset.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'ID: ${asset.assetId}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: Colors.grey.shade600),
                        SizedBox(width: 4),
                        Text(
                          asset.location,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Status Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  asset.status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
